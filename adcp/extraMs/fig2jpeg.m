function theOutputFile = fig2jpeg(theFilename, theFigure)

% fig2jpeg -- Save a figure in JPEG format.
%  fig2jpeg('theFilename', theFigure) saves theFigure
%   (default = current figure) to 'theFilename'.  If
%   no flename is given, the Matlab "uiputfile" dialog
%   is invoked.


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

  
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Jan-2000 17:35:28.
% Updated    03-Jan-2000 17:35:28.

if nargout > 0, theOutputFile = []; end

if nargin < 1
	[f, p] = uiputfile('unnamed.jpg', 'Save Figure As JPEG:');
	if ~any(f)
		help(mfilename)
		return
	end
	if p(end) ~= filesep, p(end+1) = filesep; end
	theFilename = [p f];
end
if nargin < 2, theFigure = gcf; end

theOldFigure = gcf;

figure(theFigure)
[x, map] = getframe(theFigure);
imwrite(x, map, theFilename, 'jpg','quality',100)
%imwrite(x, map, theFilename, 'tiff')

if nargout > 0, theOutputFile = which(theFileName); end
