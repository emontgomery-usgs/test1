function [x, y, elev, sstr]= linfrm_rawimg(ncr, settings)
% LINFR_RAWMIMG uses the first increasing return in each angular scan to
% define a line approximating the seafloor
%  inputs: the open netdcf object for the raw file and settings
% settings is a structure and must contain 3 things:
%   1) tidx- the time index of the first dimension of ncr (1-4_
%   2) thold- threshold of size of (diff) to use in peak detection
%   3) rot2compass- value needed to get up as North in the plot
% autonan must be on before ncr was opened
%
%  outputs: xdist position along the sweep
%	    elevation = height of the seafloor for that xdist
%	    sstrn = value of the maximum for the elevantion
%
%  This is a work in progress aimed at resolving ripples
% emontgomery@usgs.gov   Sept.21, 2009

% use settings to set indices etc.- set defaults otherwise
if isfield(settings,'tidx')
    tidx=settings.tidx;
else
    tidx=1;
end
if isfield(settings,'thold')
    thold=settings.thold;
else
    thold=5;
end
if isfield(settings,'rot2compass')
    rot2compass=settings.rot2compass;
else
    rot2compass=0;
end
%contains: (time, number_rotations, npoints, nscans)
 szs = ncsize(ncr{'raw_image'});
%
%Note the last headangle and data point is NG, so that dimension needs to be -1

% alternate method trying to get the first part of the peak 
%for hh=1:szs(2)
%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncr{'raw_image'});
Ro=.05; % distance (m) from axis of rotation to head
hdangle=ncr{'headangle'}(tidx,:,:);
meters_per_point=1/(szs(3)/ncr.Range(:));
  alpha = ncr{'azangle'}(tidx,:)+settings.rot2compass; % the azimuth rotation angle, [nAz] positions, on x-y plane
  alpha = alpha.*(pi/180); % convert to radians

%
% pre-allocate
x=ones(szs(2),szs(4)-1); y=ones(szs(2),szs(4)-1); elev=ones(szs(2),szs(4)-1); sstr=ones(szs(2),szs(4)-1);
% alternate method trying to get the first part of the peak
%iAz=1;   % for now- will want to do all the rotations eventually
for iAz=1:szs(2)
for jj=1:szs(4)-1
    % Note the last headangle and data point is NG, so that dimension needs to be -1
    first_hi_val=find(diff(ncr{'raw_image'}(tidx,iAz,50:end,jj) > thold),1,'first');
    maxval=max(ncr{'raw_image'}(tidx,iAz,50:end,jj));
    if (isempty(first_hi_val))
        scan_surfval(jj)=1;
        sstr(iAz,jj)=1;
    else
        scan_surfval(jj)=first_hi_val+50;
        sstr(iAz,jj)=maxval;
    end
end
  if iAz==1
    minidx=szs(4)/2-5; maxidx=szs(4)/2+5;
    A=median(scan_surfval(minidx:maxidx))*meters_per_point; 
  end
  hdang=hdangle(iAz,1:szs(4)-1);
  beta = hdang.*(pi/180); % convert to radians
  m = A.*tan(beta); % horizontal distance from sweep apex to measurement M
  gamma = atan(m./Ro); % angle between points A and M
  elev(iAz,1:szs(4)-1) = (scan_surfval(1:szs(4)-1)*meters_per_point).*cos(beta(1:1:szs(4)-1)); % measured distance from apex A to bed
  x(iAz,:) = sqrt(m.^2+Ro.^2).*sin(gamma+alpha(iAz));
  y(iAz,:) = sqrt(m.^2+Ro.^2).*cos(gamma+alpha(iAz));
  %clf
  %plot(x(iAz,:), -elev(iAz,:))
  clear scan_surfval beta gamma hdang

  %now remove everything greater than 3 std_devs of the mean
    %mn_el=gmean(elev);
    std_el=gstd(elev(iAz,:));
    med_el=gmedian(elev(iAz,:));
       gd_lims=[-med_el-(2*std_el) -med_el+(2*std_el)];
    % this gets rid primarily of tripod beam, but may want to change
    ng_idx=find(-elev(iAz,:) < gd_lims(1) | -elev(iAz,:) > gd_lims(2));
    if ~isempty(ng_idx)
     elev(iAz,ng_idx)=NaN; 
    end
     %figure
   %   hold on  %overplot on original
   % plot(x(iAz,:),-elev(iAz,:),'r.')
   %    title(['seafloor extracted from raw image: rot step ' num2str(iAz) ', range setting= ' num2str(ncr.Range(:))])
   %    xlabel('horizontal distance along seafloor(m)')
   %    ylabel('depth(m)')
   %    grid on
   %    axis ([-2.5 2.5 -.9 -.5])
   %    hold off
end      
       % this is how to use the maximum of each scan after interpolation onto
% cartesian. I don't think this is as good as selecting the beginning of the upswing
% 
%zz=max(imi);  % imi from plotrange_cdf, plottype=3d_frm_img                     
%  for ik=1:length(zz)
%   if ~isnan(zz(ik))
%    nn=find(imi(:,ik)==zz(ik),1,'first');
%   else
%    nn=1;
%   end
%  ly(ik)=nn;
%  end
 