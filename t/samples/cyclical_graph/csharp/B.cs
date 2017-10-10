using System;
using d;

namespace b {

  public class B {
    private string _name;

    public B(string name) {
      this._name = name;
    }

    public string name() {
      D dprint = new D("Letter D");
      Console.WriteLine(dprint.name());
      return this._name;
    }
  }

}
