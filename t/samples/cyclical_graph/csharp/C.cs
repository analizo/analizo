using System;
using e;

namespace c {

  public class C {
    private string _name;

    public C(string name) {
      this._name = name;
    }

    public string name() {
      E eprint = new E("Letter E");
      Console.WriteLine(eprint.name());
      return this._name;
    }
  }

}
