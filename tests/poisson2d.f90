! ------------------------------------------------------ !
! Quantulaba - poisson2d.f90 - Krzysztof Kolasinski 2016
!
! This example shows how to use Quantulaba to solve sparse
! system of linear equations with PARDISO. As example we
! solve poisson equaion in 2D:
!       \nabla^2 psi(x,y) = rho(x,y)
! where: rho(x,y) is the density at point (x,y)
!        psi(x,y) is the potential generated by this density
! ------------------------------------------------------ !
program poisson2d
use modunits
use modscatter
implicit none
character(*),parameter :: output_folder = "poisson2d_output/"
type(qscatter)             :: qt
doubleprecision            :: a_dx,x,y,hx,hy
integer ,parameter         :: nx = 100
integer ,parameter         :: ny = 100
doubleprecision,parameter  :: dx = 5.0 ! [nm]
integer , dimension(nx,ny) :: gindex ! converts local index (i,j) to global index
doubleprecision ,dimension(nx*ny) :: rho , phi ! density and potentials arrays, must be 1D array
integer :: i,j,k

QSYS_DEBUG_LEVEL = 0 ! Disable DEBUG

! Use atomic units in effective band model -> see modunit.f90 for more details
call modunits_set_GaAs_params()
a_dx = dx * L2LA ! convert it to atomic units
hx = dx * nx / 2 ! center of the box
hy = dx * ny / 2

! Initalize system
call qt%init_system()

! ----------------------------------------------------------
! 1. Create mesh - loop over width and height of the lattice
! ----------------------------------------------------------
k      = 0
gindex = 0
do i = 1 , nx
do j = 1 , ny
    x = (i-1) * dx
    y = (j-1) * dx
    call qt%qatom%init((/ x , y , 0.0 * dx /))
    ! Add atom to the system.
    call qt%qsystem%add_atom(qt%qatom)
    k           = k + 1
    gindex(i,j) = k
    ! As an example we use two gaussians with different sign for electron density
    rho(k) = exp( -0.01*( (x-hx+50)**2 + (y-hy)**2 ) ) - exp( -0.01*( (x-hx-50)**2 + (y-hy)**2 ) )
enddo
enddo

! ----------------------------------------------------------
! 2. Construct logical connections between sites on the mesh.
! ----------------------------------------------------------
! Set criterium for the nearest neightbours "radius" search algorithm.
! Same as above qt%qnnbparam is a auxiliary variable of type(nnb_params) - more details in modsys.f90
! This structure is responsible for different criteria of nearest neighbour searching
qt%qnnbparam%box = (/2*dx,2*dx,0.0D0/) ! do not search for the sites far than (-dx:+dx) direction
! Setup connections between sites with provided by you function "connect", see below for example.
call qt%qsystem%make_lattice(qt%qnnbparam,c_simple=connect)

! ----------------------------------------------------------
! 3. Use calc_linsys to solve system of equations. Our matrix
! is symmetric thus we use matrix type to be QSYS_LINSYS_PARDISO_REAL_STRUCT_SYM
! dvec - is the left hand vector, its value will be replaced by solution
! ----------------------------------------------------------
phi = rho
call qt%qsystem%calc_linsys(dvec=phi,pardiso_mtype=QSYS_LINSYS_PARDISO_REAL_STRUCT_SYM)
call qt%save_system(output_folder//"system.xml")
call qt%qsystem%save_data(output_folder//"psi.xml",array1d=phi)

! Print solution.
open(unit=11,file=output_folder//"Potential.dat")
do i = 1 , nx
do j = 1 , ny
    x = (i-1) * dx
    y = (j-1) * dx
    write(11,"(4f)"),x,y,rho(gindex(i,j)),phi(gindex(i,j))
enddo
    write(11,*),""
enddo
! ----------------------------------------------------------
! X. Clean memory...
! ----------------------------------------------------------
call qt%destroy_system()
print*,"Generating plots..."
print*,"Plotting solution..."
call system("cd "//output_folder//"; ./plot_Sol.py")
print*,"Use Viewer program to see the structure and created leads."
contains

! ---------------------------------------------------------------------------
! This function decides if site A (called here atomA)  has hoping
! to atom B, and what is the value of the coupling.
! If there is no interaction between them returns false, otherwise true.
! Poisson equation after discretization leads to the tight-biding like
! problem, thus we can use matrix creation using connect function.
! ---------------------------------------------------------------------------
logical function connect(atomA,atomB,coupling_val)
    use modcommons
    implicit none
    type(qatom) :: atomA,atomB

    complex*16  :: coupling_val ! you must overwrite this variable
    ! local variables
    integer         :: xdiff,ydiff
    doubleprecision :: dydiff,dxdiff,t0,y

    ! Calculate distance between atoms in units of dx.
    dxdiff = (atomA%atom_pos(1)-atomB%atom_pos(1))/dx
    dydiff = (atomA%atom_pos(2)-atomB%atom_pos(2))/dx
    ! Convert it to integers
    xdiff = NINT(dxdiff)
    ydiff = NINT(dydiff)
    ! default return value
    connect = .false.
    ! hoping parameter
    t0 = 1/(2*m_eff*a_dx**2)
    if( xdiff == 0 .and. ydiff == 0 ) then
        connect      = .true.
        coupling_val = 4*t0
    else if( abs(xdiff) ==  1 .and. ydiff == 0 ) then
        connect = .true.
        coupling_val = -t0
    else if( xdiff ==  0 .and. abs(ydiff) == 1 ) then
        connect = .true.
        coupling_val = -t0
    endif
end function connect
end program poisson2d
