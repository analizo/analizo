all: program

program: main.o classes.o
	$(CXX) -o $@ $^

clean:
	$(RM) *.o
	$(RM) program
