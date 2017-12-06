DIR_INC = ./include
DIR_SRC = ./src
DIR_OBJ = ./obj
DIR_BIN = ./bin


CC = g++
CFLAGS = --std=c++11 -DNDEBUG -O3 -I ${DIR_INC}
CFLAGS_G = --std=c++11 -DNDEBUG -g -I ${DIR_INC}


SRC = $(wildcard ${DIR_SRC}/*.cc ${DIR_SRC}/*.cpp)  



TARGET = numvc

BIN_TARGET = ${DIR_BIN}/${TARGET}


${BIN_TARGET}:${SRC} ${SRC}
	$(CC) $(CFLAGS) -o $@ $^

DEBUG = debug
BIN_DEBUG = ${DIR_BIN}/${DEBUG}

${BIN_DEBUG}:${SRC} ${SRC}
	$(CC) $(CFLAGS_G) -o $@ $^

.PHONY: clean	
clean :
	-rm ${BIN_TARGET}
