public class main {

  static public void Main() {
    HelloWorld hello1 = new HelloWorld();
    HelloWorld hello2 = new HelloWorld();

    hello1.say();
    hello2.say();

    // // even if we don't need to destroy these objects explicitly, we call
    // // destroy() to make this similar to the C code
    hello1.destroy();
    hello2.destroy();
  }
}
