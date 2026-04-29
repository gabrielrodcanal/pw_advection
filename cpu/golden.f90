program main
    real*8, dimension(:,:,:), allocatable :: su, sv, sw, u, v, w
    real*8, dimension(:), allocatable :: tzc1, tzc2, tzd1, tzd2
    integer :: k, j, i, nx, ny, nz
    integer :: itimer0, itimer1
    
    nx=8
    ny=8
    nz=16

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

    do i=1, nx
      do j=1, ny
        do k=1, nz
          u(k,j,i)=23.4
          v(k,j,i)=18.8
          w(k,j,i)=3.1
        end do
      end do
    end do
    
    do k=1, nz
      tzc1(k)=12.3
      tzc2(k)=1.9
      tzd1(k)=5.6
      tzd2(k)=23.8
    end do

    do i=2,nx-1
      do j=2,ny-1
        do k=2,nz-1
          su(k, j, i)=&
            (2.0*(u(k, j, i-1)*(u(k, j, i)+u(k, j, i-1))-u(k, j, i+1)*(u(k, j, i)+u(k, j, i+1)))) + &
            (1.0*(u(k, j-1, i)*(v(k, j-1, i)+v(k, j-1, i+1))-u(k, j+1, i)*(v(k, j, i)+v(k, j, i+1)))) + &
            (tzc1(k)*u(k-1, j, i)*(w(k-1, j, i)+w(k-1, j, i+1))-tzc2(k)*u(k+1, j, i)*(w(k, j, i)+w(k, j, i+1)))   

          sv(k, j, i)=&
            (2.0*(v(k, j-1, i)*(v(k, j, i)+v(k, j-1, i))-v(k, j+1, i)*(v(k, j, i)+v(k, j+1, i)))) + &
            (2.0*(v(k, j, i-1)*(u(k, j, i-1)+u(k, j+1, i-1))-v(k, j, i+1)*(u(k, j, i)+u(k, j+1, i)))) + &
            (tzc1(k)*v(k-1, j, i)*(w(k-1, j, i)+w(k-1, j+1, i))-tzc2(k)*v(k+1, j, i)*(w(k, j, i)+w(k, j+1, i)))

          sw(k, j, i)=&
            (tzd1(k)*w(k-1, j, i)*(w(k, j, i)+w(k-1, j, i))-tzd2(k)*w(k+1, j, i)*(w(k, j, i)+w(k+1, j, i))) + &
            (2.0*(w(k, j, i-1)*(u(k, j, i-1)+u(k+1, j, i-1))-w(k, j, i+1)*(u(k, j, i)+u(k+1, j, i)))) + &
            (2.0*(w(k, j-1, i)*(v(k, j-1, i)+v(k+1, j-1, i))-w(k, j+1, i)*(v(k, j, i)+v(k+1, j, i))))       
        end do
      end do
    end do


    ! Print su array to file
    open(unit=10, file='su_output.txt', status='replace', action='write')
    do i=1, nx
      write(10, '(A,I0)') 'X=', i-1
      do k=1, nz
        write(10, '(*(F12.6,1X))') (su(k,j,i), j=1,ny)
      end do
      write(10, *)
    end do
    close(10)


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
end program main