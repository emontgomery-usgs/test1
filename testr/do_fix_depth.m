% file to correct all the depth information in Myrtle Beach data
%
% run on etm's PC, using data copied from Charlene's disk under dvd\DataFiles.
%  In Matlab, cd'd to /home/ellyn/validation/MyrtleBeach/datafiles and ran this file
% etm 6/13/06
%


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

 res=fix_depth_meta(720, 11.7122, 'from ADCP');
res=fix_depth_meta(722, 10.4022, 'from ADCP');
res=fix_depth_meta(724, 9.9288, 'from ADCP');
res=fix_depth_meta(726, 7.534, 'from ADCP');
res=fix_depth_meta(728, 10.6, 'from Mooring Log');
res=fix_depth_meta(732, 10.229, 'from ADCP');
res=fix_depth_meta(742, 9.9539, 'from ADCP');
res=fix_depth_meta(744, 10.8355, 'from ADCP');
res=fix_depth_meta(746, 7.505, 'from ADCP');
res=fix_depth_meta(748, 9.8, 'from Mooring Log');
res=fix_depth_meta(752, 9.935, 'from ADCP');
res=fix_depth_meta(753, 10.4797, 'from ADCP');
%
% now deal with the microcats on surface moorings...
res=fix_depth_meta(723, 9.3, 'from Mooring Log');
res=fix_depth_meta(725, 10.7, 'from Mooring Log');
%res=fix_depth_meta(727, 9.6, 'from Mooring Log');
res=fix_depth_meta(729, 10.4, 'from Mooring Log');
res=fix_depth_meta(731, 9.4, 'from Mooring Log');
%res=fix_depth_meta(741, 9.9, 'from Mooring Log');
res=fix_depth_meta(743, 9.3, 'from Mooring Log');
res=fix_depth_meta(745, 10.8, 'from Mooring Log');
%res=fix_depth_meta(747, 9.6, 'from Mooring Log');
res=fix_depth_meta(749, 10.5, 'from Mooring Log');
res=fix_depth_meta(751, 8.62, 'from ADCP');
