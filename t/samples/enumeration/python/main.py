from enum import Enum

class MyEnumeration(Enum):
    A = "a"
    B = "b"
    C = "c"
    D = "d"


def main():
    enumeration = MyEnumeration.A
    if (enumeration == MyEnumeration.A):
        print("hello, world")