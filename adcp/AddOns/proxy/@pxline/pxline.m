function theResult = PXLine(varargin)

% PXLine -- Constructor for interactive lines.
%  PXLine(nLines) demonstrates itself with nLines.
%  PXLine('demo') invokes pxline(5).
%  PXLine(...) creates one or more interactive lines,
%   using the syntax of the Matlab "line" function.
%
%   -- A "pxline" object is returned; "ans" is used
%   if no output argument is provided.
%
%   -- Use "pxcallback('theCallback')" to set the name
%   of the callback that will be invoked after a
%   mouse-selection has occurred on the line, as
%   feval('theCallback', {thePXLine}) -- note that
%   the "pxline" object is delivered inside a cell,
%   since the callback is not a method of the "pxline"
%   class.
%
%   -- Use "pxvalue(thePXLine) to get the indices
%   of selected points in thePXLine.
%
%   -- The pseudo-fields "x", "y", "z", and "s" (selected)
%   of the "pxline" object can be referenced and assigned
%   with conventional indices, as in "x = theObject.x" and
%   "theObject.x = x".


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
 
% Version of 23-Apr-1997 08:16:09.

if nargin < 1, help(mfilename), varargin{1} = 'demo'; end

if nargin == 1 & rem(varargin{1}, 1) ~= 0 & ishandle(varargin{1})
   switch get(varargin{1}, 'Type')
   case 'line'
      h = varargin{1};
      x = get(h, 'XData');
      y = get(h, 'YData');
      z = get(h, 'ZData');
      c = get(h, 'Color');
      switch isempty(z)
      case 1
         result = pxline(x(:), y(:), 'Color', c);
      otherwise
         result = pxline(x(:), y(:), z(:), 'Color', c);
      end
      if nargout > 0, theResult = result; end
   otherwise
   end
   return
end

if nargin < 2 & strcmp(varargin{1}, 'demo')
   varargin{1} = 5;
end

if nargin > 0 & isstr(varargin{1})
   varargin{1} = eval(varargin{1});
end

if length(varargin) == 1 & length(varargin{1}) < 3
   theSize = varargin{1};
   if length(theSize) == 1, theSize = [20*theSize theSize]; end
   m = theSize(1); n = theSize(2);
   x = (0:m).' * ones(1, n);
   y = (rand(size(x)) - 0.5) + ones(size(x, 1), 1) * (1:size(x, 2));
   theFSW = findobj('Type', 'figure', 'Name', 'PXLine Demo');
   if isempty(theFSW)
      theFSW = pxfsw('PXLine Demo');
     else
      figure(theFSW)
   end
   oldLines = findobj(gcf, 'Type', 'line');
   if ~isempty(oldLines), delete(oldLines), end
   thePXLine = pxline(x, y);
   eval('zoomsafe', 'disp('' ## No zoomsafe installed'')');
   title(['PXLine(' mat2str(theSize) ')'])
   xlabel('x'), ylabel('y')
   pxevent(theFSW, 'Home')
   for i = 1:2, pxevent(theFSW, 'ZoomInX'), end
   if nargout > 0
      theResult = thePXLine;
     else
      assignin('base', 'ans', thePXLine)
   end
   return
end

theXData = varargin{1};
theYData = varargin{2};
if nargin > 2 & ~isstr(varargin{3})
   theZData = varargin{3};
  else
   theZData = 0 .* theXData;
end
theSData = zeros(size(theXData));   % Selections.

% Build a single line of NaN-separated segments.

x = theXData;
y = theYData;
z = theZData;
s = theSData + NaN;
[m, n] = size(x);
if m == 1   % Convert to column-vector.
   x = x.'; y = y.'; z = z.'; s = s.';
end
[m, n] = size(x);
theNaNs = zeros(1, n) + NaN;
x = [x; theNaNs];
y = [y; theNaNs];
z = [z; theNaNs];
s = [s; theNaNs];   % Selections.
varargin{1} = x(:);
varargin{2} = y(:);
if nargin > 2 & ~isstr(varargin{3}), varargin{3} = z(:); end

% Create the mask, then the line.

varargout{1} = [];
v = vargstr('line', length(varargin), 1);
eval(v);
theMask = varargout{1};
set(theMask, 'EraseMode', 'xor', ...
             'ButtonDownFcn', 'disp(''pxline_mask'')', ...
             'Tag', 'pxline_mask');
eval(v);
theLine = varargout{1};
set(theLine, 'EraseMode', 'normal', 'Tag', 'pxline');
x = get(theLine, 'XData');
if isempty(get(theLine, 'ZData'))
   set(theLine, 'ZData', zeros(size(x)))
end

% Adjust the selections mask.

theMarker = get(theLine, 'Marker');
theColor = get(theLine, 'Color');
if strcmp(theMarker, 'square')
   theMarker = 'o';
  else
   theMarker = 'square';
end
theMarkerSize = 6;   % No longer used.

% Newer adjustments.

theLineStyle = 'none';
theMarker = 'none';
theSelectionHighlight = 'on';
theSelected = 'on';

set(theMask, 'ZData', s(:), ...
             'LineStyle', theLineStyle, ...
             'Marker', theMarker, ...
             'MarkerSize', theMarkerSize, ...
             'MarkerFaceColor', theColor, ...
             'SelectionHighlight', theSelectionHighlight, ...
             'Selected', theSelected, ...
             'UserData', theLine);

theStruct.itSelf = [];
self = class(theStruct, 'pxline', px(theLine));
self.itSelf = px(self);
pxset(self, 'itsObject', self)
p = px(self);
pxenable(p, p);
pxenable(p)

pxset(self, 'itsXData', theXData)
pxset(self, 'itsYData', theYData)
pxset(self, 'itsZData', theZData)
pxset(self, 'itsSData', theSData)
pxset(self, 'itsMask', theMask)
pxset(self, 'itsCallback', '')
pxset(self, 'itsValue', [])
pxset(self, 'itsHandles', theMask)
result = self;

pxevent(self, 'Refresh')
   
if nargout > 0
   theResult = result;
  else
   assignin('base', 'ans', result)
end
