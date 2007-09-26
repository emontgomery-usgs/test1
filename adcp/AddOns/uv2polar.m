function [dir,spd] = uv2polar(u,v)
% uv2polar:  direction and speed of (east, north) currents
%
% function [dir,spd] = uv2polar(u,v)
%       u is eastward current component
%       v is northward current component
%       dir is compass direction of current
%             (90 for eastward flow, 270 for westward)
%       spd is magnitude of current
%
%       Fran Hotchkiss, February 20, 1998.


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

 
[dir,spd] = cart2pol(v,u);
i = find(dir < 0);
dir(i) =dir(i) + 2*pi;
dir = dir .* 180 ./ pi;
