% script ep2cf.m
%
% prototype test to see what happens if I add time_cf for cf-users...


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

 
% open a file %
nc=netcdf('7581adc-a.nc')
% get a time in seconds
%   86400 seconds/day and 1000 msec/sec
tt=(nc{'time'}*86400)+(nc{'time2'}/1000);

% open an output file
outc=netcdf('7851adc-a_cf.nc','noclobber')
ingatts=att(nc);
copy (ingatts,outc)
outc.conventions='cf-1.0';
outc.note='test for cf compliance';
ndepths=length(nc{'depth'}(:))

% establish coord vars
outc('time') = 0;
outc('depth') = ndepths;
outc('lon') = 1;
outc('lat') = 1;
%copy the existing ones
copy(nc{'time'},outc,0,1);
copy(nc{'time2'},outc,0,1);
copy(nc{'depth'},outc,0,1);
copy(nc{'lon'},outc,0,1);
copy(nc{'lat'},outc,0,1);

% now create the epic compliant time
outc{'time_cf'}(1:length(tt))=tt;
outc{'time_cf'}.units='seconds from 1 Jan -4712';
outc{'time_cf'}.axis='T';
outc{'time_cf'}.type='EVEN';
outc{'time_cf'}.note='same time as EPIC, but as one variable in seconds';
outc{'time_cf'}.units='seconds from 1 Jan -4712';

%copy the variables over too
epname=ncnames(var(nc));
for i=1:length(epname)
    disp (['creating output variable ' epname{i}]);
    ivar = nc{epname{i}};
    copy(ivar,outc,0,1);
    nc{epname{i}}.coordinates='time_cf lat lon depth':
end
close (outc)
close (nc)
