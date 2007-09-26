function theResult = form(theFunction, nin, varargin)

% form/form -- Form dialog.
%  form('theFunction', nin, {varargin}) creates a
%   dialog for 'theFunction', with nin input arguments
%   and an arbitrary number of output arguments, all of
%   whose names are given in the {varargin} argument-list.
%   Each input style can be specified by a one-character
%   prefix to its name, as follows:
%
%                  ? (edit) [default]
%                  % (text)
%                  $ (pushbutton)
%                  @ (radiobutton)
%                  # (checkbox)
%                  & (popupmenu)
%                  * (invisible form function)
%
%   If a name is actually a cell-array, it must contain
%   two elements {theName, theDefaultString}.  If the form
%   provides no output fields, the dialog is modal and the
%   input fields are returned in a cell-array of numbers,
%   strings, or cells.  In that case, theFunction should
%   be given as a prompt string.  If theFunction is a
%   cell-array, the second element is used as the name
%   of the dialog window.
%   N.B.  In PCWIN Matlab, modal dialogs often do not
%   size themselves correctly.
%  form('demo') demonstrates itself with a modal and a
%   non-modal example.
%
%  Improvement: Controls that have a numerical value
%   can be given an initial setting by providing a third
%   value in the cell description of the item, as in:
%   {'&greeting', {'hello', 'goodbye'}, 2}, where "2"
%   refers to the second item in the popupmenu list.


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
 
% Version of 22-May-1997 11:07:38.
% Updated    02-Sep-1999 13:22:09.

if nargin < 1, help(mfilename), return, end
if nargin < 2, nin = 0; end
if nargin > 1 & isstr(nin), nin = eval(nin); end
if isempty(theFunction), theFunction = '*'; end

theFigureName = '';
if iscell(theFunction)
   theFigureName = theFunction{2};
   theFunction = theFunction{1};
end
if isempty(theFigureName)
   theFigureName = theFunction;
end

if strcmp(theFunction, 'demo')
   form('(180/pi)*atan2', 2, {'y', 1}, {'x', 1}, {'degrees', []});
   set(gcf, 'Position', get(gcf, 'Position') + [40 -40 0 0])
   result = form({'Your Name Please:', 'Your Name'}, 3, ...
                         {'First', 'William'}, ...
                         {'Middle', 'Jefferson'}, ...
                         {'Last', 'Clinton'});
   if nargout > 0, theResult = result; end
   return
end

theCurrentPosition = [0 0 0 0];
if any(findobj(0, 'Type', 'figure'))
   theCurrentPosition = get(gcf, 'Position');
end
theCurrentTopLeft = theCurrentPosition(1:2) + theCurrentPosition(3:4);

theFigure = figure('Name', theFigureName, ...
                   'NumberTitle', 'off', 'Tag', 'normal', ...
                   'Resize', 'on', 'Visible', 'off');

set(gca, 'Visible', 'off')
theUnits = get(theFigure, 'Units');
set(0, 'DefaultUIControlUnits', 'pixels')
thePos = get(0, 'DefaultUIControlPosition');
set(0, 'DefaultUIControlUnits', theUnits)
thePos = round(thePos .* [100 100 104 104] ./ 100);   % 2% margin.
theWidth = thePos(3);
theHeight = thePos(4);
theWidth = ceil(theWidth .* 5);
theHeight = ceil(theHeight * (length(varargin) + 3));
theUnits = get(theFigure, 'Units');
set(theFigure, 'Units', 'pixels')
thePos = get(theFigure, 'Position');
thePos(2) = thePos(2) + thePos(4) - theHeight;
thePos(3) = theWidth;
thePos(4) = theHeight;
theTopLeft = thePos(1:2) + thePos(3:4);
if min(abs(theTopLeft - theCurrentTopLeft)) < 10
   thePos(1:2) = thePos(1:2) + [+20 -20];
end
set(theFigure, 'Position', thePos)
set(theFigure, 'Units', theUnits);

theFrame = uicontrol('Style', 'frame', ...
                     'Units', 'normalized', ...
                     'Position', [0 0 1 1], ...
                     'BackgroundColor', [0.25 0.25 1]);

t = zeros(length(varargin)+2, 2);

theRequest = 'request(get(gcf, ''UserData''))';
theMore = 'request(get(gcf, ''UserData''), ''More'')';
theSubmission = 'request(get(gcf, ''UserData''), ''Submit'')';
theCancelation = 'request(get(gcf, ''UserData''), ''Cancel'')';
theCloseRequest = 'request(get(gcf, ''UserData''), ''CloseRequest'')';

theControls = zeros(2*length(varargin)+3, 1);

theVisible = 'on';
if ~isempty(theFunction) & theFunction(1) == '*'
   theFunction(1) = '';
   theVisible = 'off';
end

c(1) = uicontrol('Style', 'text', 'Visible', theVisible', ...
                          'String', theFunction, ...
                          'Tag', theFunction, ...
                          'BackgroundColor', [0.5 1 1]);
                          
c(2) = uicontrol('Style', 'pushbutton', ...
                          'String', 'Cancel', ...
                          'Callback', theCancelation, ...
                          'BackgroundColor', [1 0.5 1]);
                          
c(3) = uicontrol('Style', 'pushbutton', ...
                          'String', 'Submit', 'Tag', '=', ...
                          'Callback', theSubmission, ...
                          'BackgroundColor', [1 1 0.5]);

j = 0;
k = 0;
for i = 1:length(varargin)
   if i == 1
      k = k + 1;
      t(k, :) = [j+1 j+1];
      j = j + 1;
      theControls(j) = c(1);
   end
   k = k + 1;
   t(k, :) = [j+1 j+2];
   j = j + 1;
   theTag = varargin{i};
   theString = [];
   theValue = [];
   theValueFlag = 0;
   if iscell(theTag)
      if length(theTag) > 2
          theValue = theTag{3};
          theValueFlag = 1;
      end
      if length(theTag) > 1, theString = theTag{2}; end
      theTag = theTag{1};
  end
   
   switch class(theString)
   case 'char'
      theString = ['''' theString ''''];
   case 'cell'
      for index = 1:length(theString)
         if ~isstr(theString{index})
            theString{index} = mat2str(theString{index});
           else
            theString{index} = ['''' theString{index} ''''];
         end
      end
   case 'double'
      theString = mat2str(theString);
   otherwise
   end
   
   switch theTag(1)
   case '?'
      theStyle = 'edit'; theTag(1) = '';
   case '%'
      theStyle = 'text'; theTag(1) = '';
   case '$'
      theStyle = 'pushbutton'; theTag(1) = '';
   case '@'
      theStyle = 'radiobutton'; theTag(1) = '';
   case '#'
      theStyle = 'checkbox'; theTag(1) = '';
   case '&'
      theStyle = 'popupmenu'; theTag(1) = '';
   otherwise
      theStyle = 'edit';
   end
   
   theControls(j) = uicontrol('Style', 'text', ...
                              'String', theTag, ...
                              'BackgroundColor', [0.5 1 1]);
   
   if i <= nin
      theUserData = [];
      theCallback = theRequest;
      switch theStyle
      case 'pushbutton'
         if ~theValueFlag, theValue = 0; end
         theUserData = theString;
         theUserData = {theTag, theString};
         theString = 'More...';
         theCallback = theMore;
      case {'checkbox', 'radiobutton'}
         if isequal(theString(:), {'0'; '1'})
            if ~theValueFlag, theValue = 0; end
           elseif isequal(theString(:), {'1'; '0'})
            if ~theValueFlag, theValue = 1; end
         end
         theString = '0 or 1';
      case 'popupmenu'
            if ~theValueFlag, theValue = 1; end
         if isempty(theString), theString = '-'; end
      otherwise
         theValue = 0;
      end
      j = j + 1;
      theControls(j) = uicontrol('Style', theStyle, ...
                                 'String', theString, ...
                                 'Value', theValue, ...
                                 'Tag', theTag, ...
                                 'UserData', theUserData, ...
                                 'HorizontalAlignment', 'left', ...
                                 'Callback', theCallback);
     else
      j = j + 1;
      theControls(j) = uicontrol('Style', 'text', ...
                                 'String', theString, ...
                                 'UserData', theUserData, ...
                                 'HorizontalAlignment', 'left', ...
                                 'Tag', theTag);
   end
   if i == nin
      k = k + 1;
      t(k, :) = [j+1 j+2];
      j = j + 1;
      theControls(j) = c(2);
      j = j + 1;
      theControls(j) = c(3);
   end
end

set(theFrame, 'UserData', theControls)

uilayout(theControls, t, [2 2 96 96]/100)

theStruct.itSelf = theFigure;
theStruct.itsData = {};
self = class(theStruct, 'form');
set(theFigure, 'UserData', self)
set(theFigure, 'CloseRequestFcn', theCloseRequest)

set(theFigure, 'Visible', 'on')
if length(varargin) <= nin   % Run as modal dialog.
   if ~any(findstr(lower(computer), 'pcwin'))
      set(theFigure, 'WindowStyle', 'modal')
   end
   set(theFigure, 'Tag', 'modal')
   waitfor(theFigure, 'UserData')
   self = get(theFigure, 'UserData');
   result = self.itsData;
   delete(theFigure)
  else
   result = self;
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
