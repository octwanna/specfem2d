!========================================================================
!
!                   S P E C F E M 2 D  Version 7 . 0
!                   --------------------------------
!
!     Main historical authors: Dimitri Komatitsch and Jeroen Tromp
!                        Princeton University, USA
!                and CNRS / University of Marseille, France
!                 (there are currently many more authors!)
! (c) Princeton University and CNRS / University of Marseille, April 2014
!
! This software is a computer program whose purpose is to solve
! the two-dimensional viscoelastic anisotropic or poroelastic wave equation
! using a spectral-element method (SEM).
!
! This program is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 2 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along
! with this program; if not, write to the Free Software Foundation, Inc.,
! 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
!
! The full text of the license is available in file "LICENSE".
!
!========================================================================

  subroutine compute_gradient_attenuation(displ_elastic,dux_dxl,duz_dxl,dux_dzl,duz_dzl, &
         xix,xiz,gammax,gammaz,ibool,ispec_is_elastic,hprime_xx,hprime_zz,nspec,nglob)

  use constants, only: CUSTOM_REAL,NGLLX,NGLLZ,NGLJ,NDIM,ZERO

  use specfem_par, only: AXISYM,is_on_the_axis,hprimeBar_xx

! compute Grad(displ_elastic) for attenuation

  implicit none

  integer :: nspec,nglob

  integer, dimension(NGLLX,NGLLZ,nspec) :: ibool

  logical, dimension(nspec) :: ispec_is_elastic

  real(kind=CUSTOM_REAL), dimension(NGLLX,NGLLZ,nspec) :: dux_dxl,duz_dxl,dux_dzl,duz_dzl
  real(kind=CUSTOM_REAL), dimension(NGLLX,NGLLZ,nspec)  :: xix,xiz,gammax,gammaz

  real(kind=CUSTOM_REAL), dimension(NDIM,nglob) :: displ_elastic

! array with derivatives of Lagrange polynomials
  real(kind=CUSTOM_REAL), dimension(NGLLX,NGLLX) :: hprime_xx!,hprimeBar_xx
  real(kind=CUSTOM_REAL), dimension(NGLLZ,NGLLZ) :: hprime_zz

! local variables
  integer :: i,j,k,ispec

! spatial derivatives
  real(kind=CUSTOM_REAL) :: dux_dxi,dux_dgamma,duz_dxi,duz_dgamma

! jacobian
  real(kind=CUSTOM_REAL) :: xixl,xizl,gammaxl,gammazl

! loop over spectral elements
  do ispec = 1,nspec

!---
!--- elastic spectral element
!---
    if (ispec_is_elastic(ispec)) then

! first double loop over GLL points to compute and store gradients
      do j = 1,NGLLZ
        do i = 1,NGLLX

! derivative along x and along z
          dux_dxi = ZERO
          duz_dxi = ZERO

          dux_dgamma = ZERO
          duz_dgamma = ZERO

! first double loop over GLL points to compute and store gradients
! we can merge the two loops because NGLLX == NGLLZ

          if (AXISYM) then
            if (is_on_the_axis(ispec)) then
              do k = 1,NGLJ
                dux_dxi = dux_dxi + displ_elastic(1,ibool(k,j,ispec))*hprimeBar_xx(i,k)
                duz_dxi = duz_dxi + displ_elastic(2,ibool(k,j,ispec))*hprimeBar_xx(i,k)
                dux_dgamma = dux_dgamma + displ_elastic(1,ibool(i,k,ispec))*hprime_zz(j,k)
                duz_dgamma = duz_dgamma + displ_elastic(2,ibool(i,k,ispec))*hprime_zz(j,k)
              enddo
            else
              do k = 1,NGLJ
                dux_dxi = dux_dxi + displ_elastic(1,ibool(k,j,ispec))*hprime_xx(i,k)
                duz_dxi = duz_dxi + displ_elastic(2,ibool(k,j,ispec))*hprime_xx(i,k)
                dux_dgamma = dux_dgamma + displ_elastic(1,ibool(i,k,ispec))*hprime_zz(j,k)
                duz_dgamma = duz_dgamma + displ_elastic(2,ibool(i,k,ispec))*hprime_zz(j,k)
              enddo
            endif
          else
            do k = 1,NGLLX
              dux_dxi = dux_dxi + displ_elastic(1,ibool(k,j,ispec))*hprime_xx(i,k)
              duz_dxi = duz_dxi + displ_elastic(2,ibool(k,j,ispec))*hprime_xx(i,k)
              dux_dgamma = dux_dgamma + displ_elastic(1,ibool(i,k,ispec))*hprime_zz(j,k)
              duz_dgamma = duz_dgamma + displ_elastic(2,ibool(i,k,ispec))*hprime_zz(j,k)
            enddo
          endif

          xixl = xix(i,j,ispec)
          xizl = xiz(i,j,ispec)
          gammaxl = gammax(i,j,ispec)
          gammazl = gammaz(i,j,ispec)

! derivatives of displacement
          dux_dxl(i,j,ispec) = dux_dxi*xixl + dux_dgamma*gammaxl
          dux_dzl(i,j,ispec) = dux_dxi*xizl + dux_dgamma*gammazl

          duz_dxl(i,j,ispec) = duz_dxi*xixl + duz_dgamma*gammaxl
          duz_dzl(i,j,ispec) = duz_dxi*xizl + duz_dgamma*gammazl

          if (AXISYM .and. is_on_the_axis(ispec) .and. i == 1) then ! d_uz/dr=0 on the axis
            duz_dxl(i,j,ispec) = 0.d0
          endif

        enddo
      enddo

    endif

  enddo

  end subroutine compute_gradient_attenuation

