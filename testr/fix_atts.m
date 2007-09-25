result=fcopy('5241adc-a_old.nc','5241adc-a.nc')
nc = netcdf('5241adc-a.nc', 'write');
if isempty(nc), return, end
 
%% Global attributes:


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

 lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['Global attributes corrected.:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
time = nc{'time'}(:);
time2 = nc{'time2'}(:);
stime = ep_datenum([time(1) time2(1)]);
n = length(time);
ltime = ep_datenum([time(n) time2(n)]);
nc.start_time = datestr(stime,0);
nc.stop_time = datestr(ltime,0);
nc.MOORING = ncchar('5241');
nc.DELTA_T = ncchar('3600');
close(nc)
