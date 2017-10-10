using System;

public class HelloWorld {
  private static int _id_seq = 0;
  private int _id;
  public static int hello = 1;

  public HelloWorld() {
    this._id = (HelloWorld._id_seq++);
  }

  public void say() {
    Console.WriteLine("Hello, world! My id is " + _id);
  }

  public void destroy() {
    Console.WriteLine("Goobdye, world! My id is " + _id);
  }

  private void private_method() {
    hello = 2;
    Console.WriteLine(hello);
  }
}
