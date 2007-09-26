function theResult = which1s(theFunction)

% which1s -- "which" for entire Matlab path.
%  which1s('theFunction') performs "which" for
%   all parts of the Matlab path, returning a
%   list of instances of 'theFunction', the
%   first of which is the current one.  The
%   routine ignores class-methods.
%  which1s (no argument) demonstrates itself
%   by operating on itself.


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
 
% Version of 29-Mar-2000 09:31:12.
% Updated    29-Mar-2000 10:08:39.

if nargin < 1& nargout < 1
	help(mfilename)
	feval(mfilename, mfilename)
	return
end

current = which(theFunction);

if isempty(current)   % Not found.
	w = {[theFunction ' not found.']};
else   % Find others.
	p = path;
	if p(1) ~= pathsep, p = [pathsep p]; end
	if p(end) ~= pathsep, p(end+1) = pathsep; end
	f = find(p == pathsep);
	w = cell(length(f-1), 1);
	w{1} = current;
	theOldPWD = pwd;
	for i = 2:length(f)
		w{i} = '';
		theDir = p(f(i-1)+1:f(i)-1);
		if ~isempty(theDir)
			cd(theDir)
			w{i} = which(theFunction);
		end
	end
	cd(theOldPWD)
end

% Delete duplicates.

[w, indices] = sort(w);
for i = length(w):-1:2
	if isequal(w{i}, w{i-1})
		w{i} = '';
	end
end
w(indices) = w;

for i = length(w):-1:2
	if isempty(w{i})
		w(i) = [];
	end
end

if nargout > 0
	theResult = w;
else
	for i = 1:length(w)
		disp(w{i})
	end
end
