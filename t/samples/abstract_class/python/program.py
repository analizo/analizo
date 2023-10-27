import sys
from dog import Dog

def main(args): 
    dog = Dog()
    print(dog.Describe());

if __name__ == '__main__':
    main(sys.argv)

