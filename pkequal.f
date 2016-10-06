      program pkequal   
      implicit none
      integer na,namax
      parameter(namax=10000)
      double precision aa(namax),deltaa(namax)
      double precision sigma8
      common/sig8/sigma8
      integer nzmax,nze,i
      parameter(nzmax=1000)
      double precision ze(nzmax),deltae(nzmax),taue(nzmax)
      common/zpke/ze,nze
      double precision a,a0,aini,tol
      parameter(a0=1.d0,aini=1.d-3,tol=1.d-8)
      double precision tau,error,dfact,deltaz,deltaz0,deltaez0,norm
      double precision omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      common/parm/omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      double precision dtauda,rombint
      external dtauda
      call setup
      call jeans(aa,deltaa,na)
      do i=1,nze
         a=1.d0/(1.d0+ze(i))
         taue(i)=rombint(dtauda,aini,a,tol)    !compute tau(z)
         call linpol(aa,deltaa,na,a,deltae(i)) !compute delta(z)
      enddo       
      call linpol(aa,deltaa,na,a0,deltaez0)
c     find w(z) constant 
      wa=0.d0
      write(*,*)'---------------------------------'
      write(*,*)' redshift    w_eq    sigma_8,eq'
      write(*,*)'---------------------------------'
      open(10,file='z_w_s8.txt',status='unknown')
      do i=nze,1,-1
         a=1.d0/(1.d0+ze(i))
 50      tau=rombint(dtauda,aini,a,tol)          
         error=(1.d0-tau/taue(i))
         if (abs(error).gt.tol) then
            w0=w0*(1+error)**10.d0
            goto 50
         endif      
c        find sigma8(z=0)    
         call jeans(aa,deltaa,na)
         call linpol(aa,deltaa,na,a,deltaz)
         call linpol(aa,deltaa,na,a0,deltaz0)
         norm=sigma8/deltaez0
         dfact=norm*deltaz0/deltaz
c        output
         write(*,60)ze(i),w0,deltae(i)*dfact    
         write(10,60)ze(i),w0,deltae(i)*dfact         
      enddo
      close(10)
  60  format(f10.5,f10.5,f10.5)
      write(*,*)'---------------------------------'
      stop
      end 
c     ------------------------------------------------------------------      
      subroutine jeans(aa,deltaa,itime)
      implicit none
      integer itime,namax,nvar,nw,ind,nout
      double precision tol,ak
      parameter(nvar=3,nw=nvar,namax=10000,tol=1.0d-8)
      double precision c(24),w(nw,9)
      double precision y(nvar)
      double precision aa(namax),deltaa(namax)
      double precision astart,amax
      double precision dtau,dtau1,dtau2,tau,taustart,taumax,tauend
      double precision dtauda,rombint
      double precision omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      common/parm/omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      external dtauda,rombint,derivs
      ak=1.d0
      astart=tol
      amax=1.d0
      taustart=rombint(dtauda,0.0d0,astart,tol)
      taumax=rombint(dtauda,0.0d0,amax,tol)
      call initial(astart,y)
      tau=taustart
      ind=1
      nout=10
      do itime=1,1000000      
         dtau1=10.0d0/ak
         dtau2=1.0d0*tau
         dtau=min(dtau1,dtau2)
         tauend=min(tau+dtau,taumax)
         call dverk(nvar,derivs,tau,y,tauend,tol,ind,c,nw,w)
         aa(itime)=y(1)
         deltaa(itime)=y(2)
         if (tau.eq.taumax) goto 30
      enddo
 30   continue
      return
      end
c     ------------------------------------------------------------------
      subroutine derivs(n,x,y,yprime)
      implicit none
      integer n
      double precision x,y(n),yprime(n)
      double precision dtauda,a,delta,deltadot,dota
      double precision omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      common/parm/omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      a=y(1)
      delta=y(2)
      deltadot=y(3)
      dota=1.d0/dtauda(a)
      yprime(1)=dota
      yprime(2)=deltadot
      yprime(3)=-dota/a*deltadot+grhom*(omegac+omegab)*delta/2.d0/a
      return
      end
c     ------------------------------------------------------------------
      subroutine initial(x,y)
      implicit none
      integer nvar
      parameter(nvar=3)
      double precision x,y(nvar)
      double precision a,delta,deltadot,aeq,dtauda
      common/mrequiv/aeq
      a=x
      delta=1.d0
      deltadot=delta/dtauda(a)/(a+aeq/1.5d0)
      y(1)=a 
      y(2)=delta
      y(3)=deltadot
      return
      end
c     ------------------------------------------------------------------
      function dtauda(a)         
      implicit none
      double precision dtauda,a,grho2
      double precision omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      common/parm/omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
c     8*pi*G*rho*a**4
      grho2=grhom*(omegac+omegab)*a+grhog+grhor*nnur+
     &   grhom*omegav*a**(1.d0-3.d0*w0-3.d0*wa)*exp(3.d0*wa*(a-1.d0))
      dtauda=sqrt(3.0d0/grho2)
      return
      end            
c     ------------------------------------------------------------------
      subroutine setup
      implicit none
      double precision pi,c,G,sigma_boltz,Mpc
      parameter(pi=3.1415926535897932384626433832795)
      parameter(c=2.99792458e8)          ! m s^-1
      parameter(G=6.6738e-11)            ! m^3 kg^-1 s^-2  
      parameter(sigma_boltz=5.670373e-8) ! J m^-2 s^-1 k^-4 
      parameter(Mpc=3.08567758149e22)    ! m
      double precision H0,tcmb,omegag,omegar
      double precision omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      common/parm/omegab,omegac,omegav,w0,wa,grhom,grhog,grhor,nnur
      double precision ombh2,omch2,h2
      double precision aeq
      common/mrequiv/aeq
      double precision sigma8
      common/sig8/sigma8
      integer nzmax,nze,i
      parameter(nzmax=1000)
      double precision ze(nzmax)
      common/zpke/ze,nze
      write(*,*)'enter H0, Tcmb, N_eff (e.g. 67.31 2.7255 3.13)'
      read(*,*)H0,tcmb,nnur
      write(*,*)'enter Omega_b*h^2, Omega_c*h^2 (e.g. 0.02222 0.1197)'
      read(*,*)ombh2,omch2
      write(*,*)'enter w0, wa (e.g. -1.0, -0.8)'
      read(*,*)w0,wa   
      write(*,*)'Enter sigma_8 (e.g. 0.829)'
      read(*,*)sigma8
      write(*,*)'Enter # of redshift for equivalence (e.g. 10)'
      read(*,*)nze
      write(*,*)'Enter redshift (e.g. 10 7 5 3 2.2 1.5 1 0.7 0.35 0)' 
      read(*,*),(ze(i),i=1,nze)
      grhom=3.d0*H0**2.d0/c**2.d0*1000.d0**2.d0                    !3*H0^2
      grhog=8.d0*pi*G/c**2.d0*4.d0*sigma_boltz/c**3.d0*tcmb**4.d0* !photons
     &     Mpc**2.d0                                                   
      grhor = 7.d0/8*(4.d0/11.d0)**(4.d0/3.d0)*grhog               !neutrinos    
      h2=H0*H0/10000
      omegag=grhog/grhom                      !photons
      omegar=grhor*nnur/grhom                 !neutrinos
      omegab=ombh2/h2                         !baryons 
      omegac=omch2/h2                         !cold dark matter 
      omegav=1.d0-omegac-omegab-omegar-omegag !dark energy
      aeq=(grhog+grhor*nnur)/grhom/(omegac+omegab)
      write(*,*)'---------------------------------'
      write(*,*)'Omega_de =',omegav  
      write(*,*)'Omega_c  =',omegac
      write(*,*)'Omega_b  =',omegab    
      write(*,*)'Omega_g  =',omegag
      write(*,*)'Omega_nu =',omegar 
      write(*,*)'z_eq =',1.d0/aeq-1
      write(*,*)'---------------------------------'
      return
      end
c     ------------------------------------------------------------------
      subroutine linpol(xa,ya,n,x,y)
      implicit none
      integer i,n
      double precision xa(n),ya(n),x,y
      if ((x.lt.xa(1)).or.(x.gt.xa(n))) write(*,*)'out of range'
      do i=1,n
         if (x.le.xa(i)) goto 10 
      enddo
 10   continue
      y=(ya(i)-ya(i-1))/(xa(i)-xa(i-1))*(x-xa(i-1))+ya(i-1)
      return
      end
c     ------------------------------------------------------------------
