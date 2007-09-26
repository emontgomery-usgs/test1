function theResult = PXFSW(theName, theScrollbars, theMenuName)

% PXFSW -- Full-Service-Window.
%  PXFSW((theName, theScrollbars) creates a Full-Service-Window
%   with theName and theScrollbars (see PXWindow/PXWindow).
%   TheMenuName defaults to '<PXFSW>'.
%  PXFSW('demo') creates a demonstration window.


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
 
% Version of 16-Apr-1997 09:23:16.

if nargin < 1, theName = 'Full-Service-Window'; end

if strcmp(theName, 'demo')
   thePXFSW = pxfsw('PXFSW Demonstration', 4);
   
   subplot(2, 2, 1)
   image, axis image, axis ij
   set(gca, 'Box', 'on')
   view(2)
   
   subplot(2, 2, 2)
   load penny
   thePenny = P(41:90, 51:100);
   h = surface(thePenny);
   theZData = get(h, 'ZData');
   set(h, 'ZData', 0 .* theZData, 'EdgeColor', 'none')
   hold on
   contour3(thePenny, 'k')
   hold off
   axis tight, axis ij
   set(gca, 'Box', 'on')
   view(2)
   
   subplot(2, 1, 2)
   x = (0:100);
   t = 2 .* pi .* x ./ max(x);
   y = cos(5 .* t); z = sin(5 .* t);
   plot3(x, y, z, 'b-o')
   set(gca, 'Box', 'on')
   view(2)
   
   if nargout > 0, self = thePXFSW; end
   return
end

if nargin < 2, theScrollbars = 'YX'; end
if nargin < 3, theMenuName = ''; end

theStruct.itSelf = [];
self = class(theStruct, 'pxfsw', pxwindow(theName, theScrollbars));
self.itSelf = px(self);
pxset(self, 'itsObject', self);

h = px(self);
pxenable(h, h);

pxfswmenu(self, theMenuName)

if nargout > 0, theResult = self; end
