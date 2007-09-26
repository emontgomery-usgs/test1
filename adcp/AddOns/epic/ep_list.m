function ep_list(theEpicFile, theOutputFile, ...
			theStartTime, theStopTime, varargin)

% ep_list -- Listing of EPIC variables.
%  ep_list(theEpicFile, theOutputFile, theStartTime, theStopTime, ...)
%   lists the EPIC variables specified by ..., for the given file and
%   times.  The function prompts for missing inputs.  The time is given
%   as [yr mo da hr mn sc] in the first six columns of the output, with
%   yr being Y2K safe.  The top row of the file contains the names of
%   the fields.


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

  
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 10-Dec-1998 11:22:23.
% Updated    09-Sep-1999 09:54:48.

CHUNK = 100;   % Records per output cycle.

% Testing.

if nargin < 1 & 0
	theEpicFile = '4381adc-a.nc';
	theOutputFile = 'unnamed.asc';
	theStartTime = '04Apr94 14:00:00';
	theStopTime = '04Apr94 16:00:00';
	ep_list(theEpicFile, theOutputFile)
	edit(theOutputFile)
	return
end

if nargin < 1 & 0
%	nc.start_time = ncchar('99- III-16  00.00.00');
%	nc.stop_time = ncchar('99- VI -21  08.35.00');

	theEpicFile = '5621pt.cdf';
	theOutputFile = 'unnamed.asc';
	theStartTime = '16Mar99 00:00:00';
	theStopTime = '21Jul99 08:35:00';
	
	theStopTime = '17Mar99 00:00:00';
	
	ep_list(theEpicFile, theOutputFile)
	edit(theOutputFile)
	return
end

% Get EPIC input file.

if nargin < 1
	help(mfilename)
	[theFile, thePath] = uigetfile('*', 'Open EPIC File');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theEpicFile = [thePath theFile];
end

nc = netcdf(theEpicFile, 'nowrite');
if isempty(nc), return, end
if ~isepic(nc)
	close(nc)
	disp(' ## Not an EPIC file.')
	return
end

% Get Ascii output file.

if nargin < 2
	[ignore, theSuggested, ignore, ignore] = fileparts(theEpicFile);
	theSuggested = [theSuggested '.asc'];
	[theFile, thePath] = uiputfile(theSuggested, 'Save List As');
	if ~any(theFile)
		close(nc)
		return
	end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theOutputFile = [thePath theFile];
end

% Check dates; prepare for rounding to nearest second.

t = nc{'time'};
t2 = nc{'time2'};

d = ep_datenum([t(:) t2(:)]);
d = round(d*86400) + 0.25;   % For later "fix(datevec(d(j)))".
d = d/86400;
disp([' ## EPIC Start Time: ' datestr(d(1))])
disp([' ## EPIC Stop  Time: ' datestr(d(end))])

% Get start/stop times.

if nargin < 3
	s.Start_Time = datestr(d(1));
	s.Stop_Time = datestr(d(end));
	s = uigetinfo(s);
	if isempty(s)
		close(nc);
		return
	end
	theStartTime = getinfo(s, 'Start_Time');
	theStopTime = getinfo(s, 'Stop_Time');
end

if nargin == 3
	s.Start_Time = theStartTime;
	s.Stop_Time = datestr(d(end));
	s = uigetinfo(s);
	if isempty(s)
		close(nc);
		return
	end
	theStartTime = getinfo(s, 'Start_Time');
	theStopTime = getinfo(s, 'Stop_Time');
end

tstart = datenum(theStartTime);
tstop = datenum(theStopTime);

indices = find(d >= tstart & d <= tstop);

if ~any(indices)
	close(nc)
	disp(' ## No records for those times.')
	return
end

disp([' ## Requested record count: ' int2str(length(indices))])

% Get the variables associated with "time".

if nargin < 5
	theNames = ncnames(var(nc('time')));
	for i = length(theNames):-1:1
		switch theNames{i}
		case {'time', 'time2'}
			theNames(i) = [];
		otherwise
		end
	end
	varargin = listpick(theNames, 'Pick Variables', 'EP_List', 'multiple');
end

if isempty(varargin)
	close(nc);
	return
end

for i = 1:length(varargin)
	v{i} = nc{varargin{i}};
end

% Construct the output format.

theOutputFormat = '%5i%3i%3i%3i%3i%3i';
width = zeros(length(v), 1);
for i = 1:length(v)
	s = size(v{i});
	columns = prod(s) / s(1);
	dt = datatype(v{i});
	switch datatype(v{i})
	case 'byte'
		width(i) = 5;
		style = 'i';
	case 'char'
		width(i) = 1;
		style = 'c';
	case 'short'
		width(i) = 10;
		style = 'i';
	case 'long'
		width(i) = 15;
		style = 'i';
	case 'float'
		width(i) = 20;
		style = 'f';
	case 'double'
		width(i) = 25;
		style = 'f';
	otherwise
		error(' ## Unknown datatype.')
	end
	width(i) = max(width(i), length(name(v{i})+1));
	fmt = ['%' int2str(width(i)) style];
	for j = 1:columns
		theOutputFormat = [theOutputFormat fmt];
	end
end
theOutputFormat = [theOutputFormat '\n'];

% Open the output file.

if ~ischar(theOutputFile)
	fp = theOutputFile;
else
	fp = fopen(theOutputFile, 'w');
	if fp < 0
		disp(' ## Output file not opened.')
		close(nc);
		return
	end
end

% Output the variable names.

theStringFormat = '   yr mo da hr mn sc';
fprintf(fp, theStringFormat);
for i = 1:length(v)
	s = size(v{i});
	columns = prod(s) / s(1);
	theStringFormat = ['%' int2str(width(i)) 's'];
	for j = 1:columns
		fprintf(fp, theStringFormat, name(v{i}));
	end
end
fprintf(fp, '\n');

% Allocate an input array.

columns = 6;
for i = 1:length(v)
	s = size(v{i});
	columns = columns + prod(s) / s(1);
end
z = zeros(CHUNK, columns);

% Output the selected variables one CHUNK at a time.

k = 0;
tic
while k < length(indices)
	if k > 0
		remaining = length(indices)-k;
		dt = remaining * (toc / k) / 86400;   % days.
		disp([' ## Remaining: ' int2str(remaining) ' records; ' dhms(dt)])
	end
	dk = min(CHUNK, length(indices)-k);
	j = indices(k+1:k+dk);
	c = 0;
	z(1:dk, c+1:c+6) = fix(datevec(d(j)));   % To rounded second.
	c = c + 6;
	for i = 1:length(v)
		s = size(v{i});
		columns = prod(s) / s(1);
		x = v{i}(j, :);
		z(1:dk, c+1:c+columns) = reshape(x, [dk, columns]);
		c = c + columns;
	end
	if k == 0, disp(z(1, :)), end
	fprintf(fp, theOutputFormat, z.');
	k = k + CHUNK;
end

% Done.

if ischar(theOutputFile), fclose(fp); end
close(nc)
