CFLAGS = -I../lib

all: hello

hello: ../lib/lib.o main.o
	$(CC) -o $@ $^

../lib/lib.o:
	$(MAKE) -C ../lib

clean:
	$(RM) hello main.o
