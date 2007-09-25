 function rem_hght0s(ncfilename)
%  for MB 7861adcp- it appears that there weren't enough bins to catch the
%  surface, so there are 0s in the data where the tops of the signal should
%  be.  Replaced them with NaN
%  emontgomery 1/26/07


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

result=fcopy(ncfilename,new_nm);    % save the original
nc = netcdf(ncfilename, 'write');   % open the a (file named b)
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['made 0 in hght_18 NaN & added comment.:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
nc{'hght_18'}.note= ncchar('tops of excursions clipped- 0s in data record changed to NaN')

% find and replace 0's in the data with NaN
h=nc{'hght_18'}(:);
zz=find(h==0);
h(zz)=NaN;
nc{'hght_18'}(:)=h;

close(nc)
