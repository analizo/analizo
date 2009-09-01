public class Main {
  public static void main(String[] args) {
    HelloWorld hello1 = new HelloWorld();
    HelloWorld hello2 = new HelloWorld();

    hello1.say();
    hello2.say();

    // Yes, I know Java does not need destructors, but I want the program to
    // work just like the C and C++ ones, and I cannot guarantee when (or if)
    // finalize() will be called.
    hello1.destroy();
    hello2.destroy();
  }
}
