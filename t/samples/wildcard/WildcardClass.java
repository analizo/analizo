import java.util.Collection;

public class WildcardClass extends Printer<Collection<?>> {
  public void helloWildcard(){
    GenericClass<?> variable = new GenericClass<String>();
    variable.print();
  }
}
