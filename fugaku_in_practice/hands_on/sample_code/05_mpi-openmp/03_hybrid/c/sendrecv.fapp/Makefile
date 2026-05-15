CC=mpifccpx
CFLAGS=-Nclang -g -std=gnu11 -Ofast -msve-vector-bits=scalable -fvectorize -ffj-lst=t
LIB=

.SUFFIXES: .o .c

SRC = main.c timer.c util_mpi.c

OBJ = $(SRC:.c=.o)

EXE=run.x

$(EXE): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LIB)

main.o: timer.o util_mpi.o main.c

timer.o: timer.c

util_mpi.o: util_mpi.c

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY:
clean:
	rm -f *.o *.lst

.PHONY:
veryclean: clean
	rm -f $(EXE)
