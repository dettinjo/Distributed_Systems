import sys
import time

def is_prime(num):
  if num <= 1:
    return False
  else:
    for i in range(2,num):
      if (num % i) == 0: return False

  return True

if __name__ == "__main__":
    start_time = time.perf_counter()
    begin=int(sys.argv[1])
    end=int(sys.argv[2])
    count = 0
    for n in range(begin,end):
      if is_prime(n):
        count += 1
    finish_time = time.perf_counter()
    print(f"Program finished in {finish_time-start_time} seconds")
    print(count)
