function [x, y, elev, sstr]= linfrm_rawimg(ncr, settings)
% LINFR_RAWMIMG uses the first increasing return in each angular scan to
% define a line approximating the seafloor
%  inputs: the open netdcf object for the raw file and settings
% settings is a structure and should contain these things:
%   1) tidx- the time index of the first dimension of ncr (1-4_
%   2) thold- threshold of size of (diff) to use in peak detection
%   3) rot2compass- value needed to get up as North in the plot
%   4) Pencil_tilt- value needed to adjust first and last scans to =
%   5) detrend - true if you want to try the detrending - experimental
%   6) blank_points - number of points to skip at beginning of each sample
%   (> 50)- low signal may need to push this value to ~100
% autonan must be on before ncr was opened
%
%  outputs: x,y = positions along the sweep
%	    elev = height of the seafloor for that xdist
%	    sstr = value of the maximum for the elevantion
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
if isfield(settings,'Pencil_tilt')
    tilt=settings.Pencil_tilt;
else
    tilt=0;
end
if isfield(settings,'blank_points')
    blank=settings.blank_points;
else
    blank=50;      % default is don't detrend
end

%contains: (time, number_rotations, npoints, nscans)
 szs = ncsize(ncr{'raw_image'});
%
%Note the last headangle and data point is NG, so that dimension needs to be -1

% alternate method trying to get the first part of the peak 
%for hh=1:szs(2)
%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncr{'raw_image'});
Ro=.12; % distance (m) from axis of rotation to head
hdangle=ncr{'headangle'}(tidx,:,:)+ tilt;
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
        first_hi_val=find(diff(ncr{'raw_image'}(tidx,iAz,blank:end,jj) > thold),1,'first');
        nn=1;       %set counter for cahnging the threshold, in case it's needed
        while( first_hi_val+blank > 350)
            temp_thold=thold-nn;
            first_hi_val=find(diff(ncr{'raw_image'}(tidx,iAz,blank:end,jj) > temp_thold),1,'first');
            nn=nn+1;
        end   
        maxval=max(ncr{'raw_image'}(tidx,iAz,blank:end,jj));
        if (isempty(first_hi_val))
            scan_surfval(jj)=1;
            sstr(knt,jj)=1;
        else
            scan_surfval(jj)=first_hi_val+blank;
            sstr(knt,jj)=ncr{'raw_image'}(tidx,iAz,first_hi_val+blank,jj);
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

  %now remove everything greater than 2 std_devs of the median
    %mn_el=gmean(elev);
    std_el=gstd(elev(iAz,:));
    med_el=gmedian(elev(iAz,:));
       gd_lims=[-med_el-(2*std_el) -med_el+(2*std_el)];
    % this gets rid primarily of tripod beam, but may want to not filter elev
    ng_idx=find(-elev(iAz,:) < gd_lims(1) | -elev(iAz,:) > gd_lims(2));
    if ~isempty(ng_idx)
     elev(iAz,ng_idx)=NaN; 
    end
 
 end      
