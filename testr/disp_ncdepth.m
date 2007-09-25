function disp_ncdepth(fname)
%
% opens a .nc file and displays the headers that were likely to have
% changed
%
%  usage disp_ncdepth('7265sc-a.nc')


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