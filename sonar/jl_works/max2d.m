function [Xm,Ym,Zm]=max2d(x,y,z,mkplt);
%  [Xm,Ym,Zm]=max2d(x,y,z);
%
%
[Z,I]=max(z);
[ZZ,II]=max(Z);
npoint=2;
xx=x((I(II)-npoint):(I(II)+npoint),(II-npoint):(II+npoint));
yy=y((I(II)-npoint):(I(II)+npoint),(II-npoint):(II+npoint));
zz=z((I(II)-npoint):(I(II)+npoint),(II-npoint):(II+npoint));
%
dx=abs(x(1,2)-x(1,1));
dy=abs(y(1,2)-y(2,2));
%
[xxx,yyy]=meshgrid([xx(1,1):(dx/10):xx(1,end)],[yy(1,1):(dy/10):yy(end,1)]);
%
zzz=griddata(xx,yy,zz,xxx,yyy,'v4');
[Zz,I]=max(zzz);
[ZZz,II]=max(Zz);
if mkplt
 figure; 
 pcolor(xxx,yyy,zzz); shading flat
end
Xm=xxx(I(II),II);
Ym=yyy(I(II),II);
Zm=zzz(I(II),II);
