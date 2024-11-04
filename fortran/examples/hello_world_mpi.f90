! hello_world_mpi
!
! BY: Jared Brzenski
!
! A simple hello-world written in Fortran with
! some basic usage with MPI
!
PROGRAM hello_world_mpi
!
include 'mpif.h'            ! need the MPI library included
!
! Some variables we will need to track
integer :: process_Rank     ! rank of the process according to MPI
integer :: size_Of_Cluster  ! num. processes requests
integer :: ierror           ! MPI error code
!
! Initialize the MPI communicator
call MPI_INIT(ierror)       
! Initilize MPI_COMM_WORLD with num. of processes
call MPI_COMM_SIZE(MPI_COMM_WORLD, size_Of_Cluster, ierror)
! Initialize MPI_COMM_WORLD for this specific process (rank)
call MPI_COMM_RANK(MPI_COMM_WORLD, process_Rank, ierror)
!
print *, 'Hello World from process: ', process_Rank, 'of ', size_Of_Cluster
! Always need to close the communicator 
call MPI_FINALIZE(ierror)
!
END PROGRAM
