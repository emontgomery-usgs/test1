function theResult = request(self, theRequest, theFields)

% form/request -- Process a Form.
%  request(self, theRequest) processes theRequest
%   on behalf of self, a Form.  The default request
%   is 'Submit'.


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

if nargin < 1, help(mfilename), return, end

if nargin < 2, theRequest = ''; end

theFigure = self.itSelf;

switch lower(theRequest)
case 'closerequest'
   theWindowTag = get(theFigure, 'Tag');
   switch theWindowTag
   case 'normal'
      theRequest = 'Cancel';
  otherwise
      theRequest = '';
      disp(' ## Choose "Cancel" or "Submit"')
   end
end

switch lower(theRequest)
case 'cancel'
   self.itsData = [];
   set(gcf, 'UserData', self)
   theWindowTag = get(theFigure, 'Tag');
   switch theWindowTag
   case 'normal'
      delete(theFigure)
   case 'modal'
   otherwise
   end
case 'get'
   [theFunction, theInputFields, theOutputFields] = doset(self);
   if nargout > 0, theResult = theInputFields; end
case 'set'
   doset(self, theFields)
case 'more'
   theControl = gcbo;
   More = get(theControl, 'UserData');
   theTag = '';
   if iscell(More)
       theTag = More{1};
       More = More{2};
   end
   switch class(More)
   case 'struct'
      if ~isempty(theTag)
         More(1) = uigetparm(More, '', theTag);
      else
         More(1) = uigetparm(More);
      end
      set(theControl, 'UserData', More)
   otherwise
      warning([' ## Incompatible data class: ' class(More)])
   end
case {'submit', ''}
   theFrame = findobj(theFigure, 'Type', 'uicontrol', 'Style', 'frame');
   theControls = get(theFrame, 'UserData');
   varargin = cell(1, 0);
   nvarargin = 0;
   nvarargout = 0;
   theOutputs = [];
   [theFunction, theInputFields, theOutputFields] = doset(self);
   self.itsData = theInputFields;
   if strcmp(lower(theRequest), 'submit')
      set(theFigure, 'UserData', self)
   end
   varargin = cell(size(theInputFields));
   nvarargin = prod(size(varargin));
   for i = 1:length(theInputFields)
      varargin{i} = theInputFields{i};
   end
   theWindowTag = get(theFigure, 'Tag');
   switch theWindowTag
   case 'normal'
      varargout = cell(size(theOutputFields));
      nvarargout = prod(size(varargout));
      theVargString = vargstr(theFunction, nvarargin, nvarargout);
      eval(theVargString, ...
            ['disp([''## Unable to evaluate ['' theFunction '']''])'])
      doset(self, [varargin; varargout]);
   case 'modal'
   otherwise
   end
otherwise
   if ~isempty(theRequest)
      warning([' ## Unrecognized request: ' mat2str(theRequest)])
   end
end

if nargout > 0, theResult = self; end
