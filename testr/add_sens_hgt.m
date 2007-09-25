function add_sens_hgt(ncfilename,mlog_dep,mlog_hgt_mab)
% adds nc.sensor_height=## (as mab) to adc and adwp .nc files
% will overwrite WATER_DEPTH and thus put ADCP depth back to matching the
% log.  However {'variable'}.sensor_depth will not match.
% usage add_sens_hgt('7431mc-a', 10.6, 0.32)
% etm (after fl code) 5/25/06


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
iswp=findstr('wp', ncfilename);

result=fcopy(ncfilename,new_nm);
nc = netcdf(ncfilename, 'write');
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
% this part applies to all types
  history = ['added attr. sens_hgt.:' nc.history(:)];
  ifeed = findstr(history,lfeed);
  history(ifeed) = ':';
  nc.history = ncchar(history);
  nc.WATER_DEPTH=mlog_dep;
  nc.sensor_height= ncfloat(mlog_hgt_mab);
       
close(nc)
