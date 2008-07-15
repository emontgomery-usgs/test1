function nrec = nodcin(infile,outfile)
% Read in NODC f291 format data and produce standard meteorological EPIC netcdf file.
% infile is name of f291 format data file.
% outfile is name of output EPIC netcdf file.
% Modified 28-Feb-2006 to include Peak wave period. Fran Lightsom.
haveA = 0;
haveB = 0;
nrec = 0;
morerecs = 1;
nvarout = 11;
epname = {'WU_422','WV_423','WD_410','WS_400','AT_21','T_25','BP_915',...
      'wh_4061','wp_4060','wd_4062','dwp_4063'};
datname = {'east','north','windir','speed','atemp','wtemp','baro','hght'...
      'period','wavdir','peak'};
east=9999*ones(800,1);
north = east;
windir = east;
speed = east;
atemp = east;
wtemp = east;
baro = east;
hght = east;
period = east;
wavdir = east;
peak = east;
year = zeros(800,1);
month = year;
day = year;
hour = year;
minute = year;
second = year;
fid = fopen(infile,'r');
outc = netcdf(outfile,'noclobber');
while morerecs;
	% Read a string. Action taken depends on character in column 10.
	instring = fgetl(fid);
    
    if (instring(1) ~= 'Y')
         nrec=nrec+1;
      %replace blanks with nines in instring
      iblank = find(instring == ' ');
      instring(iblank) = '9';
      year(nrec) = str2num(instring(1:2));
      month(nrec) = str2num(instring(4:5));
      day(nrec) = str2num(instring(7:8));
      hour(nrec) = str2num(instring(10:11));
      minute(nrec) = 0;
      keyboard
      atemp(nrec) = str2num(instring(30:33));
      baro(nrec) = str2num(instring(38:42));
      speed(nrec) = str2num(instring(43:46));
      windir(nrec) = str2num(instring(47:50));
      hght(nrec) = str2num(instring(65:67));
      period(nrec) = str2num(instring(68:70));
      wavdir(nrec) = str2num(instring(71:73));
      wtemp(nrec) = str2num(instring(80:83));
      peak(nrec) = str2num(instring(94:96));
    end
end

atemp = atemp/10;
baro = baro/10;
speed = speed/100;
windir = windir/10 + 180.;
toobig = find(windir>360.);
windir(toobig) = windir(toobig)-360.;
wtemp = wtemp/100;
hght = hght/10;
period = period/10;
peak = peak/10;
[east, north] = polar2uv(windir,speed);

alltime = ep_Time(year,month,day,hour,minute,second);
time = alltime(:,1);
time2 = alltime(:,2);
stime = datenum(year(1),month(1),day(1),hour(1),minute(1),second(1));
ltime = datenum(year(nrec),month(nrec),day(nrec),hour(nrec),minute(nrec),second(nrec));
secdif = diff(86400 * datenum(year,month,day,hour,minute,second));
tstep = median(secdif);

% Copy global attributes from ep_standard.nc to output cdf.
eps = netcdf('ep_standard.nc');
if isempty(eps)
   [epsfile,epspath] = uigetfile('*.nc','Choose epic standard file');
   eps = netcdf(epsfile);
   if isempty(eps)
      disp (['Cannot open epic standard file ' epsfile]);
      disp (['Execution ends.']);
      ncclose;
      return;
   end
end
stdatts = att(eps);
for i = 1, length(stdatts);
   copy(stdatts(i),outc);
end

%% Modify Global attributes:
 
outc.DATA_ORIGIN = ncchar('NODC');
outc.EXPERIMENT = ncchar('routine monitoring');
outc.PROJECT = ncchar('Environmental Buoy');
outc.MOORING = ncchar(mooring);
outc.DELTA_T = ncchar(num2str(tstep));
outc.DATA_CMNT = ncchar('GMT, wind direction oceanographic convention');
outc.WATER_DEPTH = nclong(wdepth);
outc.DESCRIPT = ncchar('GMT, wind direction oceanographic convention');
outc.FILL_FLAG = nclong(0);
outc.VAR_FILL = ncfloat(NaN);
history =['Imported using nodcin.m. from ascii file ' infile];  
outc.history = ncchar(history);
outc.start_time = datestr(stime,0);
outc.stop_time = datestr(ltime,0);
outc.latitude = latsign * dms2deg([latdeg latmin latsec]);
outc.longitude = lonsign * dms2deg([londeg lonmin lonsec]);
outc.water_depth = ncfloat(wdepth);
outc.CREATION_DATE = ncchar(datestr(now,0));
outc.INST_TYPE = ncchar('NDBC');
outc.instrument_number = ncchar(mooring);
outc.magnetic_variation = ncfloat(mvar);
vardesc = 'WU:WV:WD:WS:AT:T:BP:wh:wp:wd:dwp';
outc.VAR_DESC = ncchar(vardesc);
 
%% Dimensions:
outc('time') = 0;
outc('depth') = 1;
outc('lon') = 1;
outc('lat') = 1;
 
 %% Variables and attributes:
copy(eps{'time'},outc,0,1);
copy(eps{'time2'},outc,0,1);
copy(eps{'depth'},outc,0,1);
copy(eps{'lon'},outc,0,1);
copy(eps{'lat'},outc,0,1);

for i = 1: nvarout;
	ivar = eps{epname{i}};
   copy(ivar,outc,0,1)%;
end
close (eps)

for i = 1:nvarout
	ovar = outc{epname{i}};
   ovar.sensor_depth = ncfloat(sdepth(i));
	ovar.serial_number = ncchar('NDBC');
	eval (['ovar.minimum = ncfloat(min(' datname{i} '(1:nrec)));']);
   eval (['ovar.maximum = ncfloat(max(' datname{i} '(1:nrec)));']);
end

endef(outc)
outc{'time'}(1:nrec) = time(1:nrec);
outc{'time2'}(1:nrec) = time2(1:nrec);
outc{'lat'}(1) = outc.latitude(1);
outc{'lon'}(1) = outc.longitude(1);
outc{'depth'}(1) = 0.;
for i = 1:nvarout
	ovar = outc{epname{i}};
   eval (['ovar(1:nrec) = ' datname{i} '(1:nrec);' ]);
end
fclose (fid)
close (outc)

