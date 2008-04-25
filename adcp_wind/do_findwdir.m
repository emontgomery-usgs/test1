% script to remind myself how I did the ADCP wind dir stuff.
%   etm 2/7/08
% load a sample file (adcp2ep run on raw *wh000.cdf data)
ncload('7751whall2.cdf')
  tt=time+time2/86400000;
% compute wind speed and direction from raw ADCP
[dd,ss,okidx]=findwdir(u_1205,v_1206);
   % used gregorian to find that tt(804)=10/1/04 and (3780)=11/1/04 
   octindx=find(okidx>=804 & okidx < 3780);
  
%load noaa buoy wind data to compare
ncload ('44013_89t05-cal.cdf')
  ttwind=time+time2/86400000;
  % used gregorian to find october 04 data  
% Now plot direction
plot(tt(okidx(octindx)),dd(octindx),'.')
hold on
plot(ttwind(133124:133868),WS_400(133124:133868),'r.')
xlabel('time (julian day)')
ylabel ('direction (degrees)')
title('October 2004 comparison between Wind directions')
gtext('red from NOAA buoy 44013 WD\_410')
gtext('blue from ADCP direction at max(speed)')
% print -djpeg wdir_examp.jpg
% Now plot wind speed
plot(tt(okidx(octindx)),ss(octindx),'.')
hold on
plot(ttwind(133124:133868),WS_400(133124:133868),'r.')
xlabel('time (julian day)')
ylabel ('speed (cm/sec)')
title('October 2004 comparison between Wind speeds')
gtext('red from NOAA buoy 44013 WD\_410')
gtext('blue from ADCP max(speed) - speed in the bin below')
% print -djpeg wdir_examp.jpg