using System;
using f;

namespace e {

  public class E {
    private string _name;

    public E(string name) {
      this._name = name;
    }

    public string name() {
      F fprint = new F("Letter F");
      Console.WriteLine(fprint.name());
      return this._name;
    }
  }

}
