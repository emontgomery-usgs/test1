function PXHome(theFigure)

% PXHome -- Restore a figure to its "Home" view.
%  PXHome(theFigure) restores theFigure to its "Home"
%   view.  TheFigure defaults to the current figure.


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

  
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 08-Apr-1997 16:34:57.

% Find the axes and sliders.

if nargin < 1, theFigure = gcf; end

theAxes = findobj(theFigure, 'Type', 'axes');

theSliders = findobj(theFigure, 'Type', 'uicontrol', ...
                                'Style', 'slider');

% Home -- Unzoomed view and centered scrollbars.

theCurrentAxes = gca;
for i = 1:length(theAxes)
   axes(theAxes(i)), view(2)
   set(theAxes(i), 'CLimMode', 'auto')
   axis('tight')
end
axes(theCurrentAxes)

for i = 1:length(theSliders)
   theMin = get(theSliders(i), 'Min');
   theMax = get(theSliders(i), 'Max');
   lims = [theMin theMax];
   theValue = (max(lims) + min(lims)) ./ 2;
   set(theSliders(i), 'Value', theValue)
end

pxscroll

if nargout > 0, status = 0; end
