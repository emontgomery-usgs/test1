function theStatus = uisetdir(thePrompt, theInstruction)

% uisetdir -- Open the destination folder via dialog.
%  uisetdir('thePrompt', 'theInstruction') presents the "uiputfile"
%   dialog with 'thePrompt' and 'theInstruction', for selecting the
%   desired destination folder.  The returned status is logical(1)
%   if successful; otherwise, logical(0).


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
 
% Version of 03-Jul-1997 09:16:00.

if nargin < 1, thePrompt = 'Open The Destination Folder'; end
if nargin < 2, theInstruction = 'Save If Okay'; end

theFile = 0; thePath = 0;
[theFile, thePath] = uiputfile(theInstruction, thePrompt);

status = 0;                
if isstr(thePath) & any(thePath)
   status = 1;
   eval('cd(thePath)', 'status = 0;')
end

if nargout > 0, theStatus = any(any(status)); end
