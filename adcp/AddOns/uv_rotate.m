function [ur,vr] = uv_rotate(u,v,theta)

%  uv_rotate:  rotates (east, north) current components
%
% function [ur,vr] = uv_rotate(u,v,theta)
%      (u,v) are (east, north) current components.
%      theta is rotation angle in compass degrees.
%      ur is the current component in a direction 
%          theta degrees clockwise from east.
%      vr is the current component in a direction 
%          theta degrees clockwise from north.


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

 
[dir,spd] = uv2polar(u,v);
dir = dir - theta;
[ur,vr] = polar2uv(dir,spd);
