FC = mpifrtpx
FFLAGS = -O3 -Koptmsg=2 -Nlst=t
##########################################

SRC = main.f90

OBJS = $(SRC:.f90=.o)

run.x : $(OBJS)
	$(FC) $(FFLAGS) $(OBJS) -o $@

.f90.o : 
	$(FC) $(FFLAGS) -c $< -o $@

main.o:
	$(FC) $(FFLAGS) -c $*.f90

.PHONY: clean
clean:
	rm -f *.o *.lst

.PHONY: veryclean
veryclean:
	rm -f *.x


