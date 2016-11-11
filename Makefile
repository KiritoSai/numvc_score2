CC = g++
CFLAGS = --std=c++11 -DNDEBUG -O3

all : numvc 

numvc : numvc.cpp numvc.h preprocess.cc preprocess.h
	$(CC) $(CFLAGS) -o $@ $^
	
clean :
	-rm numvc
