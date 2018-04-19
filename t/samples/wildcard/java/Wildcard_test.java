public class GenericClass<T> {

    public void print(){
        System.out.print(T.class);
    }
}

public class Wildcard_sample {

    public void helloWildcard(){
        GenericClass<?> variable = new GenericClass<String>();
        variable.print();
    }
}