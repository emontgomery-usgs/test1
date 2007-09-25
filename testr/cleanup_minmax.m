function cleanup_minmax(adv_name, threshold, plt)
%
% assumes this is for adv data 
%  usage cleanup_minmax('adv7481vp-cal.nc',100,'y')
%  emontgomery 6/16/06


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

 figure
vnames=['u_1205min'; 'v_1206min'; 'w_1204min'; 'u_1205max'; 'v_1206max'; 'w_1204max'];

for ik=1:6
    if ik==3 | ik==6
        thold=thold/5;
    else
        thold=threshold;
    end
  ncload(adv_name,vnames(ik,:))
  eval(['xx=find(abs(' vnames(ik,:) ') > thold);'])
  eval(['tmp = ' vnames(ik,:) '/10;'])
  tmp(xx)=ones(length(xx),1)*NaN;
  yy=find(abs(diff(tmp)) > thold/2);
  tmp(yy+1)=ones(length(yy),1)*NaN;
 
  if (strcmp(plt,'y'))
      clf
      subplot(2,1,1)
      eval(['plot(' vnames(ik,:) ')'])
      subplot(2,1,2)
      plot(tmp,'r')
      pause (2)
  end
  
end
  
