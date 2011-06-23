all: lib.o

lib.o: main.c
	gcc -c -o $@ $<

lib.o: lib.h

clean:
	$(RM) lib.o
