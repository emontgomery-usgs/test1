function [x, y, elev, sstr]= linfrm_rawpen(ncr, settings)
% LINFRM_RAWPEN uses the first increasing return in each angular scan to
% define a line approximating the seafloor
% usage : [x, y, elev, sstr]= linfrm_rawpen(ncr, settings)
%  inputs: the open netdcf object for the raw file and settings
% settings is a structure and should contain these things:
%   1) tidx- the time index of the first dimension of ncr (72 is 1/28 at 0715)
%   2) thold- threshold of size of (diff) to use in peak detection (5-15)
%      if data retruned is noisy- try a higher threshold
%   3) rot2compass- value needed to get up as North in the plot (0)
%   4) Pencil_tilt- value needed to adjust first and last scans to balance(0)
%   5) nsweeps - number of sweeps (1)
%   6) detrend - true if you want to try the detrending - experimental
%   7) blank_points - number of points to skip at beginning of each sample
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
if isfield(settings,'nsweeps')
    nsweeps=settings.nsweeps;
else
    nsweeps=1;
end
if isfield(settings,'detrend')
    detrend=settings.detrend;
else
    detrend=0;      % default is don't detrend
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
Ro=0.0; % distance (m) from axis of rotation to head
hdangle=ncr{'headangle'}(:)+ tilt;
meters_per_point=1/(szs(2)/ncr.Range(:));
alpha = settings.rot2compass; % use how much to rotate
alpha = alpha.*(pi/180); % convert to radians

%
% pre-allocate arrays
    if nsweeps==1
        scan_nos=2:szs(3);
    else
        scan_nos=2:szs(3)/nsweeps;
    end
x=ones(nsweeps,length(scan_nos)); y=ones(nsweeps,length(scan_nos));
elev=ones(nsweeps,length(scan_nos)); sstr=ones(nsweeps,length(scan_nos));
% alternate method trying to get the first part of the peak
%iAz=1;   % for now- will want to do all the rotations eventually

knt=1;
%separating the sweeps isn't as simple as dividing the data in half-  need
%to start at the second scan, and skip the middle point.
% for 884 scans, sweep 1 is 2:442 and sweep2 is 444:884 (both length 441)
for iAz=1:nsweeps
    if nsweeps==2
        if iAz==1
            scan_nos=2:szs(3)/2;
        else
            scan_nos=(szs(3)/2)+2:szs(3);
        end
    end
    % don't know of a vectorized way to do this part- it's slow
    % ** the current "best" bottom detection is finding the change in slope 
    % of each scan (uses thold to find change in slope)
    for jj=1:length(scan_nos)
       % index into raw_image should be scan_nos
       % in sweep 2, scan_nos(1) will be 444- the value from that scan
       % should go into scan_surfval(1) on sweep 2- values are re-set each
       % sweep
        first_hi_val=find(diff(ncr{'raw_image'}(tidx,blank:end,scan_nos(jj)) > thold),1,'first');
        nn=1;       %set counter for changing the threshold, in case it's needed
        % use a lower threshold, if doesn't get a signal with first one.
        while( first_hi_val+blank > 400)
            temp_thold=thold-nn;
            first_hi_val=find(diff(ncr{'raw_image'}(tidx,blank:end,scan_nos(jj)) > temp_thold),1,'first');
            nn=nn+1;
        end   
        maxval=max(ncr{'raw_image'}(tidx,blank:end-1,scan_nos(jj)));
      %index into the output vectors should be jj to start at 1 each sweep
        if (isempty(first_hi_val))
            scan_surfval(jj)=1;
            sstr(knt,jj)=1;
        else
            scan_surfval(jj)=first_hi_val+blank;
            sstr(knt,jj)=ncr{'raw_image'}(tidx,first_hi_val+blank,jj);
        end
    end
    if iAz==1
        minidx=szs(3)/4-5; maxidx=szs(3)/4+5 % use 10 points, mmid-scan
        A=median(scan_surfval(minidx:maxidx))*meters_per_point
    end
    hdang=hdangle(scan_nos);
    beta = hdang.*(pi/180); % convert to radians
    m = A.*tan(beta); % horizontal distance from sweep apex to measurement M
    gamma = atan(m./Ro); % angle between points A and M
    elev(knt,:) = (scan_surfval*meters_per_point).*cos(beta'); % measured distance from apex A to bed
    x(knt,:) = sqrt(m.^2+Ro.^2).*sin(gamma+alpha);
    y(knt,:) = sqrt(m.^2+Ro.^2).*cos(gamma+alpha);
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
r(locaz)=-r(locaz);    % make r be minus to plut

plot(r(end,:),-elev(end,:),'r.')
hold on
plot(r(1,:),-elev(1,:),'b.')
xlabel('distance along sweep (m)')
ylabel('distance from the head (m)')
title('pencil sweeps- blue is first, red is second')

if (detrend)
% try detreding the middle and overlaying:
figure
midsweep1=find(r(1,:)> -1 & r(1,:) < 1);
locnan1=find(isnan(elev(1,midsweep1)));
if ~isempty(locnan1)  % if there are nan's try to fill with means
    elev(1,locnan1+midsweep1(1))=gmean(elev(1,locnan1+midsweep1(1)-1:locnan1+midsweep1(1)+1));
    % locnan1=find(isnan(elev(1,midsweep1))) % should be empty
end
dtel1=detrend(-elev(1,midsweep1));

plot(dtel1)
midsweep2=find(r(2,:)> -1 & r(2,:) < 1);
locnan2=find(isnan(elev(2,midsweep2)));
if ~isempty(locnan2)
    elev(2,locnan2+midsweep1(1))=gmean(elev(2,locnan2+midsweep2(1)-1:locnan2+midsweep2(1)+1));
    %elev(2,:)=fliplr(flel);
end
dtel2=detrend(-elev(2,midsweep2));

hold on
plot(dtel2,'r')
title('detrended traces extracted from first and last azimuth images')
xlabel('distance from sweep center (m)')
ylabel('distance from sonar head (m)')
text(-0.95,-.045,'blue is rotation 1, red is rotation 60')
grid on
end


