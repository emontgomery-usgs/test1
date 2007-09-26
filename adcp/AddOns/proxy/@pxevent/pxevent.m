function theResult = PXEvent(theUI, thePXEvent, theMessage)

% PXEvent -- No help available.
% PXEvent -- Dispatch an action.
%  PXEvent(theUI, thePXEvent, theMessage) dispatches
%   thePXEvent and theMessage to the 'pxevent' method
%   of the PXOwner of theUI.


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
 
% Version of 12-Jun-1997 08:24:14.

if nargin < 1, help(mfilename), return, end

if theUI == 0, return, end
if nargin < 2, theEvent = ''; end
if nargin < 3, theMessage = []; end

if 0
   pxbegets(' ## PXEvent', 3, theUI, thePXEvent, theMessage)
end

% The originator.

theType = get(theUI, 'Type');

% Default action.

if isempty(thePXEvent)
   thePXEvent = get(theUI, 'Tag');
   if isempty(thePXEvent)
      if strcmp(theType, 'uimenu')
         theString = get(theUI, 'Label');
        elseif strcmp(theType, 'uicontrol')
         theStyle = get(theUI, 'Style');
         theString = get(theUI, 'String');
         if strcmp(theStyle, 'popupmenu') | ...
            strcmp(theStyle, 'listbox')
            theValue = get(theUI, 'Value');
            theString = theString(theValue, :);
         end
         thePXEvent = theString;
      end
   end
end

% Default message.

if isempty(theMessage), theMessage = theUI; end

% De-reference uimenu or uicontrol to the parent figure.

if strcmp(theType, 'uimenu') | ...
   strcmp(theType, 'uicontrol')
   while ~strcmp(theType, 'figure')
      theUI = get(theUI, 'Parent');
      theType = get(theUI, 'Type');
   end
end

% Dispatch the event.

thePXOwner = pxowner(theUI);

result = pxevent(px(thePXOwner), thePXEvent, theMessage);

if nargout > 0, theResult = result; end
