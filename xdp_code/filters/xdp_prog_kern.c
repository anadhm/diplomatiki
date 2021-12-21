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
	.type        = BPF_MAP_TYPE_PERCPU_ARRAY,
	.key_size    = sizeof(__u32), 
	.value_size  = sizeof(struct Block),
	.max_entries = NO_BLOCKS,
};
// change to static const char[] from char[], so that string is not saved on the stack
#define bpf_print(fmt, ...)                    \
({                              \
           char ____fmt[] = fmt;                \
           bpf_trace_printk(____fmt, sizeof(____fmt),   \
                ##__VA_ARGS__);         \
})

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
		bpf_print("PASS in eth proto");
		return XDP_PASS;
	}

	/* get source IP address */
	struct iphdr *iph = data + sizeof(struct ethhdr);
	if (iph + 1 > data_end){
		//bpf_print("PASS in ip bounds");
		return XDP_PASS;
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
	// prints in be eg len=40=0x0028, will print 0x2800=10240
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
		return XDP_ABORTED;
	}
	
	struct Block * block;
	//char name[10]="10.11.1.1";
	
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
	// #pragma unroll
	// for (i=0;i<46;i=i+1){
	// 	if (name + i + 1 > data_end) {
	// 		bpf_print("drop in dns content bounds #2,i=%u",i);
	// 		return XDP_DROP;
	// 	} 
	// 	// bpf_print("name slice:%c,i=%u ",*(char*)(name + i),i);
	// 	if (*(char *)(name+i) == 0) break;
	// }
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
	__u8 fp = h1&0x000000ff;
	bpf_print("fp:%u",fp);
	/* block no */
	__u32 glbi1 = hash1;
	__u32 block1 = glbi1/BUCKETS_PER_BLOCK; //should be integer division
	// __u32 block1 = 0;
	

	// #pragma unroll
	// for (i = 0;i<BLOCKSIZE_BITS/8;i++){
	// 	// bpf_print("index:%u",i);
	// 	// bpf_print("cval:%u",b[i]);
	// 	// bpf_print(", svalue:%u",block->bitarray[i]);
	// }

	__u8 b[BLOCKSIZE_BITS/8]; //BLOCKSIZE_BITS/8
	// __builtin_memset(&b[0],0,sizeof(b));
	/* initialize */
	#pragma unroll
	for (i=0;i<BLOCKSIZE_BITS/8;i++){
		b[i] = 0;
	}
	// if (block1 > morton_filter.max_entries){
	// 	//bpf_print("abort in #block check");
	// 	return XDP_ABORTED;
	// }
	block=bpf_map_lookup_elem(&morton_filter,&block1);
	if (!block){
		//bpf_print("error in map lookup");
		return XDP_ABORTED; // key was not found
	}
	#pragma unroll
	for (__u8 i=0;i<(BLOCKSIZE_BITS/8);i++){
		// __builtin_memcpy(&b[i],&block->bitarray[i],sizeof(__u8));
		b[i] = block->bitarray[i];
		//bpf_print("item:%u",b[i]);
	}
	/* manipulate b as __u8 array of 512/8 = 64 elements
	 and do bit arithmetic to extract info about filter
	 (fsa,fca,ota)
	*/
	
	/* local bucket index */
	__u32 lbi1 = glbi1%BUCKETS_PER_BLOCK;
	unsigned short int ota_index = lbi1%OTA_BITS;
	unsigned short int ota_bit = TestBit(block->bitarray, FSA_ARRAY_END+FCA_ARRAY_END+ota_index);
	short unsigned int found = 0;

	/* search in block */
	__u16 cap = 0;
	__u8 bucket_capacities = 0;
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
			if ((index / 8) >= (BLOCKSIZE_BITS / 8)){
				return XDP_ABORTED;
			}
			__u8 item;
			item = block->bitarray[index/8];
			//__builtin_memcpy(&item,&b[index >> 3],sizeof(__u8));
			// item = 0;
			temp_cap = 0;
			__u8 mod = index%8;
			temp_cap =(unsigned int)((item >> (6 - mod)) & 0x03);
			// bpf_print("index:%u",index);
			// bpf_print("item:%u",item);
			// bpf_print("tcap:%u",temp_cap);
			
			bucket_capacities += temp_cap;	
					
		}
	}
	
	__u8 item;
	// item = 16;
	// boundary checks
	index = FSA_ARRAY_END + lbi1*FCA_BITS;
	if ((index/8) >= (BLOCKSIZE_BITS/8)){
		// bpf_print("abort in index check");
		return XDP_ABORTED;
	}
	item = block->bitarray[(index/8)];
	// bpf_print("problemi:%u",(FSA_ARRAY_END + lbi1*FCA_BITS)>>3);
	__u8 mod = (FSA_ARRAY_END + lbi1*FCA_BITS) % 8;
	// bpf_print("lbi1:%u,index:%u,mod:%u",lbi1,index/8,mod);
	cap = (unsigned int)((item >> (6 - mod)) & 0x03);
	//bucket_capacities = 0; // out of memory bounds according to verifier
	__u8 buc = 0;
	#pragma unroll
	for (buc = 0;buc<3;buc++){
		// buc <3, since we have 3 slots per bucket
		// boundary checks
		// bpf_print("bacps:%u,cap=%u",bucket_capacities,cap);
		if (bucket_capacities + buc >= NO_FINGERPRINTS){
				//bpf_print("abort in index check #2");
				return XDP_DROP;
			}
		if (buc < cap){
			index = bucket_capacities + buc;
			
			if ((index < (BLOCKSIZE_BITS/8)) && (index >= 0)){
				// verifier rejects program without print statement
				// see issue: https://www.spinics.net/lists/bpf/msg45069.html
				bpf_print("found index:%u",index);
				cand_fp = block->bitarray[index];
				// bpf_print("cand_fp:%u",cand_fp);
				}
			else return XDP_DROP;
			
			// bpf_print("cf:%u",cand_fp);
			if (cand_fp == fp){
				found = 1;
				break;
			}
		}
	}
	//bpf_print("found:%u, fp=%u",found,fp);
	if (found || !ota_bit){
		if (found) {
			//bpf_print("success");
			return XDP_PASS;
			} // item was found
	}
	else {
		__u16 in = 0;
		__u32 hash2 = hash1 + (integer_exp(-1, hash1&1))*offset(fp);
		__u32 glbi2 = hash2 % n;
		__u32 block2 = glbi2/BUCKETS_PER_BLOCK;
		if (block2 > morton_filter.max_entries){
			return XDP_ABORTED;
		}
		block = bpf_map_lookup_elem(&morton_filter,&block2);
		if (!block){
			return XDP_ABORTED; // key was not found
		}
		// for (int i=0;i<(BLOCKSIZE_BITS/8);i++){
		// 	b[i] = block->bitarray[i] ;
		// }
		__u32 lbi2 = glbi2%BUCKETS_PER_BLOCK;
		found = 0;
		__u16 temp_cap = 0;
		bucket_capacities = 0;
		cap = 0;
		#pragma unroll
		for (__u8 i=0;i<BUCKETS_PER_BLOCK;i++){
			if (i<lbi2) {/* fca bucket index in the block */
				in = FSA_ARRAY_END + i*FCA_BITS;
				/* add previous buckets' capacities */
				// index >> 3 == index / 8
				if (in/8 >= BLOCKSIZE_BITS/8) return XDP_ABORTED;
				__u8 item;
				item = block->bitarray[in/8];
				// __u8 item = 0;
				temp_cap = 0;
				__u8 mod = in % 8;
				temp_cap = (unsigned int)(item >> (6 - mod)) & 0x03;
				bucket_capacities += temp_cap;
			}
		}
		// boundary checks
		in = FSA_ARRAY_END + lbi2*FCA_BITS;
		if ((FSA_ARRAY_END + lbi2*FCA_BITS)/8 >= BLOCKSIZE_BITS/8){
			return XDP_ABORTED;
		}
		__u8 item;
		item = block->bitarray[(in/8)];
		// item = 0;
		__u8 mod = in % 8;
		cap = (item >> (6 - mod)) & 0x03;

		__u8 cand_fp = 0;
		__u8 buc = 0;
		//buc < 3 always
		#pragma unroll
		for (buc = 0;buc<3;buc++){
			// buc <3, since we have 3 slots per bucket
			// boundary checks
			// bpf_print("bacps:%u,cap=%u",bucket_capacities,cap);
			if (bucket_capacities + buc >= NO_FINGERPRINTS){
					//bpf_print("abort in index check #2");
					return XDP_DROP;
				}
			if (buc < cap){
				__u8 in = bucket_capacities + buc;
				
				if ((in < (BLOCKSIZE_BITS/8)) && (in >= 0)){
					// verifier rejects program without print statement
					// see issue: https://www.spinics.net/lists/bpf/msg45069.html
					bpf_print("found index:%u",in);
					cand_fp = block->bitarray[in];
					// ;;
					}
				else return XDP_DROP;
				
				// bpf_print("cf:%u",cand_fp);
				if (cand_fp == fp){
					found = 1;
					break;
				}
			}
		}
		if (found) {return XDP_PASS;}
	}
	bpf_print("failure");
	return XDP_DROP;
}
char _license[] SEC("license") = "GPL";
