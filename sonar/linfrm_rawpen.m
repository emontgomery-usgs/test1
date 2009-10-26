function [x, y, elev, sstr]= linfrm_rawpen(ncp, settings)
% LINFR_RAWPEN uses the first increasing return in each angular scan to
% define a line approximating the seafloor
%  inputs: the open netdcf object for the raw file and settings
% settings is a structure and should contain these things:
%   1) tidx- the time index of the first dimension of ncp (72 is 1/28 at 0715)
%   2) thold- threshold of size of (diff) to use in peak detection (5-15)
%      if data retruned is noisy- try a higher threshold
%   3) rot2compass- value needed to get up as North in the plot (0)
%   4) Pencil_tilt- value needed to adjust first and last scans to balance(0)
%   5) nsweeps - number of sweeps (1)
%   6) detrend - true if you want to try the detrending - experimental
% autonan must be on before ncp was opened
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

%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncp{'raw_image'});
%
%Note the last headangle and data point is NG, so that dimension needs to be -1

% alternate method trying to get the first part of the peak
%for hh=1:szs(2)
%contains: (time, number_rotations, npoints, nscans)
szs = ncsize(ncp{'raw_image'});
Ro=0.0; % distance (m) from axis of rotation to head
hdangle=ncp{'headangle'}(:)+ tilt;
meters_per_point=1/(szs(2)/ncp.Range(:));
alpha = settings.rot2compass; % use how much to rotate
alpha = alpha.*(pi/180); % convert to radians

%
% pre-allocate
% use rotnos=[1:1:60]; to do all rotations in an entire azimuth image- very slow!!
    if nsweeps==1
        scan_nos=1:szs(3)-1;
    else
        scan_nos=1:szs(3)/2;
    end
x=ones(nsweeps,length(scan_nos)); y=ones(nsweeps,length(scan_nos));
elev=ones(nsweeps,length(scan_nos)); sstr=ones(nsweeps,length(scan_nos));
% alternate method trying to get the first part of the peak
%iAz=1;   % for now- will want to do all the rotations eventually

knt=1;
for iAz=1:nsweeps
    if nsweeps==2
        if iAz==1
            scan_nos=1:szs(3)/2;
        else
            scan_nos=(szs(3)/2):szs(3)-1;
        end
    end
    for jj=scan_nos
        % Note the last headangle and data point is NG, so that dimension needs to be -1
        first_hi_val=find(diff(ncp{'raw_image'}(tidx,50:end,jj) > thold),1,'first');
        maxval=max(ncp{'raw_image'}(tidx,iAz,50:end,jj));
        if (isempty(first_hi_val))
            scan_surfval(jj)=1;
            sstr(knt,jj)=1;
        else
            scan_surfval(jj)=first_hi_val+50;
            sstr(knt,jj)=ncp{'raw_image'}(tidx,iAz,first_hi_val+50,jj);
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
    elev(knt,:) = (scan_surfval(scan_nos)*meters_per_point).*cos(beta'); % measured distance from apex A to bed
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


