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
   if instring == -1;%the end of file has been reached. 
      morerecs = 0;
      linetype = 'X';
   else
      linetype = instring(10);
   end
   switch linetype
	case 'A'
   	if (~haveA)
         haveA = 1;
         mooring = instring(11:16);
         latdeg = str2num(instring(27:28));
         latmin = str2num(instring(29:30));
         latsec = str2num(instring(31:32));
         latsign = instring(33);
         if latsign == 'N';
            latsign = 1;
         elseif latsign == 'S';
            latsign = -1;
         else latsign = 0;
         end
         londeg = str2num(instring(34:36));
         lonmin = str2num(instring(37:38));
         lonsec = str2num(instring(39:40));
         lonsign = instring(41);
         if lonsign == 'E';
            lonsign = 1;
         elseif lonsign == 'W';
            lonsign = -1;
         else lonsign = 0;
         end         
         wdepth = str2num(instring(42:46))/10;
         mvar = str2num(instring(47:50));
   	end
	case 'B'
   	nrec = nrec + 1;
   	if (~haveB)
      	haveB = 1;
         anemom = -str2num(instring(27:29))/10;
         sdepth = [anemom,anemom,anemom,anemom,anemom,0,0,0,0,0,0];
      end
      %replace blanks with nines in instring
      iblank = find(instring == ' ');
      instring(iblank) = '9';
      year(nrec) = str2num(instring(4:7));
      month(nrec) = str2num(instring(19:20));
      day(nrec) = str2num(instring(21:22));
      hour(nrec) = str2num(instring(23:24));
      minute(nrec) = str2num(instring(25:26));
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

% with relatively slowly changing data, can interp over single missing
% points.  Atemp, baro and wtemp have interpolation allowed before NaN 
% filling the rest of the spikes.  The variables simply have spikes replaced by NaN
atemp = atemp/10;
 xx=find(atemp>=999.9);
 for ik=1:length(xx)-1
   if(xx(ik+1) ~= xx(ik)+1)
     atemp(xx(ik))=(atemp(xx(ik)-1) + atemp(xx(ik)+1))/2;
   end
 end
 clear xx
  xx=find(atemp>=100);
  atemp(xx)=NaN;
  clear xx
baro = baro/10;
  xx=find(baro==9999.9);
   for ik=1:length(xx)-1
   if(xx(ik+1) ~= xx(ik)+1)
     baro(xx(ik))=(baro(xx(ik)-1) + baro(xx(ik)+1))/2;
   end
   end
  clear xx
  xx=find(baro>2000);
  baro(xx)=NaN;
  clear xx
speed = speed/100;
  xx=find(speed==99.99);
  speed(xx)=NaN;
  clear xx
windir = windir/10 + 180.;
toobig = find(windir>360.);
windir(toobig) = windir(toobig)-360.;
  xx=find(windir>360);
  windir(xx)=NaN;
  clear xx
wtemp = wtemp/100;
  xx=find(wtemp==99.99);
  for ik=1:length(xx)-1
   if(xx(ik+1) ~= xx(ik)+1)
     wtemp(xx(ik))=(wtemp(xx(ik)-1) + wtemp(xx(ik)+1))/2;
   end
   end
  clear xx
  xx=find(wtemp>50); 
  wtemp(xx)=NaN;
  clear xx
xx = find(wavdir >=720);
 wavdir(xx)=NaN;
 clear xx
hght = hght/10;
  xx=find(hght>=99.9);
  hght(xx)=NaN;
  clear xx
period = period/10;
  xx=find(period==999.9 | period == 99.9);
  period(xx)=NaN;
  clear xx
peak = peak/10;
  xx=find(peak==999.9 | peak == 99.9);
  peak(xx)=NaN;
  clear xx
[east, north] = polar2uv(windir,speed);

alltime = ep_time(year,month,day,hour,minute,second);
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
fclose (fid);
close (outc);

