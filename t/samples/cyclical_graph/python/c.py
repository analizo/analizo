from e import E

class C:
  def __init__(self, name):
      self.__name = name
      
  def name(self):
    eprint = E("Letter E");
    print(eprint.name());
    return self.__name;