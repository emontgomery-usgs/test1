function aduplicate(fileName, newFileName)

% aduplicate -- Duplicate file via AppleScript.
%  aduplicate(fileName ,  newFileName ) duplicates
%   the file 'fileName' to the new file 'newFileName'.
%   If 'fileName' contains no file-separators, the
%   "which" function is used to get its full-path.
%
% See also: ACOPY, ARENAME, AMOVE, AREVEAL, APPLESCRIPT.


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

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Jul-1999 10:48:34.
% Updated    14-Jul-1999 17:02:56.

if ~any(fileName == filesep)
	fileName = which(fileName);
end

fileName = ['"' fileName '"'];
newFileName = ['"' newFileName '"'];

resultString = applescript('aduplicate.mac', '-useEnglish', ...
                           'itemName', fileName, 'newName', newFileName);
						   
resultString = resultString(2:end-1);
disp(resultString)
