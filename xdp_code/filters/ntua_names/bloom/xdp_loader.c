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

#include "../../../common/common_params.h"
#include "../../../common/common_user_bpf_xdp.h"
#include "../../../common/common_libbpf.h"
// #include "common_kern_user.h"

// #include "cuckoo_filter.h"
static const char *default_filename = "xdp_prog_kern.o";
//static const char *filter_output = "output.txt"; // the file that has the filter
static const int map_entries = 17940;

int convertBinaryToDecimal(int n);

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
const char *map_name    =  "xdp_stats_map";
const char *filter_name =  "bloom_filter";

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
		       pin_basedir, subdir, map_name);
	if (len < 0) {
		fprintf(stderr, "ERR: creating map_name\n");
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
	map_expect.value_size = sizeof(__u8); 
	map_expect.max_entries = map_entries;

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
	__u32 result = 0;
  	int i = 0;
	FILE *f;
	/* Open the file with the filter and load it in the map. */
	f = fopen("output.txt","r");
	if (f == NULL) {
		printf("Error opening output.txt");
		exit(1);
	}

	int c;
	int index;
	__u8 bf_value;
	int number = 0;
	int decimal = 0;
	int processed_chars = 0;
	char myString[9];
	int times = 0;
	// set the first element of the first map to the ip passed as a parameter
	while ((c = getc(f)) != EOF)
	{
		index = processed_chars % 8;
		processed_chars++;
		myString[index] = (char)c;
		if (index == 7) {
			myString[8] = '\0';
			number = atoi(myString);
			decimal = convertBinaryToDecimal(number);
			bf_value = (__u8)decimal;
			result = bpf_map_update_elem(filter_map_fd, &times, &bf_value, BPF_ANY);
			times++;
			if (result != 0) {
					fprintf(stderr, "bpf_map_update_elem error %d %s \n", errno, strerror(errno));
					return 1;
			}	
		}
	}

	fclose(f);
	return EXIT_OK;
}
int convertBinaryToDecimal(int n)
{
	int decimalNumber = 0, i = 0, remainder;
	while (n != 0)
	{
		remainder = n % 10;
		n /= 10;
		decimalNumber += remainder << i;
		++i;
	}
	return decimalNumber;
}