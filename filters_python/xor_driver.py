from pyxorfilter import Xor8, Xor16


output_file = "/home/anastasia/diplomatiki/xdp_code/filters/xor_output.txt"
if __name__=='__main__':
    st = "www.google.com"
    s = ""
    for part in st.split('.'):
        s = s + chr(len(part)) + part # construct string as it appears in dns packet
    input = ["10.11.1.2",s]
    filter = Xor8(3)
    filter.populate(input)
    print(filter.__filter)