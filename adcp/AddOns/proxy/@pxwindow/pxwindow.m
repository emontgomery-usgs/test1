function theResult = PXWindow(theTitle, theScrollbars)

% PXWindow -- Window with scrollbars.
%  PXWindow(theTitle, theScrollbars) creates a window
%   with theScrollbars (one or more of 'XYZC').  The
%   PXObject is returned.
%  PXWindow(theTitle, nScrollbars) creates
%   the window with nScrollbars, in the order 'YXZC',
%   corresponding to right, bottom, left, and top.


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
 
% Version of 10-Apr-1997 16:18:25.

if nargin < 1
   theTitle = 'PXWindow';
   theScrollbars = 2;
  elseif nargin == 1
   if ~isstr(theTitle)
      theScrollbars = theTitle;
      theTitle = 'PXWindow';
     else
      theScrollbars = 2;
   end
end

% Create the figure.

theFigure = figure('Name', theTitle, 'Visible', 'off');

% Allocate the basic object.

theStruct.itSelf = theFigure;
self = class(theStruct, 'pxwindow', px(theFigure));

% Bind the object to itself.

pxset(self, 'itsObject', self)

% Enable events via the the PXReference.

h = px(self);
pxenable(h, h);

pxenable(h, 'WindowButtonDownFcn')
pxenable(h, 'ResizeFcn')

% Create the scrollbars.

if isstr(theScrollbars)
   nScrollbars = length(theScrollbars);
  else
   nScrollbars = theScrollbars;
   theScrollbars = 'YXZC';
end

nScrollbars = min(nScrollbars, length(theScrollbars));
theScrollbars = upper(theScrollbars);

for i = 1:nScrollbars
   pxscrollbar([theScrollbars(i) 'Scroll']);
end

% Show the figure.

pxresize(h)
set(h, 'Visible', 'on')
set(gca, 'Box', 'on')

if nargout > 0, theResult = self; end
