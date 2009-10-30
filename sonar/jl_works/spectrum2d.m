function [Kx,Ky,Pxy]=spectrum2d(X,m,n,dx,dy,index)
%
%  function [Kx,Ky,Pxy]=spectrum2d(X,m,n,dx,dy,index)
%
%  Function to estimate the 2-D power spectrum of a 2-D matrix
%  It assigns the correct wavenumbers on the axes.
%
%  INPUTS:   X    =  matrix to be fft-ed (2-D) (size m x n) or greater
%            m,n  =  number if points to be FFTed at each diection
%                    it should be power of 2, (m - corresponds to rows - x direction
%                    while n corresponds to y direction.
%            dx,dy = resolution (in space) the along the x and y directions
%                    the matrix X has been sampled in the x and y directions
%            index = if 1 Pxy is one-sided self preserving spectrum
%                    otherwise it is two-sided self preserving spectrum
%  
%  OUTPUT:   Kx    = wave number in the x - direction
%            Ky    = wave number in the y - direction
%            Pxy   = spectral energy
%
%  Uses: ndetrend.m, fft2.m
%  
%  Uses the method described in: "How to use the MATALB FFT2-routines" by
%  Harald E. Krogstand, NTNU, 2004.
%  http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=11639&objectType=FILE
%
%  v1.2, Sept.,6, 2007
%  Forced DC levels (f=0+/- 1 bin) to zero.
%  v1.1
%  George Voulgaris, April 27, 2007
%
if nargin<6
    index=3;
end
%X           = planefit(XI,YI,ZI);
X           = ndetrend(X,2);
fftransform = fft2(X,m,n);
ESD         = abs(fftransform).^2;
[M,N]       = size(fftransform);
%
%---- Set area around DC to be set to sero
%
Im=[1,2,M];  % 1 is always the zero level, 2 and M are the ones either side
In=[1,2,N];
ESD(Im,In)=ESD(Im,In)*0;
%
%---- Set energy at Nyquist frequency to zero (if M, N even)
%
if mod(M,2)==0; 
    ESD(M/2+1,:)=ESD(M/2+1,:)*0; 
end
if mod(N,2)==0; 
    ESD(:,N/2+1)=ESD(:,N/2+1)*0; 
end
%
%-------------------------------------------------------------------------
% computes the wavenumber values for the fft axes
%-------------------------------------------------------------------------
kx1 = mod(1/2 + (0:(M-1))/M,1)-1/2;
kx  = kx1*(2*pi/dx);
kx  = fftshift(kx);
ky1 = mod(1/2 + (0:(N-1))/N,1)-1/2;
ky  = ky1*(2*pi/dy);
ky  = fftshift(ky);
%
ESD = fftshift(ESD);
if index==1;
  ix=find(kx>=0);
  Kx=kx(ix);
  Ky=ky;
  Pxy=4*ESD(:,ix)/((M*N)^2);  % Self-preserving spectrum 1-sided
else
  Kx=kx;
  Ky=ky;
  Pxy=ESD/((M*N)^2);  % Self-preserving spectrum 2-sided
end
% Uncomment Below if you want to see a plot
% [KX,KY]=meshgrid(kx,ky);
% pcolor(kx,ky,ESD)
% xlabel('Wavenumber (kx)')
% ylabel('Wavenumber (ky)')

