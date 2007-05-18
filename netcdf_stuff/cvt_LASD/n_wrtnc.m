function n_wrtnc(stn)
% fill the netcdf container defined by LAtmpl.cdl with data from a .mat
% file created by n_rdlacsd(sta)
%  outputs stn.cdf file with relatively correct metadata based on params
%  in the ascii file header
%  called by do_cvt_lacsd.m

    ofile = [ stn '.cdf']

    cmd=[ 'load ' stn '.mat']

  %% Load the data file
    eval(cmd)

    ndepth = length(h); %Depths of the bin.

    fnin='LAtmpl.cdl'
    fnout=[stn '.cdl'];
    txtin='xxdepthxx';
    txtout=int2str(ndepth);
    % you have to have a number in the .cdl for dimensioning the .cdf file
    % this line substitutes the actual number of bins for xxdepthxx
    reptxt( fnin, txtin, fnout, txtout );

 % this creates the empty .cdf file structure
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
    amin = min(a);           %n_rdlacsd stores amplitude as 'a'
     idx=find(a==1e35);
      tmp=a;
       tmp(idx)=NaN;
       amax = max(tmp);
    snrmin = min(s);          %n_rdlacsd stores signal to noise ratio as 's'
     idx=find(s==1e35);
      tmp=s;
      tmp(idx)=NaN;
      snrmax = max(tmp);
    stdcormin = min(c);       %n_rdlacsd stores std/corr as 'c'
     idx=find(c==1e35);
      tmp=c;
      tmp(idx)=NaN;
       stdcormax = max(tmp);

 % Replace NaNs (is this really needed?)
 %   if auto_nan was inadvertantly on when the .mat file was made, yes
    u(isnan(u))=1.e35;
    v(isnan(v))=1.e35;
    a(isnan(a))=1.e35;


%% Parse the template
%%

    nt=length(time);
 %Fill coordinate variables
    ncw{'time'}(1:nt)=time+2440000;  % 2440000 == May-23-1968
    ncw{'time2'}(1:nt)=time2;
    ncw{'lon'}(:) = dlon;
    ncw{'lat'}(:) = dlat;
    ncw{'depth'}(1:ndepth)= h;
 % fill regualr variables
    ncw{'u_1205'}(1:nt,1:ndepth)= u;
    ncw{'v_1206'}(1:nt,1:ndepth)= v;
    ncw{'ampl'}(1:nt,1:ndepth)= a;
    ncw{'snr'}(1:nt,1:ndepth)= s;
    ncw{'stdcor'}(1:nt,1:ndepth)= c;


 %find first and last good record
    sti=find(u(:,10)~=1e35,1,'first');
    eni=find(u(:,10)~=1e35,1,'last');
 % you do need the 2440000 to get matlab to print the date right
    st_dt=datestr(gregorian((time(sti)+2440000 + time2(sti)/86400000)));
    en_dt=datestr(gregorian((time(eni)+2440000 + time2(eni)/86400000)));

 % modify the variable attributes
    ncw{'u_1205'}.maximum(:)=umax;
    ncw{'u_1205'}.minimum(:)=umin;
    ncw{'u_1205'}.sensor_depth(:)=wdep;
    ncw{'u_1205'}.serial_number(:)=str2num(SerialNumber(3:5));
    ncw{'v_1206'}.maximum(:)=vmax;
    ncw{'v_1206'}.minimum(:)=vmin;
    ncw{'v_1206'}.sensor_depth(:)=wdep;
    ncw{'v_1206'}.serial_number(:)=str2num(SerialNumber(3:5));;
    ncw{'ampl'}.maximum(:)=amax;
    ncw{'ampl'}.minimum(:)=amin;
    ncw{'ampl'}.serial_number(:)=str2num(SerialNumber(3:5));
    ncw{'ampl'}.sensor_depth(:)=wdep;
    ncw{'snr'}.maximum(:)=snrmax;
    ncw{'snr'}.minimum(:)=snrmin;
    ncw{'snr'}.serial_number(:)=str2num(SerialNumber(3:5));
    ncw{'snr'}.sensor_depth(:)=wdep;
    ncw{'stdcor'}.maximum(:)=stdcormax;
    ncw{'stdcor'}.minimum(:)=stdcormin;
    ncw{'stdcor'}.sensor_depth(:)=wdep;
    ncw{'stdcor'}.serial_number(:)=str2num(SerialNumber(3:5));

 %replace global metadata attributes
    ncw.MOORING=sta;
    ncw.WATER_DEPTH=wdep;
    ncw.CREATION_DATE=datestr(now);
    ncw.longitude=dlon;
    ncw.latitude=dlat;
    ncw.ProfileInterval=ProfileInterval(2:6);
    ncw.ProfilesperBurst=deblank(ProfilesperBurst);
    ncw.BurstInterval=deblank(BurstInterval);
    ncw.PressureInstalled=PressureInstalled;
    ncw.AveragingInterval=AveragingInterval;
    ncw.start_time=st_dt;
    ncw.stop_time=en_dt;
    ncw.DESCRIPT=['LACSD ' stn(end-1:end) ' mooring ADP']
    ncw.ADP_serial_number=str2num(SerialNumber(3:5));
 % close the new .cdf file
 close(ncw)
