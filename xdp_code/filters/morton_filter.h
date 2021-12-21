#include <linux/bpf.h>
#include <sys/cdefs.h>

// TODO: find way to change these default values
#define BLOCKSIZE_BITS 512
static const __u32 NO_BLOCKS = 1;
static const __u32 BUCKETS_PER_BLOCK = 64; //logical buckets
static const __u32 OTA_BITS = 16;
static const __u32 FCA_BITS = 2; //as in python code
#define NO_FINGERPRINTS 46
static const __u32 FINGERPRINT_SIZE = 8;
static const __u32 FSA_ARRAY_END = 368; // fsa has this many bits
static const __u32 FCA_ARRAY_END = BUCKETS_PER_BLOCK*FCA_BITS; // fca has this many bits

struct Block {
    __u8 bitarray[BLOCKSIZE_BITS/8];
};

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