% autonan_on
% sets global netcdf toolbox options for autonan to on
% for creating and modifying .nc files autonan should probably be off
% for displaying graphics in already existing .nc files ON is useful
%   ** you may also need to "clear global"
% 
global nctbx_options;
nctbx_options.theAutoNaN = 1;
nctbx_options.theAutoscale = 1;

