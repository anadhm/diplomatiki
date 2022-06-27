import sys,os,time,random
sys.path.insert(0,"./cuckoo_filter")
from cuckoo_filter import *
from morton import *
from bloom import *


check_tp_times = False
check_tn_times = False
check_fp_rate = True

names_file = "../names/all_names"
names = []
with open(names_file,"r") as f:
    for line in f.readlines():
        item = ""
        tokens = line.rstrip().split(".")
        for token in tokens:
            item = item + chr(len(token)) + token
        names.append(item)



# Bloom5_DH
bf_size = 28658448
bf = BloomFilter(bf_size)

# Cuckoo15
cf_attr = {
    "buckets":2**24, # 2^19
    "entries":4,
    "error_rate":0.0003,
    "max_kicks":500
}
cf = Cuckoo(
    buckets=cf_attr["buckets"],
    entries=cf_attr["entries"],
    error_rate=cf_attr["error_rate"],
    max_kicks=cf_attr["max_kicks"]
)
 # Morton_3_8
mf_attr = {
    "block_size":512,
    "fingerprint_size":8,
    "ota_bits":16,
    "no_buckets":64,
    "no_slots":3,
    "no_fingerprints":46
}
x = len(names)/0.95
mf8 = MortonFilter(
    math.ceil(x/mf_attr["no_fingerprints"]),
    block_size=mf_attr["block_size"],
    fingerprint_size=mf_attr["fingerprint_size"],
    no_buckets=mf_attr["no_buckets"],
    ota_bits=mf_attr["ota_bits"],
    no_fingerprints=mf_attr["no_fingerprints"])
# 512_3_16
mf_attr = {
    "block_size":512,
    "fingerprint_size":16,
    "ota_bits":16,
    "no_buckets":32,
    "no_slots":3,
    "no_fingerprints":27
}

mf16 = MortonFilter(
    math.ceil(x/mf_attr["no_fingerprints"]),
    block_size=mf_attr["block_size"],
    fingerprint_size=mf_attr["fingerprint_size"],
    no_buckets=mf_attr["no_buckets"],
    ota_bits=mf_attr["ota_bits"],
    no_fingerprints=mf_attr["no_fingerprints"])

filters_1 = [(bf,"Bloom"),(cf,"Cuckoo")]
filters_2 = [(mf8,"Morton8"),(mf16,"Morton16")]
times = []

negative_counts = [0,0,0,0]
# Construction of filters
for f,f_n in filters_1:
    start = time.time()
    for name in names:
        f.insert(name)
    end = time.time()
    print(f"{f_n} filter constructed in {end-start} seconds.")

for f,f_n in filters_2:
    start = time.time()
    for name in names:
        f.insert(name)
    end = time.time()
    print(f"{f_n} filter constructed in {end-start} seconds.")

# tp_times_bf = [] # millisec
# tp_times_cf = []
# tn_times_bf = []
# tn_times_cf = []
# for name in names:
#     start = int(round(time.time() * 1000))
#     bf.check(name)
#     end = int(round(time.time() * 1000))
#     t = end - start
#     tp_times_bf.append(t)

#     start = int(round(time.time() * 1000))
#     cf.check(name)
#     end = int(round(time.time() * 1000))
#     t = end - start
#     tp_times_cf.append(t)

# avg_tp_bf = sum(tp_times_bf) / len(tp_times_bf)
# avg_tp_cf = sum(tp_times_cf) / len(tp_times_cf)
# print(f"average true positive check time in bf:{avg_tp_bf}")
# print(f"average true positive check time in cf:{avg_tp_cf}")

# tn_times_bf = [] # millisec
# tn_times_cf = []
# tn_times_bf = []
# tn_times_cf = []
neg_names = []
for i in range(2000000):
    # check if a random number is in filter (should not be)
    neg_names.append(str(random.randint(0,10000000)))
found_bf = 0
found_cf = 0
for name in neg_names:
    # start = int(round(time.time() * 1000))
    f = bf.check(name)
    # end = int(round(time.time() * 1000))
    # t = end - start
    # tn_times_bf.append(t)
    if f:
        found_bf +=1
    # start = int(round(time.time() * 1000))
    f = cf.check(name)
    # end = int(round(time.time() * 1000))
    # t = end - start
    # tn_times_cf.append(t)
    if f:
        found_cf += 1

# avg_tn_bf = sum(tn_times_bf) / len(tn_times_bf)
# avg_tn_cf = sum(tn_times_cf) / len(tn_times_cf)
# print(f"average true negative check in bf:{avg_tn_bf}, found:{found_bf}")
# print(f"average true negative check in cf:{avg_tn_cf}, found:{found_cf}")

# tp_times_mf8 = [] # millisec
# tp_times_mf16 = []
# tn_times_mf8 = []
# tn_times_mf16 = []
# for name in names:
#     # start = int(round(time.time() * 1000))
#     mf8.check(name)
#     # end = int(round(time.time() * 1000))
#     # t = end - start
#     # tp_times_mf8.append(t)
#     # start = int(round(time.time() * 1000))
#     mf16.check(name)
#     # end = int(round(time.time() * 1000))
#     # t = end - start
#     # tp_times_mf16.append(t)
    
# avg_tp_mf8 = sum(tp_times_mf8) / len(tp_times_mf8)
# avg_tp_mf16 = sum(tp_times_mf16) / len(tp_times_mf16)
# print(f"average true positive check in mf8:{avg_tp_mf8}")
# print(f"average true positive check in mf16:{avg_tp_mf16}")

# tp_times_mf8 = [] # millisec
# tp_times_mf16 = []
# tn_times_mf8 = []
# tn_times_mf16 = []
found_mf8 = 0
found_mf16 = 0

found = False
for name in names:
    # start = int(round(time.time() * 1000))
    found = mf8.check(name)
    # end = int(round(time.time() * 1000))
    # t = end - start
    # tp_times_mf8.append(t)
    if found:
        found_mf8 += 1
    # start = int(round(time.time() * 1000))
    found = mf16.check(name)
    # end = int(round(time.time() * 1000))
    # t = end - start
    # tp_times_mf16.append(t)
    if found:
        found_mf16 += 1

print("False positive rates:")
all_neg = len(neg_names)
print(f"Bloom: {found_bf/all_neg}, Cuckoo: {found_cf/all_neg}")
print(f"Morton8: {found_mf8/all_neg}, Morton16: {found_mf16/all_neg}")
# avg_tp_mf8 = sum(tp_times_mf8) / len(tp_times_mf8)
# avg_tp_mf16 = sum(tp_times_mf16) / len(tp_times_mf16)
# print(f"average true negative check in mf8:{avg_tp_mf8}")
# print(f"average true negative check in mf16:{avg_tp_mf16}")