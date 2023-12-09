from c import C

class F:
  def __init__(self, name):
      self.__name = name
      
  def name(self):
    cprint = C("Letter C");
    print(cprint.name());
    return self.__name;