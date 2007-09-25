% script to do the conversion to hourly averaged from the 'b' version of
% files charlene created for MyrtleBeach


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

 cd '/mnt/ccdr_stg/data/MyrtleBeach/725'
  dolly('7251mc-b.nc', '7251mc-b1h.nc', 'hour_avg')
cd '/mnt/ccdr_stg/data/MyrtleBeach/722/722sc'
  dolly('7222sc-b.nc', '7222sc-b1h.nc', 'hour_avg')
cd '/mnt/ccdr_stg/data/MyrtleBeach/724/724sc'
  dolly('7242sc-b.nc', '7242sc-b1h.nc', 'hour_avg')
cd '/mnt/ccdr_stg/data/MyrtleBeach/744/744sc'
  dolly('7442sc-b.nc', '7442sc-b1h.nc', 'hour_avg')
