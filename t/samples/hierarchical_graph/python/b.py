from d import D

class B:
  def __init__(self, name):
    self.__name = name
  

  def name(self):
    dprint: D = D("Letter D")
    print(dprint.name())
    return self.__name
