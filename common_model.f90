! ----------------------------------------------------------------------------------
! The subroutine FUNC() evaluates the right-hand side of the ODE system.
! Given the current state U(1:6) and parameter values PAR(*), it computes
! the derivatives F(1:6). AUTO uses the same calling convention for every
! problem, therefore we include inputs that are declared but not used
! (see below for details).
!
! Inputs:
! NDIM - Number of state variables (dimensions) in the ODE system. 
!        For this model, NDIM = 6.
!
! U    - Current state vector of the system:
!        U(1) = PL, predator in littoral habitat
!        U(2) = FL, forager in littoral habitat
!        U(3) = JL, juvenile in littoral habitat
!        U(4) = PP, predator in pelagic habitat
!        U(5) = FP, forager in pelagic habitat
!        U(6) = JP, juvenile in pelagic habitat
!
! ICP  - AUTO continuation parameter index array. AUTO uses this to identify
!        which parameter(s) in PAR are being varied during continuation.
!        This subroutine receives ICP but does not use it directly.
!
! PAR  - Parameter vector containing model parameters. In this subroutine,
!        PAR is read but not modified.
!
! IJAC - Jacobian flag used by AUTO:
!        0: compute F only
!        1: compute F and DFDU
!        2: compute F, DFDU, and DFDP
!        This subroutine currently ignores IJAC and does not explicitly
!        compute Jacobian matrices.
!
! Outputs:
! F    - Derivative vector / vector field evaluated at the current state:
!        F(1) = dPL/dt
!        F(2) = dFL/dt
!        F(3) = dJL/dt
!        F(4) = dPP/dt
!        F(5) = dFP/dt
!        F(6) = dJP/dt
!
! Optional AUTO outputs:
! DFDU - Jacobian matrix with respect to state variables:
!        DFDU(i,j) = partial derivative of F(i) with respect to U(j).
!        This subroutine declares DFDU but does not fill it.
!
! DFDP - Jacobian matrix with respect to parameters:
!        DFDP(i,j) = partial derivative of F(i) with respect to PAR(j).
!        This subroutine declares DFDP but does not fill it.

SUBROUTINE FUNC(NDIM,U,ICP,PAR,IJAC,F,DFDU,DFDP)
  
  ! Overrides the default implicit typing rules for names. 
  IMPLICIT NONE 
  
  ! Declaration of inputs / outputs
  INTEGER, INTENT(IN) :: NDIM, IJAC, ICP(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM), PAR(*)
  DOUBLE PRECISION, INTENT(OUT) :: F(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: DFDU(NDIM,*), DFDP(NDIM,*) ! declared but not used

  ! Declaration of state variables
  DOUBLE PRECISION :: PL, FL, JL
  DOUBLE PRECISION :: PP, FP, JP

  ! Declaration of model parameters
  DOUBLE PRECISION :: r, a, m, b, s, e, fec, g, q, c
  DOUBLE PRECISION :: dP, dF, dJ
  DOUBLE PRECISION :: mu, deltar, deltas, beta, toggle
  DOUBLE PRECISION :: rL, rP, aL, aP ! habitat specific 

  ! Numerical safeguard
  DOUBLE PRECISION, PARAMETER :: payoff_floor = 1.0D-12 ! equivalent to 0.000000000001
  
  ! State variables
  PL=U(1)
  FL=U(2) 
  JL=U(3)
  PP=U(4)
  FP=U(5)
  JP=U(6)
  
  ! Model Parameters
  r=PAR(1)
  a=PAR(2)
  m=PAR(3)
  b=PAR(4)
  s=PAR(5)
  e=PAR(6)
  fec=PAR(7)
  g=PAR(8)
  q=PAR(9)
  c=PAR(10)
  dP=PAR(19)
  dF=PAR(12)
  dJ=PAR(13)
  mu=PAR(14)
  deltar=PAR(15)
  deltas=PAR(16)
  beta=PAR(17)
  toggle=PAR(18)
  
  ! Habitat variation
  rL = r*(1.D0 - deltar) 
  rP = r*(1.D0 + deltar)
  aP = a*(1.D0 + deltas)
  aL = a*(1.D0 - deltas)
  
  ! Ordinary Differential Equations (Model)
  F(1) = maturation(g,JL) - (m+mu)*PL - emig(dP,toggle,fitPL(FL,PL,JL), &
    & fitPP(FP,PP,JP))*PL + emig(dP,toggle,fitPP(FP,PP,JP),fitPL(FL,PL,JL))*PP
  F(2) = logistic(rL,b,FL) - type3(aL,PL,FL,s) + type1(e*q,FL,JL) - emig(dF,toggle, &
    & fitFL(FL,PL,JL),fitFP(FP,PP,JP))*FL + emig(dF,toggle,fitFP(FP,PP,JP), &
    & fitFL(FL,PL,JL))*FP
  F(3) = fec*PL - maturation(g,JL) - m*JL - type1(q,FL,JL) - type1(c,PL,JL) - &
    & emig(dJ,toggle,fitJL(PL,FL,JL),fitJP(PP,FP,JP))*JL + emig(dJ,toggle, &
    & fitJP(PP,FP,JP),fitJL(PL,FL,JL))*JP
  F(4) = maturation(g,JP) - (m+mu)*PP - emig(dP,toggle,fitPP(FP,PP,JP), &
    & fitPL(FL,PL,JL))*PP + emig(dP,toggle,fitPL(FL,PL,JL),fitPP(FP,PP,JP))*PL
  F(5) = logistic(rP,b,FP) - type3(aP,PP,FP,s) + type1(e*q,FP,JP) - emig(dF,toggle, &
    & fitFP(FP,PP,JP),fitFL(FL,PL,JL))*FP + emig(dF,toggle,fitFL(FL,PL,JL), &
    & fitFP(FP,PP,JP))*FL
  F(6) = fec*PP - maturation(g,JP) - m*JP - type1(q,FP,JP) - type1(c,PP,JP) - &
    & emig(dJ,toggle,fitJP(PP,FP,JP),fitJL(PL,FL,JL))*JP + emig(dJ,toggle, &
    & fitJL(PL,FL,JL),fitJP(PP,FP,JP))*JL
  RETURN
  
CONTAINS ! The following functions are nested inside FUNC(). They can use
         ! variables from FUNC(), such as rL or aL.

  DOUBLE PRECISION FUNCTION maturation(g,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: g,j
    maturation = (g*j)/(1+j*j)
  END FUNCTION maturation
  
  DOUBLE PRECISION FUNCTION type3(a,p,f,s)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: a,p,f,s
    type3 = (a*p*f*f)/(1+s*f*f)
  END FUNCTION type3
  
  DOUBLE PRECISION FUNCTION logistic(r,b,f)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: r,b,f
    logistic = r*f - b*f*f
  END FUNCTION logistic
  
  DOUBLE PRECISION FUNCTION sig(a)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: a
    sig = 1/(1+exp(-a))
  END FUNCTION sig
  
  DOUBLE PRECISION FUNCTION type1(a,x,y)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: a,x,y
    type1 = a*x*y
  END FUNCTION type1
  
  ! Fitness Equations
  DOUBLE PRECISION FUNCTION fitPL(f,p,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: f,p,j
    fitPL = 0
  END FUNCTION fitPL
  
  DOUBLE PRECISION FUNCTION fitPP(f,p,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: f,p,j
    fitPP = 0
  END FUNCTION fitPP
  
  DOUBLE PRECISION FUNCTION fitFL(f,p,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: f,p,j
    fitFL = LOG(MAX(EXP((rL - b*f) - (aL*p*f)/(1 + s*f*f) + e*q*j), payoff_floor))
  END FUNCTION fitFL
  
  DOUBLE PRECISION FUNCTION fitFP(f,p,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: f,p,j
    fitFP = LOG(MAX(EXP((rP - b*f) - (aP*p*f)/(1 + s*f*f) + e*q*j), payoff_floor))
  END FUNCTION fitFP
  
  DOUBLE PRECISION FUNCTION fitJL(p,f,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: p,f,j
    fitJL = LOG(MAX(g/(1 + j*j), payoff_floor) / MAX(m + q*f + c*p, payoff_floor))
  END FUNCTION fitJL
  
  DOUBLE PRECISION FUNCTION fitJP(p,f,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: p,f,j
    fitJP = LOG(MAX(g/(1 + j*j), payoff_floor) / MAX(m + q*f + c*p, payoff_floor))
  END FUNCTION fitJP
  
  DOUBLE PRECISION FUNCTION emig(d,toggle,win,wout)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: d,toggle,win,wout
    emig = toggle*d*sig(beta*(wout - win))
  END FUNCTION emig
 
END SUBROUTINE FUNC

! ----------------------------------------------------------------------------------

! The subroutine STPNT() supplies AUTO with the parameter values and state
! variables from which continuation begins. 
!
! Inputs:
! NDIM - Number of state variables in the ODE system. For this model,
!        NDIM = 6.
!
! T    - Time supplied by AUTO. The model is autonomous, so STPNT receives T
!        but does not use it.
!
! Inputs / outputs:
! PAR  - Model parameter vector. STPNT assigns the default values PAR(1:18).
!
! Outputs:
! U    - Initial equilibrium state returned to AUTO:
!        U(1) = PL = 0, predator in littoral habitat
!        U(2) = FL, equilibrium forager density in littoral habitat
!        U(3) = JL = 0, juvenile in littoral habitat
!        U(4) = PP = 0, predator in pelagic habitat
!        U(5) = FP, equilibrium forager density in pelagic habitat
!        U(6) = JP = 0, juvenile in pelagic habitat


SUBROUTINE STPNT(NDIM,U,PAR,T) 
  ! Overrides the default implicit typing rules for names.
  IMPLICIT NONE

  ! Declaration of inputs / outputs
  INTEGER, INTENT(IN) :: NDIM
  DOUBLE PRECISION, INTENT(OUT) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: T

  ! Values read from experiment_parameters.dat - this is a temporary output file 
  DOUBLE PRECISION :: input_deltar,input_deltas,input_movement

  ! Newton and Jocobian variables
  DOUBLE PRECISION :: x,y,h,f1,f2,f1x,f2x,f1y,f2y,j11,j12,j21,j22,det,dx,dy
  DOUBLE PRECISION :: rL,rP,fitL,fitP,emigLP,emigPL
  INTEGER :: iter,ios
  CHARACTER(LEN=256) :: input_line

  ! Initialize optional inputs before attempting to read the parameter file.
  input_deltar=0.D0
  input_deltas=0.D0
  input_movement=-1.D0 ! A negative movement value indicates that the default rates should be kept.


  ! Attempts to open the file 'experiment_parameters.dat" (temporary file)
  ! STATUS = 'OLD' : requires the file to already exist
  ! IOSTAT=ios : prevents a missing file from immediately terminating the program
  OPEN(99,FILE='experiment_parameters.dat',STATUS='OLD',IOSTAT=ios)
  IF (ios.EQ.0) THEN
    READ(99,'(A)',IOSTAT=ios) input_line
    CLOSE(99)
    IF (ios.EQ.0) THEN
      READ(input_line,*,IOSTAT=ios) input_deltar,input_deltas,input_movement
      IF (ios.NE.0) THEN
        input_movement=-1.D0 ! 
        READ(input_line,*) input_deltar,input_deltas
      END IF
    END IF
  END IF

  ! Default model parameters
  PAR(1)  = 0.40D0    ! r       | 0.40  | intrinsic growth rate for forager 
  PAR(2)  = 0.05D0    ! a       | 0.05  | baseline predator attack-rate coefficient
  PAR(3)  = 0.10D0    ! m       | 0.10  | mortality rate
  PAR(4)  = 0.06D0    ! b       | 0.06  | forager density-dependence coefficient
  PAR(5)  = 0.005D0   ! s       | 0.005 | predation saturation coefficient
  PAR(6)  = 0.10D0    ! e       | 0.10  | forager conversion efficiency
  PAR(7)  = 1.00D0    ! fec     | 1.00  | predator fecundity
  PAR(8)  = 0.30D0    ! g       | 0.30  | maximum juvenile maturation rate
  PAR(9)  = 0.15D0    ! q       | 0.15  | juvenile-forager interaction rate
  PAR(10) = 0.02D0    ! c       | 0.02  | juvenile-predator interaction rate
  PAR(11) = 0.00D0    ! Reserved for AUTO-07p
  PAR(12) = 0.50D0    ! dF      | 0.50  | forager dispersal rate
  PAR(13) = 0.50D0    ! dJ      | 0.50  | juvenile dispersal rate
  PAR(14) = 0.00D0    ! mu      | 0.00  | fishing effort 
  PAR(15) = 0.00D0    ! deltar  | 0.00  | variation in productivity
  PAR(16) = 0.00D0    ! deltas  | 0.00  | variation in attack rate
  PAR(17) = 0.25D0    ! beta    | 0.25  | combined movement fitness sensitivity
  PAR(18) = 1.00D0    ! toggle  | 1 (on)| enable movement; 1 (on) and 0 (off)
  PAR(19) = 0.50D0    ! dP      | 0.50  | predator dispersal rate

  ! Copies the file's producitivty contrast into PAR(15) and PAR(16) respectively
  ! but only if its magnitude exceeds 10e-14. 
  IF (ABS(input_deltar).GT.1.0D-14) PAR(15)=input_deltar
  IF (ABS(input_deltas).GT.1.0D-14) PAR(16)=input_deltas
  IF (input_movement.GE.0.D0) THEN !Checks whether a valid movement override was supplied.
  ! Read optional experiment settings from the temporary parameter file.
  ! First try the current three-value format: deltar, deltas, movement.
  ! If only two values are present, set movement to -1, meaning “not specified.”
  ! A missing file also leaves movement at -1, so the default rates are kept.
    PAR(19)=input_movement
    PAR(12)=input_movement
    PAR(13)=input_movement
  END IF

  ! Set predators and juveniles to zero, then initialize the two forager
  ! densities at their habitat-specific carrying capacities. These values
  ! are the exact predator-free equilibrium when net movement is zero and
  ! provide the initial guess for the coupled equilibrium otherwise.
  U(1:NDIM)=0.D0 ! Sets every state variable to zero
  rL=PAR(1)*(1.D0-PAR(15)) ! computes littoral intrinsic growth
  rP=PAR(1)*(1.D0+PAR(15)) ! computes pelagic intrinsic growth
  x=MAX(rL/PAR(4),1.0D-8)  ! initializes littoral density using the sinle-habitat positive logistic equilibrium
  y=MAX(rP/PAR(4),1.0D-8)  ! initializes pelagic density using the sinle-habitat positive logistic equilibrium
  h=1.0D-6 ! Sets the forward finite-difference increment used to estimate the Jacobian

  ! NEWTON ITERATION
  ! Begins a loop of at most 30 Newton iterations
  DO iter=1,30
    ! Computes simplified littoral forager per-capita growth 
    fitL=rL-PAR(4)*x 
    fitP=rP-PAR(4)*y
    ! Computes the per-capita movement rate
    emigLP=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitP-fitL)))
    emigPL=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitL-fitP)))
    ! Computes residuals
    f1=rL*x-PAR(4)*x*x-emigLP*x+emigPL*y
    f2=rP*y-PAR(4)*y*y-emigPL*y+emigLP*x
    IF (MAX(ABS(f1),ABS(f2)).LT.1.0D-12) EXIT ! tests residual convergence using the infinity norm
    
    ! Slightly perturb each density to estimate how both residuals respond.
    ! These finite-difference slopes form the Jacobian used by Newton’s method.

    ! Perturb the littoral density
    fitL=rL-PAR(4)*(x+h)
    fitP=rP-PAR(4)*y
    emigLP=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitP-fitL)))
    emigPL=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitL-fitP)))
    f1x=rL*(x+h)-PAR(4)*(x+h)*(x+h)-emigLP*(x+h)+emigPL*y
    f2x=rP*y-PAR(4)*y*y-emigPL*y+emigLP*(x+h)

    ! Perturb the pelagic density
    fitL=rL-PAR(4)*x
    fitP=rP-PAR(4)*(y+h)
    emigLP=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitP-fitL)))
    emigPL=PAR(12)*PAR(18)/(1.D0+EXP(-PAR(17)*(fitL-fitP)))
    f1y=rL*x-PAR(4)*x*x-emigLP*x+emigPL*(y+h)
    f2y=rP*(y+h)-PAR(4)*(y+h)*(y+h)-emigPL*(y+h)+emigLP*x

    ! Use the estimated Jacobian to calculate density corrections that move
    ! both residuals toward zero, then repeat until the equilibrium is accurate.

    ! Jacobian 
    j11=(f1x-f1)/h
    j21=(f2x-f2)/h
    j12=(f1y-f1)/h
    j22=(f2y-f2)/h
    det=j11*j22-j12*j21
    IF (ABS(det).LT.1.0D-14) EXIT
    dx=(-f1*j22+j12*f2)/det
    dy=(j21*f1-j11*f2)/det
    x=MAX(x+dx,1.0D-8)
    y=MAX(y+dy,1.0D-8)
    IF (MAX(ABS(dx),ABS(dy)).LT.1.0D-12) EXIT
  END DO

  ! Store the converged forager densities in AUTO's state vector. All other
  ! state variables remain zero from the initialization above.
  U(2)=x
  U(5)=y
END SUBROUTINE STPNT

! declared but not used (see 'c.common_model' for details)
SUBROUTINE BCND(NDIM,PAR,ICP,NBC,U0,U1,FB,IJAC,DBC)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,NBC,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: U0(NDIM),U1(NDIM)
  DOUBLE PRECISION, INTENT(OUT) :: FB(*)
  DOUBLE PRECISION, INTENT(INOUT) :: DBC(*)
END SUBROUTINE BCND

! declared but not used (see 'c.common_model' for details)
SUBROUTINE ICND(NDIM,PAR,ICP,NINT,U,UOLD,UDOT,UPOLD,FI,IJAC,DINT)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,NINT,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM),UOLD(NDIM),UDOT(NDIM),UPOLD(NDIM)
  DOUBLE PRECISION, INTENT(OUT) :: FI(*)
  DOUBLE PRECISION, INTENT(INOUT) :: DINT(*)
END SUBROUTINE ICND

! declared but not used (see 'c.common_model' for details)
SUBROUTINE FOPT(NDIM,U,ICP,PAR,IJAC,FS,DFDU,DFDP)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(OUT) :: FS
  DOUBLE PRECISION, INTENT(INOUT) :: DFDU(*),DFDP(*)
END SUBROUTINE FOPT

! declared but not used (see 'c.common_model' for details)
SUBROUTINE PVLS(NDIM,U,PAR)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
END SUBROUTINE PVLS
