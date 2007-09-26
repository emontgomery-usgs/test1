function theResult = PXSet(self, theField, theValue)

% PXSet -- No help available.
% PXSet -- Set values in self, a "px" object.
%  PXSet(self, 'theField', theValue) sets 'theField'
%   of self, a "px" object, to theValue, as in the
%   notation "self.theField = theValue".
%  PXSet(self, 'theField') returns the value of
%  'theField' of self, as in the notation
%   "theValue = self.theField".
%  PXSet(self) returns all the fields of self
%   as a "struct" object.
%  PXSet (no argument) shows help.


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
 
% Version of 04-Apr-1997 13:31:58.

if nargin < 1, help(mfilename), return, end

wasCell = 1;

if nargin > 1 & ~iscell(theField)
   theField = {theField};
   wasCell = 0;
end

if nargin > 2 & ~iscell(theValue)
   theValue = {theValue};
end

theUI = px(self);
theUserData = get(theUI, 'UserData');

switch nargin
case 1
   if nargout > 0
      theValue = theUserData;
     else
      disp(theUserData)
   end
case 2
   theValue = cell(size(theField));
   for i = 1:prod(size(theField))
      theValue{i} = [];
      successful = 0;
      if ~strcmp(lower(theField{i}), 'userdata')
         successful = 1;
         eval('theValue{i} = get(theUI, theField{i});', ...
              'successful = 0;');
      end
      if ~successful
         theValue{i} = eval('getfield(theUserData, theField{i})', '[]');
      end
   end
   if ~wasCell, theValue = theValue{1}; end
   if nargout < 1, disp(theValue), end
otherwise
   for i = 1:prod(size(theField))
      successful = 0;
      if ~strcmp(lower(theField{i}), 'userdata')
         successful = 1;
         eval('set(theUI, theField{i}, theValue{i});', ...
              'successful = 0;');
      end
      if ~successful
         theUserData = ...
            eval('setfield(theUserData, theField{i}, theValue{i})', '');
      end
      theValue = [];
   end
   set(theUI, 'UserData', theUserData);
end

if nargout > 0, theResult = theValue; end
