#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include "morton_filter.h"
#include <string.h>

// #define SetBit(A,k)     ( A[(k)/8] |= (1 << ((k)%8)) )
// #define ClearBit(A,k)   ( A[(k)/8] &= ~(1 << ((k)%8)) )
// #define TestBit(A,k)    ( A[(k)/8] & (1 << ((k)%8)) )

void strToBitArray(char *source,int srclen, __u8 *result,int rlen){
	/* Takes a string as input and retuns a bitarray in result.
	Result has more than one __u32 elements so be careful with that.
	Manipulate this bitarray using the macros {Set,Clear,Test}Bit at start. */
	int index = 0;
	for (index=0; index<srclen; index++){ //srclen - 1 because last char is \0
		//printf("index=%i\n",index);
		if (source[index] == '0'){
			ClearBit(result, index); //macro takes care of wrapping
		}
		else if (source[index] == '1'){
			SetBit(result, index);	//macro takes care of wrapping
		}
		else if (source[index] == '\n'){
			// printf("reached end of block\n");
			continue;
		} else if (source[index] == '\0'){
            printf("end of file");
        }
		else{
			printf("error loading in bitarray\n");
			return;
		}
	}
	return;

}
int main(){
    int found = 0;
    int i;
    FILE *f;
	/* Open the file with the filter and load it in the map. */
	f = fopen("output.txt","r");
	
	int index1 =0; 
    int processed_chars = 0;
	uint no_block = 0;
	uint bitlen = BLOCKSIZE_BITS/8; // how many __u32 we need to fit 1 block in a u32 array
	__u32 c;
	__u32 result = 0;
	__u8 bitarray[bitlen]; // __u8 = 8 bits, whole bitarray = 1 block
	char char_array[BLOCKSIZE_BITS + 1]; // 1 char from file = 1 bit in filter, plus 1 character for EOL
	/* Read chars from file, and when we have read BLOCKSIZE no of chars
	load them as bitarray in bitarray. */
	while((c = getc(f)) != EOF)
	{
		index1 = processed_chars % (BLOCKSIZE_BITS+1);
		processed_chars++;
		char_array[index1] = (char)c;
		if (index1==BLOCKSIZE_BITS){
			// convert the char_array in a bitarray, in order to load it in the filter
			strToBitArray(char_array,(BLOCKSIZE_BITS+1),bitarray,bitlen);
            // for (int i=0;i<bitlen;i++){
            //     printf(" %u ",bitarray[i]);
            // }
			// printf("\n");
		no_block++;
		}
	}
    /* Try to search for something */
    char * name = "10.11.1.2";
    __u32 len = strlen(name);
    __u8 fp = fingerprint(name, len);
    __u32 lbi1 = h1(name, len); // ==glbi1 if we have 1 block
    __u32 block1 = 0;
    
    //printf("len = %u, fp = %u, lbi1 = %u\n",len,fp,lbi1);
    /* search in block */
	__u32 bucket_capacities = 0;
	__u32 index;
	__u32 cap = 0;
    printf("lbi1= %u\n",lbi1);
    printf("map[55] = %u\n",bitarray[55]);
	#pragma unroll
	for (i=0;i<lbi1;i++){
		/* fca bucket index in the block */
		index = FSA_ARRAY_END + i*FCA_BITS;
        /* add previous buckets' capacities */
		__u8 item = bitarray[index/8];
        printf("index = %u\n",index);
        __u8 temp_cap = 0;
        __u8 mask;
        __u8 mod = i%8;
        temp_cap = (item >> (6 - mod)) & 0x03;
        printf("temp_cap = %u, item = %u\n",temp_cap,item);
		bucket_capacities += temp_cap;
        
	}
	index = FSA_ARRAY_END + lbi1*FCA_BITS;
	__u8 item = bitarray[index/8];
	__u8 mod = index % 8;
	cap = (unsigned int)((item >> (6 - mod)) & 0x03);
	index = bucket_capacities;
    __u8 cand_fp = 0;
	int buc = 0;
	while ((!found) && (buc != cap)){
		/* search in bucket's fingerprints */
		cand_fp=bitarray[index+buc];
		if (cand_fp == fp){
			found = 1;
		} else { buc++; }
	}
	printf("Size of array (sizeof):%lu\n",sizeof(bitarray));
    printf("previous buckets: %u, current bucket: %u.\n",bucket_capacities,cap);
    if (found) printf("found!\n");
    return found;
}