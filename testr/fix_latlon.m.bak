function fixlatlon(ncfilename,gdlat, gdlon)
% corrects lat lon for a given .nc file
% usage fix_latlon('7431mc-a', 33.649, -78.849)
% etm (after fl code) 5/23/06

perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_old.nc'];

result=fcopy(ncfilename,new_nm);
nc = netcdf(ncfilename, 'write');
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['Global attributes corrected.:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
nc.latitude = ncfloat(gdlat);
nc{'lat'}(1)=gdlat;
nc.longitude = ncfloat(gdlon);
nc{'lon'}(1)=gdlon;
close(nc)
