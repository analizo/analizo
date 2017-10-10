using System;
using c;

namespace f {

  public class F {
    private string _name;

    public F(string name) {
      this._name = name;
    }

    public string name() {
      C cprint = new C("Letter C");
      Console.WriteLine(cprint.name());
      return this._name;
    }
  }

}
