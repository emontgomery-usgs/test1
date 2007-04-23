function add_sens_hgt(ncfilename,mlog_dep,mlog_hgt_mab)
% adds nc.sensor_height=## (as mab) to adc and adwp .nc files
% will overwrite WATER_DEPTH and thus put ADCP depth back to matching the
% log.  However {'variable'}.sensor_depth will not match.
% usage add_sens_hgt('7431mc-a', 10.6, 0.32)
% etm (after fl code) 5/25/06

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
