function fixlatlon(ncfilename,gdlat, gdlon)
% corrects lat lon for a given .nc file
% usage fix_latlon('7431mc-a', 33.649, -78.849)
% etm (after fl code) 5/23/06


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
