all: src/main.c
	g++ -O2 -m64 -o bin/example $< lib/lib/libfmodex64.so

clean:
	rm -f bin/example
