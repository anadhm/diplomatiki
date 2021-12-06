/* SPDX-License-Identifier: GPL-2.0 */
#include <arpa/inet.h>
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <bpf/bpf_endian.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <stdio.h>
#include <stdbool.h>
#include <sys/cdefs.h>
#include <stdio.h>

// #include <linux/socket.h>

#include "../headers/dns.h"
#include "morton_filter.h" /* defines helpers for filter */
#include "common_kern_user.h" /* defines: struct datarec; */

/* 
	morton_filter_map is constructed as follows:
	key = no of block
	value = block
	so key_size = u32
	value_size = size_of_block_in_bits
	max_entries = no of blocks
 */
 // map_fd[0]
struct bpf_map_def SEC("maps") morton_filter = {
	.type        = BPF_MAP_TYPE_ARRAY,
	.key_size    = sizeof(__u32), 
	.value_size  = (BLOCKSIZE_BITS/32)*sizeof(__u32),
	.max_entries = NO_BLOCKS,
};
/* LLVM maps __sync_fetch_and_add() as a built-in function to the BPF atomic add
 * instruction (that is BPF_STX | BPF_XADD | BPF_W for word sizes)
 */
// #ifndef lock_xadd
// #define lock_xadd(ptr, val)	((void) __sync_fetch_and_add(ptr, val))
// #endif

SEC("xdp_morton_filter")
int xdp_morton_filter_func(struct xdp_md *ctx)
{
	/* Parse packet headers to check if it is a DNS question.
	Afterwards, compute the two hashes and lookup the name in query
	in Morton filter. */

	// placeholder for when real packets come in
	void *data_end = (void *)(long)ctx->data_end;
	void *data = (void *)(long)ctx->data;
	struct ethhdr *eth = data;

	// check packet size
	if (eth + 1 > data_end){
		return XDP_DROP;
	}

	// check if packet is ipv6
	if (bpf_ntohs(eth->h_proto) != ETH_P_IP){
		return XDP_DROP;
	}

	// get source IP address
	struct iphdr *iph = data + sizeof(struct ethhdr);
	if (iph + 1 > data_end){
		return XDP_DROP;
	}
	// check for ping packets
	if (iph->protocol != IPPROTO_ICMP){ //1 for icmp, may need bpf_ntoh
		return XDP_DROP;
	}
	//__be32 address = iph->saddr;
	// char *item = {0};
	//inet_ntop(AF_INET,&address,item,sizeof(item)); //can't link external functions
	// if (item==NULL){
	// 	return XDP_DROP;
	// }
	char item[10]="10.11.1.2"; 
	
	/* we now have item and can calculate the hashes
	to test if it is in the map (according to morton_filter*/
	/* so we need to calculate hash1 and hash2, know how many blocks
	we have and get block1 (and possibly block2). These will be the keys in the map
	that communicates with userspace
	then calculate its position in the block and check ota_bit
	*/
	__u8 fp = fingerprint(item);
	// block no
	__u32 glbi1 = h1(item);
	__u32 block1 = glbi1/BUCKETS_PER_BLOCK; //should be integer division
	__u32 *b;
	b=bpf_map_lookup_elem(&morton_filter,&block1);
	if (!b){
		return XDP_ABORTED; // key was not found
	}
	/* manipulate b as __u32 array of 512/32 = 16 elements
	 and do bit arithmetic to extract info about filter
	 (fsa,fca,ota)
	*/

	// local bucket index
	__u32 lbi1 = glbi1%BUCKETS_PER_BLOCK;
	unsigned short int ota_index = lbi1%OTA_BITS;
	unsigned short int ota_bit = TestBit(b, FSA_ARRAY_END+FCA_ARRAY_END+ota_index);

	if (read_and_cmp(b, lbi1, fp) || !ota_bit){
		return XDP_PASS; // item was found
	}
	else {
		__u32 glbi2 = h2(item);
		__u32 block2 = glbi2/BUCKETS_PER_BLOCK;
		b = bpf_map_lookup_elem(&morton_filter,&block2);
		if (!b){
			return XDP_ABORTED; // key was not found
		}
		__u32 lbi2 = glbi2%BUCKETS_PER_BLOCK;
		if (read_and_cmp(b, lbi2, fp)){
			return XDP_PASS;
		}
	}
	return XDP_DROP;
}
char _license[] SEC("license") = "GPL";
