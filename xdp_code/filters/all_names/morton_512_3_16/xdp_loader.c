/* SPDX-License-Identifier: GPL-2.0 */
#include <asm-generic/int-ll64.h>
static const char *__doc__ = "XDP loader\n"
	" - Allows selecting BPF section --progsec name to XDP-attach to --dev\n";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <getopt.h>

#include <sys/resource.h>
#include <limits.h>

#include <locale.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

#include <bpf/bpf.h>
#include <bpf/libbpf.h>

#include <net/if.h>
#include <linux/if_link.h> /* depend on kernel-headers installed */

#include "../../common/common_params.h"
#include "../../common/common_user_bpf_xdp.h"
#include "../../common/common_libbpf.h"
#include "common_kern_user.h"

#include "morton_filter.h"
static const char *default_filename = "xdp_prog_kern.o";
//static const char *filter_output = "output.txt"; // the file that has the filter

// Macros to manipulate bit arrays. It is assumed the encapsulating int has size of 8.
// Due order of operation wrap 'k' in parentheses in case it
// is passed as an equation, e.g. i + 1, otherwise the first
// part evaluates to "A[i + (1/32)]" not "A[(i + 1)/32]"
#define SetBit(A,k)     ( A[(k)/16] |= (1 << (15 - (k)%16)) )
#define ClearBit(A,k)   ( A[(k)/16] &= ~(1 << (15 - (k)%16)) )
#define TestBit(A,k)    ( A[(k)/16] & (1 << (15 - (k)%16)) )

static const struct option_wrapper long_options[] = {

	{{"help",        no_argument,		NULL, 'h' },
	 "Show help", false},

	{{"dev",         required_argument,	NULL, 'd' },
	 "Operate on device <ifname>", "<ifname>", true},

	{{"skb-mode",    no_argument,		NULL, 'S' },
	 "Install XDP program in SKB (AKA generic) mode"},

	{{"native-mode", no_argument,		NULL, 'N' },
	 "Install XDP program in native mode"},

	{{"auto-mode",   no_argument,		NULL, 'A' },
	 "Auto-detect SKB or native mode"},

	{{"force",       no_argument,		NULL, 'F' },
	 "Force install, replacing existing program on interface"},

	{{"unload",      no_argument,		NULL, 'U' },
	 "Unload XDP program instead of loading"},

	{{"quiet",       no_argument,		NULL, 'q' },
	 "Quiet mode (no output)"},

	{{"filename",    required_argument,	NULL,  1  },
	 "Load program from <file>", "<file>"},

	{{"progsec",    required_argument,	NULL,  2  },
	 "Load program in <section> of the ELF file", "<section>"},

	{{0, 0, NULL,  0 }, NULL, false}
};

#ifndef PATH_MAX
#define PATH_MAX	4096
#endif

const char *pin_basedir =  "/sys/fs/bpf";
//const char *map_name    =  "xdp_stats_map";
const char *filter_name =  "morton_filter";
const char *offsets_name = "offsets";
void strToBitArray(char *source,int srclen, __u16 *result,int rlen){
	/* Takes a string as input and retuns a bitarray in result.
	Result has more than one __u32 elements so be careful with that.
	Manipulate this bitarray using the macros {Set,Clear,Test}Bit at start. */
	int index = 0;
	for (index=0; index<srclen-1; index++){ //srclen - 1 because last char is \0
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
		}
		else{
			printf("error loading in bitarray\n");
			return;
		}
	}
	return;

}

/* Pinning maps under /sys/fs/bpf in subdir */
int pin_maps_in_bpf_object(struct bpf_object *bpf_obj, const char *subdir)
{
	char map_filename[PATH_MAX];
	char pin_dir[PATH_MAX];
	int err, len;

	len = snprintf(pin_dir, PATH_MAX, "%s/%s", pin_basedir, subdir);
	if (len < 0) {
		fprintf(stderr, "ERR: creating pin dirname\n");
		return EXIT_FAIL_OPTION;
	}

	len = snprintf(map_filename, PATH_MAX, "%s/%s/%s",
		       pin_basedir, subdir, filter_name);
	if (len < 0) {
		fprintf(stderr, "ERR: creating filter_name\n");
		return EXIT_FAIL_OPTION;
	}
	len = snprintf(map_filename, PATH_MAX, "%s/%s/%s",
		       pin_basedir, subdir, offsets_name);
	if (len < 0) {
		fprintf(stderr, "ERR: creating offsets_name\n");
		return EXIT_FAIL_OPTION;
	}

	/* Existing/previous XDP prog might not have cleaned up */
	if (access(map_filename, F_OK ) != -1 ) {
		if (verbose)
			printf(" - Unpinning (remove) prev maps in %s/\n",
			       pin_dir);

		/* Basically calls unlink(3) on map_filename */
		err = bpf_object__unpin_maps(bpf_obj, pin_dir);
		if (err) {
			fprintf(stderr, "ERR: UNpinning maps in %s\n", pin_dir);
			return EXIT_FAIL_BPF;
		}
	}
	if (verbose)
		printf(" - Pinning maps in %s/\n", pin_dir);

	/* This will pin all maps in our bpf_object */
	err = bpf_object__pin_maps(bpf_obj, pin_dir);
	if (err)
		return EXIT_FAIL_BPF;

	return 0;
}

int main(int argc, char **argv)
{
	struct bpf_object *bpf_obj;
	int err;

	struct config cfg = {
		.xdp_flags = XDP_FLAGS_UPDATE_IF_NOEXIST | XDP_FLAGS_DRV_MODE,
		.ifindex   = -1,
		.do_unload = false,
	};
	/* Set default BPF-ELF object file and BPF program name */
	strncpy(cfg.filename, default_filename, sizeof(cfg.filename));
	/* Cmdline options can change progsec */
	parse_cmdline_args(argc, argv, long_options, &cfg, __doc__);

	/* Required option */
	if (cfg.ifindex == -1) {
		fprintf(stderr, "ERR: required option --dev missing\n\n");
		usage(argv[0], __doc__, long_options, (argc == 1));
		return EXIT_FAIL_OPTION;
	}
	if (cfg.do_unload) {
		/* TODO: Miss unpin of maps on unload */
		return xdp_link_detach(cfg.ifindex, cfg.xdp_flags, 0);
	}
	// change limits
	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
		perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");
		return 1;
	}
	bpf_obj = load_bpf_and_xdp_attach(&cfg);
	if (!bpf_obj)
		return EXIT_FAIL_BPF;

	if (verbose) {
		printf("Success: Loaded BPF-object(%s) and used section(%s)\n",
		       cfg.filename, cfg.progsec);
		printf(" - XDP prog attached on device:%s(ifindex:%d)\n",
		       cfg.ifname, cfg.ifindex);
	}
	
	/* Use the --dev name as subdir for exporting/pinning maps */
	err = pin_maps_in_bpf_object(bpf_obj, cfg.ifname);
	if (err) {
		fprintf(stderr, "ERR: pinning maps\n");
		return err;
	}
	/* Get the filter map fd */
	struct bpf_map_info map_expect = {0};
	struct bpf_map_info info = {0};
	char pin_dir[PATH_MAX];
	int filter_map_fd;
	int len;
	int offsets_fd;
	
	len = snprintf(pin_dir, PATH_MAX, "%s/%s", pin_basedir, cfg.ifname);
	if (len < 0) {
		fprintf(stderr, "ERR: creating pin dirname\n");
		return EXIT_FAIL_OPTION;
	}
	filter_map_fd = open_bpf_map_file(pin_dir,filter_name,&info);
	if (filter_map_fd < 0) {
		return EXIT_FAIL_BPF;
	}
	/* Check map info */
	map_expect.key_size = sizeof(__u32);
	map_expect.value_size = sizeof(struct Block); // 512 bits
	map_expect.max_entries = NO_BLOCKS;

	err = check_map_fd_info(&info, &map_expect);
	if (err) {
		fprintf(stderr, "ERR: map via FD not compatible\n");
		return err;
	}
	if (verbose) {
		printf("\nCollecting stats from BPF map\n");
		printf(" - BPF map (bpf_map_type:%d) id:%d name:%s"
		       " key_size:%d value_size:%d max_entries:%d\n",
		       info.type, info.id, info.name,
		       info.key_size, info.value_size, info.max_entries
		       );
	}
	
	
	

	FILE *f;
	/* Open the file with the filter and load it in the map. */
	f = fopen("output.txt","r");
	
	int index =0; 
	int processed_chars = 0;
	uint no_block = 0;
	uint bitlen = BLOCKSIZE_BITS/FINGERPRINT_SIZE; // how many __u16 we need to fit 1 block in a u16 array
	__u32 c;
	__u32 result = 0;
	__u16 bitarray[bitlen]; // __u16 = 16 bits, whole bitarray = 1 block
	char char_array[BLOCKSIZE_BITS + 1]; // 1 char from file = 1 bit in filter, plus 1 character for EOL
	/* Read chars from file, and when we have read BLOCKSIZE no of chars
	load them as bitarray in bitarray. */
	struct Block block = {0};
	while((c = getc(f)) != EOF)
	{
		
		index = processed_chars % (BLOCKSIZE_BITS+1);
		processed_chars++;
		char_array[index] = (char)c;
		if (index==BLOCKSIZE_BITS){
			// convert the char_array in a bitarray, in order to load it in the filter
			strToBitArray(char_array,(BLOCKSIZE_BITS+1),bitarray,bitlen);
			for (int i=0;i<bitlen;i++){
				block.bitarray[i] = bitarray[i];
			}
			result = bpf_map_update_elem(filter_map_fd, &no_block, &block, BPF_ANY);
			if (result != 0) {
    			fprintf(stderr, "bpf_map_update_elem error %d %s \n", errno, strerror(errno));
    			return 1;
  			}
		no_block++;
		}
	}
	offsets_fd = open_bpf_map_file(pin_dir, offsets_name, &info);
	/* Check map info */
	map_expect.key_size = sizeof(__u32);
	map_expect.value_size = sizeof(__u32); // 512 bits
	map_expect.max_entries = 32;

	err = check_map_fd_info(&info, &map_expect);
	if (err) {
		fprintf(stderr, "ERR: map via FD not compatible\n");
		return err;
	}
	if (verbose) {
		printf("\nCollecting stats from BPF map\n");
		printf(" - BPF map (bpf_map_type:%d) id:%d name:%s"
		       " key_size:%d value_size:%d max_entries:%d\n",
		       info.type, info.id, info.name,
		       info.key_size, info.value_size, info.max_entries
		       );
	}

	if (offsets_fd < 0){
		return EXIT_FAIL_BPF;
	}
	__u32 offsets[] = {83, 149, 211, 277, 337, 397, 457, 521, 
          587, 653, 719, 787, 853, 919, 983, 1051, 1117, 1181, 1249, 1319, 1399, 
          1459, 
          1511, 1571, 1637, 1699, 1759, 1823, 1889, 1951, 2017, 1579};
	__u32 res;
	for (__u32 i=0;i<32;i++){
		/* Create the map with offsets that we need in kernel side */
		/* That many values can't fit in BPF stack space */
		__u32 value = offsets[i];
		res = bpf_map_update_elem(offsets_fd, &i, &value, BPF_ANY);
		if (res != 0) {
    			fprintf(stderr, "bpf_map_update_elem error %d %s \n", errno, strerror(errno));
    			return 1;
  			}
	}
    
	fclose(f);
	return EXIT_OK;
}
