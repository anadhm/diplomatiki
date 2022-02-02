from morton import *
import time,os,sys

if __name__ == '__main__':
    # # dummy input
    # input = ['item'+str(i) for i in range(2000)]
    # filter = MortonFilter(len(input)//46 + 1)
    # for item in input:
    #     filter.insert(item)

    # test 1: ping from 10.11.1.2
    # test 2: dns query for www.google.com
    # dns payload format
    # s = chr(3) + "www" + chr(6) + "google" + chr(3) + "com"
    # input = ["10.11.1.2",s]
    
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
    filter = MortonFilter(len(input_l)//46 + 1)
    for item in input_l:
        filter.insert(item)
    #     print(f"{item} inserted in filter")
    #     found = filter.query(item)
    #     if found:
    #         print(f"{item} found in filter right after insertion")
    
    # write in file
    output_file = '../xdp_code/filters/output.txt'
    serialized = filter.serialize()
    with open(output_file,'w') as f:
        f.write(serialized)
    print('# of items added: ' + str(counter))