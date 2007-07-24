%script plot_az_imgscans
%
% a script to view the images from the azimuth drive
%  There are 60 sweeps, each offset by 3 degrees from the previous
%
% these must be run first:
%  [PenData, PenHa, PSwa, PAza] = readrangeall; (on S1071317.r02)
%   plt_17r02 (create an output file with the x-y images named s17r02_img)
%   load S17r02_img  (has imgi_mat)
%  EMONTGOMERY 7/24/07
%
% xx and yy are the vectors into which the slant range image was
% interpolated (constant for this file
yy=[.2:.0025:2.2]';
xx=[-3:.0125:3];
for ik=1:60
pcolor(xx,-yy,squeeze(imgi_mat(ik,:,:))); shading flat
text(-3,-.4,['sweep # ' num2str(ik)])
xlabel('distance (m)')
ylabel('depth (m)')
title('Megansett 7/13 P17r02 using azimuth and logger')
pause(1)
end
