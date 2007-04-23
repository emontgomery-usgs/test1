% example of how one might change some global attributes in a .nc file
% the original file is copied to save it, then the original is modified
result=fcopy('5241adc-a_old.nc','5241adc-a.nc')
nc = netcdf('5241adc-a.nc', 'write');
if isempty(nc), return, end
 
%% Global attributes:
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
