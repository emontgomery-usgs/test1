% run delsed_var repeatedly to get rid of sed?_981 variable
% which was derived incorrectly from neph*
%delsed_var('7261advs-a.nc');


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

 delsed_var('7262advs-a.nc');
delsed_var('7461advs-a.nc');
delsed_var('7462advs-a.nc');
delsed_var('7282advs-a.nc');
delsed_var('7482advs-a.nc');
%delsed_var('728pcvp-cal5.nc');
%delsed_var('748pcvp-cal6.nc');
