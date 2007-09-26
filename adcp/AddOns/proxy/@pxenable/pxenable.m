function status = PXEnable(theUI, theCommand, theMessage)

% PXEnable -- No help available.
% PXEnable -- Enable an event or command.
%  PXEnable(theUI, 'theCommand', 'theMessage') installs
%   'PXEvent(theCurrent, ''theCommand'', theMessage)'
%   in theUI graphics entity, where theCurrent is the
%   current object (usually gcbo);
%   theCommand is the name of the callback; and theMessage
%   is additional literal information.  TheCommand defaults
%   to 'ButtonDownFcn' or 'Callback', and theMessage
%   defaults to an alias of the originator of the event.
%   TheUI may be a vector of several entities,
%   provided they all can accept the same setup.
%  PXEnable(theUI, theOwner, append) attaches theUI to
%   theOwner (a "px" object), enabling theUI to pass commands
%   and events to it.  If append is non-zero, theUI is
%   appended to the list of other UI that theOwner already
%   owns.


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

% Generic enable.

if isa(theUI, 'px') & nargin == 1
   self = theUI;
   pxset(self, 'itsObject', self)
   p = px(self);
   pxenable(p, p);
   pxenable(p)
   set(p, 'Tag', class(self))
   return
end
    
% Attach theUI to an Owner.

if theUI == 0, return, end
if nargin > 1
   if ~isstr(theCommand)
      theObject = theCommand;
      append = 0;
      if nargin > 2, append = theMessage; end
      if isempty(pxderef(theUI))
         theUI = new(px(theUI));
      end
      if isempty(pxderef(theObject))
         theObject = new(px(theObject));
      end
      ui = pxderef(theUI);
      obj = pxderef(theObject);
      ui.itsOwner = theObject;
      if any(append)
%        obj.itsUI = [b.itsUI; theUI(:)];   % A typo crept in.  How?
         obj.itsUI = [obj.itsUI; theUI(:)];
        else
         obj.itsUI = theUI(:);
      end
      return
   end
end

% Default command and message.

if nargin < 2, theCommand = 'ButtonDownFcn'; end
itsType = get(theUI(1), 'Type');
if nargin < 3, theMessage = ['''' itsType '''']; end

% Identify the method to apply.

theMethod = 'pxevent';

% Identify the current target and property to be set.

theProperty = theCommand;
if strcmp(itsType, 'figure')
   theCurrent = 'pxgcf';
  elseif strcmp(itsType, 'axes')
   theCurrent = 'pxgca';
  elseif strcmp(itsType, 'image') | ...
         strcmp(itsType, 'patch') | ...
         strcmp(itsType, 'line') | ...
         strcmp(itsType, 'text') | ...
         strcmp(itsType, 'surface')
   theCurrent = 'pxgco';
  elseif strcmp(itsType, 'uicontrol')
   theCurrent = 'pxgco';
   if nargin < 2, theProperty = 'Callback'; end
  elseif strcmp(itsType, 'uimenu')
   theCurrent = 'pxgcm';
   theProperty = 'Callback';
end

theCurrent = 'gcbo';   % Universal.

% Default the message if none was provided.

if nargin < 3
   theString = '';
   if strcmp(itsType, 'figure')
      theString = get(theUI(1), 'Name');
      theString = 'gcf';
     elseif strcmp(itsType, 'axes')
      theString = get(theUI(1), 'Title');
      theString = 'gca';
     elseif strcmp(itsType, 'image') | ...
            strcmp(itsType, 'patch') | ...
            strcmp(itsType, 'line') | ...
            strcmp(itsType, 'surface')
      theString = itsType;
      theString = 'gco';
     elseif strcmp(itsType, 'text')
      theString = get(theUI(1), 'String');
      theString = 'gco';
     elseif strcmp(itsType, 'uicontrol')
      theString = get(theUI(1), 'String');
      theString = 'gco';
     elseif strcmp(itsType, 'uimenu')
      theString = get(theUI(1), 'Label');
      theString = 'gcm';
   end
   if any(theString), theString = 'gcbo'; end
   if ~isempty(theString)
      theMessage = ['''' theString ''''];
   end
end

% Construct and install the call to the method.

e = [theMethod ...
     '(' theCurrent ',''' theCommand ''',' theMessage ')'];
set(theUI, theProperty, e)
