import time
def setup_mainchain():
    try:
        time.sleep(2) # placeholder
    except:
        print("Unexpected error:", sys.exc_info()[0])
    else:
        print("Network ok!")
        
def attack():
    time.sleep(5) # placeholder

def main():
    setup_mainchain()
    input("Start attack?(press any button)")
    start_time = time.time()
    attack()
    end_time = time.time()
    print("Attack ended.\nTime: " + str(end_time-start_time) + " seconds.")

if __name__=='__main__':
    main()