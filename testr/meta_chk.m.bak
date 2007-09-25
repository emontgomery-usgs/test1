function [nms, todo]=meta_chk(nc_name)
% reads global attributes out of a .nc file to compare to .xls to check
% header info.    etm 5/16/06
%  usage : [att_names, att_vals] = meta_chk('7511aqc-a.nc');
%    the user needs to launch this from the directory where the file resides

nms={'latitude';'longitude';'start_time';'stop_time';'Deployment_date';'Recovery_date';...
    'WATER_DEPTH'; 'sensor_height'; 'magnetic_variation';}
ncf=netcdf(nc_name);

for ik=1:length(nms)
     eval(['to_check{ik}=ncf.' nms{ik} '(:);'])
end

close(ncf);
todo=to_check;
