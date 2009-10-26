function [x, y, elev, sstr]= linfrm_rawimg_frstlast(ncr, settings)
% LINFR_RAWMIMG_FRSTLAST uses the first increasing return in each angular scan to
% define a line approximating the seafloor
%  inputs: the open netdcf object for the raw file and settings
% settings is a structure and should contain these things:
%   1) tidx- the time index of the first dimension of ncr (1-4)
%   2) thold- threshold of size of (diff) to use in peak detection (5-15)
%      if data returned is noisy- try a higher threshold
%   3) rot2compass- value needed to get up as North in the plot (0)
%   4) Pencil_tilt- value needed to adjust first and last scans to balance(0)
%   5) detrend - true if you want to try the detrending - experimental
% autonan must be on before ncr was opened
%
%  outputs: x,y = positions on the seafloor relative to azimuth center
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
if isfield(settings,'detrend')
    detrend=settings.detrend;
else
    detrend=0;      % default is don't detrend
end

%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncr{'raw_image'});
%
%Note the last headangle and data point is NG, so that dimension needs to be -1

% alternate method trying to get the first part of the peak
%for hh=1:szs(2)
%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncr{'raw_image'});
Ro=0.0; % distance (m) from axis of rotation to head  (was .12)
hdangle=ncr{'headangle'}(tidx,:,:)+ tilt;
meters_per_point=1/(szs(3)/ncr.Range(:));
alpha = ncr{'azangle'}(tidx,:)+settings.rot2compass; % the azimuth rotation angle, [nAz] positions, on x-y plane
alpha = alpha.*(pi/180); % convert to radians

%
% pre-allocate
% use rotnos=[1:1:60]; to do all rotations in an entire azimuth image- very slow!!
rotnos=[1 60];  % for first and last rotations only- approx 1 hour apart
x=ones(length(rotnos),szs(4)-1); y=ones(length(rotnos),szs(4)-1);
elev=ones(length(rotnos),szs(4)-1); sstr=ones(length(rotnos),szs(4)-1);
% alternate method trying to get the first part of the peak
%iAz=1;   % for now- will want to do all the rotations eventually

knt=1;
for iAz=rotnos
    for jj=1:szs(4)-1
        % Note the last headangle and data point is NG, so that dimension needs to be -1
        first_hi_val=find(diff(ncr{'raw_image'}(tidx,iAz,50:end,jj) > thold),1,'first');
        maxval=max(ncr{'raw_image'}(tidx,iAz,50:end,jj));
        if (isempty(first_hi_val))
            scan_surfval(jj)=1;
            sstr(knt,jj)=1;
        else
            scan_surfval(jj)=first_hi_val+50;
            sstr(knt,jj)=ncr{'raw_image'}(tidx,iAz,first_hi_val+50,jj);
        end
    end
    if iAz==1
        minidx=szs(4)/2-5; maxidx=szs(4)/2+5
        A=median(scan_surfval(minidx:maxidx))*meters_per_point
    end
    hdang=hdangle(iAz,1:szs(4)-1);
    beta = hdang.*(pi/180); % convert to radians
    m = A.*tan(beta); % horizontal distance from sweep apex to measurement M
    gamma = atan(m./Ro); % angle between points A and M
    elev(knt,1:szs(4)-1) = (scan_surfval(1:szs(4)-1)*meters_per_point).*cos(beta(1:1:szs(4)-1)); % measured distance from apex A to bed
    x(knt,:) = sqrt(m.^2+Ro.^2).*sin(gamma+alpha(iAz));
    y(knt,:) = sqrt(m.^2+Ro.^2).*cos(gamma+alpha(iAz));
    %clf
    %plot(x(iAz,:), -elev(iAz,:))
    clear scan_surfval beta gamma hdang
    
    %now remove everything greater than 2 std_devs of the median
    %mn_el=gmean(elev);
    clear ng_idx
    std_el=gstd(elev(knt,:));
    med_el=gmedian(elev(knt,:));
    gd_lims=[-med_el-(2*std_el) -med_el+(2*std_el)];
    % this gets rid primarily of tripod beam, but may want to not filter elev
    ng_idx=find(-elev(knt,:) < gd_lims(1) | -elev(knt,:) > gd_lims(2));
    if ~isempty(ng_idx)
        elev(knt,ng_idx)=NaN;
    end
    knt=knt+1;
end
figure
[r,az]=pcoord(x,y);  % returns r as all positive
locaz=find(az> 180);
r(locaz)=-r(locaz);    % make r be minus to plus
plot(r(end,:),-elev(end,:),'r.')
hold on
plot(r(1,:),-elev(1,:),'b.')
title('raw traces extracted from first and last azimuth images')
xlabel('distance from sweep center (m)')
ylabel('distance from sonar head (m)')
text(-2.3,-.83,'blue is rotation 1, red is rotation 60')
grid on
if detrend
% try detreding the middle and overlaying:
figure
midsweep1=find(r(1,:)> -1 & r(1,:) < 1);
locnan1=find(isnan(elev(1,midsweep1)));
if ~isempty(locnan1)  % if there are nan's try to fill with means
    elev(1,locnan1+midsweep1(1))=gmean(elev(1,locnan1+midsweep1(1)-1:locnan1+midsweep1(1)+1));
    % locnan1=find(isnan(elev(1,midsweep1))) % should be empty
end
dtn1=detrend(-elev(1,midsweep1));

midsweep2=find(r(2,:)> -1 & r(2,:) < 1);
locnan2=find(isnan(elev(2,midsweep2)));
if ~isempty(locnan2)
    elev(2,locnan2+midsweep1(1))=gmean(elev(2,locnan2+midsweep2(1)-1:locnan2+midsweep2(1)+1));
    %elev(2,:)=fliplr(flel);
end
dtn2=detrend(-elev(2,midsweep2));

figure
plot(r(1,midsweep1),dtn1,'b') %
hold on
plot(r(2,midsweep2),dtn2,'r') % 
title('detrended traces extracted from first and last azimuth images')
xlabel('distance from sweep center (m)')
ylabel('distance from sonar head (m)')
text(-0.95,-.045,'blue is rotation 1, red is rotation 60')
grid on
end

