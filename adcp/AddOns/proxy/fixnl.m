function theResult = fixnl(theInputFile, theOutputFile)

% fixnl -- Fix newline characters.
%  fixnl('theInputFile', 'theOutputFile') repairs the
%   newline characters in the text file named 'theInputFile'
%   and places the result in 'theOutputFile'.  If no input
%   file is given, the get/put file dialogs are used.
%   The name of the output file is returned.


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
 
% Version of 24-Apr-1997 14:40:37.

% Get input file.

if nargin < 1, theInputFile = ''; end
if nargin < 2, theOutputFile = ''; end

if nargin < 1
   while (1)
      result = fixnl('', '');
      if isempty(result)
         if nargout > 0, theResult = result; end
         return
      end
   end
end

result = '';
   
if isempty(theInputFile)
   theInputFilename = 0;
   thePrompt = 'Select File To Convert:';
   [theInputFilename, thePathname] = uigetfile('*', thePrompt);
   if ~any(theInputFilename)
      if nargout > 0, theResult = result; end
      return
   end
   theInputFile = [thePathname theInputFilename];
  else
   theInputFilename = theInputFile;
end

% Get output file.

if isempty(theOutputFile)
   theOutputFile = 0;
   theOutputFilename = theInputFilename;
   thePrompt = 'Save Converted File As:';
   [theOutputFilename, thePathname] = ...
         uiputfile(theInputFilename, thePrompt);
   if ~any(theOutputFilename)
      if nargout > 0, theResult = result; end
      return
   end
   theOutputFile = [thePathname theOutputFilename];
  else
   theOutputFilename = theOutputFile;
end

if strcmp(theOutputFile, '.')
   theOutputFile = theInputFile;
end

% Read input file.

fp = fopen(theInputFile, 'r');
s = setstr(fread(fp).');
fclose(fp);

% Save to temporary file if overwriting.

if strcmp(lower(theOutputFile), lower(theInputFile))
   theSavedFile = [theInputFile '.saved'];
   fp = fopen(theSavedFile, 'w');
   theCount = fwrite(fp, s);
   fclose(fp);
   if theCount ~= length(s)
      disp(' ## Unable to save a copy of the input file.')
      if nargout > 0, theResult = result; end
      return
   end
end

CR = setstr(13);   % Carriage-return.
LF = setstr(10);   % Line-feed.
CRLF = [CR LF];    % PC and Vax style.

c = computer;
if findstr(computer, 'MAC')           % Macintosh.
   NL = CR;
  elseif findstr(computer, 'PCWIN')   % PC.
   NL = CRLF;
  elseif findstr(computer, 'VMS')     % Vax VMS.
   NL = CRLF;
  else                                % Unix.
   NL = LF;
end

f = find(s == LF);
g = find(s == CR);
if any(f) & any(g), s(f) = ''; end

f = find(s == LF);
s(f) = CR;

if ~strcmp(NL, CR)
   s = strrep(s, CR, NL);
end

% Save to output file.

fp = fopen([theOutputFile], 'w');
theCount = fwrite(fp, s);
fclose(fp);

% Delete temporary file.

result = theOutputFile;

if strcmp(lower(theOutputFile), lower(theInputFile))
   if theCount == length(s)
      delete(theSavedFile)
     else
      result = '';
      disp(' ## Error during "fixnl" output.')
      disp([' ##    Original data are in "' theSavedFile '"'])
   end
end

disp([' ## Newlines fixed -- ' theInputFilename ' ==> ' theOutputFilename])

if nargout > 0, theResult = result; end
