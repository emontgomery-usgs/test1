function theResult = StarBeam(theDataFile, thePermission)

% StarBeam/StarBeam -- ADCP Data Browser.
%  StarBeam('theDataFile', 'thePermission') opens
%   'theDataFile' of ADCP measurements for browsing,
%   with 'thePermission': 'write' or 'nowrite' (default).
%   The "uigetfile" dialog is invoked if no filename
%   is given, or if a wildcard is given.
%   The "starbeam" object is returned or placed in
%   the caller's "ans".  It is also available as
%   "px(gcf)" whenever the "StarBeam Browser" window
%   is frontmost.
%
% STARBEAM WINDOW
%
% The "StarBeam Browser" window offers slider-controls
%  for scrolling through the data.  The window contains
%  four panels, for showing four data-types for a single
%  beam, or one data-type for four beams.  When velocities
%  for earth-coordinates are shown, the panels represent
%  from top to bottom: u (positive east), v (positive north),
%  w (positive up), and the inferred error.
%
% STARBEAM MENUBAR
%
% The StarBeam menubar is for selecting the variables
%  to be shown: velocity, correlation, AGC, percent-good,
%  and tilt.  The data can be displayed by beam or by
%  type.  Other menus offer easy ways to change
%  the display without having to interact with the
%  "StarBeam Setup" dialog.
%
% STARBEAM SETUP DIALOG
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
%  in the file.  Do not change.
%
% The "Ensemble Time Sampling" field shows the time
%  sample-interval as a "dhms" time-string.  Do not
%  change.
%
% The "Bin Start, Count, Step, and Max" fields are
%  used for selecting the particular ADCP bins to
%  show, by bin number.  The default behavior is
%  to show all bins.
%
% The "Time Axis" field allows the horizontal scaling
%  to be expressed as time or record-number.  The
%  default is to show time.
%
% The "Plot Style" field offers several choices for
%  the display style to be shown. The default is
%  "image".
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

 
%  This browser relies on particular names for NetCDF
%   variables, mainly: TIM, Rec, vel1..4, cor1..4, AGC1..4,
%   and PGd1..4.  The NetCDF file is not an EPIC-file.
%   For beam-data, the vel1..4 correspond to beams 1..4,
%   respectively.  For earth-coordinates, they correspond
%   to u (east), v (north), w (up), and the so-called w-error.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 14-Sep-1998 15:29:13.
% Updated    15-Oct-1998 22:23:13.
% Updated    29-Oct-1998 15:59:40.
% Updated    02-Nov-1998 14:35:02.
% Updated    05-Oct-1999 11:14:34.
% Revised   05-Nov-2004 for MATLAB 7.0

if nargout > 0, theResult = []; end

if nargin < 1, theDataFile = ''; help(mfilename), end
if nargin < 2, thePermission = 'nowrite'; end

if isequal(theDataFile, 'write') | ...
		isequal('theDataFile', 'nowrite')
	thePermission = theDataFile;
	theDataFile = '';
end

if isempty(theDataFile), theDataFile = '*'; end

if any(theDataFile == '*')
   help(mfilename)
	thePrompt = theDataFile;
   [theFile, thePath] = uigetfile(thePrompt, 'Select ADCP File');
   if ~any(theFile), return, end
   theDataFile = [thePath theFile];
   cd(thePath)
end

theData = netcdf(theDataFile, thePermission);
if isempty(theData), return, end

theDataVars = var(theData);
theDataNames = ncnames(theDataVars);

theStruct.itSelf = [];
self = class(theStruct, 'starbeam', pxwindow('StarBeam Browser', 'XY'));

pxset(self, 'itsData', theData)

pxset(self, 'itsBinStart', []);
pxset(self, 'itsBinCount', []);
pxset(self, 'itsBinStep', []);
pxset(self, 'itsEnsembleStart', []);
pxset(self, 'itsEnsembleCount', []);
pxset(self, 'itsEnsembleStep', []);
pxset(self, 'itsVariables', []);
pxset(self, 'itsPlotStyle', []);   % 'plot', 'image', or 'contour'.

self.itSelf = px(self);
pxset(self, 'itsObject', self);

theFigure = px(self);
pxenable(theFigure, theFigure);
pxenable(theFigure, 'CloseRequestFcn')

set(theFigure, 'WindowButtonDownFcn', '')
set(theFigure, 'WindowButtonMotionFcn', '')
set(theFigure, 'WindowButtonUpFcn', '')


theMenus = addmenus(self);
set(theFigure, 'MenuBar', 'none')

% colormenu does not exist in version 7 and higher
v = ver('MATLAB');
if str2num(strtok(v.Version,'.')) < 7,
    colormenu;
    h = findobj(gcf, 'Type', 'uimenu', 'Label', 'colormaps');
    if any(h), set(h, 'Label', '<ColorMaps>'), end
end

theTimeName = 'time';		% ZYDECO default = EPIC time.
theTimeUnits = 'unknown units';
if isempty(theData{theTimeName})
   theTimeName = 'TIM';   % Try TIM.
   if isempty(theData{theTimeName})
      theTimeName = listpick(ncnames(var(theData)), ...
                       'Pick Time Variable', 'Time', 'unique');
      if isempty(theTimeName), theTimeName = {''}; end
      theTimeName = theTimeName{1};
   end
end

switch theTimeName
case 'time'
	t = round(theData{'time2'}(1:2) * 1000);   % seconds.
otherwise
	t = round(theData{theTimeName}(1:2) * 86400);    % seconds.
end
theTimeSampling = dhms(diff(t) / 86400);   % dhms.

theTimeUnits = theData{theTimeName}.units(:);

theDepthName = 'D';
theDepthUnits = theData{theDepthName}.units(:);
theDepthSampling = theData{theDepthName}.bin_size(:);
theDepthSampling = [num2str(theDepthSampling) ' ' theDepthUnits];

pxset(self, 'itsTimeName', theTimeName);
pxset(self, 'itsTimeUnits', theTimeUnits);
pxset(self, 'itsTimeSampling', theTimeSampling);

pxset(self, 'itsDepthName', theDepthName);
pxset(self, 'itsDepthUnits', theDepthUnits);
pxset(self, 'itsDepthSampling', theDepthSampling);

initialize(self)

if nargout > 0
   theResult = self;
  else
   assignin('base', 'ans', self)
end
