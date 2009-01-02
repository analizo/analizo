CFLAGS = -dr
OBJECTS = module1.o module2.o module3.o

all: program

program: $(OBJECTS)
	gcc -o $@ $(OBJECTS)

clean:
	rm -f *.o *.expand program tags
