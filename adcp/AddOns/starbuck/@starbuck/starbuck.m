function theResult = starbuck(theDataFile, thePermission)

% starbuck/starbuck -- Constructor for "starbuck" class.
%  starbuck('theDataFile') opens a 'starbuck" browser
%   for 'theDataFile', using 'thePermission': 'write'
%   or 'nowrite' (default).  The "uigetfile" dialog
%   is invoked if no file is given, or is a wildcard
%   '*' is found in the name.  The "starbuck" object
%   is returned or placed in the caller's ans.  It
%   can be recovered by executing "ps(gcf)" if its
%   window is frontmost.
%
% STARBUCK WINDOW
%
% The scrollable "StarBuck Browser" window shows several
%  panels for ADCP velocity measurements contained in a
%  NetCDF/EPIC file.
%
% STARBUCK MENUBAR
%
% The StarBuck menubar is for selecting the variables
%  to be shown, mainly ADCP velocities.  Various sub-menus
%  offer easy ways to change the display without having to
%  interact with the "StarBuck Setup" dialog.
%
% STARBUCK SETUP DIALOG
%
% The "Ensemble Averaging" checkbox causes the displays
%  to show ensemble averages if checked.  The averaging
%  width is given by the "Ensemble Step" field.  The
%  default is unchecked (no-averaging).
%
% The "Ensemble Start" field may be a record-number, or
%  a valid Matlab date string in quotes.  See "help datestr"
%  and "help datenum" for formats.  The default is
%  to start at the first record.
%
% The "Ensemble Stop" field is ignored at present.
%
% The "Ensemble Count" field may be a record-count, or
%  a "dhms" (day-hour-minute-second) time-string in quotes.
%  See "help dhms2d" and "help d2dhms".  The default
%  is to show 50 records.
%
% The "Ensemble Step" field may be a record-count, or
%  a "dhms" time-string in quotes.  See "help dhms2d"
%  and "help d2dhms".  The default step is 1 record.
%
% The "Ensemble Max" field shows the number of records
%  in the file.  Do not change it.
%
% The "Ensemble Time Sampling" field shows the time
%  sample-interval as a "dhms" time-string.  Do not
%  change it.
%
% The "Bin Start, Count, Step, and Max" fields are
%  used for selecting the particular ADCP bins to
%  show, by bin number.  The default behavior is
%  to show all bins.
%
% The "Bin Stop" field is ignored at present.
%
% The "Time Axis" field allows the horizontal scaling
%  to be expressed as time (default) or ensemble-number.
%
% The "Depth Axis" field allows the vertical scaling
%  to be expressed as depth (default) or bin-number.
%
% The "Plot Style" field offers several choices for
%  the display style to be shown.  The default is
%  "image".  The "contour" option superimposes
%  contours on an image.
%
% The "Rotation" angle for earth-coordinates is given
%  in degrees.  A positive angle rotates the horizontal
%  data counter-clockwise, equivalent to rotating the
%  coordinate system clockwise.  For example, to correct
%  for a magnetic declination of 16 degrees West, use +16.
%  The default angle is 0.
%
% The "ColorFactor" is for color-scaling the vertical
%  velocity in an image.  Zero (0) allows the vertical
%  velocity image to range over the full color-map.
%  A value of one (1) forces the same color scaling
%  for all velocities.  A larger number amplifies the
%  vertical velocity scaling by the given factor.
%  The default is 1.


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
 
% Version of 23-Nov-1999 17:07:41.
% Updated    17-Dec-1999 23:56:56.

if nargout > 0, theResult = []; end
if nargin < 1, theDataFile = []; end
if nargin < 2, thePermission = 'nowrite'; end

if isps(theDataFile)
	thePS = theDataFile;
	theStruct.ignore = [];
	self = class(theStruct, 'starbuck', thePS);
	set(handle(self), 'UserData', self)
	if nargout > 0, theResult = self; end
	return
end

if isequal(theDataFile, 'write') | ...
		isequal('theDataFile', 'nowrite')
	thePermission = theDataFile;
	theDataFile = '';
end

if isempty(theDataFile), theDataFile = '*'; end

if any(theDataFile == '*')
	[theFile, thePath] = uigetfile(theDataFile, 'Select ADCP EPIC File');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theDataFile = [thePath theFile];
end

theNetCDF = netcdf(theDataFile, thePermission)
if isempty(theNetCDF)
	disp(' ## File must be NetCDF -- please check.')
	return
end

theDataFile = name(theNetCDF);

t = theNetCDF{'time'};
t2 = theNetCDF{'time2'};
if isempty(t) | isempty(t2)
	close(theNetCDF)
	disp([' ## Not an EPIC file: ' theDataFile])
	return
else
	t_code = t.epic_code(:);
	t2_code = t2.epic_code(:);
	if t_code ~= 624 | t2_code ~= 624
		disp([' ## Not an EPIC file: ' theDataFile])
		close(theNetCDF)
		return
	end
end

theFigure = figure('Name', 'StarBuck ADCP Browser');

theStruct.ignore = [];
self = class(theStruct, 'starbuck', ps(theFigure));
psbind(self)

psset(self, 'itsData', theNetCDF)

doinitialize(self)

if nargout > 0
	theResult = self;
else
	assignin('caller', 'ans', self)
end
