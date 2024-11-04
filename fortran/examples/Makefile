# Compiler
FC = gfortran
FCMPI = mpifort

# Compiler flags
FCFLAGS = -O2

# Executable names
EXE1 = hello
EXE2 = hello_mpi

# Source files
SRC1 = hello_world.f90
SRC2 = hello_world_mpi.f90

# Build targets
all: $(EXE1) $(EXE2)

$(EXE1): $(SRC1)
	$(FC) $(FCFLAGS) -o $(EXE1) $(SRC1)

$(EXE2): $(SRC2)
	$(FCMPI) $(FCFLAGS) -o $(EXE2) $(SRC2)

# Clean up
clean:
	rm -f $(EXE1) $(EXE2) *.o *.mod

