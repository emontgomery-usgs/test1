function theResult = PXEvent(self, thePXEvent, theMessage)

% PXEvent -- Event handler for PXSurface.
%  PXEvent(self, thePXEvent, theMessage) processes thePXEvent
%   and theMessage on behalf of self, a "pxsurface" object.


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
 
% Version of 23-Apr-1997 08:55:57.

if nargin < 1, help(mfilename), return, end
if nargin < 2, thePXEvent = ''; end
if nargin < 3, theMessage = []; end

assignin('base', 'ans', self)

result = [];

h = px(self);

switch lower(thePXEvent)
case {'buttondownfcn', ''}
   set(h, 'Selected', 'off')
   if (1)
      thePointer = get(gcf, 'Pointer');
      set(gcf, 'Pointer', 'circle')
      theStartPoint = mean(get(gca, 'CurrentPoint'));
      theRBBox = rbbox;   % Pixels in the gcf.
      theEndPoint = mean(get(gca, 'CurrentPoint'));
      set(gcf, 'Pointer', thePointer)
     else
      theRBLine = rbline;
      theStartPoint = theRBLine(1:2);
      theEndPoint = theRBLine(3:4);
   end
   xStart = theStartPoint(1);
   yStart = theStartPoint(2);
   xEnd = theEndPoint(1);
   yEnd = theEndPoint(2);
   x = get(h, 'XData');
   y = get(h, 'YData');
   z = get(h, 'ZData');
   [iStart, jStart] = find(xStart <= x & yStart <= y);
   iStart = iStart(1); jStart = jStart(1);
   [iEnd, jEnd] = find(xEnd <= x & yEnd <= y);
   iEnd = iEnd(1); jEnd = jEnd(1);
   iRange = (min(iStart, iEnd):max(iStart, iEnd)) - 1;
   jRange = (min(jStart, jEnd):max(jStart, jEnd)) - 1;
   g = pxget(self, 'itsCompanion');
   gz = get(g, 'ZData');
   i = 2*iRange; j = 2*jRange;
   temp = gz(i, j);
   selected = ~isnan(temp);
   if all(all(selected))
      if strcmp(get(gcf, 'SelectionType'), 'normal')
         temp = NaN;   % De-select.
        elseif strcmp(get(gcf, 'SelectionType'), 'extend')
         temp = z(iRange, jRange) + 1;
      end
     else
      if strcmp(get(gcf, 'SelectionType'), 'normal')
         temp = z(iRange, jRange) + 1;
        elseif strcmp(get(gcf, 'SelectionType'), 'extend')
         temp = NaN;   % De-select.
      end
   end
   gz(i, j) = temp;
   set(g, 'ZData', gz);
   theCallback = pxget(self, 'itsCallback');
   if ~isempty(theCallback) & isstr(theCallback)
      feval(theCallback, {self})
   end
otherwise
   result = PXEvent(super(self), thePXEvent, theMessage)
end

if nargout > 0, theResult = result; end
