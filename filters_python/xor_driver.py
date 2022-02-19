from pyxorfilter import Xor8, Xor16


output_file = "/home/anastasia/diplomatiki/xdp_code/filters/xor_output.txt"
if __name__=='__main__':
    names_file = "/home/anastasia/diplomatiki/filters_python/ntua_names"
    domain_form = chr(len("example")) + "example" + chr(3) + "com"
    input_l = []
    with open(names_file,"r") as f:
        lines = f.readlines()
        for name_r in lines:
            name = name_r.rstrip()
            item = chr(len(name)) + name + domain_form
            input_l.append(item)
    

    filter = Xor8(len(input_l))
    filter.populate(input_l)

    # write in file
    # size = "_512_3_16" # 512 bit block, 3 slots/bucket, 16 bit fingerprint
    # output_file = '../xdp_code/filters/morton'+size+ '/output.txt'
    # serialized = filter.serialize()
    # with open(output_file,'w') as f:
    #     f.write(serialized)

    print(filter.__filter)