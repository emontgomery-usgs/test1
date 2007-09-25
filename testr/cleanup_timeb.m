function cleanup_timeb(ncfilename)
%  rcm data typically has gaps at the day change.  The timebase in a 
%  cdf file has to be constant, so this program fixes it.
%  also works for adcp files with gaps in timebase
%  etm mod  01/18/07


%%% START USGS BOILERPLATE -------------%%
% This program was written to modify a netCDF file in some way.
% It is self documenting- there is currently no other publication 
% describing the use of this software.
%
% Program written in Matlab v7.4,0.287 (R2007a)
% Program ran on PC with Windows XP Professional OS.
% The software requires the netcdf toolbox and mexnc, both available
% from SourceForge (http://www.sourceforge.net)
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_new.cdf'];

% open input file
nc = netcdf(ncfilename);   % open the a (file named b)
if isempty(nc), return, end
% and the NEW EMPTY output file to take trimmed data
   outc = netcdf(new_nm,'clobber');
 
%% set the dimensions (only applies to coordinate variables)

outc('time') = 0;
outc('depth')=length(nc{'depth'}(:));
outc('lon') = 1;
outc('lat') = 1;

%copy the info over - this is a way of DEFINING the variables
%  this happens in the loop below : copy(nc{'time'},outc,0,1);
      % have to copy the structure of the variable into the new array with
      % size 0 initially, then copy new contents to determine the size.
   vnam=ncnames(var(nc));
   % use the names from nc, but get the empty variables from ep-standard.
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
     
      for ik=1:length(vnam)% create the non-record variables
        epvar=eps{vnam{ik}};
        if isempty(epvar)  %get from nc, if not in eps
          eval(['copy(nc{''' char(vnam(ik)) '''},outc,0,1);']) 
        else
          copy(epvar,outc,0,1);
        end
        % eval(['copy(nc{''' char(vnam(ik)) '''},outc,0,1);'])
      end
      close(eps)

  % endef must be used to terminate the variable definition
   % and the termination *MUST* come before values are written to any
    % variable!    
      endef(outc)

 % need to copy over all the global attributes here
 atn=ncnames(att(nc));
 for j=1:length(atn)
  eval( ['copy(nc.' char(atn(j)) ',outc);'])
 end
 
%% Global attributes:
lfeed = char(10);
outc.CREATION_DATE = ncchar(datestr(now,0));
history = ['timebase made even by cleaup_timeb.m:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
outc.history = ncchar(history);

% NOW set the values of some of the coordinate vars, but don't do time yet!
outc{'lat'}(:)=nc{'lat'}(:);
outc{'lon'}(:)=nc{'lon'}(:);
outc{'depth'}(:)=nc{'depth'}(:);
% is 0 when comes from nc, and can't be set to VAR_FILL
% so doing this for the moment
 %outc{'time'}.FillValue_(:)=999999999
 %outc{'time2'}.FillValue_(:)=999999999

tt=nc{'time'}(:)+(nc{'time2'}(:)/86400000);
  tng=find(isnan(tt)); 
  if isempty(tng)
      tng=find(tt == 0);
  end     
  yy=find(diff(tng)==1);  % rcms usually have dups
  if isempty(yy)
      dups=find(diff(tt)==0);
  else
      dups=tng(yy);
  end
      
%  here we want to insert the shorter strings into the first nlen items
%  later we use nctrim to get rid of the trailing irrelevant junk
  nlen=length(tt)-length(dups);
  if ~isempty(dups)       % this branch is for rcms
    for ik=6:length(vnam)
        eval(['xx=nc{''' char(vnam(ik)) '''}(:);'])
            xx(dups)=[];
            % put the new shorter timebase into outc
            eval(['outc{''' char(vnam(ik)) '''}(1:nlen)=xx;']) 
      % put the new shorter timebase into outc
     clear xx 
    end
    t1=nc{'time'}(:);
      t1(dups)=[];
    t2=nc{'time2'}(:);
      t2(dups)=[];
    ttn=t1+(t2/86400000);
      tng=find(isnan(ttn)); 
     if isempty(tng)
        tng=find(ttn == 0);
     end  
     % now that any duplicates are removed
       ttn(tng)=(ttn(tng-1)+ttn(tng+1))/2;  % replace NG with the mean
      % use ep_time.m to create the times- it requires y m d h m s
       dttm=gregorian(ttn);
       ntime=ep_time(dttm(:,1),dttm(:,2),dttm(:,3),dttm(:,4),dttm(:,5),dttm(:,6));
       nl=length(ntime);
       outc{'time'}(1:nl)=ntime(:,1);
       outc{'time2'}(1:nl)=ntime(:,2); 
  %% don't neet to Call nctrim here, but could be useful otherwise
  %%  outc = nctrim(nc,outc, start:stop);
  
  else      %this is for adcp's
     %now that any duplicates are removed, interpolate over nan's in
     %the timebase
    xn=find(isnan(tt));
   if ~isempty(xn)
    tt(xn)=(tt(xn-1)+tt(xn+1))/2;  % replace NAN with the mean 
    % now place these into outc's time and time2
       dttm=gregorian(tt);
       ntime=ep_time(dttm(:,1),dttm(:,2),dttm(:,3),dttm(:,4),dttm(:,5),dttm(:,6));
       nl=length(ntime);
       outc{'time'}(1:nl)=ntime(:,1);
       outc{'time2'}(1:nl)=ntime(:,2); 
    % they should all get the rest of the variables copied,
    % regardless of what happened to time
    nl=length(tt);
     for ik=[6:length(vnam)]
         eval(['outc{''' char(vnam(ik)) '''}(:) = nc{''' char(vnam(ik)) '''}(:);'])
     end   
   end 
  end

close (outc);
close (nc);
