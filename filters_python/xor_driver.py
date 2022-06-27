from pyxorfilter import Xor8, Xor16
import mmh3


output_file = "/home/anastasia/diplomatiki/xdp_code/filters/ntua_names/xor8/xor_output.txt"
if __name__=='__main__':
    names_file = "/home/anastasia/diplomatiki/names/ntua_names"
    domain_form = chr(len("example")) + "example" + chr(3) + "com"
    input_l = []
    with open(names_file,"r") as f:
        lines = f.readlines()
        for name_r in lines:
            name = name_r.rstrip()
            item = chr(len(name)) + name + domain_form
            input_l.append(item)
    

    # print(input_l[400])
    input_l = [mmh3.hash(x,signed=False) & ((1 << 24) - 1) for x in input_l]
    print(input_l[400])
    # input_l = list(range(1000000))
    filter = Xor8(len(input_l))
    print('length of input',len(input_l))

    filter.populate(input_l)

    # write in file
    # size = "_512_3_16" # 512 bit block, 3 slots/bucket, 16 bit fingerprint
    # output_file = '../xdp_code/filters/morton'+size+ '/output.txt'
    # serialized = filter.serialize()
    # with open(output_file,'w') as f:
    #     f.write(serialized)

    #print(filter.__filter)