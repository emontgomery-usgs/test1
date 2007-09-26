function theResult = PXEvent(self, thePXEvent, theMessage)

% PXEvent -- Event handler for PXLine.
%  PXEvent(self, thePXEvent, theMessage) processes thePXEvent
%   and theMessage on behalf of self, a "pxline" object.


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

theLine = px(self);
theMask = pxget(self, 'itsMask');

TIMING = 1;
TIMING = 0;

switch lower(thePXEvent)
case 'buttondownfcn'
   set(theLine, 'Selected', 'off')
   theRBLine = rbline;
if TIMING, tic, end
   theStartPoint = theRBLine(1:2);
   theEndPoint = theRBLine(3:4);
   xStart = theStartPoint(1);
   yStart = theStartPoint(2);
   xEnd = theEndPoint(1);
   yEnd = theEndPoint(2);
   
   theXData = pxget(self, 'itsXData');
   [m, n] = size(theXData);
   if m == 1, theXData = theXData.'; end
   [m, n] = size(theXData);
   x = zeros(m+1, n);
   y = zeros(m+1, n);
   z = zeros(m+1, n);
   x(:) = get(theLine, 'XData');
   y(:) = get(theLine, 'YData');
   z(:) = get(theLine, 'ZData');
   
   x(isnan(x)) = inf;
   y(isnan(y)) = inf;
   
% Adjust for aspect ratio of plot.

   theUnits = get(gca, 'Units');
   set(gca, 'Units', 'pixels')
   thePos = get(gca, 'Position');
   dx = thePos(3); dy = thePos(4);
   set(gca, 'Units', theUnits)
   
   xScale = abs(diff(get(gca, 'XLim'))) ./ dx;
   yScale = abs(diff(get(gca, 'YLim'))) ./ dy;
   
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
   if ~all(temp)
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
   x = pxget(self, 'itsXData');
   y = pxget(self, 'itsYData');
   z = pxget(self, 'itsZData');
   s = pxget(self, 'itsSData');
   if size(x, 1) == 1, x = x.'; end
   if size(y, 1) == 1, y = y.'; end
   if size(z, 1) == 1, z = z.'; end
   if size(s, 1) == 1, s = s.'; end
   s(s == 0) = NaN;
   s(~isnan(s)) = z(~isnan(s));
   [m, n] = size(x);
   theNaNs = zeros(1, n) + NaN;
   x = [x; theNaNs];
   y = [y; theNaNs];
   z = [z; theNaNs];
   s = [s; theNaNs];
   set(theMask, 'XData', x(:), 'YData', y(:), 'ZData', s(:))
   if strcmp(theMessage, 'all')
      set(theLine, 'XData', x(:), 'YData', y(:), 'ZData', z(:))
   end
case 'nanify'   % This needs work!!
   theSData = pxget(self, 'itsSData');
   f = find(theSData(:) == 1);
   if any(f)
      theXData = pxget(self, 'itsXData');
      theXData(f) = NaN;
      pxset(self, 'itsXData', theXData);
      pxevent(self, 'refresh')
   end
otherwise
   result = PXEvent(super(self), thePXEvent, theMessage)
end

if nargout > 0, theResult = result; end
