import mmh3
from bitstring import BitArray

# input_file = "/home/anastasia/diplomatiki/names/all_names"
# output_file = "/home/anastasia/diplomatiki/xdp_code/filters/all_names/bloom/output.txt"
bf_size = 28658448
#bf_size = 143520


def get_hashes(item):
    h1 = mmh3.hash(item,signed=False,seed=0)
    h2 = mmh3.hash(item,signed=False,seed=1)
    
    hash1 = h1
    hash2 = (h1 + h2) #& (2 ** 32 - 1) # make it 32-bit
    hash3 = (h1 + 2*h2) #& (2 ** 32 - 1)
    hash4 = (h1 + 3*h2) #& (2 ** 32 - 1)
    hash5 = (h1 + 4*h2) #& (2 ** 32 - 1)
    hash1 = hash1 % bf_size
    hash2 = hash2 % bf_size
    hash3 = hash3 % bf_size
    hash4 = hash4 % bf_size
    hash5 = hash5 % bf_size
    return hash1,hash2,hash3,hash4,hash5

class BloomFilter:
    def __init__(self,bf_size):
        self.bf = BitArray(bf_size)
        self.bf.set(0)
        return None
    
    def check(self,item):
        hashes = get_hashes(item)
        return self.bf[hashes[0]] or self.bf[hashes[1]] or self.bf[hashes[2]] or self.bf[hashes[3]] or self.bf[hashes[4]] 

    def insert(self,item):
        hashes = get_hashes(item)
        self.bf[hashes[0]] = 1
        self.bf[hashes[1]] = 1
        self.bf[hashes[2]] = 1
        self.bf[hashes[3]] = 1
        self.bf[hashes[4]] = 1
        return None
