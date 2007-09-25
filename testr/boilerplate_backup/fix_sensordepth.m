function fix_sensordepth(ncfilename,inst_dep)
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
history = ['attributes corrected.:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
 if (nc.inst_depth ~= inst_dep)
   nc.inst_depth = ncfloat(inst_dep);
 end
% variable attributes
nc{'T_28'}.sensor_depth=ncfloat(inst_dep);
nc{'C_51'}.sensor_depth=ncfloat(inst_dep);
nc{'S_40'}.sensor_depth=ncfloat(inst_dep);
nc{'STH_71'}.sensor_depth=ncfloat(inst_dep);
close(nc)
