program pw_advection
    call main()
end program

subroutine main()
use, intrinsic :: iso_fortran_env
    real*8, dimension(:,:,:), allocatable :: su, sv, sw, u, v, w
    real*8, dimension(:), allocatable :: tzc1, tzc2, tzd1, tzd2
    integer :: k, j, i, nx, ny, nz
    integer :: itimer0, itimer1
    integer :: counter_zeros
    integer :: counter
    integer :: num_args, ix
    character(len=12), dimension(:), allocatable :: args
    integer :: fu
    namelist /DIMENSIONS/ nx, ny, nz

    open(action='read', file="dimensions.nml", newunit=fu)
    read(nml=DIMENSIONS, unit=fu)
    close(fu)

    !nx=8
    !ny=8
    !nz=15
    !read(args(2),*) nx
    !read(args(2),*) ny
    !read(args(3),*) nz

    allocate(su(nz, ny, nx))
    allocate(sv(nz, ny, nx))
    allocate(sw(nz, ny, nx))
    allocate(u(nz, ny, nx))
    allocate(v(nz, ny, nx))
    allocate(w(nz, ny, nx))
    allocate(tzc1(nz))
    allocate(tzc2(nz))
    allocate(tzd1(nz))
    allocate(tzd2(nz))

    !call timer_init()
    !call timer_start(itimer0, label='Initialise')

    do i=1, nx
      do j=1, ny
        do k=1, nz
          u(k,j,i)=10.0
          v(k,j,i)=20.0
          w(k,j,i)=30.0
        end do
      end do
    end do
    
    do k=1, nz
      tzc1(k)=50.0
      tzc2(k)=15.0
      tzd1(k)=100.0
      tzd2(k)=5.0
    end do

    !call timer_stop(itimer0)
    !call timer_start(itimer1, label='Compute')

    counter = 1

    do i=2,nx-1
      do j=2,ny-1
        do k=2,nz-1
          su(k, j, i)=&
            (2.0*(u(k, j, i-1)*(u(k, j, i)+u(k, j, i-1))-u(k, j, i+1)*(u(k, j, i)+u(k, j, i+1)))) + &
            (1.0*(u(k, j-1, i)*(v(k, j-1, i)+v(k, j-1, i+1))-u(k, j+1, i)*(v(k, j, i)+v(k, j, i+1)))) + &
            (tzc1(k)*u(k-1, j, i)*(w(k-1, j, i)+w(k-1, j, i+1))-tzc2(k)*u(k+1, j, i)*(w(k, j, i)+w(k, j, i+1)))   
          su(k, j, i) = counter

          sv(k, j, i)=&
            (2.0*(v(k, j-1, i)*(v(k, j, i)+v(k, j-1, i))-v(k, j+1, i)*(v(k, j, i)+v(k, j+1, i)))) + &
            (2.0*(v(k, j, i-1)*(u(k, j, i-1)+u(k, j+1, i-1))-v(k, j, i+1)*(u(k, j, i)+u(k, j+1, i)))) + &
            (tzc1(k)*v(k-1, j, i)*(w(k-1, j, i)+w(k-1, j+1, i))-tzc2(k)*v(k+1, j, i)*(w(k, j, i)+w(k, j+1, i)))
          sv(k, j, i) = counter

          sw(k, j, i)=&
            (tzd1(k)*w(k-1, j, i)*(w(k, j, i)+w(k-1, j, i))-tzd2(k)*w(k+1, j, i)*(w(k, j, i)+w(k+1, j, i))) + &
            (2.0*(w(k, j, i-1)*(u(k, j, i-1)+u(k+1, j, i-1))-w(k, j, i+1)*(u(k, j, i)+u(k+1, j, i)))) + &
            (2.0*(w(k, j-1, i)*(v(k, j-1, i)+v(k+1, j-1, i))-w(k, j+1, i)*(v(k, j, i)+v(k+1, j, i))))       
          sw(k, j, i) = counter
          counter = counter + 1
        end do
      end do
    end do

    !call timer_stop(itimer1)

    !call timer_report()

    counter_zeros = 0

    do i=2,nx-1
        do j=2,ny-1
            do k=2,nz
                if ((i == 2 .and. j > 1 .and. k > 1) .or. i > 2) then
                    write(*,*) su(k,j,i)
                end if
            end do
        end do
    end do

    do i=2,nx-1
        do j=2,ny-1
            do k=2,nz
                if ((i == 2 .and. j > 1 .and. k > 1) .or. i > 2) then
                    write(*,*) sv(k,j,i)
                end if
            end do
        end do
    end do

    do i=2,nx-1
        do j=2,ny-1
            do k=2,nz
                if ((i == 2 .and. j > 1 .and. k > 1) .or. i > 2) then
                    write(*,*) sw(k,j,i)
                end if
            end do
        end do
    end do

    deallocate(su)
    deallocate(sv)
    deallocate(sw)
    deallocate(u)
    deallocate(v)
    deallocate(w)
    deallocate(tzc1)
    deallocate(tzc2)
    deallocate(tzd1)
    deallocate(tzd2)
end subroutine main
