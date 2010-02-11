public abstract class Polygon {
  protected int width, height;
  
  public polygon (int width){
    this.width = width;
  }

  public polygon (int width, int height){
    this.width = width;
    this.height = height;  
  }
 
  public abstract int area ();
}
