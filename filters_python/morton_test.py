from morton import *
import time,os,sys

if __name__ == '__main__':

    names_file = "/home/anastasia/diplomatiki/filters_python/ntua_names"
    domain_form = chr(len("example")) + "example" + chr(3) + "com"
    f_input = []
    counter = 0
    with open(names_file,"r") as f:
        lines = f.readlines()
        for name_r in lines:
            name = name_r.rstrip()
            item = chr(len(name)) + name + domain_form
            f_input.append((item,name))
            # if counter > 4000:
            #     break
            counter = counter + 1
    
    filter = MortonFilter(len(f_input)//46 + 1)
    for item,name in f_input:
        # print(repr(item))
        filter.insert(item)

    # foundAll = True
    # for item,_ in f_input:
    #     foundAll = foundAll & filter.query(item)
    
    # print(f"found all items inserted: {foundAll}")
    while True:
        name_r = input("insert domain to search:")
        name = name_r.rstrip()
        item = chr(len(name)) + name + domain_form
        print(f"querying for item: {repr(item)}, fp: {fingerprint(item)}")
        match = filter.query(item,verbose=True)
        print(f"item: {item}, found in filter: {match}")
        print("###########")
   
    # write in file
    output_file = '/home/anastasia/diplomatiki/xdp_code/filters/output.txt'
    serialized = filter.serialize()
    with open(output_file,'w') as f:
        f.write(serialized)
    # print("found all added items: ",foundAll)

    # item = chr(len("toise")) + "toise" + domain_form
    # filter.query(item,verbose = True)
    
    print('# of items added: ' + str(counter))