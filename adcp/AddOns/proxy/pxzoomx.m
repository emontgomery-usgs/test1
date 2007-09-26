function status = DoZoomX(theFactor, theAxes)

% DoZoomX -- No help available.
% DoZoomX -- Zoom the limits of 'x' axes.
%  DoZoomX(theFactor, theAxes) zooms the 'x' limits of theAxes
%   (default = all axes in gcf) by theFactor (default = 2).


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

  
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1, theFactor = 2; end
if nargin < 2, theAxes = []; end

result = dozoom(theFactor, theAxes, 'x');

if nargout > 0, status = result; end
