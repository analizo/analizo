CXXFLAGS=-Isrc

test/hello_test: src/hello.o test/hello_test.o
	$(CXX) -o $@ $^

clean:
	$(RM) test/hello_test */*.o
