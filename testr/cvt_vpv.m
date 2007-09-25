function cvt_vpv(fname)
%
% converts an epic format ADCP data file to the format needed as input to
% vpv, a velocity profile display program.


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

 
% which write_vpv
ncload(fname,'u_1205');
ncload(fname,'v_1206');
ncload(fname,'time');
ncload(fname,'time2');
% convert epic time to matlab time
  % EPIC time in netcdf files stored as Julian Day in 2 parts
    tt=(time)+time2/(86400000);
  % Julian day 2440000 begins at 0000 hours, May 23, 1968
    mdnt=tt-2440000+datenum('23-May-1968');
    
    %now use write_vpv to create the outputs
    oname=[fname(1:5) '_vpv.txt'];
    write_vpv(oname, mdnt, u_1205, v_1206);
  