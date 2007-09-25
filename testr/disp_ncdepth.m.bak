function disp_ncdepth(fname)
%
% opens a .nc file and displays the headers that were likely to have
% changed
%
%  usage disp_ncdepth('7265sc-a.nc')


if (exist(fname, 'file'))
    nc=netcdf(fname);
   disp ([fname ':  WATER_DEPTH: ' num2str(nc.WATER_DEPTH(:)) ,...
       ', inst_height: ' num2str(nc.inst_height(:)) ', inst_depth: ',...
       num2str(nc.inst_depth(:))])
   
    vn=var(nc);
   for ik=6:length(vn)
     if (~isempty(vn{ik}.sensor_depth(:)))
         disp ([name(vn{ik}) ' ' num2str(nc{name(vn{ik})}.sensor_depth(:))])
     end
   end
close(nc)
end