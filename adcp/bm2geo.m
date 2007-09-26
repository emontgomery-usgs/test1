function theResult = bm2geo(theBeamData, theElevations, theAzimuths, ...
								theHeading, thePitch, theRoll, ...
								theOrientation, theBlankingDistance)
% bm2geo -- Convert ADCP beam-data to geographic components.
%  bm2geo(theBeamData, theElevations, theAzimuths, theHeading,
%   thePitch, theRoll, 'theOrientation', theBlankingDistance)
%   converts theBeamData to geographic coordinates, using the
%   beam configuration (theElevations, theAzimuths) and other
%   orientation information. Solutions with fewer than four
%   beams in the corresponding depth-cell are returned as NaNs.
%   All angles in degrees.  TheOrientation = {'down' | 'up'}.
%
% This code performs all the angular operations needed
%  to convert ADCP beam-coordinate data to geographic
%  coordinates.  It does not make adjustments for the
%  speed-of-sound or the ADCP frequency, both of which
%  can be done before or after the present operations.
%
% "bm2geo" calls the "bm2dir" and "bm2xyze" functions.


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
 
% Version of 28-Apr-1998 11:49:00.
% Updated    16-Jul-1999 09:20:24.
% updated 05-Oct-1999 
% Updated 13-Aug-2001 added 'extrap' to the interp1 command (line 79) because the interp1 command changed
%  in Matlab 6.0, and would fill in NaNs for theBeamData values (ALR), but kept old interp1 for earlier versions
% Updated 05-Nov-2004 for MATLAB 7.x, suppress interp1 warnings

% Reference: ADCP Coordinate Transformation: Formulas and
%  Calculations (technical manual, 26 pages), RD Insruments,
%  1997.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theElevations = [-70 -70 -70 -70]; end
if nargin < 3, theAzimuths = [270 90 0 180]; end
if nargin < 4, theHeading = 0; end
if nargin < 5, thePitch = 0; end
if nargin < 6, theRoll = 0; end
if nargin < 7, theOrientation = 'up'; end   % RDI default = 'down'.
if nargin < 8, theBlankingDistance = 150; end   % cm.  RDI default = 0.

% One elevation value given.

for j = length(theElevations)+1:4
	theElevations(j) = theElevations(j-1);
end

[m, n] = size(theBeamData);

% Depth-bins, scaled for 20 or 30 degree nominal beam-angle,
%  based on the z-components of the beam-direction matrix.
%  See reference page 8.

RCF = 180 ./ pi;

if mean(abs(theElevations)) > 65
	s = sin(70 ./ RCF);
else
	s = sin(60 ./ RCF);
end

theBeamDirections = bm2dir(theElevations, theAzimuths, ...
						theHeading, thePitch, theRoll, ...
						theOrientation);

depth_scale = (theBeamDirections(:, 3) ./ s).';
depth_bins = (1:m).' * abs(depth_scale);

% Interpolate the beam data in nearest-neighbor
%  fashion.  (The ADCP uses this scheme internally
%  when recording in earth-coordinates.)

result = zeros(size(theBeamData));
temp = zeros(1, n);
% Added 'extrap' to the interp1 command so it would run in Matlab 6.0, but kept old interp1 for earlier versions
ver = version;  %Determine version of Matlab
ver = str2num (ver(1));
if ver < 6
   for j = 1:n
      theBeamData(:, j) = interp1(depth_bins(:, j),...
          theBeamData(:, j), (1:m).', 'nearest');
   end
else
    % turn off the warning generated in MATLAB 7.0
    s = warning('off', 'MATLAB:interp1:NaNinY');
    for j = 1:n
       theBeamData(:, j) = interp1(depth_bins(:, j),...
           theBeamData(:, j), (1:m).', 'nearest','extrap');
    end
    warning('on',s.identifier);
end
 

% Transformation matrix.  See reference page 10.

theTransformation = bm2xyze(theElevations, theAzimuths, ...
						theHeading, thePitch, theRoll, ...
						theOrientation);

% Patch any three-beam data by forcing error = 0.

three_beam = find(isfinite(theBeamData)*ones(4, 1) == 3);
%disp(length(three_beam))
if any(three_beam)
	data = theBeamData(three_beam, :);
	mask = isnan(data);
	data(mask) = 0;
	tran = ones(length(three_beam), 1) * theTransformation(4, :);
	err = (data .* tran) * ones(4, 1);
	data(mask) = -err ./ tran(mask);
	theBeamData(three_beam, :) = data;
end

% Convert the beam-data (four-columns) to
%  earth-coordinates via post-multiplication
%  by the transpose of the transformation matrix.

result = theBeamData * theTransformation.';

% Pin three-beam error to zero exactly.
%f is not defined!
if any(three_beam), result(three_beam, 4) = 0; end

% Output.

if nargout > 0
	theResult = result;
else
	disp(result)
end
