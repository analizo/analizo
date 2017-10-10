using System;

class Square : Tetragon {
  public Square(int w) {
    this.width = w;
  }

  public override int Area() {
    return (width * width);
  }

  public override int Perimeter() {
    return (width * 4);
  }
}
