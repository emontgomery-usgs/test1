function theResult = rbline(onMouseUp, onMouseMove, onMouseDown)

% rbline -- Rubber line tracking (Matlab-4 and Matlab-5).
%  rbline('demo') demonstrates itself.
%  rbline('onMouseUp', 'onMouseMove', 'onMouseDown') conducts interactive
%   rubber-line tracking, presumably because the mouse button was pressed
%   down on the current-callback-object (gcbo).  The 'on...' callbacks are
%   automatically invoked with: "feval(theCallback, theInitiator, theLine)"
%   after each window-button event, using the object that started this
%   process, plus theLine as [xStart yStart xEnd yEnd] for the current
%   rubber-line.  The callbacks default to ''.  The coordinates of the
%   line are specified as [xStart yStart xEnd yEnd].  In Matlab-5, these
%   are returned on mouse-up.  In Matlab-4, they are placed in the
%   "UserData" of the current figure window.


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

 
% Private interface:
%  rbline(1) is automatically called on window-button-motions.
%  rbline(2) is automatically called on window-button-up.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Jun-1997 15:54:39.
% Version of 11-Jun-1997 15:17:22.
% Version of 18-Jun-1997 16:18:29.

global RBLINE_HANDLE
global RBLINE_INITIATOR
global RBLINE_ON_MOUSE_MOVE
global RBLINE_POINTER

if nargin < 1, onMouseUp = 0; end

theVersion = version;
isVersion5 = (theVersion(1) == '5');

if strcmp(onMouseUp, 'demo')
   help rbline
   x = cumsum(rand(200, 1) - 0.45);
   y = cumsum(rand(200, 1) - 0.25);
   h = plot(x, y, '-r');
   if isVersion5
      set(h, 'ButtonDownFcn', 'disp(rbline)')
     else
      set(h, 'ButtonDownFcn', 'rbline')
   end
   figure(gcf), set(gcf, 'Name', 'RBLINE Demo')
   return
  elseif isstr(onMouseUp)
   theMode = 0;
  else
   theMode = onMouseUp;
   onMouseUp = '';
end

if theMode == 0   % Mouse down.
   if nargin < 3, onMouseDown = ''; end
   if nargin < 2, onMouseMove = ''; end
   if nargin < 1, onMouseUp = ''; end
   if isVersion5
      theCurrentObject = 'gcbo';
     else
      theCurrentObject = 'gco';
   end
   RBLINE_INITIATOR = eval(theCurrentObject);
   if strcmp(get(RBLINE_INITIATOR, 'Type'), 'line')
      theColor = get(RBLINE_INITIATOR, 'Color');
     else
      theColor = 'black';
   end
   RBLINE_ON_MOUSE_MOVE = onMouseMove;
   pt = mean(get(gca, 'CurrentPoint'));
   x = [pt(1) pt(1)]; y = [pt(2) pt(2)];
   RBLINE_HANDLE = line(x, y, ...
                        'EraseMode', 'xor', ...
                        'LineStyle', '--', ...
                        'LineWidth', 2.5, ...
                        'Color', theColor, ...
                        'Marker', '+', 'MarkerSize', 13, ...
                        'UserData', 1);
   set(gcf, 'WindowButtonMotionFcn', 'rbline(1);')
   set(gcf, 'WindowButtonUpFcn', 'rbline(2);')
   theRBLine = [x(1) y(1) x(2) y(2)];
   if ~isVersion5
      set(gcf, 'UserData', theRBLine)
   end
   if ~isempty(onMouseDown)
      feval(onMouseDown, RBLINE_INITIATOR, theRBLine)
   end
   RBLINE_POINTER = get(gcf, 'Pointer');
   set(gcf, 'Pointer', 'circle');
   if isVersion5
      eval('waitfor(RBLINE_HANDLE, ''UserData'', [])')
     else
%    eval('rbbox', '')   % Matlab-4 "rbbox" is buggy.
   end
   if isVersion5
      switch RBLINE_POINTER
      case {'watch', 'circle'}
         RBLINE_POINTER = 'arrow';
      otherwise
      end
      set(gcf, 'Pointer', RBLINE_POINTER);
      set(gcf, 'WindowButtonMotionFcn', '')
      set(gcf, 'WindowButtonUpFcn', '')
      x = get(RBLINE_HANDLE, 'XData');
      y = get(RBLINE_HANDLE, 'YData');
      delete(RBLINE_HANDLE)
   end
   theRBLine = [x(1) y(1) x(2) y(2)];   % Scientific.
   if ~isVersion5, set(gcf, 'UserData', theRBLine), end
   if isVersion5
      if ~isempty(onMouseUp)
         feval(onMouseUp, RBLINE_INITIATOR, theRBLine)
      end
   end
elseif theMode == 1   % Mouse move.
   pt2 = mean(get(gca, 'CurrentPoint'));
   x = get(RBLINE_HANDLE, 'XData');
   y = get(RBLINE_HANDLE, 'YData');
   x(2) = pt2(1); y(2) = pt2(2);
   set(RBLINE_HANDLE, 'XData', x, 'YData', y)
   theRBLine = [x(1) y(1) x(2) y(2)];
   if ~isVersion5, set(gcf, 'UserData', theRBLine), end
   if ~isempty(RBLINE_ON_MOUSE_MOVE)
      feval(RBLINE_ON_MOUSE_MOVE, RBLINE_INITIATOR, theRBLine)
   end
elseif theMode == 2   % Mouse up.
   pt2 = mean(get(gca, 'CurrentPoint'));
   x = get(RBLINE_HANDLE, 'XData');
   y = get(RBLINE_HANDLE, 'YData');
   x(2) = pt2(1); y(2) = pt2(2);
   theRBLine = [x(1) y(1) x(2) y(2)];
   set(RBLINE_HANDLE, 'XData', x, 'YData', y, 'UserData', [])
   if ~isVersion5
      set(gcf, 'WindowButtonMotionFcn', '')
      set(gcf, 'WindowButtonUpFcn', '')
      delete(RBLINE_HANDLE)
      set(gcf, 'UserData', theRBLine)
      set(gcf, 'Pointer', RBLINE_POINTER);
      set(gcf, 'Pointer', 'arrow');
      RBLINE_HANDLE = [];
      RBLINE_INITIATOR = [];
      RBLINE_ON_MOUSE_MOVE = '';
      RBLINE_POINTER = '';
      if nargout < 1, disp(theRBLine), end
   end
else
end

if nargout > 0, theResult = theRBLine; end
