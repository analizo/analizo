class HelloWorld:
  __id_seq = 0
  hello = 1 

  def __init__(self):
    self.__id = __id_seq + 1
    __id_seq += 1
  

  def say(self):
    print("Hello, world! My is id " + self.__id)
  

  def destroy(self):
    print("Goodbye, world! My id is " + self.__id)
  

  def __private_method():
    hello = 2
    print(hello)
