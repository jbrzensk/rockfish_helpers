! ======================================================================
! NAME
!
!   hello_world.f90
!
! AUTHOR
!
!   Jared Brzenski
!
! DESCRIPTION
!
!   A simple hello world program written in Fortran 90
!
! USAGE
!
!   Compile and run with the following commands:
!
!     gfortran hello_world.f90
!     ./a.out
!
!   OR compile and run with the included Makefile
!
!     make all
!     ./hello
!
! LAST UPDATED
!
!   November 3, 2024
!
! ----------------------------------------------------------------------

program hello_world
        ! Fortran code sets the variables used
        ! no implicit types allowed
        implicit none
        !
        print *, "Hello World!"
        !
end program
