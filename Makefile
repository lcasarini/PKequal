FC = gfortran
FFLAGS =  -O3 -ffast-math -march=native -funroll-loops

.f.o:
	$(FC) $(FFLAGS) -c $<

OBJ = pkequal.o dverk.o rombint.o 



all: clean pkequal

pkequal: $(OBJ)
	$(FC) $(FFLAGS) $(OBJ) -o $@

clean:
	rm -f *.o
tidy: 
	rm -f *.o $(exe)

