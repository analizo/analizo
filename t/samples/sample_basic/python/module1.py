from module2 import *
import module3

def main():
    localvar = 0

    say_hello()
    say_bye()

    print(f"variable = {module3.variable}")
    variable = 20

    print(f"variable = {variable}")
    print(f"localvar = {localvar}")

    module3.callback()
    return 0

main()