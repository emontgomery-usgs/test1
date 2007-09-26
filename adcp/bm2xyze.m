function theResult = bm2xyze(theElevations, theAzimuths, ...
								theHeading, thePitch, theRoll, ...
								theOrientation)
% bm2xyze -- ADCP beam to X-Y-Z-E transformation.
%  bm2xyze(theElevations, theAzimuths) returns the transformation
%   matrix that converts beam data (4 columns) to X-Y-Z-E data by
%   pre-multiplication, using RDI conventions for ADCP measurements.
%   The beam-directions point away from the transponders, whereas
%   positive velocities point toward them.  The error-vector
%   coefficients are scaled to be approximately 0.5.  All angles
%   in degrees.
%  bm2xyze(theElevations, theAzimuths, theHeading, thePitch, theRoll,
%   'theOrientation') uses the additional orientation information as
%   well.  All angles in degrees.  TheOrientation is {'down' | 'up'}.
%  bm2xyze (no arguments) demonstrates itself by returning the
%   transformation for the conventional arrangement of beams
%   pointed downwards 20 degrees from vertical, at azimuths
%   of [270 90 0 180], other angles = 0.


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
 
% Version of 12-May-1998 14:47:33.

% Reference: ADCP Coordinate Transformation: Formulas and
%  Calculations (technical manual, 26 pages), RD Insruments,
%  1997.

if nargin < 1
	help(mfilename)
	theElevations = [-70 -70 -70 -70]
	theAzimuths = [270 90 0 180]
	theHeading = 0
	thePitch = 0
	theRoll = 0
	theOrientation = 'down'
	theTransformation = bm2xyze(theElevations, theAzimuths, ...
							theHeading, thePitch, theRoll, ...
							theOrientation);
	if nargout > 0
		theResult = theTransformation;
	else
		theTransformation
	end
	return
end

% Default arguments.

if nargin < 2, theAzimuths = [270 90 0 180]; end
if nargin < 3, theHeading = 0; end
if nargin < 4, thePitch = 0; end
if nargin < 5, theRoll = 0; end
if nargin < 6, theOrientation = 0; end

% One elevation value given.

for i = length(theElevations)+1:4
	theElevations(i) = theElevations(i-1);
end

% From X-Y-Z to beam directions.

theBeamDirections = ...
		bm2dir(theElevations, theAzimuths, ...
				theHeading, thePitch, theRoll, ...
				theOrientation);

% From beam directions to X-Y-Z coordinates.
%  See reference page 10.

theInverse = theBeamDirections \ eye(4, 4);

% Error-vector.  See reference page 10.

theErrorVector = [theInverse(:, 1:3) \ theInverse(:, 4); -1];
theErrorVector = theErrorVector / norm(theErrorVector);

% Append.

theTransformation = [theInverse; theErrorVector.'];

% Result for outward beam-directions, with positive
%  velocities directed inwards.

result = -theTransformation;

% Output.

if nargout > 0
	theResult = result;
else
	disp(result)
end
