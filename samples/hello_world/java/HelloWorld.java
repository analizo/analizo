public class HelloWorld {
  private static int _id_seq = 0;

  private int _id;

  public HelloWorld() {
    this._id = (_id_seq++);
  }

  public void say() {
    System.out.println("Hello, world! My is id " + _id);
  }

  public void destroy() {
    System.out.println("Goodbye, world! My id is " + _id);
  }

}
