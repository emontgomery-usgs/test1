function self = PX(theClass, theSuperClass, theUI)

% PX -- No help available.
% PX -- Base constructor for the "px" class.
%
% Objects derived from the px class respond to
%  "self.theField = theValue" and "theValue =
%  self.theField" statements, for any number and
%  variety of public fields and values, including
%  the fields of the associated "HandleGraphics"
%  item.
%
%  PX (no argument) returns a "px" object, also
%   called a PXObject.
%  PX(theUI) returns a PXObject attached to theUI,
%   a "HandleGraphics" handle.
%  PX(aPXObject) returns the associated PXReference,
%   equivalent to the handle of the attached UI.
%  PX(aPXReference) returns the associated PXObject.
%  aPXObject.theField accesses the value of theField,
%   including any field of the attached UI, which
%   takes precedent.
%  PX('theClass', 'theSuperClass', theUI) returns a string
%   that must be evaluated inside the constructor of 'theClass'
%   in order to create an object derived from the "px" class.
%   If theUI, a "HandleGraphics" handle, is given, it becomes
%   the PXReference for the returned PXObject.  Otherwise,
%   a default reference is used.
%  PX(aPXObject, theUI) clones the contents of aPXObject
%   onto theUI, where theUI is a "HandleGraphics" handle
%   or [].  It returns a PXObject.
%  PX(aPXReference, theUI) clones the associated PXObject
%   onto theUI.  It returns a PXReference.
%
% Always call "new(px, ...)" to return a PXReference
%  to a new PXObject.  The additional arguments can
%  be used to initialize the object with a sequence
%  of ('theField', theValue, ...) pairs, as in the
%  "struct" function.
%
% The contents of PXReferences can be accessed with
%  the "px..." commands in the "Proxy"  folder.  For
%  example, "pxget(thePXReference, 'theField')" is
%  analogous to "pxget(thePXObject, 'theField')".


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
 
% Version of 04-Apr-1997 13:04:03.

if nargin < 1 & nargout < 1
   eval('setdef(mfilename)', '')
   return
end

% Toggle between PXObject and PXReference, adding
%  the object if necessary.

if nargin == 1
   switch(class(theClass))
     case 'double'   % Return the object.
      theReference = theClass;
      self = [];
      switch ispx(theReference)
        case 0
         if ishandle(theReference)
            self = px('px', theReference);
         end
        case 1
         self = theReference.itSelf;
        case 2
         theStruct = get(theReference, 'UserData');
         self = theStruct.itsObject;
        case 3
         self = theReference.itsObject;
      end
     case 'char'
      if strcmp(theClass, 'px')
         self = px;
        else
         self = px(theClass, 'px');
      end
     otherwise   % Return the reference.
      if isa(theClass, 'px') == 1
         theObject = theClass;
         self = theObject.itSelf;
      end
   end
   return
end

% Defaults.

if nargin < 3, theUI = []; end
if nargin < 2, theSuperClass = ''; end
if nargin < 1, theClass = 'px'; end

% Constructor-string to be evaluated.

if nargin > 1
   if ischar(theClass) & ~isempty(theClass) & ...
      ischar(theSuperClass)
      s = ['class(struct(' ...
                     '''itsClass'', ' theClass ', ' ...
                     '''itsSuperClass'', ' theSuperClass '), ' ...
                     theClass];
      if ~isempty(theSuperClass)
         s = [s  ', eval([' theSuperClass];
         if ~isempty(theUI)
            s = [s ' ''('' ' theUI ' '')'' '];
         end
         s = [s '])'];
      end
      s = [s ')'];
      self = s;
      return
   end
end

% Create a "px" object with theUI, if any.

if isstr(theClass) & ~strcmp(theClass, 'px')
   self = [];
   return
end

if nargin == 2 & ...
      (isempty(theSuperClass) | ishandle(theSuperClass))
   theUI = theSuperClass;
end
theSuperClass = '';

% Window for objects, if needed.

c = get(0, 'Children');
if ~any(c)
   figure('Name', 'Proxy', 'NumberTitle', 'off', ...
      'Position', [16 48 192 32], 'MenuBar', 'none')
   set(gca, 'Visible', 'off')
end

% State of the window and axes.

theFigureVis = get(gcf, 'Visible');
theAxesVis = get(gca, 'Visible');

% The UI container of the object.

if isempty(theUI)
   theUI = text(0, 0, '', ...
                      'HorizontalAlignment', 'center', ...
                      'Visible', 'off', ...
                      'Tag', 'px');
end
theStruct.itSelf = theUI;
theStruct.itsHandles = [];
                     
% Restore widow and axes state.
                     
set(gca, 'Visible', theAxesVis)
set(gcf, 'Visible', theFigureVis)

% Create or clone the "px" object.

if isstr(theClass) & strcmp(theClass, 'px')
   self = class(theStruct, theClass);
   theStruct.itsObject = self;
  elseif ispx(theClass) == 1
   self = theClass;
   self.itSelf = theUI;
   theStruct.itsObject = self;
  elseif ispx(theClass) == 2
   self = px(theClass);
   self.itSelf = theUI;
   theStruct.itsObject = self;
end

% Relocate the existing 'UserData', if any.

theUserData = get(theStruct.itSelf, 'UserData');
if ~isempty(theUserData)
   theStruct.UserData = theUserData;
end

set(theStruct.itSelf, 'UserData', theStruct)

self = theStruct.itsObject;
if ispx(theClass) == 2, self = px(self); end
