CFLAGS = -dr
OBJECTS = module1.o module2.o module3.o

all: program

program: $(OBJECTS)
	gcc -o $@ $(OBJECTS)

egypt-original.$(FORMAT): $(OBJECTS)
	egypt . | dot -T$(FORMAT) -o$@

egypt-cluster.$(FORMAT): $(OBJECTS)
	egypt --cluster . | dot -T$(FORMAT) -o$@

egypt-modules.$(FORMAT): $(OBJECTS)
	egypt --modules . | dot -T$(FORMAT) -o$@

clean:
	rm -f *.o *.expand program tags
