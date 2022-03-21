from morton import *
import time,os,sys,math

if __name__ == '__main__':
    names_file = "ntua_names"
    domain_form = chr(len("example")) + "example" + chr(3) + "com"
    input_l = []
    counter = 0
    with open("/home/anastasia/diplomatiki/filters_python/"+names_file,"r") as f:
        lines = f.readlines()
        for name_r in lines:
            name = name_r.rstrip()
            item = chr(len(name)) + name + domain_form
            input_l.append(item)
            counter = counter + 1
    # if we want 0.95 load factor, then we need x*0.95 = len(input)
    # -> x = len(input)/0.95 -> blocks = x//46 +1 
    x = len(input_l)/0.95

    # 512_7_8
    filter_attr = {
        "block_size":512,
        "fingerprint_size":8,
        "ota_bits":17,
        "no_buckets":21,
        "no_slots":7,
        "no_fingerprints":54
    }

    filter = MortonFilter(
        math.ceil(x/filter_attr["no_fingerprints"]),
        block_size=filter_attr["block_size"],
        fingerprint_size=filter_attr["fingerprint_size"],
        no_buckets=filter_attr["no_buckets"],
        ota_bits=filter_attr["ota_bits"],
        no_slots=filter_attr["no_slots"],
        no_fingerprints=filter_attr["no_fingerprints"])
    for item in input_l:
        filter.insert(item)
    #     print(f"{item} inserted in filter")
    #     found = filter.query(item)
    #     if found:
    #         print(f"{item} found in filter right after insertion")
    # foundAll = True
    # for item in input_l:
    #     if (not filter.query(item)):
    #         foundAll = False
    #         print(f"query failed for item: {item}")

    # item = chr(len("mercator")) + "mercator" + domain_form
    # filter.query(item,verbose=True)
    

    # item = chr(len("gramateia")) + "gramateia" + domain_form
    # filter.query(item,verbose=True)
    
    # write in file
    size = "_512_7_8" # 512 bit block, 7 slots/bucket, 8 bit fingerprint
    output_file = '../xdp_code/filters/morton'+size+ '/output.txt'
    serialized = filter.serialize()
    with open(output_file,'w') as f:
        f.write(serialized)
    # print('# of items added: ' + str(counter))