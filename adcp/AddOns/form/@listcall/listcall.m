function theResult = ListCall(theSourceList, thePrompt, ...
                                theName, theCall, varargin)

% ListCall/ListCall -- Call in response to listbox selection.
%  ListCall{theSourceList}, 'thePrompt', 'theName', 'theCall')
%   creates a modal dialog with {theSourceList} strings in a
%   listbox, which calls 'theCall(gcbo)' whenever any item is
%   selected.  Upon "Okay", the current list is returned.
%   Upon "Cancel", the empty-matrix [] is returned.  if no
%   output argument is provided, the answer is placed silently
%   in "ans".  This routine is useful for toggling the state of
%   list items by clicking on them.  The user is responsible
%   for updating the "String" and "Value" properties of the
%   list-box (the "gcbo"), as appropriate.
%   appropriate.  The default action is to do nothing.
%  ListCall(nItems) demonstrates itself with nItems; default = 25.


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
 
% Version of 13-Jan-1998 17:58:49.

if nargin < 1 & isempty(gcbo)
    help(mfilename)
    theSourceList = 'demo';
end

if isequal(theSourceList, 'demo')
    theSourceList = 22;
elseif ischar(theSourceList)
    theSourceList = eval(theSourceList);
end

if length(theSourceList) == 1
    nItems = theSourceList;
    result = listcall_demo(nItems);
    assignin('caller', 'ans', result)
    return
end

if nargin < 2, thePrompt = 'Select'; end
if nargin < 3, theName = 'ListCall'; end
if nargin < 4, theCall = ''; end

theSourceList = [theSourceList(:)];

if nargout > 1, theResult = cell(0, 1); end

theFigure = figure('Name', theName, 'NumberTitle', 'off', ...
   'WindowStyle', 'modal', 'Visible', 'off', 'Resize', 'off');
thePosition = get(theFigure, 'Position');
thePosition(2) = thePosition(2) + 0.10 * thePosition(4);
thePosition(3) = 0.30 .* thePosition(3);
thePosition(4) = 0.80 .* thePosition(4);
set(theFigure, 'Position', thePosition)

theStruct.itSelf = theFigure;
self = class(theStruct, 'listcall');
set(theFigure, 'UserData', self)

if isempty(self), return, end

theFrame = uicontrol('Style', 'frame', 'Visible', 'on', ...
   'Units', 'normalized', 'Position', [0 0 1 1], ...
   'BackgroundColor', [0.5 1 1]);

theControls = zeros(4, 1);
theControls(1) = uicontrol('Style', 'text', 'Tag', 'Label', ...
   'String', thePrompt);
theControls(2) = uicontrol('Style', 'listbox', 'Tag', 'List', ...
   'String', theSourceList, 'Value', 1, 'UserData', theCall);
theControls(3) = uicontrol('Style', 'pushbutton', 'Tag', 'Cancel', ...
   'String', 'Cancel', 'UserData', []);
theControls(4) = uicontrol('Style', 'pushbutton', 'Tag', 'Okay', ...
   'String', 'Okay', 'UserData', theSourceList);

theLayout = [  10   10   10   10   10   10
              Inf  Inf  Inf  Inf  Inf  Inf
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               30   30   30   30   30   30
               60   60  Inf  Inf   70   70
               60   60  Inf  Inf   70   70];

uilayout(theControls, theLayout, [2 2 96 92]./100)
set(theFrame, 'UserData', theControls)

theCallback = ['event(get(gcf, ''UserData''))'];
set(theControls(2:4), 'Callback', theCallback)
set(theControls(1), 'BackgroundColor', [0.5 1 1]);

if any(findstr(computer, 'MAC'))
    set(theControls(2), 'FontName', 'Monaco', ...
                        'FontSize', 12, ...
                        'FontAngle', 'normal', ...
                        'FontWeight', 'normal')
end

if length(varargin) > 0
    set(theControls(2), varargin{:})
end

set(theFigure, 'Visible', 'on')
waitfor(theFigure, 'UserData', [])

result = get(gco, 'UserData');

delete(theFigure)

if nargout > 0
   theResult = result;
else
    assignin('caller', 'ans', result)
end
