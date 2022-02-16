from morton import *
import time,os,sys,math

if __name__ == '__main__':
    names_file = "ntua_names"
    domain_form = chr(len("example")) + "example" + chr(3) + "com"
    input_l = []
    counter = 0
    with open(names_file,"r") as f:
        lines = f.readlines()
        for name_r in lines:
            name = name_r.rstrip()
            item = chr(len(name)) + name + domain_form
            input_l.append(item)
            counter = counter + 1
    # if we want 0.95 load factor, then we need x*0.95 = len(input)
    # -> x = len(input)/0.95 -> blocks = x//46 +1 
    x = len(input_l)/0.95
    filter = MortonFilter(math.ceil(x/46))
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
    item = input_l[0]
    filter.query(item,verbose=True)
    # write in file
    # size = "_512_3_8" # 512 bit block, 3 slots/bucket, 8 bit fingerprint
    # output_file = '../xdp_code/filters/morton'+size+ '/output.txt'
    # serialized = filter.serialize()
    # with open(output_file,'w') as f:
    #     f.write(serialized)
    # print('# of items added: ' + str(counter))