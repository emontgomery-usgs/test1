function theResult = zoomsafe(varargin)

% ZoomSafe -- Safe zooming with the mouse.
%  ZoomSafe('demo') demonstrates itself with an interactive
%   line.  Zooming occurs with clicks that are NOT on the line.
%  ZoomSafe('on') initiates safe-zooming in the current window.
%   Zooming occurs with each click in the current-figure, except
%   on a graphical object whose "ButtonDownFcn" is active.
%  ZoomSafe('on', 'all') applies any new axis limits to all the
%   axes in the figure.  For companion axes having exactly the
%   same 'XLim' range as the one that was clicked, the 'YLim'
%   range remains intact.  The same synchronization is invoked
%   for corresponding 'YLim' situations as well.
%  ZoomSafe('all') same as ZoomSafe('on', 'all').
%  ZoomSafe (no argument) same as ZoomSafe('on').
%  ZoomSafe('off') turns it off.
%  ZoomSafe('out') zooms fully out.
%  ZoomSafe(theAmount, theDirection) applies theAmount of zooming
%   to theDirection: 'x', 'y', or 'xy' (default).
%  Note: when zooming actually occurs, this routine returns
%   logical(1); otherwise, logical(0).
%
%   "Click-Mode"   (Macintosh Action)   Result
%   "normal"       (click)              Zoom out x2, centered on click.
%   "extend"       (shift-click)        Zoom in x2, centered on click.
%   "alt"          (option-click)       Center on click without zooming.
%   "open"         (double-click)       Revert to unzoomed state.
%   (Use click-down-and-drag to invoke a rubber-rectangle.)
%
%  Use click-drag to map the zooming to a rubber-rectangle.


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
 
% Version of 19-Jun-1997 08:42:57.
% Updated    02-Aug-1999 14:40:31.

result = logical(0);

if nargin < 1, varargin = {'on'}; end

if isstr(varargin{1}) & ~isempty(varargin{1}) & ...
      any(varargin{1}(1) == '0123456789.')
   varargin{1} = eval(varargin{1});
end

if ~isstr(varargin{1})
   theAmount = varargin{1};
   varargin{1} = 'manual';
end

theFlag = logical(0);
isAll = logical(0);

theOldXLim = get(gca, 'XLim');
theOldYLim = get(gca, 'YLim');

switch varargin{1}
case 'manual'
   isAll = (nargin > 2);
   theDirection = 'xy';
   if nargin > 1, theDirection = varargin{2}; end
   theXLim = get(gca, 'XLim');
   theYLim = get(gca, 'YLim');
   if theAmount == 0
      axis tight
      switch theDirection
      case 'x'
         set(gca, 'YLim', theYLim)
      case 'y'
         set(gca, 'XLim', theXLim)
      case 'xy'
      otherwise
      end
      theAmount = 1;
      theXLim = get(gca, 'XLim');
      theYLim = get(gca, 'YLim');
   end
   cx = mean(theXLim);
   cy = mean(theYLim);
   dx = diff(theXLim) ./ 2;
   dy = diff(theYLim) ./ 2;
   switch theDirection
   case 'x'
      theXLim = cx + [-dx dx] ./ theAmount;
   case 'y'
      theYLim = cy + [-dy dy] ./ theAmount;
   case 'xy'
      theXLim = cx + [-dx dx] ./ theAmount;
      theYLim = cy + [-dy dy] ./ theAmount;
   otherwise
   end
   set(gca, 'XLim', theXLim, 'YLim', theYLim);
   theFlag = 1;
case 'demo'
   x = (0:30) ./ 30;
   y = rand(size(x)) - 0.5;
   for i = 2:-1:1
      subplot(1, 2, i)
      theLine = plot(x, y, '-o');
      set(theLine, 'ButtonDownFcn', 'disp(''## hello'')')
      set(gcf, 'Name', 'ZoomSafe Demo')
   end
   result = zoomsafe('on', 'all');
case 'all'
   result = zoomsafe('on', 'all');
case 'on'
   isAll = (nargin > 1);
   if ~isAll
      set(gcf, 'WindowButtonDownFcn', 'if zoomsafe(''down''), end')
     else
      set(gcf, 'WindowButtonDownFcn', 'if zoomsafe(''down'', ''all''), end')
   end
case 'down'
   isAll = (nargin > 1);
   dozoom = 0;
   switch get(gcbo, 'Type')
   case {'figure'}   % "axes" not needed.
      switch get(gco, 'Type')
	  case {'figure'}
         dozoom = 1;
      otherwise
         if isempty(get(gco, 'ButtonDownFcn'))
            dozoom = 1;
         end
      end
   otherwise
   end
   switch dozoom
   case 1
      thePointer = get(gcf, 'Pointer');
      set(gcf, 'Pointer', 'watch')
      theRBRect = rbrect;
      x = sort(theRBRect([1 3]));
      y = sort(theRBRect([2 4]));
      theXLim = get(gca, 'XLim');
      theYLim = get(gca, 'YLim');
      theLimRect = [theXLim(1) theYLim(1) theXLim(2) theYLim(2)];
	  d = doubleclick;   % Trap any double-click.
      if any(d)   % Valid double-click.
         if ~isAll
            result = zoomsafe('out');
           else
            result = zoomsafe('out', 'all');
         end
         set(gcf, 'Pointer', 'arrow')
		 if nargout > 0, theResult = result; end
         return
	 elseif isempty(d)   % Ignore initial-click of double.
		 if nargout > 0, theResult = result; end
		  return
      else   % Not a double-click.
      end
      switch get(gcf, 'SelectionType')
      case 'normal'
         theFlag = 1;
         theAmount = [2 2];   % Zoom-in by factor of 2.
      case 'extend'
         theFlag = 1;
         theAmount = [0.5 0.5];
      case 'open'   % Pre-empted by "doubleclick" above.
         if ~isAll
            result = zoomsafe('out');
           else
            result = zoomsafe('out', 'all');
         end
         set(gcf, 'Pointer', 'arrow')
		 if nargout > 0, theResult = result; end
         return
      otherwise
         theAmount = [1 1];
         x = [mean(x) mean(x)];
         y = [mean(y) mean(y)];
      end
      if diff(x) == 0 | diff(y) == 0
         cx = mean(x);
         cy = mean(y);
         dx = diff(theXLim) ./ 2;
         dy = diff(theYLim) ./ 2;
         x = cx + [-dx dx] ./ theAmount(1);
         y = cy + [-dy dy] ./ theAmount(2);
        else
         r1 = theLimRect;
         r2 = theRBRect;
         switch get(gcf, 'SelectionType')
         case 'normal'
            r4 = maprect(r1, r2, r1);
         case 'extend'
            r4 = maprect(r2, r1, r1);
         otherwise
            r4 = r1;
         end
         x = r4([1 3]);
         y = r4([2 4]);
      end
      set(gca, 'XLim', sort(x), 'YLim', sort(y))
      theFlag = 1;
	  result = logical(1);
      switch thePointer
      case {'watch', 'circle'}
         thePointer = 'arrow';
      otherwise
      end
      set(gcf, 'Pointer', thePointer)
      set(gcf, 'Pointer', 'arrow')
   otherwise
   end
case 'motion'
case 'up'
case 'off'
   set(gcf, 'WindowButtonDownFcn', '');
case 'out'
   isAll = (nargin > 1);
   theFlag = 1;
   axis tight
   result = logical(1);
otherwise
   temp = eval(varargin{1});
   switch class(temp)
   case 'double'
      if ~isAll
         result = zoomsafe(temp);
        else
         result = zoomsafe(temp, 'all');
      end
   otherwise
      warning('## Unknown option')
   end
end

% Synchronize the other axes.

if isAll & theFlag & 1
   theGCA = gca;
   theXLim = get(theGCA, 'XLim');
   theYLim = get(theGCA, 'YLim');
   theAxes = findobj(gcf, 'Type', 'axes');
   for i = 1:length(theAxes)
      if theAxes(i) ~= theGCA
         axes(theAxes(i))
         x = get(gca, 'XLim');
         y = get(gca, 'YLim');
         if all(x == theOldXLim)
            set(theAxes(i), 'XLim', theXLim)
         end
         if all(y == theOldYLim)
            set(theAxes(i), 'YLim', theYLim)
         end
     end
   end
   axes(theGCA)
end

if nargout > 0, theResult = result; end

% legend   % Causes excessive flashing.

function rect4 = MapRect(rect1, rect2, rect3)

% MapRect -- Map rectangles.
%  MapRect(rect1, rect2, rect3) returns the rectangle
%   that is to rect3 what rect1 is to rect2.  Each
%   rectangle is given as [x1 y1 x2 y2].
%  MapRect('demo') demonstrates itself by showing
%   that maprect(r1, r2, r1) ==> r2.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jun-1997 08:33:39.

if nargin < 1, help(mfilename), rect1 = 'demo'; end

if strcmp(rect1, 'demo')
   rect1 = [0 0 3 3];
   rect2 = [1 1 2 2];
   rect3 = rect1;
   r4 = maprect(rect1, rect2, rect3);
   begets('MapRect', 3, rect1, rect2, rect3, r4)
   return
end

if nargin < 3, help(mfilename), return, end

r4 = zeros(1, 4);
i = [1 3];
for k = 1:2
   r4(i) = polyval(polyfit(rect1(i), rect2(i), 1), rect3(i));
   i = i + 1;
end

if nargout > 0
   rect4 = r4;
  else
   disp(r4)
end

function theResult = doubleclick

% doubleclick -- Trap for double-clicks.
%  doubleclick (no argument) returns TRUE if a click
%   is detected during its execution; otherwise, FALSE.
%   Call "doubleclick" during a "WindowButtonDown" or
%   "ButtonDown" callback, preferably at the top of
%   procedure.  The 'Interruptible' property of the
%   callback-object must be 'on'.  The double-click
%   time is 0.5 sec.  A valid double-click causes
%   two values to be returned: first, a logical(1),
%   then an empty-matrix [].  The latter signifies
%   the single-click that initiated the process.
%   For a valid single-click, only logical(0) is
%   returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Jul-1998 09:47:16.

global CLICK_COUNT

DOUBLE_CLICK_TIME = 1/2;   % Seconds.

if isempty(CLICK_COUNT), CLICK_COUNT = 0; end

CLICK_COUNT = CLICK_COUNT + 1;

if CLICK_COUNT == 1
	tic
	while isequal(CLICK_COUNT, 1) & toc < DOUBLE_CLICK_TIME, end
end

drawnow   % Process the event-cue.

% Note:
%  Despite the "drawnow" seen above, Matlab does not
%  update the "SelectionType" in timely fashion, so
%  it cannot be used to trap a double-click properly.

result = (CLICK_COUNT > 1);

CLICK_COUNT = [];

if nargout > 0
	theResult = result;
else
	disp(result)
end
