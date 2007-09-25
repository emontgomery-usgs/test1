function [st_time, end_time]=chk_time(fname)
%
%  use this function to get the first and last times from USGS netcdf files
%open the netcdf file


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

 eval(['nc=netcdf(''' fname ''');'])
%
%  extract and save the time words in a sensible format
%    time is days, time2 is miliseconds
st_time=gregorian(nc{'time'}(1)+(nc{'time2'}(1)/3600/1000/24));
end_time=gregorian(nc{'time'}(end)+(nc{'time2'}(end)/3600/1000/24));

% or you could plot time, if you want...
% plot(nc{'time'}(:)+nc{'time2'}(:)/(1000*3600*24),'.');
close (nc)
