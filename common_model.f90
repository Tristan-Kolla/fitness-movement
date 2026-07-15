SUBROUTINE FUNC(NDIM,U,ICP,PAR,IJAC,F,DFDU,DFDP)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM, IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(OUT) :: F(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: DFDU(NDIM,*), DFDP(NDIM,*)
  DOUBLE PRECISION :: PL,FL,JL,PP,FP,JP
  DOUBLE PRECISION :: r,a,mP,mJ,bL,sL,bP,sP
  DOUBLE PRECISION :: eL,eP,fecL,fecP,gL,gP,qL,qP
  DOUBLE PRECISION :: cL,cP,dP,dF,dJ,alphaP,alphaF,alphaJ
  DOUBLE PRECISION :: omegap,omegaf,omegaj,mu,deltar,deltas,beta,toggle
  DOUBLE PRECISION :: rL,rP,aP,aL
  PL=U(1)
  FL=U(2)
  JL=U(3)
  PP=U(4)
  FP=U(5)
  JP=U(6)
  r=PAR(1)
  a=PAR(2)
  mP=PAR(3)
  mJ=PAR(4)
  bL=PAR(5)
  sL=PAR(6)
  bP=PAR(7)
  sP=PAR(8)
  eL=PAR(9)
  eP=PAR(10)
  fecL=PAR(11)
  fecP=PAR(12)
  gL=PAR(13)
  gP=PAR(14)
  qL=PAR(15)
  qP=PAR(16)
  cL=PAR(17)
  cP=PAR(18)
  dP=PAR(19)
  dF=PAR(20)
  dJ=PAR(21)
  alphaP=PAR(22)
  alphaF=PAR(23)
  alphaJ=PAR(24)
  omegap=PAR(25)
  omegaf=PAR(26)
  omegaj=PAR(27)
  mu=PAR(28)
  deltar=PAR(29)
  deltas=PAR(30)
  beta=PAR(31)
  toggle=PAR(32)
  rL = r + deltar
  rP = r - deltar
  aP = a + deltas
  aL = a - deltas
  F(1) = maturation(gL,JL) - (mP+mu)*PL - emig(dP,toggle,alphaP, fitPL(FL,PL,JL), &
    & fitPP(FP,PP,JP))*PL + emig(dP,toggle,alphaP, fitPP(FP,PP,JP), fitPL(FL,PL,JL))*PP
  F(2) = logistic(rL,bL,FL) - type3(aL,PL,FL,sL) + type1(eL*qL,FL,JL) - emig(dF,toggle,alphaF, &
    & fitFL(FL,PL,JL), fitFP(FP,PP,JP))*FL + emig(dF,toggle,alphaF, fitFP(FP,PP,JP), &
    & fitFL(FL,PL,JL))*FP
  F(3) = fecL*PL - maturation(gL,JL) - mJ*JL - type1(qL,FL,JL) - type1(cL,PL,JL) - &
    & emig(dJ,toggle,alphaJ, fitJL(PL,FL,JL), fitJP(PP,FP,JP))*JL + emig(dJ,toggle,alphaJ, &
    & fitJP(PP,FP,JP), fitJL(PL,FL,JL))*JP
  F(4) = maturation(gP,JP) - (mP+mu)*PP - emig(dP,toggle,alphaP, fitPP(FP,PP,JP), &
    & fitPL(FL,PL,JL))*PP + emig(dP,toggle,alphaP, fitPL(FL,PL,JL), fitPP(FP,PP,JP))*PL
  F(5) = logistic(rP,bP,FP) - type3(aP,PP,FP,sP) + type1(eP*qP,FP,JP) - emig(dF,toggle,alphaF, &
    & fitFP(FP,PP,JP), fitFL(FL,PL,JL))*FP + emig(dF,toggle,alphaF, fitFL(FL,PL,JL), &
    & fitFP(FP,PP,JP))*FL
  F(6) = fecP*PP - maturation(gP,JP) - mJ*JP - type1(qP,FP,JP) - type1(cP,PP,JP) - &
    & emig(dJ,toggle,alphaJ, fitJP(PP,FP,JP), fitJL(PL,FL,JL))*JP + emig(dJ,toggle,alphaJ, &
    & fitJL(PL,FL,JL), fitJP(PP,FP,JP))*JL
  RETURN
CONTAINS
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
    fitFL = (rL - bL*f) - (aL*p*f)/(1 + sL*f*f) + eL*qL*j
  END FUNCTION fitFL
  DOUBLE PRECISION FUNCTION fitFP(f,p,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: f,p,j
    fitFP = (rP - bP*f) - (aP*p*f)/(1 + sP*f*f) + eP*qP*j
  END FUNCTION fitFP
  DOUBLE PRECISION FUNCTION fitJL(p,f,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: p,f,j
    fitJL = (gL/(1 + j*j)) - qL*f - cL*p
  END FUNCTION fitJL
  DOUBLE PRECISION FUNCTION fitJP(p,f,j)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: p,f,j
    fitJP = (gP/(1 + j*j)) - qP*f - cP*p
  END FUNCTION fitJP
  DOUBLE PRECISION FUNCTION emig(d,toggle,alpha,win,wout)
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(IN) :: d,toggle,alpha,win,wout
    emig = toggle*d*(sig(beta*alpha*(wout - win)))
  END FUNCTION emig
END SUBROUTINE FUNC

SUBROUTINE STPNT(NDIM,U,PAR,T)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM
  DOUBLE PRECISION, INTENT(OUT) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: T
  DOUBLE PRECISION :: input_deltar,input_deltas
  DOUBLE PRECISION :: x,y,h,f1,f2,f1x,f2x,f1y,f2y,j11,j12,j21,j22,det,dx,dy
  DOUBLE PRECISION :: rL,rP,fitL,fitP,emigLP,emigPL
  INTEGER :: iter,ios

  input_deltar=0.D0
  input_deltas=0.D0
  OPEN(99,FILE='experiment_parameters.dat',STATUS='OLD',IOSTAT=ios)
  IF (ios.EQ.0) THEN
    READ(99,*) input_deltar,input_deltas
    CLOSE(99)
  END IF

  PAR(1:40)=0.D0
  PAR(1)=4.0000000000000002D-01
  PAR(2)=5.0000000000000003D-02
  PAR(3)=1.0000000000000001D-01
  PAR(4)=1.0000000000000001D-01
  PAR(5)=5.9999999999999998D-02
  PAR(6)=5.0000000000000001D-03
  PAR(7)=5.9999999999999998D-02
  PAR(8)=5.0000000000000001D-03
  PAR(9)=1.0000000000000001D-01
  PAR(10)=1.0000000000000001D-01
  PAR(11)=1.0000000000000000D+00
  PAR(12)=1.0000000000000000D+00
  PAR(13)=2.0000000000000001D-01
  PAR(14)=2.0000000000000001D-01
  PAR(15)=2.0000000000000001D-01
  PAR(16)=2.0000000000000001D-01
  PAR(17)=2.0000000000000000D-02
  PAR(18)=2.0000000000000000D-02
  PAR(19)=1.0000000000000001D-01
  PAR(20)=1.0000000000000001D-01
  PAR(21)=1.0000000000000001D-01
  PAR(22)=2.5000000000000000D-01
  PAR(23)=2.5000000000000000D-01
  PAR(24)=2.5000000000000000D-01
  PAR(25)=1.0000000000000000D-02
  PAR(26)=1.0000000000000000D-02
  PAR(27)=1.0000000000000000D-02
  PAR(28)=0.0000000000000000D+00
  PAR(29)=0.0000000000000000D+00
  PAR(30)=0.0000000000000000D+00
  PAR(31)=0.0000000000000000D+00
  PAR(32)=1.0000000000000000D+00

  IF (ABS(input_deltar).GT.1.0D-14) PAR(29)=input_deltar
  IF (ABS(input_deltas).GT.1.0D-14) PAR(30)=input_deltas

  U(1:NDIM)=0.D0
  rL=PAR(1)+PAR(29)
  rP=PAR(1)-PAR(29)
  x=MAX(rL/PAR(5),1.0D-8)
  y=MAX(rP/PAR(7),1.0D-8)
  h=1.0D-6

  DO iter=1,30
    fitL=rL-PAR(5)*x
    fitP=rP-PAR(7)*y
    emigLP=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitP-fitL)))
    emigPL=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitL-fitP)))
    f1=rL*x-PAR(5)*x*x-emigLP*x+emigPL*y
    f2=rP*y-PAR(7)*y*y-emigPL*y+emigLP*x
    IF (MAX(ABS(f1),ABS(f2)).LT.1.0D-12) EXIT

    fitL=rL-PAR(5)*(x+h)
    fitP=rP-PAR(7)*y
    emigLP=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitP-fitL)))
    emigPL=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitL-fitP)))
    f1x=rL*(x+h)-PAR(5)*(x+h)*(x+h)-emigLP*(x+h)+emigPL*y
    f2x=rP*y-PAR(7)*y*y-emigPL*y+emigLP*(x+h)

    fitL=rL-PAR(5)*x
    fitP=rP-PAR(7)*(y+h)
    emigLP=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitP-fitL)))
    emigPL=PAR(20)*PAR(32)/(1.D0+EXP(-PAR(31)*PAR(23)*(fitL-fitP)))
    f1y=rL*x-PAR(5)*x*x-emigLP*x+emigPL*(y+h)
    f2y=rP*(y+h)-PAR(7)*(y+h)*(y+h)-emigPL*(y+h)+emigLP*x

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

  U(1)=0.D0
  U(2)=x
  U(3)=0.D0
  U(4)=0.D0
  U(5)=y
  U(6)=0.D0
END SUBROUTINE STPNT

SUBROUTINE BCND(NDIM,PAR,ICP,NBC,U0,U1,FB,IJAC,DBC)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,NBC,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: U0(NDIM),U1(NDIM)
  DOUBLE PRECISION, INTENT(OUT) :: FB(*)
  DOUBLE PRECISION, INTENT(INOUT) :: DBC(*)
END SUBROUTINE BCND

SUBROUTINE ICND(NDIM,PAR,ICP,NINT,U,UOLD,UDOT,UPOLD,FI,IJAC,DINT)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,NINT,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM),UOLD(NDIM),UDOT(NDIM),UPOLD(NDIM)
  DOUBLE PRECISION, INTENT(OUT) :: FI(*)
  DOUBLE PRECISION, INTENT(INOUT) :: DINT(*)
END SUBROUTINE ICND

SUBROUTINE FOPT(NDIM,U,ICP,PAR,IJAC,FS,DFDU,DFDP)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM,IJAC
  INTEGER, INTENT(IN) :: ICP(*)
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
  DOUBLE PRECISION, INTENT(OUT) :: FS
  DOUBLE PRECISION, INTENT(INOUT) :: DFDU(*),DFDP(*)
END SUBROUTINE FOPT

SUBROUTINE PVLS(NDIM,U,PAR)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: NDIM
  DOUBLE PRECISION, INTENT(IN) :: U(NDIM)
  DOUBLE PRECISION, INTENT(INOUT) :: PAR(*)
END SUBROUTINE PVLS
