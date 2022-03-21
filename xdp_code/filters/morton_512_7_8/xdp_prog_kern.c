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
#include "morton_filter.h" /* defines helpers for filter */

#define BITARRAY_SIZE 64 // temporary placeholder for BLOCKSIZE_BITS/8
/* 
	morton_filter_map is constructed as follows:
	key = no of block
	value = block
	so key_size = u32
	value_size = size_of_block_in_bytes
	max_entries = no of blocks
 */
 // map_fd[0]
struct bpf_map_def SEC("maps") morton_filter = {
	.type        = BPF_MAP_TYPE_ARRAY,
	.key_size    = sizeof(__u32), 
	.value_size  = sizeof(struct Block),
	.max_entries = NO_BLOCKS,
};

struct bpf_map_def SEC("maps") offsets = {
	.type        = BPF_MAP_TYPE_ARRAY,
	.key_size    = sizeof(__u32), 
	.value_size  = sizeof(__u32),
	.max_entries = 32,
};
// change to static const char[] from char[], so that string is not saved on the stack
#define bpf_print(fmt, ...)                    \
({                              \
           char ____fmt[] = fmt;                \
           bpf_trace_printk(____fmt, sizeof(____fmt),   \
                ##__VA_ARGS__);         \
})
static __always_inline __u32 offset(__u8 f){
	// __u32 off_range = 16;
    // __u16 ft = (__u32)f;
    __u32 *off;
	__u32 mod = (__u32)f % 32 ;
	/* These are too many values to fit into BPF stack so we need to access them from a BPF map */
	off = bpf_map_lookup_elem(&offsets,&mod);
	if (!off) {
		return -1;
	}
	return *off;
    // static const __u16 offsets[33] = {83, 149, 211, 277, 337, 397, 457, 521, 
    //       587, 653, 719, 787, 853, 919, 983, 1051, 1117, 1181, 1249, 1319, 1399, 
    //       1459, 
    //       1511, 1571, 1637, 1699, 1759, 1823, 1889, 1951, 2017, 1579,'\0'};
    
    // __u16 offset = offsets[ft % 32];
	
}

SEC("xdp_morton_filter")
int xdp_morton_filter_func(struct xdp_md *ctx)
{
	/* Parse packet headers to check if it is a DNS question.
	Afterwards, compute the two hashes and lookup the name in query
	in Morton filter. */

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
	// if (iph->protocol != IPPROTO_ICMP){
	// 	return XDP_DROP;
	// }
	/* check for UDP packets */
	if (iph->protocol != IPPROTO_UDP){ // IPPROTO_UDP == 17
		bpf_print("drop in udp,proto=%u",iph->protocol);
		return XDP_DROP;
	}
	
	struct udphdr *udph = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
	if (udph + 1 > data_end){
		//bpf_print("drop in udp bounds");
		return XDP_DROP;
	}

	if (udph->dest != 13568){// 53(10) == 0x0035, be-> 0x3500 == 13658(10)
		//bpf_print("drop in udp port = %u",udph->dest);
		return XDP_DROP;
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
	
	struct Block * block;
	
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
		if (name + i + 1 > data_end) {
			//bpf_print("drop in dns content bounds #3");
			return XDP_DROP;
		}
		// char c = *(char *)(name+i);
		// bpf_print("name part:%c",c); //doesn't print?

		if (*(char *)(name+i) == 0) {
			//bpf_print("break,i=%u",i);
			break;
			}
		prev_prev_byte = prev_byte;
		prev_byte = byte;
		byte = *(char *)(name+i);
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
	
	/* Take 1st byte of hash as fingerprint instead of last
		to minimize false positives. */

	// bpf_print("primary hash:%u",h1);
	/* h1 = h1 >> (32 - fp_size)  -> verifier wouldn't allow this */
	h1 = (h1 >> 24);

	// bpf_print("primary hash after shift:%u",h1);
	__u8 fp = (__u8)h1;
	if (fp == 0) fp = (__u8)1; /* fp=0 is reserved for EMPTY fingerprints */
	bpf_print("fp:%u",fp);
	/* block no */
	__u32 glbi1 = hash1;
	
	__u32 block1 = glbi1/BUCKETS_PER_BLOCK; //should be integer division
	// __u32 block1 = 0;
	bpf_print("blk1:%u",block1);

	block=bpf_map_lookup_elem(&morton_filter,&block1);
	if (!block){
		bpf_print("error in map lookup");
		return XDP_DROP; // key was not found
	}
	
	/* manipulate b as __u8 array of 512/8 = 64 elements
	 and do bit arithmetic to extract info about filter
	 (fsa,fca,ota)
	*/
	
	/* local bucket index */
	__u16 lbi1 = glbi1%BUCKETS_PER_BLOCK;
	lbi1 &= 31;
	unsigned short int ota_index = lbi1%OTA_BITS;
	__u8 ota_bit = 0;
	__u16 long_ota_index = (FSA_ARRAY_END + FCA_ARRAY_END + ota_index-1)&BLOCKSIZE_BITS;
	if ((long_ota_index/8) < 64){
		ota_bit = Bool(TestBit(block->bitarray, long_ota_index&511));
	}
	bpf_print("ota_index: %u, ota_bit: %u",ota_index,ota_bit);
	short unsigned int found = 0;

	/* search in block */
	__u16 cap = 0;
	__u16 bucket_capacities = 0;
	__u16 index = 0;
	
	__u8 cand_fp=0;
	__u16 temp_cap = 0;
	#pragma unroll
	for (__u8 i=0;i<BUCKETS_PER_BLOCK;i++){
		if (i<lbi1){
			/* fca bucket index in the block */
			index = FSA_ARRAY_END + i*FCA_BITS;
			/* add previous buckets' capacities */
			// index >> 3 == index / 8
			if ((index / FINGERPRINT_SIZE) >= (BLOCKSIZE_BITS / FINGERPRINT_SIZE)){
				bpf_print("drop in fca 291");
				return XDP_DROP;
			}
			temp_cap = 0;
			#pragma unroll
			for (__u8 j=0;j<FCA_BITS;j++){
				if ((index + j)/FINGERPRINT_SIZE < BLOCKSIZE_BITS/FINGERPRINT_SIZE){
					__u8 bit = Bool(TestBit(block->bitarray, index + j));
					// __u8 bit = 0;
					temp_cap += (bit << (FCA_BITS - 1 - j));
					// switch (j) {
					// case 0: temp_cap += (bit << 2);
					// case 1:	temp_cap += (bit << 1);
					// case 2:	temp_cap += (bit << 0);
					// default: continue;
					// }
				}
			}
			
			// bpf_print("index:%u",index);
			// bpf_print("item:%u",item);
			// bpf_print("tcap:%u",temp_cap);
			
			bucket_capacities += temp_cap;	
		}
	}
	
	// boundary checks
	index = FSA_ARRAY_END + (lbi1*FCA_BITS);
	index &= 511;
	bpf_print("index: %u", index);
	if ((index/FINGERPRINT_SIZE) >= (BLOCKSIZE_BITS/FINGERPRINT_SIZE)){
		bpf_print("drop in index 313");
		return XDP_DROP;
	}
	#pragma unroll
	for (__u8 j=0;j<FCA_BITS;j++){
		__u8 temp = (index + j);
		temp &= 511;
		if (temp ){
			// necessary boundary check to stop verifier complaining
			__u8 bit = 0;
				// bit = Bool(TestBit(block->bitarray, temp));
				__u8 temp_eight = temp/8;
				temp_eight &= 63;
				// bpf_print("%u",temp_eight);
				if (temp_eight > 63){
					break;
				}
				bit = Bool( (block->bitarray[temp_eight] & (1 << (7-(temp%8)))));
				// __u8 bit = 0;
			cap += (bit << (FCA_BITS - 1 - j));
		}
	}
	__u8 buc = 0;
	// #pragma unroll
	for (buc = 0;buc<SLOTS;buc++){
		// buc <7, since we have 7 slots per bucket
		// boundary checks
		bpf_print("bcaps:%u,cap=%u",bucket_capacities,cap);
		if (bucket_capacities + buc > NO_FINGERPRINTS){
				// bpf_print("drop in index check 329");
				// bpf_print("bucket caps:%u, buc:%u, cap:%u",bucket_capacities,buc,cap);
				// bpf_print("mod:%u", mod);
				break;
			}
		index = 0;
		if (buc < cap){
			index = bucket_capacities + buc;
			
			if ((index < (BLOCKSIZE_BITS/FINGERPRINT_SIZE)) && (index >= 0)){
				// verifier rejects program without print statement
				// see issue: https://www.spinics.net/lists/bpf/msg45069.html
				bpf_print("found index:%u",index);
				// cand_fp = 0;
				cand_fp = block->bitarray[index];
				bpf_print("cand_fp:%u",cand_fp);
				}
			else {
				bpf_print("drop in search 343");
				return XDP_DROP;
			}
			bpf_print("cf:%u",cand_fp);
			if (cand_fp == fp){
				found = 1;
				break;
			}
		}
	}
	// bpf_print("found:%u",found);
	//bpf_print("found:%u, fp=%u",found,fp);
	if (found || !ota_bit){
		if (found) {
			//bpf_print("success!\n"); // verifier rejects this print??
			return XDP_PASS;
			} // item was found
		else {
			bpf_print("ota_bit not set, item not found in h1");
		}
	}
	else {
		__u16 in = 0;
		// __u32 hash2 = hash1 + (integer_exp(-1, hash1&1))*offset(fp);
		__u16 off = offset(fp);
		if (off < 0) {
			bpf_print("error loading offset\n");
			return XDP_DROP;
		}
		// int flag = 0;
		int int_off = (hash1 & 1) ? off : (-1)*off;
		int hash2 = (int)hash1 + int_off;
		if (hash2 > (int)n) {
			hash2 = hash2 - (int)n;
			// flag = 1;
		}
		else if (hash2 < 0) {
			hash2 = hash2 + (int)n;
			// flag = 2;
		}
		__u32 glbi2 = (__u32)hash2;
		__u32 block2 = glbi2/BUCKETS_PER_BLOCK;
		
		block = bpf_map_lookup_elem(&morton_filter,&block2);
		if (!block){
			bpf_print("drop 381");
			// bpf_print("flag:%d",flag);
			// bpf_print("off:%d",int_off);
			// bpf_print("hash1:%u",hash1);
			// bpf_print("hash2:%d",hash2);
			// bpf_print("glbi2 of item:%u",glbi2);
			// bpf_print("blk2:%u",block2);
			return XDP_DROP; // key was not found
		}
		__u16 lbi2 = (__u16)glbi2%BUCKETS_PER_BLOCK;
		lbi2 &= 31;
		found = 0;
		__u16 temp_cap = 0;
		bucket_capacities = 0;
		cap = 0;
		// #pragma unroll
		for (__u8 i=0;i<BUCKETS_PER_BLOCK;i++){
			if (i<lbi2) {/* fca bucket index in the block */
				in = FSA_ARRAY_END + i*FCA_BITS;
				/* add previous buckets' capacities */
				// index >> 3 == index / 8
				if (in/FINGERPRINT_SIZE >= BLOCKSIZE_BITS/FINGERPRINT_SIZE) {
					bpf_print("drop in fca 395");
					return XDP_DROP;
				}
				temp_cap = 0;
				#pragma unroll
				for (__u8 j=0;j<FCA_BITS;j++){
					if ((in + j)/FINGERPRINT_SIZE < BLOCKSIZE_BITS/FINGERPRINT_SIZE){
						__u8 bit = Bool(TestBit(block->bitarray, in + j));
						// __u8 bit = 0;
						temp_cap += (bit << (FCA_BITS - 1 - j));
						// switch (j) {
						// case 0: temp_cap += (bit << 2);
						// case 1:	temp_cap += (bit << 1);
						// case 2:	temp_cap += (bit << 0);
						// default: continue;
						// }
					}
				}
				bpf_print("temp_cap: %u",temp_cap);
				bucket_capacities += temp_cap;
			}
		}
		// boundary checks
		in = FSA_ARRAY_END + lbi2*FCA_BITS;
		if (in >= BLOCKSIZE_BITS){
			bpf_print("drop in bound check 410");
			return XDP_DROP;
		}
		// #pragma unroll
		for (__u8 j=0;j<FCA_BITS;j++){
			__u16 temp = (in + j) & 511;
			if (temp/8 < 64){
				// necessary boundary check to stop verifier complaining
				__u8 bit = 0;
					// bit = Bool(TestBit(block->bitarray, temp)); // 504 = 512 -8, 504/8 = 63 = max_value that gets verifier happy
				// __u8 bit = 0;
				cap += (bit << (FCA_BITS - 1 - j));
			}
		}
		__u8 cand_fp = 0;
		__u8 buc = 0;
		// #pragma unroll
		for (buc = 0;buc<SLOTS;buc++){
			// buc <7, since we have 7 slots per bucket
			// boundary checks
			bpf_print("bacps:%u,cap=%u",bucket_capacities,cap);
			if (bucket_capacities + buc > NO_FINGERPRINTS){
					bpf_print("drop in index check 427");
					break;
				}
			if (buc < cap){
				__u8 in = bucket_capacities + buc;
				
				if ((in < (BLOCKSIZE_BITS/FINGERPRINT_SIZE)) && (in >= 0)){
					// verifier rejects program without print statement
					// see issue: https://www.spinics.net/lists/bpf/msg45069.html
					bpf_print("found index:%u",in);
					// cand_fp = 0;
					cand_fp = block->bitarray[in];
					// ;;
					}
				else {
					bpf_print("drop in search 441");
					return XDP_DROP;
				}
				
				// bpf_print("cf:%u",cand_fp);
				if (cand_fp == fp){
					found = 1;
					break;
				}
			}
		}
		// if (cap || bucket_capacities) found = 0;
		if (found) {
			//bpf_print("success!\n");
			return XDP_PASS;
		}
		else {
			bpf_print("item not found in h2");
		}
	}
	bpf_print("failure\n");
	return XDP_DROP;
}
char _license[] SEC("license") = "GPL";
