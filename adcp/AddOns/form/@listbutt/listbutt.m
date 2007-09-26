function ListButt(theButtons, theCallbacks, ...
                    thePrompt, theName, varargin)

% ListButt/ListButt -- Listbox full of buttons.
%  ListButt{theButtons}, {theCallbacks}, 'thePrompt', ...
%   'theName', ...') creates a non-modal dialog with {theButtons},
%   (a list of names) and theCallbacks (a list of callback strings).
%   The title is 'thePrompt' and the window name is 'theName'.
%   The appearance of the listbox can be modified with additional
%   arguments that specify conventional property name/value pairs.
%   Each click in the listbox calls the corresponding callback
%   with the name of the item selected.  The user may also adjust
%   any aspect of the dialog via the "gcbo" during such callbacks.
%   Clicking on a blank-line toggles the 'Resize' property of the
%   dialog window.
%  ListButt(nItems) demonstrates itself with nItems.


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
    theButtons = 'demo';
end

if isequal(theButtons, 'demo')
    theButtons = 20;
elseif ischar(theButtons)
    theButtons = eval(theButtons);
end

if length(theButtons) == 1
    nItems = theButtons;
    theButtons = cell(1, nItems);
    for i = 1:length(theButtons)
        theButtons{i} = ['<< Button (' int2str(i) ') >>'];
    end
    theCallbacks = 'disp';
    thePrompt = 'Select Any Item';
    theName = 'ListButt Demo';
    listbutt(theButtons, theCallbacks, ...
            thePrompt, theName);
    return
end

if nargin < 2, theCallbacks = {'disp'}; end
if nargin < 3, thePrompt = 'Select Any Item'; end
if nargin < 4, theName = 'ListButt'; end

if ~iscell(theButtons), theButtons = {theButtons}; end
if ~iscell(theCallbacks), theCallbacks = {theCallbacks}; end

% Put a blank-line between each item.

b = cell(2*length(theButtons)+1, 1);
for i = 1:length(b)
    b{i} = ' ';
end
for i = 1:length(theButtons)
    b{2*i} = theButtons{i};
end
theButtons = b;

if length(theCallbacks) > 1
    c = cell(2*length(theCallbacks)+1, 1);
    for i = 1:length(c)
        c{i} = '';
    end
    for i = 1:length(theCallbacks)
        c{2*i} = theCallbacks{i};
    end
    theCallbacks = c;
end

if nargout > 1, theResult = cell(0, 1); end

theFigure = figure('Name', theName, 'NumberTitle', 'off', ...
   'WindowStyle', 'normal', 'Visible', 'off', 'Resize', 'off');
thePosition = get(theFigure, 'Position');
thePosition(2) = thePosition(2) + 0.10 * thePosition(4);
thePosition(3) = 0.30 .* thePosition(3);
thePosition(4) = 0.80 .* thePosition(4);
set(theFigure, 'Position', thePosition)

theStruct.itSelf = theFigure;
self = class(theStruct, 'listbutt');
set(theFigure, 'UserData', self)

if isempty(self), return, end

theFrame = uicontrol('Style', 'frame', 'Visible', 'on', ...
   'Units', 'normalized', 'Position', [0 0 1 1], ...
   'BackgroundColor', [0.5 1 1]);

if ~iscell(theButtons), theButtons = {theButtons}; end
if ~iscell(theCallbacks), theCallbacks = {theCallbacks}; end

theControls = zeros(2, 1);
theControls(1) = uicontrol('Style', 'text', 'Tag', 'Label', ...
   'String', thePrompt);
theControls(2) = uicontrol('Style', 'listbox', 'Tag', 'List', ...
   'String', theButtons, 'UserData', theCallbacks);

theLayout = [  10   10   10   10   10   10
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
               30   30   30   30   30   30];

uilayout(theControls, theLayout, [2 2 96 92]./100)
set(theFrame, 'UserData', theControls)

theCallback = ['event(get(gcf, ''UserData''))'];
set(theControls(2), 'Callback', theCallback)
set(theControls(1), 'BackgroundColor', [0.5 1 1]);

if any(findstr(computer, 'MAC'))
    set(theControls(2), 'FontName', 'Chicago', ...
                        'FontSize', 12, ...
                        'FontAngle', 'normal', ...
                        'FontWeight', 'normal')
end

if length(varargin) > 0
    set(theControls(2), varargin{:})
end

set(theFigure, 'Visible', 'on')
