function theResult = uigetparm(theParameters, theFilename, theStoredName)

% uigetparm -- Dialog for getting parameters.
%  uigetparm(theParameters) presents a modal dialog
%   based on the fields of theParameters struct.
%   The modified struct is returned or displayed, as
%   deemed appropriate.  If "cancelled", the returned
%   value is the empty-matrix [].  For controls that
%   have a numerical value, an initial value can be
%   established by wrapping the contents of the
%   element and its desired initial value in a cell,
%   as in {{'hello', 'goodbye'}, 2} to set 'goodbye'
%   as the initial selection in the popupmenu.
%  uigetparm(theParameters, 'theFilename', 'theStoredName')
%   writes the modal dialog result as 'theStoredName' to
%   'theFilename' -- it invokes uigetfile() if a wildcard.
%   The stored name defaults to the name of theParameters
%   argument that was input to this routine.
%  uigetparm('theFilename', 'theStoredName') gets and
%   puts the modal dialog result from/to 'theFilename'
%   as 'theStoredName'.
%  uigetparm('demo') demonstrates itself.


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

if nargin < 1, help(mfilename), theParameters = 'demo'; end

if isequal(theParameters, 'demo')
   theParameters.first = 'William';
   theParameters.middle = 'Jefferson';
   theParameters.last = 'Clinton';
   theParameters.age = {48, 49, 50};
   theParameters.democrat = {1, 0};
   theParameters.other.hometown = {'Little Rock, AK', 'Washington, D.C.'};
   theParameters.other.nickname = {'Buddy', 'Bubba', 'Schmucko'};
   theParameters.other.paramour = {'Gennifer', 'Monica', 'Paula'};
   uigetparm(theParameters, 'thePresident.mat', 'thePresident');
   uigetparm('thePresident.mat', 'thePresident.mat', 'thePresident');
   load thePresident.mat
   thePresident
   assignin('base', 'thePresident', thePresident)
   return
end

if nargin < 3
   if isstr(theParameters)
      theStoredName = theParameters;
      f = find(theStoredName == '.' | theStoredName == filesep);
      if any(f)
         theStoredName(f(length(f):length(theStoredString))) = '';
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
    theStoredName = 'parameters';
 end
if nargin < 2, theFilename = theStoredName; end
if isstr(theParameters)
   if nargin < 2, theFilename = '*'; end
end

theUpdateFlag = 0;

if isstr(theParameters)
   if nargin < 2, theFilename = '*.mat'; end
   if any(theFilename == '*')
      theFile = 0;
      [theFile, thePath] = uigetfile(theFilename, 'Select a Parameter File');
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

if isstr(theParameters)
   eval(['load ' theFilename])
   theParameters = eval(theStoredName, '[]');
   if isempty(theParameters), return, end
end

theFields = fieldnames(theParameters);

varargin = cell(length(theFields), 1);

v = cell(1, 2);
for i = 1:length(theFields)
   theField = theFields{i};
   theValue = getfield(theParameters, theField);
   switch class(theValue)
   case 'char'
   case 'cell'
      theDefault = [];
      if iscell(theValue{1}) & length(theValue) > 1
         theDefault = theValue{2};
         theValue = theValue{1};
      end
      if isequal(theValue(:), {0; 1})
         theValue = {0; 1};
         theField = ['#' theField];
        elseif isequal(theValue(:), {1; 0})
         theValue = {1; 0};
         theField = ['#' theField];
        else
         theField = ['&' theField];   % Popupmenu.
      end
      if ~isempty(theDefault)
         theValue = {theValue, theDefault};
      end
   case 'struct'
      theField = ['$' theField];
   otherwise
   end
   v{1} = theField;
   v{2} = theValue;
   if iscell(theValue) & iscell(theValue{1})
      v{2} = theValue{1};
      if length(theValue) > 1, v{3} = theValue{2}; end
   end
   varargin{i} = v;
end

varargin = [{{theFilename, theStoredName}}; {length(theFields)}; varargin];
varargout = cell(1, 1);

[varargout{:}] = form(varargin{:});

result = varargout{1};
if isequal(result, [])   % Cancelled.
   if nargout > 0
      theResult = result;
     else
      result
   end
   return
end

for i = 1:length(result)
   if iscell(result{i}) & length(result{i}) > 1
      if isa(result{i}{2}, 'struct')
         result{i} = result{i}{2};   % Dig out 'struct'.
      end
   end
   theParameters = setfield(theParameters, theFields{i}, result{i});
end

if theUpdateFlag & ~isempty(theFilename) & ~isempty(theStoredName)
   s = theStoredName;
   eval([theStoredName ' = theParameters;'])
   eval(['save ' theFilename ' ' s])
end

if nargout > 0
   theResult = theParameters;
  elseif ~theUpdateFlag
   theParameters
end
