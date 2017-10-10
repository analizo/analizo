using System;

class Rect : Tetragon {
  public Rect(int w, int h) {
    this.width = w;
    this.heigth = h;
  }

  public override int Area() {
    return (width * heigth);
  }

  public override int Perimeter() {
    return (width * 2 + heigth * 2);
  }
}
