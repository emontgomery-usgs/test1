function [st_time, end_time]=chk_time(fname)
%
%  use this function to get the first and last times from USGS netcdf files
%open the netcdf file
eval(['nc=netcdf(''' fname ''');'])
%
%  extract and save the time words in a sensible format
%    time is days, time2 is miliseconds
st_time=gregorian(nc{'time'}(1)+(nc{'time2'}(1)/3600/1000/24));
end_time=gregorian(nc{'time'}(end)+(nc{'time2'}(end)/3600/1000/24));

% or you could plot time, if you want...
% plot(nc{'time'}(:)+nc{'time2'}(:)/(1000*3600*24),'.');
close (nc)
