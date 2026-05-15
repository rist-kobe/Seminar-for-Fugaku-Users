! Copyright 2024 Research Organization for Information Science and Technology
module mykernel
  use mytype, only: DP
  implicit none
contains
  subroutine poly1(x, c1, c2)
     real(kind=DP), dimension(:), contiguous, intent(inout) :: x
     real(kind=DP), dimension(:), contiguous, intent(in) :: c1
     real(kind=DP), dimension(:), contiguous, intent(in) :: c2
    
     x(:) = c1(:) + x(:)*c2(:)
  end subroutine poly1

  subroutine poly4(x, c1, c2)
     real(kind=DP), dimension(:), contiguous, intent(inout) :: x
     real(kind=DP), dimension(:), contiguous, intent(in) :: c1
     real(kind=DP), dimension(:), contiguous, intent(in) :: c2
    
     x(:) = c1(:) + x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*c1(:))))
  end subroutine poly4

  subroutine poly8(x, c1, c2)
     real(kind=DP), dimension(:), contiguous, intent(inout) :: x
     real(kind=DP), dimension(:), contiguous, intent(in) :: c1
     real(kind=DP), dimension(:), contiguous, intent(in) :: c2
    
     x(:) = c1(:)                                           &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*(c1(:) &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*c1(:)  &
           )))))))
  end subroutine poly8

  subroutine poly16(x, c1, c2)
     real(kind=DP), dimension(:), contiguous, intent(inout) :: x
     real(kind=DP), dimension(:), contiguous, intent(in) :: c1
     real(kind=DP), dimension(:), contiguous, intent(in) :: c2
    
     x(:) = c1(:)                                           &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*(c1(:) &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*(c1(:) &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*(c1(:) &
           +x(:)*(c2(:)+x(:)*(c1(:)+x(:)*(c2(:)+x(:)*c1(:)  &
           )))))))))))))))
  end subroutine poly16
end module mykernel
