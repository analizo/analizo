from c import C
from b import B

def main():
  b: B = B("Letter B")
  c: C = C("Letter C")

  print(b.name())
  print(c.name())

