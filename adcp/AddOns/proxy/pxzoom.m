function status = PXZoom(theFactor, theAxes, theDirection)

% PXZoom -- No help available.
% PXZoom -- Zoom the limits of an axes.
%  PXZoom(theFactor, theAxes, 'theDirection') zooms the limits
%   of theAxes by theFactor along theDirection ('x' or 'y').
%   TheFactor defaults to 2, meaning to zoom in by a factor
%   of 2.  Its inverse is 0.5.  If theFactor is 0, theAxes is
%   returned to its 'auto' mode.  TheAxes defaults to all axes
%   in the current figure.  This routine affects only the x and
%   y directions.
%  PXZoom(theFactor, 'theDirection') executes
%   PXZoom(theFactor, [], 'theDirection'), which zooms all axes
%   along theDirection ('x' or 'y').


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

  
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargout > 0, status = 0; end

if nargin < 1, theFactor = 2; end
if nargin < 2, theAxes = []; end
if nargin < 3, theDirection = 'xy'; end

if isstr(theAxes)
   theDirection = theAxes;
   theAxes = [];
end

if isempty(theAxes)
   theAxes = findobj(gcf, 'Type', 'axes');
end

if ~isempty(theAxes)
   theAxes = flipud(theAxes);
   for i = 1:length(theAxes)
      axes(theAxes(i))
      zoomsafe(theFactor, theDirection)
   end
end

figure(gcf)
