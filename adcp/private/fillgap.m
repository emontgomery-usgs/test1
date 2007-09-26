function [v,gaps_filled,gaps_unfilled]=fillgap(u,maxgap);
% FILLGAP fill gaps (nans) shorter than MAXGAP by linear interpolation
% gaps bigger than MAXGAP values long will not be filled
% Usage: [v,gaps_filled,gaps_unfilled]=fillgap(u,maxgap);
%
% u = vector or 2D matrix (columns of time series data)
% maxgap = max number of values in gap to fill
%
% Note: must be uniformly spaced time series.  If not, use
% "interp1gap" to fill in mixing time and NaN gap values before
% using "fillgap".
% rsignell@usgs.gov


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

 
[m,n]=size(u);
u=u(:);
good=find(finite(u));
dind=diff(good);
ibound1=find(dind<=(maxgap+1)& dind>1);  
ibound=find(dind>(maxgap+1));  
gaps_filled=length(ibound1);
gaps_unfilled=length(ibound);

bind=good(ibound); %boundary between good data and bad data with gaps > maxgap
x=1:length(u);
v=interp_r(x(good),u(good),x);
v=reshape(v,m,n);
%
% mask gaps that were longer than maxgap
%
for j=1:length(bind),
  j0=bind(j)+1;
  j1=bind(j)+dind(ibound(j))-1;
  jj=j0:j1;
  v(jj)=v(jj)*NaN;
end

