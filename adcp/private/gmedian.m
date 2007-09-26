function xnew=gmedian(x)
% gmedian - just like median, except that it skips over bad points
%  Usage:  xnew=gmedian(x);
%             x can be a vector or matrix


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. Côté, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andrée L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

 [imax,jmax]=size(x);
if(imax==1),
  imax=jmax;
  jmax=1;
  x=x.';
end
for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=median(x(good,j));
       else
          xnew(j)=NaN;
       end
end
