function fix_adv_salt(ncfilename)
% computes correct salinity for adv's with ctd attached.  Current method
% generates something obviously NOT salinity
% usage fix_adv_salt('adv7282vp-cal2')
% etm 6/30/06


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

 
perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_old.nc'];

result=fcopy(ncfilename,new_nm);
nc = netcdf(ncfilename, 'write');
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['recomputed salinity from T&C.:' nc.history(:) ':' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
% have to make cond into cond. ratio and adjust units
zz=sw_salt((nc{'CTDCON_4218'}(:)*10/sw_c3515),....
    nc{'CTDTMP_4211'}(:),sw_pres(nc{'depth'}(:),nc{'lat'}(:)));
nc{'CTDSAL_4214'}(:)=zz;
close(nc)
