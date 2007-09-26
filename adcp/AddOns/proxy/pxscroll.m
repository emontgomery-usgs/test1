function status = PXScroll(theScrollbar, theAxes, theSettings)

% PXScroll -- No help available.
% PXScroll -- Pan via scrollbar setting.
%  PXScroll(theScrollbar, theAxes) adjusts theAxes to fit theScrollbar
%   settings.  TheScrollbar defaults to all Scrollbars, ,i.e., any with
%   'String' = '[HVXYZCRBLT]Scroll'.  TheAxes defaults to all axes in
%   the current figure.
%  PXScroll(theScrollbar, theAxes, theSettings) adjusts theAxes to
%   correspond to theSettings [value min max].  A lone-value between
%   0 and 1 represents a proportional setting within the existing
%   range of the scrollbar.
%  PXScroll(theProportionalSetting) applies theProportionalSetting
%   (0 to 1) to all the axes and scrollbars.


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

  
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.
 
% Version of 28-May-96 at 14:35:00.445.

if nargout > 0, status = 0; end

theAmount = [];

if nargin < 1, theScrollbar = []; end
if nargin < 2, theAxes = []; end
if nargin < 3, theSettings = []; end

if nargin == 1 & ~isempty(theScrollbar)
   if theScrollbar(1, 1) >= 0 & theScrollbar(1, 1) <= 1
      theSettings = theScrollbar(1, 1);
      theScrollbar = [];
      theAxes = [];
   end
end

if isempty(theScrollbar)
   theScrollbar = findobj(gcf, 'Type', 'uicontrol', ...
                               'Style', 'slider');
end

if isempty(theAxes)
   theAxes = findobj(gcf, 'Type', 'axes');
end

% Scrollbar by name.

if isstr(theScrollbar)
   theScrollbar = findobj(gcf, 'Type', 'uicontrol', ...
                               'Style', 'slider', ...
                               'String', theScrollbar);
end

% Multiple actions.

if length(theScrollbar) > 1 | length(theAxes) > 1
   for j = 1:length(theAxes)
      for i = 1:length(theScrollbar)
         pxscroll(theScrollbar(i), theAxes(j), theSettings)
      end
   end
   return
end

% Check for proper types.

if ~strcmp(get(theScrollbar, 'Type'), 'uicontrol'), return, end
if ~strcmp(get(theScrollbar, 'Style'), 'slider'), return, end
if ~strcmp(get(theAxes, 'Type'), 'axes'), return, end

% Scrollbar message.

theMessage = get(theScrollbar, 'String');
c = '';
if length(theMessage) > 0
   c = theMessage(1);
end
if any(c == 'XHB')
   theMessage = 'XScroll';   % The X axis.
  elseif any(c == 'YVR')
   theMessage = 'YScroll';   % The Y axis.
  elseif any(c == 'ZL')
   theMessage = 'ZScroll';   % The Z axis.
  elseif any(c == 'CT')
   theMessage = 'CScroll';   % The Color axis.
  else
   return
end

% Scrollbar settings.

theAction = theMessage;
theValue = get(theScrollbar, 'Value');
theMin = get(theScrollbar, 'Min');
theMax = get(theScrollbar, 'Max');
if length(theSettings) == 1   % Proportional value.
   theCoeff = theSettings;
   theValue = theMin + theCoeff .* (theMax - theMin);
  elseif length(theSettings) == 3
   theValue = theSettings(1);
   theMin = theSettings(2);
   theMax = theSettings(3);
end
set(theScrollbar, 'Min', theMin, 'Max', theMax, ...
                  'Value', theValue)
theCoeff = (theValue - theMin) ./ (theMax - theMin);

% Scroll.

theLimit = [theAction(1) 'Lim'];
theDirection = [theAction(1) 'Dir'];
coeff = theCoeff;
if theAction(1) ~= 'C'
   if strcmp(get(theAxes, theDirection), 'reverse')
     coeff = 1 - coeff;
   end
end

theXLim = get(theAxes, 'XLim');   % Save axis limits.
theYLim = get(theAxes, 'YLim');
theZLim = get(theAxes, 'ZLim');
theCLim = get(theAxes, 'CLim');

theLim = get(theAxes, theLimit);
theRange = diff(theLim);

oldAxes = gca;   % Save current axes.

% set(theAxes, 'CLimMode', 'auto')   % Full color span.

axes(theAxes), axis('tight')       % Tight-fit.

theAutoLim = get(theAxes, theLimit);
theAutoRange = diff(theAutoLim);
center = theAutoLim(1) + coeff .* theAutoRange;
mn = center - theRange ./ 2;
mx = center + theRange ./ 2;

set(theAxes, 'XLim', theXLim)   % Restore axis limits.
set(theAxes, 'YLim', theYLim)
set(theAxes, 'ZLim', theZLim)
set(theAxes, 'CLim', theCLim)

set(theAxes, theLimit, [mn mx])

axes(oldAxes)   % Restore current axes.

figure(gcf)

if nargout > 0, status = 0; end
