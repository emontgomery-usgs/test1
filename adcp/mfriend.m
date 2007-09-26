function outfile = mfriend(infile, outfile)

%function outfile = mfriend(infile, outfile)
%mfriend is an adaptation of fcomment to specifically work 
%the tilt calibration output files that have unrecognizable characters.
% fcomment -- Convert text file for "load" compatibility.
%  fcomment('infile', 'outfile') converts the "infile" to the
%   "outfile" by prepending each comment-line with '%' and
%   passing all other lines intact.  The "uigetfile" and
%   "uiputfile" dialogs are invoked if areguments are not
%   provided.


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

 
% edited by Jessica M. Cote, 1999
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 09-Nov-1998 05:37:45.

% For Bob Beardsley, WHOI.
% 01-Apr-1998 14:22:34.

if nargin < 1
	help(mfilename)
	[theFile, thePath] = uigetfile('*.*', 'Select A File:');
	if ~any(theFile), return, end
	infile = [thePath theFile];
end

theSuggested = infile;
i = find(theSuggested == filesep);
if any(i), theSuggested(1:i(length(i))) = []; end
i = find(theSuggested == '.');
if any(i), theSuggested(i(length(i)):length(theSuggested)) = []; end
theSuggested = [theSuggested '.out'];

if nargin < 2
	[theFile, thePath] = uiputfile(theSuggested, 'Save matlab friendly File As:');
	if ~any(theFile), return, end
	outfile = [thePath theFile];
end

%if isequal(exist(outfile),2) | isequal(exist('theFile'),0); 
%   disp(['File already exists, file creation aborted']); return, end

f = fopen(infile, 'r');
if f < 0, return; end
g = fopen(outfile, 'w');
if g < 0, fclose(f); return, end

while (1)
	s = fgets(f);
	if isequal(s, -1), break; end
   t = upper(s);
   if any(t >= 'A' & t ~= 'E' & t <= 'Z')
		s = ['% ' s];
    end
	fwrite(g, s);
end

fclose(f);
fclose(g);
