function theResult = ncmkmask(inFile, outFile, fillValue)

% ncmkmask -- Make a NetCDF "mask" file.
%  ncmkmask('inFile', 'outFile', fillValue) creates a "mask"
%   file named 'outFile', based on the 'inFile'.  The output
%   variables have the names and dimensions of the input
%   variables, but they contain byte-data, filled with the
%   given fillValue (default = 0).  Attributes are ignored.
%   If a file is entered as an open "netcdf" object, it
%   will remain open at the end of this routine.  Use '*'
%   to open a file via dialog.


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
 
% Version of 06-Jan-1999 17:59:45.

VERBOSE = 1;

if nargout > 0, theResult = []; end

if nargin < 1, help(mfilename); end
if nargin < 1, inFile = '*'; end
if nargin < 2, outFile = '*'; end

if nargin < 3, fillValue = 0; end
if ischar(fillValue), fillValue = eval(fillValue); end

% Input file.

if isa(inFile, 'netcdf')
	f = inFile;
else
	f = netcdf(inFile, 'nowrite');
end

if isempty(f), return, end

% Output file.

if isa(outFile, 'netcdf')
	g = outFile;
elseif any(outFile == '*')
	[p, outFile, e, v] = fileparts(name(f));
	outFile = ['*' outFile '.msk'];
	g = netcdf(outFile, 'clobber');
else
	g = netcdf(outFile, 'noclobber');
end

if isempty(g) & ~isa(inFile, 'netcdf')
	close(f)
	return
end

% Creation information.

g.CreatedBy = mfilename;
g.CreatedOn = datestr(now);
g.BasedOnFile = name(f);

% Transfer the dimensions.

if VERBOSE
	disp([' ## Data File: ' name(f)])
	disp([' ## Mask File: ' name(g)])
	disp(' ## Defining dimensions ...')
end

d = dim(f);
for i = 1:length(d)
	if isrecdim(d{i})
		theLength = 0;   % Record-dimension.
	else
		theLength = length(d{i});
	end
	if VERBOSE, disp([' ##    ' name(d{i}) ' ...']), end
	g(name(d{i})) = theLength;
end

% Re-create the variables as "byte" data.

if VERBOSE, disp(' ## Defining variables ...'), end
v = var(f);
for i = 1:length(v)
	if VERBOSE, disp([' ##    ' name(v{i}) ' ...']), end
	d = ncnames(dim(v{i}));   % Dim. names.
	g{name(v{i})} = ncbyte(d{:});   % New variable.
	g{name(v{i})}.FillValue_ = fillValue;   % Fill it.
end

g = endef(g);

% Expand record-variables, if any.

r = recdim(g);
if ~isempty(r)
	if VERBOSE, disp(' ## Filling record-variables ...'), end
	v = var(r);
	for i = 1:length(v)
		if VERBOSE, disp([' ##    ' name(v{i}) ' ...']), end
		sz = ncsize(f{name(v{i})});
		for i = 1:length(sz)
			indices{i} = sz(i);
		end
		v{i}(indices{:}) = fillValue;
	end
end

% Done.

if VERBOSE, disp(' ## Done.'), end
if ~isa(outFile, 'netcdf'), close(g), end
if ~isa(inFile, 'netcdf'), close(f), end
