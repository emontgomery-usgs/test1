function n_wrtnct(stn)
% fill the netcdf container defined by LTtmpl.cdl with data from a .mat
% file created by n_rdlacsdt(fname) (for thermistor data)
%  outputs stn.cdf file with relatively correct metadata based on params
%  in the ascii file header
%  called by do_cvt_lacsdt.m

    ofile = [ stn '.cdf']

    cmd=[ 'load ' stn '.mat']

  %% Load the data file
    eval(cmd)

    ndepth = length(dpths); % Depths of the thermistors.

    fnin='LTtmpl.cdl'
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
    tmin = min(tempd);
     idx=find(tempd==1e35);
      tmp=tempd;
      tmp(idx)=NaN;
      tmax = max(tmp);

 % Replace NaNs (is this really needed?)
 %   if auto_nan was inadvertantly on when the .mat file was made, yes
    tempd(isnan(tempd))=1.e35;


%% Parse the template
%%
    nt=length(time);
 %Fill coordinate variables
    ncw{'time'}(1:nt)=time+2440000;  % 2440000 == May-23-1968
    ncw{'time2'}(1:nt)=time2;
    ncw{'lon'}(:) = dlon;
    ncw{'lat'}(:) = dlat;
    ncw{'depth'}(1:ndepth)= dpths;
 % fill regualr variables
    ncw{'T_28'}(1:nt,1:ndepth)= tempd;

 %find first and last good record
    sti=find(tempd(:,10)~=1e35,1,'first');
    eni=find(tempd(:,10)~=1e35,1,'last');
 % you do need the 2440000 to get matlab to print the date right
    st_dt=datestr(gregorian((time(sti)+2440000 + time2(sti)/86400000)));
    en_dt=datestr(gregorian((time(eni)+2440000 + time2(eni)/86400000)));

 % modify the variable attributes
    ncw{'T_28'}.maximum(:)=tmax;
    ncw{'T_28'}.minimum(:)=tmin;
    
 %replace global metadata attributes
 %  dlat, dlon, wdep from adcp datafile headers, via posdep.mat
    ncw.MOORING=stn(1:2);
    ncw.WATER_DEPTH=wdep;  
    ncw.CREATION_DATE=datestr(now);
    ncw.longitude=dlon;
    ncw.latitude=dlat;
    ncw.start_time=st_dt;
    ncw.stop_time=en_dt;
    ncw.DESCRIPT=['LACSD ' stn(1:2) ' mooring thermistors']
 % close the new .cdf file
 close(ncw)
