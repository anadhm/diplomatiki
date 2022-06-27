#include <linux/bpf.h>
#include <sys/cdefs.h>

// TODO: find way to change these default values
#define BLOCKSIZE_BITS 512
#define NO_ITEMS 8303 // no if items in ntua_names
static const __u32 BUCKETS_PER_BLOCK = 32; //logical buckets
static const __u32 OTA_BITS = 16;
static const __u32 FCA_BITS = 2; //as in python code
#define NO_FINGERPRINTS 27
static const double LOAD_FACTOR = 0.95;
static const __u32 LOADF_ITEMS = NO_ITEMS/LOAD_FACTOR;
static const int expr = LOADF_ITEMS % NO_FINGERPRINTS;
// static const __u32 NO_BLOCKS = expr > 0 ? expr + 1: expr;
static const __u32 NO_BLOCKS = 324;
#define FINGERPRINT_SIZE 16
static const __u8 SLOTS = 3;
static const __u32 FSA_ARRAY_END = 432; // fsa has this many bits
static const __u32 FCA_ARRAY_END = BUCKETS_PER_BLOCK*FCA_BITS; // fca has this many bits

struct Block {
    __u16 bitarray[BLOCKSIZE_BITS/FINGERPRINT_SIZE];
};

// Due order of operation wrap 'k' in parentheses in case it
// is passed as an equation, e.g. i + 1, otherwise the first
// part evaluates to "A[i + (1/32)]" not "A[(i + 1)/32]"
#define SetBit(A,k)     ( A[(k)/16] |= (1 << (15 - (k)%16)) )
#define ClearBit(A,k)   ( A[(k)/16] &= ~(1 << (15 - (k)%16)) )
#define TestBit(A,k)    ( A[(k)/16] & (1 << (15 - (k)%16)) )