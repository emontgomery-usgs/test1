% process azimuth 'XYZ' file

% Preliminaries: get data, load into an array called B
fname = input('Input file name:  ', 's');

lnfile = length(fname);
eval(['load ' fname])

namewoext = fname(1:lnfile-4);
if(~isletter(namewoext(1))) 
     namewoext = ['X' namewoext];
end
Aname = strrep(namewoext,'-','_');

eval(['B = ' Aname ';'])

Bsize = size(B);

if(Bsize(2) == 8)
     R = B(:,3);
     thetan = B(:,4).*pi/180;
     phin   = B(:,5).*pi/180;
else
     R = sqrt(B(:,3).^2 + B(:,4).^2 + B(:,5).^2);
     thetan = atan(B(:,3)./B(:,4);
     phin = asin(B(:,5)./R);
end     
goods = find(R>0);
azoffset = 0.085;        % Sonar head mount offset in meters
phioffset = 0.0;         % Sonar head rotation offset in degrees 

azsteps = diff(find(diff(test3)));    % profile points per azimuth step.

phinn = phin(goods) - phioffset.*pi./180;     % apply phi (ordinal) correction

Xtest  = R(goods).*sin(phinn).*cos(thetan) + azoffset.*cos(thetan);
Ytest  = R(goods).*sin(phinn).*sin(thetan) - azoffset.*sin(thetan);

Ztest = -R(goods).*cos(phinn);

% Create 400x400 mesh grid for regridding and 'tinning' data
XIB = min(Xtest):(max(Xtest)-min(Xtest))/400:max(Xtest);
YIB = min(Ytest):(max(Ytest)-min(Ytest))/400:max(Ytest);
[XIIB,YIIB] = meshgrid(XIB,YIB);
ZIB = griddata(Xtest,Ytest,Ztest, XIIB,YIIB);

I = find(ZIB > -0.2);
ZIB(I) = NaN;
IL = find(ZIB < -1.1);
ZIB(IL) = NaN;
ZIBN = medfilt2(ZIB);
surf(XIIB,YIIB,ZIBN)
shading 'flat'
%axis('equal')
colormap 'copper'