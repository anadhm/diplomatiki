from morton import *
import time,os,sys,math

if __name__ == '__main__':
    ntua_file = "../names/ntua_names"
    all_file = "/home/anastasia/diplomatiki/names/all_names"
    # domain_form = chr(len("example")) + "example" + chr(3) + "com"
    input_l = []
    # opt = "ntua"
    opt = "all"
    counter = 0
    if opt == "ntua":
        with open(ntua_file,"r") as f:
            lines = f.readlines()
            for name_r in lines:
                name = name_r.rstrip()
                item = chr(len(name)) + name + domain_form
                input_l.append(item)
                counter = counter + 1
    # if we want 0.95 load factor, then we need x*0.95 = len(input)
    # -> x = len(input)/0.95 -> blocks = x//46 +1 
    if opt == "all":
        # print("all")
        # se_names = "../names/se_names"
        # with open(se_names) as f:
        #     lines = f.readlines()
        #     for line in lines:
        #         tokens = line.rstrip().split(".")
        #         item = ""
        #         for token in tokens:
        #             item = item + chr(len(token)) + token
        #         # print(item)
        #         input_l.append(item)
        
        # nu_names = "../names/nu_names"
        # with open(nu_names) as f:
        #     lines = f.readlines()
        #     for line in lines:
        #         tokens = line.rstrip().split(".")
        #         item = ""
        #         for token in tokens:
        #             item = item + chr(len(token)) + token
        #         # print(item)
        #         input_l.append(item)
        with open(all_file) as f:
            lines = f.readlines()
            for line in lines:
                tokens = line.rstrip().split(".")
                item = ""
                for token in tokens:
                    item = item + chr(len(token)) + token
                # print(item)
                input_l.append(item)
          

    x = len(input_l)/0.95

    # 512_3_16
    filter_attr = {
        "block_size":512,
        "fingerprint_size":16,
        "ota_bits":16,
        "no_buckets":32,
        "no_slots":3,
        "no_fingerprints":27
    }


    fil = MortonFilter(
        no_blocks=math.ceil(x/filter_attr["no_fingerprints"]),
        block_size=filter_attr["block_size"],
        fingerprint_size=filter_attr["fingerprint_size"],
        no_buckets=filter_attr["no_buckets"],
        ota_bits=filter_attr["ota_bits"],
        no_fingerprints=filter_attr["no_fingerprints"])
    for item in input_l:
        fil.insert(item)
    #     print(f"{item} inserted in filter")
    #     found = filter.query(item)
    #     if found:
    #         print(f"{item} found in filter right after insertion")
    # foundAll = True
    # for item in input_l:
    #     if (not fil.query(item)):
    #         foundAll = False
    #         print(f"query failed for item: {item}")

    # addr = "gramateia"
    # item = chr(len(addr)) + addr + domain_form
    # filter.query(item,verbose=True)
    
    # write in file
    size = "_512_3_16" # 512 bit block, 3 slots/bucket, 16 bit fingerprint
    output_file = '../xdp_code/filters/'+opt+ \
    '_names/morton' \
    +size+ '/output.txt'
    serialized = fil.serialize()
    with open(output_file,'w') as f:
        f.write(serialized)
    # print('# of items added: ' + str(counter))