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

// #include <linux/socket.h>

// #include "../headers/dns.h"
#include "dns.h"
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
	.value_size  = (BLOCKSIZE_BITS/8)*sizeof(__u8),
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
	if (iph->protocol != IPPROTO_ICMP){
		return XDP_DROP;
	}
	// check for udp packets
	// if (iph->protocol != IPPROTO_UDP){
	// 	return XDP_DROP;
	// }
	
	// struct udphdr *udph = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
	// if (udph + 1 > data_end){
	// 	return XDP_DROP;
	// }

	// if (udph->dest != DNS_SERVICE_PORT){//defined in dns.h, depends on packets sent by scapy
	// 	return XDP_DROP;
	// }

	// struct dnshdr *dnsh = data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr);
	// if (dnsh + 1 > data_end){
	// 	return XDP_DROP;
	// }
	//DNS Payload
	// char * name = data + sizeof(struct ethhdr) + sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct dnshdr) - 1;
	// // __u32 length = 0;
	// if (name + 1 > data_end){
	// 	return XDP_DROP;
	// }
	// __u32 i;
	// #pragma unroll
	// for (i=0;i<46;i = i+1){
	// 	if (item + i + 1 > data_end){
	// 		return XDP_DROP;
	// 	}
	// 	if (item[i]==0) break;
	// 	length++;
	// }
	char name[10]="10.11.1.2";
	
	/* we now have item and can calculate the hashes
	to test if it is in the map (according to morton_filter*/
	/* so we need to calculate hash1 and hash2, know how many blocks
	we have and get block1 (and possibly block2). These will be the keys in the map
	that communicates with userspace
	then calculate its position in the block and check ota_bit
	*/
	__u32 i = 0;
	__u32 byte = 0; // holds the last character in every iteration
	__u32 prev_byte = 0; // holds the previous from the last character in the iteration
	__u32 prev_prev_byte = 0; // holds the third character from the end
	__u32 upper_16 = 0; // upper digit of the hexadecimal number
	__u32 lower_16 = 0;  // lower digit of the hexadecimal number 
	__u32 multiplier = 1; // although mmh3 works in chunks of 4, multiplier helps make it in steps of 1
	
	// variables that will hold the hashes of the string
	__u32 h1 = 0;
	__u32 k = 0;
	#pragma unroll
	for (i = 0; i < 46; i = i + 1) {
		// if (name + i + 1 > data_end) {
		// 	return XDP_DROP;
		// }
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
	}
	h1 ^= i;
	h1 ^= (h1 >> 16);
	h1 *= 0x85ebca6b;
	h1 ^= (h1 >> 13);
	h1 *= 0xc2b2ae35;
	h1 ^= (h1 >> 16);

	__u32 n = NO_BLOCKS*BUCKETS_PER_BLOCK;
	
	__u32 hash1 = h1 % n;
	__u8 fp = hash1&0x000000ff;
	/* block no */
	__u32 glbi1 = hash1;
	__u32 block1 = glbi1/BUCKETS_PER_BLOCK; //should be integer division
	__u8 b[64]; //BLOCKSIZE_BITS/8
	__u8 *block;
	block=bpf_map_lookup_elem(&morton_filter,&block1);
	if (!block){
		return XDP_ABORTED; // key was not found
	}
	/* manipulate b as __u8 array of 512/8 = 64 elements
	 and do bit arithmetic to extract info about filter
	 (fsa,fca,ota)
	*/
	__builtin_memcpy(block,b,BLOCKSIZE_BITS/8);
	/* local bucket index */
	__u32 lbi1 = glbi1%BUCKETS_PER_BLOCK;
	unsigned short int ota_index = lbi1%OTA_BITS;
	unsigned short int ota_bit = TestBit(b, FSA_ARRAY_END+FCA_ARRAY_END+ota_index);
	int found = 0;

	/* search in block */
	__u32 bucket_capacities = 0;
	__u32 index;
	__u32 cap = 0;
	#pragma unroll
	for (i=0;i<=lbi1;i++){
		/* fca bucket index in the block */
		index = FSA_ARRAY_END + i*FCA_BITS;
		int first_item=0xa0; // 0b11000000
        int second_item=0x30; //0b00110000
        int third_item=0x0a; //0b00001100
        int fourth_item=0x03; //0b00000011
        /* add previous buckets' capacities */
        //boundary check
		// if (b + index/8 + 1 > data_end){
		// 	return XDP_DROP;
		// }
		__u8 item = b[index/8];
        __u8 temp_cap = 0;
        __u8 mask;
        switch (i%4){
            case 0:
                mask=first_item;
                break;
            case 1:
                mask=second_item;
                break;
            case 2:
                mask=third_item;
                break;
            case 3:
                mask=fourth_item;
                break;
            default:
                mask = 0;
                break;
        }
        temp_cap = item & mask;
        if (i==lbi1){
            cap += temp_cap;
        } else {
            bucket_capacities += temp_cap;
        }
	}
	index = bucket_capacities;
    __u8 cand_fp = 0;
	int buc = 0;
	while ((!found) && (buc != cap)){
		/* search in bucket's fingerprints */
        // boundary check
		// if (b+ index + buc + 1 > data_end){
		// 	return XDP_DROP;
		// }
		cand_fp=b[index+buc];
		if (cand_fp == fp){
			found = 1;
		} else { buc++; }
	}

	if (found || !ota_bit){
		if (found) return XDP_PASS; // item was found
	}
	else {
		__u32 hash2 = hash1 + (integer_exp(-1, hash1&1))*offset(fp);
		__u32 glbi2 = hash2 % n;
		__u32 block2 = glbi2/BUCKETS_PER_BLOCK;
		block = bpf_map_lookup_elem(&morton_filter,&block2);
		if (!block){
			return XDP_ABORTED; // key was not found
		}
		__builtin_memcpy(block, b, BLOCKSIZE_BITS/8);
		__u32 lbi2 = glbi2%BUCKETS_PER_BLOCK;
		found = 0;
		#pragma unroll
		for (i=0;i<=lbi2;i++){
			/* fca bucket index in the block */
			index = FSA_ARRAY_END + i*FCA_BITS;
			int first_item=0xa0; // 0b11000000
			int second_item=0x30; //0b00110000
			int third_item=0x0a; //0b00001100
			int fourth_item=0x03; //0b00000011
			/* add previous buckets' capacities */
			//boundary check
			// if (b + index/8 + 1 > data_end){
			// 	return XDP_DROP;
			// }
			__u8 item = b[index/8];
			__u8 temp_cap = 0;
			__u8 mask;
			switch (i%4){
				case 0:
					mask=first_item;
					break;
				case 1:
					mask=second_item;
					break;
				case 2:
					mask=third_item;
					break;
				case 3:
					mask=fourth_item;
					break;
				default:
					mask = 0;
					break;
			}
			temp_cap = item & mask;
			if (i==lbi2){
				cap += temp_cap;
			} else {
				bucket_capacities += temp_cap;
			}
		}
		index = bucket_capacities;
		__u8 cand_fp = 0;
		int buc = 0;
		while ((!found) && (buc != cap)){
			/* search in bucket's fingerprints */
			// boundary check
			// if (b+ index + buc + 1 > data_end){
			// 	return XDP_DROP;
			// }
			cand_fp=b[index+buc];
			if (cand_fp == fp){
				found = 1;
			} else { buc++; }
		}
		if (found){
			return XDP_PASS;
		}
	}
	return XDP_DROP;
}
char _license[] SEC("license") = "GPL";
