function [penline, azline]=pen_azcomp(image_date,settings)
% currently compares pen and az rotation 1 from 1/28/09 ar 0715
%
% usage: [p022509, a022509]=pen_azcomp([2009, 02, 25, 13,00,00], seta);
%
% where inputs:
% image_date- a numeric vector containing [yyyy, mo, da, hh, mm ss]
% settings is a structure and should contain these things:
%   1) thold- threshold of size of (diff) to use in peak detection (5-15)
%      if data returned is noisy- try a higher threshold
%   2) rot2compass- value needed to get up as North in the plot (0)
%   3) Pencil_tilt- value needed to adjust first and last scans to balance(0)
%
% outputs are structures for both pencil and azimuth containing
%  x,y positions relative to azimuth center
%  elev - elevation = seafloor shape extracted from raw_image
%  sstr- signal strength where elevation was picked
%  dist - distance along line of sweep 1
%  sample_time - the actual time associated with the data

% emontgomery- October 2009

% autonan must be on before ncr was opened
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
if isfield(settings,'detrend')  % optional
    detrend=settings.detrend;
else
    detrend=0;      % default is don't detrend
end
% set a default tidx
tidx=1;

target_date=datenum(image_date);

% start with the pencil
ncp=netcdf('8558pen_raw.cdf');
% find the time_setp to use
tt=ncp{'time'}(:)+(ncp{'time2'}(:)./86400000);
dnall=datenum(gregorian(tt));
loc=find(dnall >target_date,1,'first')
if (abs(target_date-dnall(loc-1)) < abs(target_date-dnall(loc)))
    loc=loc-1;
end
disp(['For pencil data:'])
disp(['target date is ' datestr(image_date) '. date of sample used is ' datestr(gregorian(tt(loc))) '.'])
settings.tidx=loc;
setttings.nsweeps=2;
[px,py,pelev,psstr]=linfrm_rawpen(ncp,settings);
close(ncp)

% set up the outputs
penline.x=px;
penline.y=py;
penline.elev=pelev;
penline.sstr=psstr;
penline.sample_time=datestr(gregorian(tt(loc)));

%Now do the azimuth
fname=['az' num2str(image_date(1)) '-' num2str(image_date(2),'%02d') '-'  num2str(image_date(3),'%02d') '_raw.cdf']
nc=netcdf(fname);
%since the azimuth files contain only one day, just work with time
td=(nc{'time2'}(:)./86400000);
aztar_date=target_date-floor(target_date);
loc=find(td >aztar_date,1,'first')
if isempty(loc)
    loc=4;
else
    if (abs(aztar_date-td(loc-1)) < abs(aztar_date-td(loc)))
        loc=loc-1;
    end
end
settings.tidx=loc
disp(['For azimuth data:'])
disp(['target date is ' datestr(image_date) '. Date of sample used is ' datestr(floor(target_date)+td(loc)) '.'])
seta.tidx=loc;
[x,y,elev,sstr]=linfrm_rawimg_frstlast(nc,settings);
close(nc)

% set up the outputs
azline.x=x;
azline.y=y;
azline.elev=elev;
azline.sstr=sstr;
azline.sample_time=datestr(target_date+td(loc));

%now do a plot comparing them- pencil first
[rp,azp]=pcoord(px,py);  % returns r as all positive
locp=find(azp> 180);
rp(locp)=-rp(locp);    % make r be minus to plus
figure
plot(rp(1,:),-pelev(1,:),'c')
hold on
%then azimuth rotation 1
[ra,aza]=pcoord(x(1,:),y(1,:));  % returns r as all positive
locaz=find(aza> 180);
ra(locaz)=-ra(locaz);    % make r be minus to plus
plot(ra(1,:),-elev(1,:),'b')

penline.dist=rp;
azline.dist=ra;

title('Pencil and azimuth rotation 1 traces extracted raw_images')
xlabel('distance from sweep center (m)')
ylabel('distance from sonar head (m)')
text(-2.4,-.75,'blue is azimuth 1, cyan is pencil')
