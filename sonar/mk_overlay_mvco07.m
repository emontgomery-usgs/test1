%script mk_overlay_mvco07
% mk_overlay places a tripod's instruments on a processed fan image to verify 
% orientation is correct.
%  Made for hatteras09 tripod 855 data.  Currently uses a processed file
%  with no rotation of the fan image
% emontgomery   5/15/09

%Get the image, and create variables
ncp=netcdf('8369fan0416_hrproc.cdf');
xx=ncp{'x'}(:); yy=ncp{'y'}(:);
% use the 51st image to go with the first pencil image
sonar_image=ncp{'sonar_image'}(98,1,:,:);
tt=ncp{'time'}(160)+(ncp{'time2'}(160)/86400000);
if (ischar(ncp.magnetic_variation(:)))
  magvar=str2double(ncp.magnetic_variation(:));
else
   magvar=ncp.magnetic_variation(:);
end
close (ncp)
%plot the image to use as a basemap
figure(1)
himage=imagesc(xx,yy,sonar_image,'CDataMapping','scaled');
set(gca,'tickdir','out');
set(gca,'xticklabel',' ');
set(gca,'ydir','Normal');
colormap gray;
axis square
% rotate the tripod and overlay the rotated coordinates on fan image
% remember fan image -180 is the middle of the empty wedge.
% it's a little worrisome the extra 10 is required here???
%fc855rot(-magvar+10,'y');      % the declination is included, so take it out
% 60 seems like a good amount- based on eyeball not measurement
fc836rot('836',75-magvar,'y')
%t836_plot_rot
xlabel('distance (m)')
ylabel('distance (m)')
title (['fan image from ' datestr(gregorian(tt))])

