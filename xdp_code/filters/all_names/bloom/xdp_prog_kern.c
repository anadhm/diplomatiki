/* SPDX-License-Identifier: GPL-2.0 */
#include <arpa/inet.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <bpf/bpf_endian.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <stdio.h>
#include <linux/udp.h>
#include <netinet/in.h>
#include <stdbool.h>
#include <sys/cdefs.h>
#include <stdio.h>

#include "dns.h"

static const int no_bits = 28658448;
static const int map_entries = 3582306;
struct bpf_map_def SEC("maps") bloom_filter = {
	.type        = BPF_MAP_TYPE_ARRAY,
	.key_size    = sizeof(__u32), 
	.value_size  = sizeof(__u8),
	.max_entries = map_entries,
};
// change to static const char[] from char[], so that string is not saved on the stack
#define bpf_print(fmt, ...)                    \
({                              \
           char ____fmt[] = fmt;                \
           bpf_trace_printk(____fmt, sizeof(____fmt),   \
                ##__VA_ARGS__);         \
})


SEC("xdp_bloom_filter")
int xdp_bloom_filter_func(struct xdp_md *ctx)
{
	/* Parse packet headers to check if it is a DNS question.
	Afterwards, compute the necessary hashes and 
	look if name is in Bloom Filter */

	void *data_end = (void *)(long)ctx->data_end;
	void *data = (void *)(long)ctx->data;
	struct ethhdr *eth = data;

	/* check packet size */
	if (eth + 1 > data_end){
		//bpf_print("drop in eth bounds");
		return XDP_DROP;
	}

	/* check if packet is ipv4 */
	if (bpf_ntohs(eth->h_proto) != ETH_P_IP){
		bpf_print("not eth proto, proto:%u",bpf_ntohs(eth->h_proto));
		return XDP_PASS;
	}

	/* get source IP address */
	struct iphdr *iph = data + sizeof(struct ethhdr);
	if (iph + 1 > data_end){
		//bpf_print("drop in ip bounds");
		return XDP_DROP;
	}
	/* check for UDP packets */
	if (iph->protocol != IPPROTO_UDP){ // IPPROTO_UDP == 17
		bpf_print("drop in udp,proto=%u",iph->protocol);
		return XDP_PASS;
	}
	
	struct udphdr *udph = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
	if (udph + 1 > data_end){
		//bpf_print("drop in udp bounds");
		return XDP_DROP;
	}

	if (udph->dest != 13568){// 53(10) == 0x0035, be-> 0x3500 == 13658(10)
		//bpf_print("drop in udp port = %u",udph->dest);
		return XDP_PASS;
	}
	// prints in big endian eg len=40=0x0028, will print 0x2800=10240
	// bpf_print("source:%u",udph->source);
	// bpf_print("dest:%u",udph->dest);
	// bpf_print("len:%u",udph->len);
	// bpf_print("check:%u", udph->check);

	struct dnshdr *dnsh = data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr);
	if (dnsh + 1 > data_end){
		//bpf_print("drop in dns bounds");
		return XDP_DROP;
	}
	// bpf_print("tid:%u",dnsh->tid);
	// bpf_print("flags:%u",dnsh->flags);
	// bpf_print("nqueries:%u",dnsh->nqueries);
	
	/* DNS Payload */
	char * name = data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct dnshdr);
	if (name + 1 > data_end){
		//bpf_print("abort in dns content bounds");
		return XDP_DROP;
	}
	
	/* we now have item and can calculate the hashes
	to test if it is in the map */

	__u32 i = 0;
	__u32 byte = 0; // holds the last character in every iteration
	__u32 prev_byte = 0; // holds the previous from the last character in the iteration
	__u32 prev_prev_byte = 0; // holds the third character from the end
	__u32 upper_16 = 0; // upper digit of the hexadecimal number
	__u32 lower_16 = 0;  // lower digit of the hexadecimal number 
	__u32 multiplier = 1; // although mmh3 works in chunks of 4, multiplier helps make it in steps of 1
	
	// variables that will hold the hashes of the string
	__u32 h1 = 0;
	__u32 h2 = 1;
	__u32 k = 0;

#pragma unroll
for (i = 0; i < 60; i = i + 1) {
	if (name + i + 1 > data_end) {
		return XDP_PASS;
	}
	if (name[i] == 0) break;
	prev_prev_byte = prev_byte;
	prev_byte = byte;
	byte = name[i];
	upper_16 = byte / 16;
	lower_16 = byte % 16;
	k += lower_16 * multiplier;
	multiplier *= 16;
	k += upper_16 * multiplier;
	multiplier *= 16;
	// mmh3 works in chunks of 4
	if (i % 4 == 3) { 
		k *= 0xcc9e2d51;
		k = (k << 15) | (k >> 17);
		k *= 0x1b873593;
		h1 ^= k;
		h1 = (h1 << 13) | (h1 >> 19);
		h1 = h1 * 5 + 0xe6546b64;
		
		h2 ^= k;
		h2 = (h2 << 13) | (h2 >> 19);
		h2 = h2 * 5 + 0xe6546b64;
		
		multiplier = 1;
		k = 0;
	}
}

  	// Deal with the remaining characters
  k = 0;
  __u32 remains = i % 4;
  __u8 tail0 = 0;
  __u8 tail1 = 0;
  __u8 tail2 = 0;

  if (remains == 1) {
	  tail0 = byte;
  } else if (remains == 2) {
	  tail1 = byte;
	  tail0 = prev_byte;
  } else if (remains == 3) {
	  tail2 = byte;
	  tail1 = prev_byte;
	  tail0 = prev_prev_byte;
  }

  if (remains == 3) {
	  k ^= (tail2 << 16);
	  remains = remains - 1;
  }
  if (remains == 2) {
	  k ^= (tail1 << 8);
	  remains = remains - 1;
  }
  if (remains == 1) {
	  k ^= tail0;
	  k *=0xcc9e2d51;
	  k = (k << 15) | (k >> 17);
	  k *= 0x1b873593;
	  h1 ^= k;
	  h2 ^= k;
  }

  h1 ^= i;
  h2 ^= i;

  h1 ^= (h1 >> 16);
  h2 ^= (h2 >> 16);

  h1 *= 0x85ebca6b;
  h2 *= 0x85ebca6b;

  h1 ^= (h1 >> 13);
  h2 ^= (h2 >> 13);

  h1 *= 0xc2b2ae35;
  h2 *= 0xc2b2ae35;

  h1 ^= (h1 >> 16);
  h2 ^= (h2 >> 16);

  __u32 hash1 = h1;
  hash1 = hash1 % no_bits;
  __u32 index1 = hash1 / 8;
  __u32 mod1 = (hash1 % 8) + 1;
  __u8 *byte1 = bpf_map_lookup_elem(&bloom_filter, &index1);
  if (!byte1) return XDP_PASS;
  __u8 char1 = *byte1;
  char1 >>= (8 - mod1);
  char1 &= 0x01;
  if (char1 == 0) return XDP_DROP;

  __u64 hash2 = (__u64)h1 + (__u64)h2;
  hash2 = hash2 % no_bits;
  __u32 index2 = hash2 / 8;
  __u32 mod2 = (hash2 % 8) + 1;
  __u8 *byte2 = bpf_map_lookup_elem(&bloom_filter, &index2);
  if (!byte2) return XDP_PASS;
  __u8 char2 = *byte2;
  char2 >>= (8 - mod2);
  char2 &= 0x01;
  if (char2 == 0) return XDP_DROP;

  __u64 hash3 = (__u64)h1 + 2 * (__u64)h2;
  hash3 = hash3 % no_bits;
  __u32 index3 = hash3 / 8;
  __u32 mod3 = (hash3 % 8) + 1;
  __u8 *byte3 = bpf_map_lookup_elem(&bloom_filter, &index3);
  if (!byte3) return XDP_PASS;
  __u8 char3 = *byte3;
  char3 >>= (8 - mod3);
  char3 &= 0x01;
  if (char3 == 0) return XDP_DROP;

  __u64 hash4 = (__u64)h1 + 3 * (__u64)h2;
  hash4 = hash4 % no_bits;
  __u32 index4 = hash4 / 8;
  __u32 mod4 = (hash4 % 8) + 1;
  __u8 *byte4 = bpf_map_lookup_elem(&bloom_filter, &index4);
  if (!byte4) return XDP_PASS;
  __u8 char4 = *byte4;
  char4 >>= (8 - mod4);
  char4 &= 0x01;
  if (char4 == 0) return XDP_DROP;

  __u64 hash5 = (__u64)h1 + 4 * (__u64)h2;
  hash5 = hash5 % no_bits;
  __u32 index5 = hash5 / 8;
  __u32 mod5 = (hash5 % 8) + 1;
  __u8 *byte5 = bpf_map_lookup_elem(&bloom_filter, &index5);
  if (!byte5) return XDP_PASS;
  __u8 char5 = *byte5;
  char5 >>= (8 - mod5);
  char5 &= 0x01;
  if (char5 == 0) return XDP_DROP;

  return XDP_PASS;
}
char _license[] SEC("license") = "GPL";
