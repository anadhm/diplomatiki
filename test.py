import time

def attack():
    time.sleep(5) # placeholder

def main():
    input("Start attack?(press any button)")
    start_time = time.time()
    attack()
    end_time = time.time()
    print("Attack ended.\nTime: " + str(end_time-start_time) + " seconds.")

if __name__=='__main__':
    main()