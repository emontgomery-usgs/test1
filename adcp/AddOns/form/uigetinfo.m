function theResult = uigetinfo(theInformation, ...
								theFilename, theStoredName)

% uigetinfo -- Dialog for getting information.
%  uigetinfo(theInformation) presents a modal dialog
%   for interacting with the fields of theInformation,
%   a Matlab struct.  The modified struct is returned
%   or displayed.  If the dialog is "cancelled", the
%   returned value is the empty-matrix [].
%
%   Simple example:
%
%      theInfo.edit = 'William'
%      theInfo.radiobutton = {'radiobutton', 0}   % 0 or 1.
%      theInfo.checkbox = {'checkbox', 1}   % 0 or 1.
%      theInfo.popupmenu = {{'hello', 'goodbye'}, 2}   % 1 or 2.
%      theInfo.subdialog.foo = 'anything'   % Sub-dialog.
%      theInfo.subdialog.bar = 'anything'
%      theNewInfo = uigetinfo(theInfo)
%
%   For a list, the initial selection can be specified
%   by wrapping the list (a cell-array) and its desired
%   initial index (a number > 0) in a cell.  In the
%   example above, 'goodbye' will be the initial
%   selection in the popupmenu.  If no initial value
%   is given, the first list-element is selected.
%   Lists may contain only "char" or "double" values,
%   in any combination.
%
%   Note that 'checkbox' and 'radiobutton' are key-words,
%   which must be spelled exactly as shown.  If no initial
%   value is given, the value is set to 0 (OFF).
%
%   A field which itself is a struct leads to a sub-dialog
%   with the fields of the sub-struct as its entries.  The
%   scheme can be extended ad-infinitim.  If a sub-dialog
%   is cancelled, its fields remain unmodified from its
%   previous state.  Dialogs cannot be dismissed before
%   their sub-dialogs, nor can more than one sub-dialog
%   at any particular level be shown at one time.  That
%   is, the dialogs behave as if they are "modal", even
%   though it may be possible bring any of them to the
%   front at any time.
%
%  uigetinfo(theInformation, 'theFilename', 'theStoredName')
%   writes the modal dialog result as 'theStoredName' to
%   'theFilename' -- it invokes uigetfile() if a wildcard.
%   The stored name defaults to the name of theInformation
%   argument that was input to this routine, and theFilename
%   defaults to theInformation name + ".mat".
%  uigetinfo('theFilename', 'theStoredName') gets and
%   puts the modal dialog result from/to 'theFilename'
%   as 'theStoredName'.
%  uigetinfo('demo') demonstrates itself by presenting
%   a dialog built from a struct, then showing it again
%   after its previous state has been retrieved from
%   a file.  The final result is placed in "ans".


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
 
% Version of 22-May-1997 11:06:58.

% N.B. Don't cancel out of a sub-dialog.  We need
%  to disable the "cancel" button there.

if nargin < 1, help(mfilename), theInformation = 'demo'; end

if isequal(theInformation, 'demo')
   theInformation.first = 'William';
   theInformation.middle = 'Jefferson';
   theInformation.last = 'Clinton';
   theInformation.age = {{48, 49, 50}, 1};
   theInformation.democrat = {'radiobutton', 0};
   theInformation.other.hometown = ...
		{{'Little Rock, AK', 'Marthas Vinyard, MA', 'Washington, D.C.'}, 1};
   theInformation.other.nickname = ...
		{{'Bubba', 'Buddy', 'Schmucko', 'The Creep'}, 2};
   theInformation.other.paramour = {{'Gennifer', 'Monica', 'Paula'}, 2};
   uigetinfo(theInformation, 'thePresident.mat', 'thePresident');
   if (1)
      uigetinfo('thePresident.mat', 'thePresident.mat', 'thePresident');
   end
   load thePresident.mat
   thePresident
   assignin('base', 'thePresident', thePresident)
   if nargout > 0
      theResult = thePresident;
   else
      assignin('base', 'thePresident', thePresident)
      assignin('base', 'ans', thePresident)
   end
   return
end

if nargin == 1
	switch lower(class(theInformation))
	case 'struct'
		theFilename = [inputname(1) '.mat'];
		theStoredName = inputname(1);
		result = uigetinfo(theInformation, theFilename, theStoredName);
		if nargout > 0, theResult = result; end
	otherwise
		theFilename = theInformation;
		theStoredName = theFilename;
		f = find(theStoredName == filesep);
		if any(f), theStoredName(1:f) = ''; end
		f = find(theStoredName == '.');
		if any(f),
			theStoredName(f(1):length(theStoredName)) = '';
		end
		result = uigetinfo(theFilename, theFilename, theStoredName);
		if nargout > 0, theResult = result; end
	end
	return
end

if nargin == 2
   if isa(theInformation, 'char')
      theStoredName = theFilename;
		theFilename = theInformation;
      f = find(theStoredName == '.' | theStoredName == filesep);
      if any(f)
         theStoredName(f(length(f)):length(theStoredName)) = '';
         f(length(f)) = [];
      end
      if any(f)
         theStoredName(1:f(length(f))) = '';
      end
     else
      theStoredName = inputname(1);
   end
end

if isempty(theStoredName)
	theStoredName = 'information';
end

if nargin < 2, theFilename = theStoredName; end

if isa(theInformation, 'char')
   if nargin < 2, theFilename = '*'; end
end

theUpdateFlag = 0;

if isstr(theInformation)
   if nargin < 2, theFilename = '*.mat'; end
   if any(theFilename == '*')
      theFile = 0;
      [theFile, thePath] = uigetfile(theFilename, 'Select an Information File');
      if ~any(theFile), return, end
      eval(['cd ' thePath])
      theFilename = theFile;
   end
  elseif nargin > 1
   if ~isempty(theFilename) & any(theFilename == '*')
      theFile = 0;
      [theFile, thePath] = uiputfile('unnamed.mat', 'Save As');
      if ~any(theFile), return, end
      eval(['cd ' thePath])
      theFilename = theFile;
   end
   if nargin < 3, theStoredName = inputname(1); end
end

if ~isempty(theFilename), theUpdateFlag = 1; end

if isa(theInformation, 'char')
   eval(['load ' theInformation])
   theInformation = eval(theStoredName, '[]')
   if isempty(theInformation), return, end
end

% Canonical form for each field: a cell with
%  the contents and the initial index for
%  each control.  Keywords: 'checkbox' and
%  'radiobutton'.

theFields = fieldnames(theInformation);

for i = 1:length(theFields)
   theField = theFields{i};
   v = getfield(theInformation, theField);
   if ischar(v)
      if isequal(v, 'checkbox') | ...
            isequal(v, 'radiobutton')
         v = {v 0};   % Default = OFF.
      else
         v = {v 1};   % Default = 1.
      end
   elseif isa(v, 'cell') & ~isempty(v)
      if isequal(v{1}, 'checkbox') | ...
               isequal(v{1}, 'radiobutton')
         if length(v) < 2
            v = [v {0}];   % Default = OFF.
         end
      elseif isa(v{1}, 'cell')
         if length(v) < 2
            v = [v {1}];   % Default = 1.
         end
      elseif isa(v{1}, 'char')
         v = {v 1};   % Default = 1.
      elseif isa(v{1}, 'double')
         v = {v 1};   % Default = 1.
      end
   elseif isa(v, 'struct')
   else   % Anything else; probably invalid.
      v = {v 1};   % Default = 1.
   end
   theInformation = setfield(theInformation, theField, v);
end

varargin = cell(length(theFields), 1);

for i = 1:length(theFields)
   theField = theFields{i};
   theFieldContents = getfield(theInformation, theField);
   if isa(theFieldContents, 'cell')
      theString = theFieldContents{1};
      theInitialValue = theFieldContents{2};
   else
      theString = theFieldContents;
      theInitialValue = [];
   end
   switch class(theString)
   case 'char'
      if isequal(theString, 'checkbox')
         theField = ['#' theField];   % checkbox.
      elseif isequal(theString, 'radiobutton')
         theField = ['@' theField];   % radiobutton.
      elseif 0 & theString(1) == '%'
         theField = ['%' theField];   % static text.
      else
         theField = ['?' theField];   % edit.
      end
   case 'double'
		theField = ['?' theField];   % edit.
   case 'cell'
		if isempty(theString), theString = {[]}; end
      if isequal(theString{1}, 'checkbox')
         theField = ['#' theField];   % checkbox.
      elseif isequal(theString{1}, 'radiobutton')
         theField = ['@' theField];   % radiobutton.
      elseif length(theString) < 2
			theString = theString{1};
			if 0 & theString(1) == '%'
            theField = ['%' theField];   % static text.
			else
            theField = ['?' theField];   % edit.
         end
      else
         theField = ['&' theField];   % popupmenu.
      end
   case 'struct'
      theField = ['$' theField];   % pushbutton.
   otherwise
   end
   varargin{i} = {theField, theString, theInitialValue};
end

varargin = [{{theFilename, theStoredName}}; {length(theFields)}; varargin];
varargout = cell(1, 1);

[varargout{:}] = uiform(varargin{:});

result = varargout{1};
if isequal(result, [])   % Cancelled.
   if nargout > 0
      theResult = result;
     else
      result
   end
   return
end

temp = theInformation;

[m, n] = size(result);
for i = 1:m
   r = result{i, 1};
   if iscell(r) & length(r) > 1 & isa(r{2}, 'struct')
      r = r{2};   % Dig out 'struct'.
   elseif ischar(r)   % Checkbox, radiobutton, or string.
      if isequal(r, 'checkbox') | ...
         isequal(r, 'radiobutton')
         r = result(i, :);
      else
         r = r;
      end
	elseif isa(r, 'double')
		r = r;
   else   % Something with a value.
      r = result(i, :);
   end
   theInformation = setfield(theInformation, theFields{i}, r);
end

if theUpdateFlag & ~isempty(theFilename) & ~isempty(theStoredName)
   THE_STORED_NAME = theStoredName;
   eval([theStoredName ' = theInformation;'])
   eval(['save ' theFilename ' ' THE_STORED_NAME])
end

if nargout > 0
   theResult = theInformation;
  elseif ~theUpdateFlag
   theInformation
end
