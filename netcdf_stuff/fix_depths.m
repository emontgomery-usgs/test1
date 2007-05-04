result=fcopy('7552vm-trm.nc','7552vm-e.nc')
nc = netcdf('7552vm-e.nc', 'write');
if isempty(nc), return, end
 
%% Global attributes:
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['Depth values corrected. :' nc.history(:)];
nc.history = ncchar(history);
nc.inst_depth = ncfloat(9.3);
nc{'depth'}(1) = 9.3;
nc{'u_1205'}.sensor_depth = ncfloat(9.3);
nc{'v_1206'}.sensor_depth = ncfloat(9.3);
nc{'T_28'}.sensor_depth = ncfloat(9.3);
close(nc)
