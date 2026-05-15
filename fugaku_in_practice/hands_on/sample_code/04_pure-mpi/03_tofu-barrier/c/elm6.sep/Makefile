CC=mpifccpx
COPT=-O2 -msve-vector-bits=scalable
LIB= 
INC=
CFLAGS=-Nclang -g -std=gnu11 $(COPT) $(INC) 
LDFLAGS=$(CFLAGS)

SRC = main.c timer.c

OBJ  = $(SRC:.c=.o)

.SUFFIXES: .o .c

run.x: $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) $(LIB) -o $@	

main.o: timer.o main.c

timer.o: timer.c

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY:
clean:
	rm -f *~ *.o 

.PHONY:
veryclean: clean
	rm -f *.x
