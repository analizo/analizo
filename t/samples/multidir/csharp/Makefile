all: hello test/hello_test

hello:
	mcs hello.cs src/hello.cs

test/hello_test:
	mcs src/hello.cs test/hello_test.cs

clean:
	$(RM) *.exe src/*.exe
