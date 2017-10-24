
cc = gcc

.PHONY : clean

# 1st task is default
compile: clean helloworld.so

# target
helloworld.so: helloworld.c
	cc -fPIC -shared -o libhelloworld.so helloworld.c

clean :
	rm -f *.so
