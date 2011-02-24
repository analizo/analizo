CXXFLAGS=-Isrc

all: hello test/hello_test

hello: hello.o src/hello.o
	$(CXX) -o $@ $^

test/hello_test: src/hello.o test/hello_test.o
	$(CXX) -o $@ $^

clean:
	$(RM) hello test/hello_test */*.o *.o
