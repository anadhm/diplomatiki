import os,sys,time
import mmh3
from bitstring import BitArray, BitStream
import math,random

# TODO: see if we can have a variable number of (logical) buckets per block later
no_buckets = 64
HASH_SIZE = 32

def fingerprint(item, fp_size=8):
        # create bitmask according to fp_size
        bitmask = BitArray(HASH_SIZE)
        bitmask.set(True,range(HASH_SIZE - 1,HASH_SIZE - fp_size - 1, -1))
        
        # use mmh3 hash and truncate it to fp_size bits to get the fingerprint
        fp = mmh3.hash(item, signed=False) & bitmask.uint # default hash returns 32-bit
        return fill_bits(fp,fp_size) # pad with leading zeros if necessary        

def fill_bits(item,no_bits):
    """Takes as input: 
    item := the number that in binary format may have leading zeros
    no_bits := how many bits we want in binary format.
    Returns: a string representing the item with the appropriate leading zeros.
    """
    # we add +2 to no_bits to accommodate for characters '0b'
    return format(item,'#0'+str(no_bits+2)+'b')

class MortonFilter:
    # Block size is dictated by the physical block size of the
    # storage medium for which the MF is optimized. 
    # eg 512-bit block for 512-bit cache line
    # TODO: figure out how to partition the block according to block size
    # i.e. how many buckets and of what size
    # TODO: support more filter configurations than the default: 3-slot buckets with 8 bit fingerprints
    # TODO: add checks for valid sizes in block creation
    class Block:
        def __init__(self,no,block_size=512,fingerprint_size=8,overflow_bits=15,no_buckets=64,no_slots=3,no_fingerprints=46):
            self.ota = BitArray(overflow_bits) # initialize Overflow Tracking Array - OTA
            self.fca_bits = math.ceil(math.log2(no_slots))
            self.fca = BitArray(no_buckets*self.fca_bits) # initialize Fullness Counter Array - FCA
            # initialize Fingerprint Storage Array - FSA
            self.fsa = BitArray(no_fingerprints*fingerprint_size)
            self.fp_size = fingerprint_size
            self.no_slots = no_slots
            # no is used to get glbi from blk and lbi
            self.no = no
            self.no_fingerprints = no_fingerprints

        def serialize(self):
            s = BitArray()
            s.append(self.fsa)
            s.append(self.fca)
            s.append(self.ota)
            return s

        def index_OTA(self,lbi):
            # there are 3 different methods to map fp to ota bit in the notes, we choose the simplest one

            return lbi % (self.ota.len)

        def set_OTA(self,lbi):
            index = self.index_OTA(lbi)
            self.ota.set(True,index)
            return

        def get_OTA(self,lbi):
            index = self.index_OTA(lbi)
            return self.ota[index]
        
        def has_capacity(self):
            """Checks if the block has spare capacity in its FSA."""
            # fingerprint 0 is for empty slots
            # if block has space, last fingerprint is 0
            return (self.fsa[-self.fp_size::].uint == 0)

        def bucket_capacity(self,lbi):
            """Returns the lbi bucket capacity in current block."""
            bits = self.fca_bits
            return self.fca[lbi*bits:(lbi+1)*bits].uint


        def table_simple_store(self,bucket,fp): ## insert will succeed cause we checked it beforehand
            offset = 0
            bits = self.fca_bits
            bucket_cap = self.bucket_capacity(bucket)
            # calculate the bucket offset
            for i in range(bucket):
                cap = self.bucket_capacity(i)
                offset += cap
            # shift by one slot (equal to self.fp_size) the elements in the fsa
            self.fsa[(offset + bucket_cap)*self.fp_size::] >>= self.fp_size
            # store the fingerprint
            self.fsa.overwrite(BitArray(fp),(offset + bucket_cap)*self.fp_size)
            # increment the fca counter
            
            self.fca.overwrite(BitArray(fill_bits(bucket_cap+1,bits)),bucket*bits)
            return

        def read_and_cmp(self,lbi,fp):
            """Reads a block at the bucket lbi and returns true if fp is in the block."""
            offset = 0
            match = False
            bits = self.fca_bits
            bucket_cap = self.bucket_capacity(lbi)
            for i in range(lbi):
                # fca is a bitarray
                # we need to count 2 bits for each bucket
                # hence this weird for loop
                cap = self.fca[i*bits:(i+1)*bits].uint
                offset += cap
            for i in range(bucket_cap):
                index = offset+i
                # some pointer arithmetic to get the item from bitarray
                item = self.fsa[index*self.fp_size:(index+1)*self.fp_size]
                # for now fp is in binary string form, and item is a BitArray
                # we can directly compare them
                if (item==fp):
                    match = True
                    break
            return match
            


        def printFCA(self,reverse=False): # use reverse option when printing in bigendian format
            if (reverse):
                temp = BitArray(self.fca)
                temp.reverse()
                print(temp.bin)
            else:
                print(self.fca.bin)
            return
        def printFSA(self,reverse=False):
            if (reverse):
                temp = BitArray(self.fsa)
                temp.reverse()
                print(temp.bin)
            else:
                print(self.fsa.bin)
            return
        def printOTA(self,reverse=False):
            if (reverse):
                temp = BitArray(self.ota)
                temp.reverse()
                print(temp.bin)
            else:
                print(self.ota.bin)
            return
        def print_whole_block(self,reverse=False):
            s = self.serialize()
            if (reverse):
                temp = BitArray(s)
                temp.reverse()
                print(temp.bin)
            else:
                print(s.bin)
            return
            
    def __init__(self,no_blocks,block_size=512,fingerprint_size=8):
        self.no_blocks = no_blocks
        self.block_size = block_size
        self.fingerprint_size = fingerprint_size
        self.Blocks = [] # filter is a list of Blocks
        #initialize the blocks
        for i in range(no_blocks):
            blk = self.Block(i,block_size=512) # go with default numbers for now
            self.Blocks.append(blk)
   
   
    # functions from the paper,Even-odd partial key cuckoo hashing segment

    def map(self,x,n):
        """ Maps a value x between 0 and n-1 inclusive. """
        # this is naive implementation
        # there is a faster one (Lemire mod)
        return  x % n
    def offset(self,fx):
        # off_range should be a power of two so that modulo can be done with a bitwise and
        off_range = 16
        # fx is the output of fingerprint() function, so we have to convert it to int
        integer_fp = 0
        if (isinstance(fx, str)):
            integer_fp = int(fx,2)
        elif (isinstance(fx,BitArray)):
            integer_fp = fx.uint
        else:
            integer_fp = fx
        
        return (no_buckets + integer_fp % off_range) | 1
    
    def h1(self,item):
        """ Returns the number of (primary) bucket that the item hashes to. """
        return self.map(mmh3.hash(item,signed=False),no_buckets * self.no_blocks)
    def h2(self,item):
        """ Returns the number of (secondary) bucket that the item hashes to. """
        fp = fingerprint(item)
        first_hash = self.h1(item)
        n = self.no_blocks * no_buckets
        second_hash = first_hash + ((-1)**(first_hash & 1))*self.offset(fp)
        return self.map(second_hash,n)
    
    def h_prime(self,bucket_index,fp):
        """ Calculates the alternate bucket for fp. Eg give bucket_index=h1 and return h2 and vice versa. """
        n = self.no_blocks * no_buckets
        temp = bucket_index + ((-1)**(bucket_index & 1))*self.offset(fp)
        return self.map(temp,n)
    
    def insert(self,item):
        fp = fingerprint(item)

        # global bucket index
        glbi1 = self.h1(item)
        block1 = self.Blocks[glbi1//no_buckets]
        # local (in the block) bucket index -> 0 <= lbi <= no_buckets
        lbi1 = glbi1 % no_buckets

        ## check for block or bucket overflow
        ## TODO: find a way to be able to change bits per bucket and slots per bucket
        # in the FCA, for now use default 2 (as each bucket has 3 slots)
        bits = block1.fca_bits
        bit_index_in_fca = lbi1*bits
        # bucket overflow: bucket lbi1 is full
        if (block1.fca[bit_index_in_fca:bit_index_in_fca+bits].uint == block1.no_slots or \
            # block overflow: fsa is(?) full --> check if the last element is 0
            (not block1.has_capacity())):
                ## this is where we check h2(item)
                block1.set_OTA(lbi1)
                glbi2 = self.h2(item)
                block2 = self.Blocks[glbi2//no_buckets]
                lbi2 = glbi2 % no_buckets

                bit_index_in_fca = lbi2*bits
                if (block2.fca[bit_index_in_fca:bit_index_in_fca+bits].uint == block2.no_slots or \
                    (not block2.has_capacity())): # conflict resolution -- cuckoo hashing
                     self.res_conflict(block1,block2,lbi1,lbi2,fp)
                else: # insert will be a success in this branch 
                    block2.table_simple_store(lbi2, fp)
        else: # we put item at 'h1'
            block1.table_simple_store(lbi1,fp)
        
        
    def check_candidate_bucket(self,glbi,fp):
        """Returns true if candidate bucket is available."""
        alternate_bucket = self.h_prime(glbi,fp)
        alt_blk = self.Blocks[alternate_bucket//no_buckets]
        alt_lbi = alternate_bucket % no_buckets
        bits = alt_blk.fca_bits
        alt_cap = alt_blk.fca[alt_lbi*bits:(alt_lbi+1)*bits].uint
        bucket_of = (alt_cap == alt_blk.no_slots) # true if there is of
        block_of = not alt_blk.has_capacity() # true if there is of
        return ((not bucket_of) and (not block_of))

    def remove_and_replace(self,old_blk, gbucket_index1, gbucket_index2, old_fp, new_fp,simple=True, same_bucket=True):
        """Places old_fp at its alternate bucket(and block), sets the OTA in the old_blk and puts new_fps in its place."""
        success = False
        # gbucket_index1 is the bucket that the old_fp maps to
        # gbucket_index2 is the bucket that the new_fp maps to
        # if the evicted is from the same bucket, these indices are the same
        # if they are different, we delete the old_fp from gbucket_index1
        # and insert the new_fp to gbucket_index2
        lbi = gbucket_index1 % no_buckets
        old_blk.set_OTA(lbi) # set the OTA bit
        # put old_fp to its alternate bucket
        alt_bucket = self.h_prime(gbucket_index1,old_fp)
        alt_blk = self.Blocks[alt_bucket//no_buckets]
        alt_lbi = alt_bucket % no_buckets
        if (simple):
            # if the alt bucket or block does not have space, we need to not copy over
            # the old_fp, but instead use it in the calling function in the while loop
            alt_blk.table_simple_store(alt_lbi,old_fp)
        # normally we'd use the code for the delete function
        # TODO: implement delete function (maybe)
        # for now we copy code from Block.read_and_cmp to find the old_fp in the old_blk and overwrite it with new_fp
        offset = 0
        bits = old_blk.fca_bits
        fp_size = old_blk.fp_size
        bucket_cap = old_blk.bucket_capacity(lbi)
        for i in range(lbi):
            cap = old_blk.bucket_capacity(i)
            offset += cap
        for i in range(bucket_cap): # find the index of the old_fp
            index = offset + i
            item = old_blk.fsa[index*fp_size:(index+1)*fp_size]
            if (item==old_fp):
                success = True
                if (same_bucket):
                    # if the two fingerprints are in the same bucket we simply overwrite old with the new
                    old_blk.fsa.overwrite(BitArray(new_fp),index*fp_size)
                else: # if it is not in the same bucket, we need gbucket_index2 
                    # first we need to delete old_fp from block
                    # we have the index, so we just shift to the left by fp_size
                    old_blk.fsa[(index)*old_blk.fp_size::] <<= old_blk.fp_size
                    # we also need to decrement old_fp bucket capacity
                    old_blk.fca.overwrite(BitArray(fill_bits(bucket_cap-1,bits)),lbi*bits)
                    # then we add the new_fp to its respective bucket
                    lbi2 = gbucket_index2 % no_buckets
                    old_blk.table_simple_store(lbi2,new_fp)
                break
        return success
    
    def res_conflict(self,blk1,blk2,lbi1,lbi2,fp):
        max_count = 100 # max times we can try evicting a fingerprint
        count = 0 # current count
        evicted = False
        bits = blk1.fca_bits
        while(count<max_count and not evicted):
            bit_index_in_fca = lbi1*bits
            cap1 = blk1.bucket_capacity(lbi1)
            candidates = []
            if (cap1 == blk1.no_slots):
                # we have a bucket overflow
                # candidate bucket to evict is from the specific bucket
                offset_fp = 0 # offset (in # of fingerprints) in the blk1.fsa
                glbi1 = blk1.no*no_buckets + lbi1
                for i in range(lbi1): # count how many fingerprints the buckets before have stored
                    cap = blk1.bucket_capacity(i)
                    offset_fp += cap
                # offset = offset_fp*fp_size # offset (in bits) in the blk1.fsa
                for i in range(cap1):
                    candidates.append(blk1.fsa[(offset_fp+i)*blk1.fp_size:(offset_fp+i+1)*blk1.fp_size]) # append the candidate fingerprint
                # check if a fingerprint can go to its alternate bucket
                for c in candidates:
                    if (self.check_candidate_bucket(glbi1,c)):
                        evicted = True
                        self.remove_and_replace(blk1,glbi1,c,fp)
                    break
                if (not(evicted)): 
                    # all candidate buckets were full, pick a candidate at random
                    # moreover, we need to run the while loop again because the old_fp will need to
                    # evict another fingerprint to go into its alternate bucket
                    # so the old_fp becomes new_fp and the "another fingerprint" becomes the old_fp
                    c = BitArray(random.choice(candidates))
                    self.remove_and_replace(blk1,glbi1,glbi1,c,fp,simple=False) 
                    # this does not copy the old_fp to its secondary bucket
                    # we keep it to  run the while loop again
                    fp = c # new_fp = old_fp
                    glbi2 = self.h_prime(glbi1,fp) # this is the alternate (global) bucket
                    lbi1 = glbi2 % no_buckets # this is the alternate (local) bucket
                    blk1 = self.Blocks[glbi2//no_buckets] # this is the alternate block
            else: 
                # we have a block overflow (and not a bucket overflow)
                # candidate bucket to evict is from the specific block
                glbi2 = blk1.no*no_buckets + lbi1 # the bucket the fp maps to 
                # (not necessarily the one from which we evict a fingerprint)
                pointer = 0 # a pointer to traverse the fsa
                for bucket in range(no_buckets): 
                # we need to have both fingerprints and their buckets to get their alternate bucket
                # so we check each bucket
                    cap = blk1.bucket_capacity(bucket)
                    for i in range(cap): # add the fingerprints (if cap !=0) to candidates[]
                        index = pointer + i # it's the fp index (not bit index)
                        # if (index!=blk1.no_fingerprints): # if we are not at the end of fsa
                        fp = blk1.fsa[(index)*blk1.fp_size:(index + 1)*blk1.fp_size] # fp is a BitArray
                        candidates.append((bucket,fp))
                    if (pointer + cap < blk1.no_fingerprints):
                        pointer += cap # proceed to next bucket
                # we should have blk1.no_fingerprints in candidates[]
                # check if a fingerprint can go to its alternate bucket
                if (len(candidates) != blk1.no_fingerprints):
                    print("error in loading eviction candidates from block")
                for b,old_fp in candidates:
                    glbi1 = blk1.no*no_buckets + b # glbi of the old_fp
                    if (self.check_candidate_bucket(glbi1,old_fp)): # if candidate buckets has enough slots
                        evicted = True
                        self.remove_and_replace(blk1, glbi1, glbi2, old_fp,fp, same_bucket=False)
                        break
                if (not(evicted)):
                    # all candidate buckets were full, pick a candidate at random
                    # moreover, we need to run the while loop again because the old_fp will need to
                    # evict another fingerprint to go into its alternate bucket
                    # so the old_fp becomes new_fp and the "another fingerprint" becomes the old_fp
                    b,c = random.choice(candidates)
                    glbi1 = blk1.no*no_buckets + b # glbi of the old_fp
                    # just write the new_fp and delete the old, without writing the old in its alternate location
                    c = BitArray(c)
                    self.remove_and_replace(blk1,glbi1,glbi2,c,fp,simple=False,same_bucket=False)
                    # at this point we need to insert c at its alternate location by another eviction
                    # so we run the loop again with different old_fp and fp
                    fp = c
                    glbi2 = self.h_prime(glbi1,fp) # this is the alternate (global) bucket
                    lbi1 = glbi2 % no_buckets # this is the alternate (local) bucket
                    blk1 = self.Blocks[glbi2//no_buckets] # this is the alternate block
            count+=1
        if (count > 10):
            print("eviction counter > 10")
        if (count == max_count):
            raise Exception # in most cases we haven't created enough blocks for all items
            # no_blocks*no_fingerprints > no_items

    def query(self,item):
        fp = fingerprint(item)
        glbi1 = self.h1(item)
        block1 = self.Blocks[glbi1//no_buckets]
        lbi1 = glbi1 % no_buckets
        ota_bit = block1.get_OTA(lbi1)
        match = block1.read_and_cmp(lbi1, fp)
        if (match or not(ota_bit)):
            return match
        else:
            glbi2 = self.h2(item)
            block2 = self.Blocks[glbi2//no_buckets]
            lbi2 = glbi2 % no_buckets
            return block2.read_and_cmp(lbi2, fp)
    
    def printFilter(self):
        for i,blk in enumerate(self.Blocks):
            print('Block #',i)
            blk.print_whole_block()
            print('########################')

def fill_filter(file_name,filter):
    pass

# testing
if __name__ == '__main__':
    matchAll = True
    filter = MortonFilter(14)
    for i in range(634):
        filter.insert("item"+str(i))
    start = time.time()
    for i in range(634):
        match = filter.query("item"+str(i))
        matchAll &= match # must be True (no false negatives)
        if (not(match)):
            print("query failed for: item"+str(i))
    end = time.time()
    print(matchAll)

    print("time elapsed:", end - start)
    print("program ended")