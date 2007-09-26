function theResult = bm2dir(theElevations, theAzimuths, ...
								theHeading, thePitch, theRoll, ...
								theOrientation)

% bm2dir -- ADCP beam to X-Y-Z direction-cosines.
%  bm2dir(theElevations, theAzimuths) returns the direction-
%   cosines (4-by-3 matrix) for ADCP beams, using RDI geometry.
%   All angles in degrees.  The elevations and azimuths are always
%   given as if the ADCP were oriented downwards.
%  bm2dir(theElevations, theAzimuths, theHeading, thePitch, theRoll,
%   'theOrientation') applies the additional orientation parameters,
%   which are assumed to be zero otherwise.  All angles in degrees.
%   The value for theOrientation is either 'down' or 'up'.
%  bm2dir (no arguments) demonstrates itself by returning the
%   direction-cosines for the conventional arrangement of beams
%   pointed downwards 20 degrees from vertical, at azimuths
%   of [270 90 0 180].


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
 
% Version of 07-May-1998 14:25:57.
% updated 05-Oct-1999 

% Reference: ADCP Coordinate Transformation: Formulas and
%  Calculations (technical manual, 26 pages), RD Insruments,
%  1997.

if nargin < 2
	help(mfilename)
	theElevations = [-70 -70 -70 -70]
	theAzimuths = [270 90 0 180]
	theBeamDirections = bm2dir(theElevations, theAzimuths);
	if nargout > 0
		theResult = theBeamDirections;
	else
		theBeamDirections
	end
	return
end

if nargin < 3, theHeading = 0; end
if nargin < 4, thePitch = 0; end
if nargin < 5, theRoll = 0; end
if nargin < 6, theOrientation = 'down'; end

% One elevation value given.

for i = length(theElevations)+1:4
	theElevations(i) = theElevations(i-1);
end

% No azimuths given.

if nargin < 2 | isempty(theAzimuths)
	theAzimuths = [270 90 0 180];
end

% Modify the pitch measurement for actual RDI scheme.
%  See reference page 14.

RCF = 180 / pi;
k_factor = sqrt(1 - (sin(thePitch/RCF)*sin(theRoll/RCF))^2);
thePitch = asin(sin(thePitch/RCF)*cos(theRoll/RCF)/k_factor) * RCF;

% Adjustments for down/up orientation.

switch lower(theOrientation)
case 'down'
	theRoll = -theRoll;
case 'up'
	theElevations = -theElevations;
	theAzimuths = -theAzimuths;
otherwise
end

% From X-Y-Z to beam directions.

% The compass-pitch-roll correction sequence
%  is critical.

theBeamDirections = zeros(4, 3);

for i = 1:4
	x = 0;
	y = 1;
	z = 0;
	[y, z] = rot1(y, z, theElevations(i));
	[y, x] = rot1(y, x, theAzimuths(i));
	[z, x] = rot1(z, x, theRoll);
	[y, z] = rot1(y, z, thePitch);
	[y, x] = rot1(y, x, theHeading);
	theBeamDirections(i, :) = [x y z];
end

% Output.

if nargout > 0
	theResult = theBeamDirections;
else
	disp(theBeamDirections)
end
