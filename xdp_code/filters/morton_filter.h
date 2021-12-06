#include <linux/bpf.h>
#include <sys/cdefs.h>

// TODO: find way to change these default values
static const int BLOCKSIZE_BITS = 512;
static const __u32 NO_BLOCKS = 44;
static const __u32 BUCKETS_PER_BLOCK = 64; //logical buckets
static const __u32 OTA_BITS = 15;
static const __u32 FCA_BITS = 2; //as in python code
static const __u32 NO_FINGERPRINTS = 46;
static const __u32 FINGERPRINT_SIZE = 8;
static const __u32 FSA_ARRAY_END = 368; // fsa has this many bits
static const __u32 FCA_ARRAY_END = BUCKETS_PER_BLOCK*FCA_BITS; // fca has this many bits



// Due order of operation wrap 'k' in parentheses in case it
// is passed as an equation, e.g. i + 1, otherwise the first
// part evaluates to "A[i + (1/32)]" not "A[(i + 1)/32]"
#define SetBit(A,k)     ( A[(k)/32] |= (1 << ((k)%32)) )
#define ClearBit(A,k)   ( A[(k)/32] &= ~(1 << ((k)%32)) )
#define TestBit(A,k)    ( A[(k)/32] & (1 << ((k)%32)) )

static __always_inline __u32 integer_exp(__u32 a, __u32 b){
	/* a is the base, b is the exponent */
	__u32 result = 1;
    if (a==0){
        return 0;
    }
	while (b != 0){
		result *= a;
		b--;
	}
	return result;
}
static __always_inline __u32 murmurhash(char * data){
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
    for (i = 0; i < 46; i = i + 1) {
        if (data[i] == 0) break;
        prev_prev_byte = prev_byte;
        prev_byte = byte;
        byte = data[i];
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
    return h1;
}
static __always_inline __u32 map(__u32 item,__u32 n){
	/* Maps item to [0,n-1] */
	return item % n;
}
static __always_inline __u8 fingerprint(char * data){
	//TODO: fingerprint size other than 8 bits?
	return (__u8)(murmurhash(data)&0x000000ff);
}
static __always_inline __u32 offset(__u8 f){
	int off_range = 16;
	return (BUCKETS_PER_BLOCK + (f % off_range) )| 1;
}

static __always_inline __u32 h1(char * data){
	/* Calculates MurmurHash of item and maps it to [0,n-1] */
	__u32 hash = murmurhash(data);
	__u32 h = map(hash,NO_BLOCKS*BUCKETS_PER_BLOCK);
	return h;
}
static __always_inline __u32 h2(char * data){
	__u8 fp = fingerprint(data);
	__u32 first_hash = h1(data);
	__u32 n = NO_BLOCKS*BUCKETS_PER_BLOCK;
	__u32 second_hash = first_hash + (integer_exp(-1,first_hash&1))*offset(fp);
	return map(second_hash,n);
}
static __always_inline int read_and_cmp(__u32 *block,__u32 lbi,__u8 fp){
    __u32 bucket_capacities = 0;
	int i,index;
	__u32 cap = 0;
	#pragma unroll
	for (i=0;i<=lbi;i++){
		// fca bucket index in the block
		index = FSA_ARRAY_END + i*FCA_BITS;
		#pragma unroll
		// add previous buckets' capacities, bit by bit
		for (int j=0;j<FCA_BITS;j++){
			unsigned short int bit = TestBit(block,index+j); // 0 or 1
			if (i==lbi){
				cap += integer_exp(bit,((index+j)%FCA_BITS));
			} else {
				bucket_capacities += integer_exp(bit,((index+j)%FCA_BITS)); // {0,1}^(position of bit)
			}
		}
	}
	// we now have previous buckets capacities and current bucket capacity
	// so we can calculate bucket's index in fsa
	index = bucket_capacities*FINGERPRINT_SIZE;
	int found = 0;
	__u8 cand_fp = 0;
	int buc = 0;
	while (!found || buc != cap){
		// search in bucket's fingerprints
		#pragma unroll
		for (i=0;i<FINGERPRINT_SIZE;i++){
            // construct candidate fp bit by bit
			cand_fp |= (TestBit(block, index + buc*FINGERPRINT_SIZE + i) << i);
		}
		if (cand_fp == fp){
			found = 1;
		} else { buc++; }
	}
	
    
    return found;
}