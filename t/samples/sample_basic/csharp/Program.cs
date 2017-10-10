using System;

class Program {
  static void Main() {
    int localvar = 0;

    Module1.SayHello();
    Module1.SayBye();

    Console.WriteLine("Variable = {0}", Module2.variable);
    Module2.variable = 20;

    Console.WriteLine("Variable = {0}", Module2.variable);
    Console.WriteLine("Variable = {0}", localvar);

    Module2.Callback();
  }
}
