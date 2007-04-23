function n_wrtnc(stn)
%fill the netcdf container defined in LAtmpl.cdl.
%  assumes you've run n_rdlacsd(sta) first to create the .mat file used
%  as input.  outputs stn.cdf file with relatively correct metadata

ofile = [ stn '.cdf']


cmd=[ 'load ' stn '.mat']

%% Load the data file
eval(cmd)

% dlat and dlon are created and stored in the .mat file
%dlat = 33+41.76/60
%dlon = -(118+20.02/60)

ndepth = length(h); %Depths of the bin.

fnin='LAtmpl.cdl'
fnout=[stn '.cdl'];
txtin='xxdepthxx';
txtout=int2str(ndepth);
reptxt( fnin, txtin, fnout, txtout );

%cmd = ['!ncgen -o ' ofile ' ' fnout]
%cmd = ['!ncgen -o ' ofile ' LAtmpl.cdl ']
cmd = sprintf('!ncgen -o %s %s',ofile,fnout)
eval(cmd)
%now open the cdf file you just created
ncw = netcdf(ofile,'w');

%now find the max and min, removing the 1e35's first
umin = min(u);
  idx=find(u==1e35);
  tmp=u;
  tmp(idx)=NaN;
   umax = max(tmp);
vmin = min(v);
  idx=find(v==1e35);
  tmp=v;
  tmp(idx)=NaN;
   vmax = max(tmp);
amin = min(a);
  idx=find(a==1e35);
  tmp=a;
  tmp(idx)=NaN;
   amax = max(tmp);

% Replace NaNs (is this really needed?)
%   if auto_nan was inadvertantly on when the .mat file was made, yes
u(isnan(u))=1.e35;
v(isnan(v))=1.e35;
a(isnan(a))=1.e35;


%% Parse the template
%% 

nt=length(time);
%CRS removed this in rdlacsd, and it shouldn't be
ncw{'time'}(1:nt)=time+2440000;  % 2440000 == May-23-1968
ncw{'time2'}(1:nt)=time2;
ncw{'lon'}(:) = dlon;
ncw{'lat'}(:) = dlat;

ncw{'depth'}(1:ndepth)= h;
ncw{'u_1205'}(1:nt,1:ndepth)= u;
ncw{'v_1206'}(1:nt,1:ndepth)= v;
ncw{'AGC_1202'}(1:nt,1:ndepth)= a;
ncw{'corrl'}(1:nt,1:ndepth)= c;
ncw{'sstrn'}(1:nt,1:ndepth)= s;


%find first and last good record
sti=find(u(:,10)~=1e35,1,'first');
eni=find(u(:,10)~=1e35,1,'last');
% you do need the 2440000 to get matlab to print the date right
st_dt=datestr(gregorian((time(sti)+2440000 + time2(sti)/86400000)));
en_dt=datestr(gregorian((time(eni)+2440000 + time2(eni)/86400000)));

ncw{'u_1205'}.maximum(:)=umax;
ncw{'u_1205'}.minimum(:)=umin;
ncw{'u_1205'}.sensor_depth(:)=wdep;
ncw{'v_1206'}.maximum(:)=vmax;
ncw{'v_1206'}.minimum(:)=vmin;
ncw{'v_1206'}.sensor_depth(:)=wdep;
ncw{'AGC_1202'}.maximum(:)=amax;
ncw{'AGC_1202'}.minimum(:)=amin;
ncw{'AGC_1202'}.sensor_depth(:)=wdep;
ncw{'corrl'}.sensor_depth(:)=wdep;
ncw{'sstrn'}.sensor_depth(:)=wdep;
ncw{'u_1205'}.serial_number(:)=SerialNumber;
ncw{'v_1206'}.serial_number(:)=SerialNumber;
ncw{'AGC_1202'}.serial_number(:)=SerialNumber;
ncw{'corrl'}.serial_number(:)=SerialNumber;
ncw{'sstrn'}.serial_number(:)=SerialNumber;

%replace global metadata attributes
ncw.MOORING=sta;
ncw.WATER_DEPTH=wdep;
ncw.Deployment_date=DeploymentStartDate;
ncw.Recovery_date='2006/6/9 01:1500';
ncw.CREATION_DATE=datestr(now);
ncw.longitude=dlon;
ncw.latitude=dlat;
ncw.ProfileInterval=ProfileInterval;
ncw.ProfilesperBurst=ProfilesperBurst;
ncw.BurstInterval=BurstInterval;
ncw.PressureInstalled=PressureInstalled;
ncw.AveragingInterval=AveragingInterval;
ncw.start_time=st_dt;
ncw.stop_time=en_dt;

close(ncw)