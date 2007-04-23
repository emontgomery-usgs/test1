% autonan_off
% sets global netcdf toolbox options for autonan to off
% for creating and modifying .nc files autonan should probably be off
% for displaying graphics in already existing .nc files ON is useful
%   ** you may also need to "clear global"
% 
global nctbx_options;
nctbx_options.theAutoNaN = 0;
nctbx_options.theAutoscale = 0;

