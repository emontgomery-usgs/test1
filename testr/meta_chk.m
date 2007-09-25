function [nms, todo]=meta_chk(nc_name)
% reads global attributes out of a .nc file to compare to .xls to check
% header info.    etm 5/16/06
%  usage : [att_names, att_vals] = meta_chk('7511aqc-a.nc');
%    the user needs to launch this from the directory where the file resides


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

 
nms={'latitude';'longitude';'start_time';'stop_time';'Deployment_date';'Recovery_date';...
    'WATER_DEPTH'; 'sensor_height'; 'magnetic_variation';}
ncf=netcdf(nc_name);

for ik=1:length(nms)
     eval(['to_check{ik}=ncf.' nms{ik} '(:);'])
end

close(ncf);
todo=to_check;
