function theResult = PXEvent(self, thePXEvent, theMessage)

% PXEvent -- Event handler for PXImage.
%  PXEvent(self, thePXEvent, theMessage) processes thePXEvent
%   and theMessage on behalf of self, a "pximage" object.


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

theImage = px(self);

TIMING = 1;
TIMING = 0;

switch lower(thePXEvent)
case 'buttondownfcn'
   theRBLine = rbrect;
if TIMING, tic, end
   theStartPoint = theRBLine(1:2);
   theEndPoint = theRBLine(3:4);
   xStart = theStartPoint(1);
   yStart = theStartPoint(2);
   xEnd = theEndPoint(1);
   yEnd = theEndPoint(2);
   
% Adjust for aspect ratio of plot.

   theUnits = get(gca, 'Units');
   set(gca, 'Units', 'pixels')
   thePos = get(gca, 'Position');
   dx = thePos(3); dy = thePos(4);
   set(gca, 'Units', theUnits)
   
   xScale = abs(diff(get(gca, 'XLim'))) ./ dx;
   yScale = abs(diff(get(gca, 'YLim'))) ./ dy;
   
   x = get(theImage, 'XData');
   y = get(theImage, 'YData');
   
   [x, y] = meshgrid(x, y);
   
   xx = x ./ xScale; yy = y ./ yScale; ww = xx+sqrt(-1)*yy;
   
   xs = xStart ./ xScale; ys = yStart ./ yScale;
   xe = xEnd ./ xScale; ye = yEnd ./ yScale;
   
   theStart = xs + sqrt(-1)*ys; theEnd = (xe + sqrt(-1)*ye);

   d = abs(ww - theStart);
   [iStart, jStart] = find(d == min(min(d)));
   iStart = iStart(1); jStart = jStart(1);
   
   d = abs(ww - theEnd);
   [iEnd, jEnd] = find(d == min(min(d)));
   iEnd = iEnd(1); jEnd = jEnd(1);

   i = min(iStart, iEnd):max(iStart, iEnd);
   j = min(jStart, jEnd):max(jStart, jEnd);

   theSData = pxget(self, 'itsSData');
   if size(theSData, 1) == 1, theSData = theSData.'; end
   temp = theSData(i, j);
   if ~all(all(temp))
      if strcmp(get(gcf, 'SelectionType'), 'normal')
         temp = 1;
        elseif strcmp(get(gcf, 'SelectionType'), 'extend')
         temp = 0;
      end
     else
      if strcmp(get(gcf, 'SelectionType'), 'normal')
         temp = 0;
        elseif strcmp(get(gcf, 'SelectionType'), 'extend')
         temp = 1;
      end
   end
   theSData(i, j) = temp;
if TIMING, compute_time = toc, tic, end
   pxset(self, 'itsSData', theSData);
   pxset(self, 'itHasChanged', 1);   % See "pximage/changed()".
   pxevent(self, 'refresh')
   
   theCallback = pxget(self, 'itsCallback');
   if ~isempty(theCallback) & isstr(theCallback)
      feval(theCallback, {self})
   end
if TIMING, draw_time = toc, end
case 'refresh'
   theFigure = px(self);
   while ~strcmp(get(theFigure, 'Type'), 'figure')
      theFigure = get(theFigure, 'Parent');
   end
   figure(theFigure)
   cmap = colormap;
   cmap(1, :) = 0;   % Lowest-value gets "black".
   colormap(cmap)
   c = pxget(self, 'itsCData');
   s = pxget(self, 'itsSData');
   c(logical(s)) = NaN;   % Black.
   set(theImage, 'CData', c)
otherwise
   result = PXEvent(super(self), thePXEvent, theMessage)
end

if nargout > 0, theResult = result; end
