function premask(theDataFile, theMaskFile, vel, cor, agc, pgd)

% premask -- Pre-mask for "Starbear" interaction.
%  premask('theDataFile', 'theMaskFile', vel, cor, agc, good)
%   marks 'theMaskFile' in accordance with the acceptable ranges
%   [min max] for the "vel", "cor", "AGC", and "PGd" variables
%   in 'theDataFile', respectively.  Velocity is assumed to be
%   given in cm/s, even though it is stored as mm/s in the file.


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
 
% upadted 02-jan-2007 MM to make more readable code
% Version of 14-Jan-1999 14:25:34.
% edited by JMC and CRD on 20 May 1999
% can now be called by a single line in a function
% CRD is working to allow a 4x2 input for all the ranges rather than 
% the current 1x2.

CHUNK = 100;

if nargin < 1, theDataFile = ''; end
if nargin < 2, theMaskFile = ''; end

if isempty(theDataFile), theDataFile = '*'; end
if isempty(theMaskFile), theMaskFile = '*'; end

if any(theDataFile == '*')
   help(mfilename)
   thePrompt = theDataFile;
   [theFile, thePath] = uigetfile(thePrompt, 'Select ADCP Data File');
   if ~any(theFile), return, end
   if thePath(end) ~= filesep, thePath(end+1) = filesep; end
   theDataFile = [thePath theFile];
   cd(thePath)
end

if any(theMaskFile == '*')
   help(mfilename)
   thePrompt = theMaskFile;
   [theFile, thePath] = uigetfile(thePrompt, 'Select ADCP Mask File');
   if ~any(theFile), return, end
   if thePath(end) ~= filesep, thePath(end+1) = filesep; end
   theMaskFile = [thePath theFile];
   cd(thePath)
end

theData = netcdf(theDataFile, 'nowrite');
if isempty(theData), return, end

theMask = netcdf(theMaskFile, 'write');
if isempty(theMask), close(theData), return, end

isEarth = isequal(lower(theData.transform(:)), 'eart');

if nargin < 3
	vel = [-3276.8 3276.7];
	vel1 = [-3276.8 3276.7];
	vel2 = [-3276.8 3276.7];
	vel3 = [-3276.8 3276.7];
	vel4 = [-3276.8 3276.7];
	cor = [0 255];
	agc = [0 255];
	pgd = [0 100];
	if ~isEarth
		ADCP_Valid_Range.Velocity = vel;
	else
		ADCP_Valid_Range.U = vel1;
		ADCP_Valid_Range.V = vel2;
		ADCP_Valid_Range.W = vel3;
		ADCP_Valid_Range.Werr = vel4;
	end
	ADCP_Valid_Range.Correlation = cor;
	ADCP_Valid_Range.Gain = agc;
	ADCP_Valid_Range.PercentGood = pgd;
	s = uigetinfo(ADCP_Valid_Range);
	if ~isempty(s)
		if ~isEarth
			vel = getinfo(s, 'Velocity');
			vel = ones(4, 1) * vel;
		else
			u = getinfo(s, 'U');
			v = getinfo(s, 'V');
			w = getinfo(s, 'W');
			werr = getinfo(s, 'Werr');
			vel = [u; v; w; werr];
		end
		cor = ones(4, 1) * getinfo(s, 'Correlation');
		agc = ones(4, 1) * getinfo(s, 'Gain');
		pgd = ones(4, 1) * getinfo(s, 'PercentGood');
	end
end

vel = 10 * vel;   % Convert cm/s to mm/s.

for k = 1:4
	vmask{k} = theMask{['vel' int2str(k)]};
end

nrecords = size(theData{'vel1'});
nrecords = nrecords(1);

% Velocity.

vel

if any(isfinite(vel(:)))
	for ibeam = 1:4
		theVarname = ['vel' int2str(ibeam)];
		disp([' ## ' theVarname ' ...'])
		data = theData{theVarname};
		mask = vmask{ibeam};
		m = size(data, 1);
		i = 0;
		while i < m
			j = i+1:min(i+CHUNK, nrecords);
			s = data(j, :);
			t = mask(j, :);
		%	bad = s < min(vel(ibeam, :)) | s > max(vel(ibeam, :));
			bad = s < min(vel(1, :)) | s > max(vel(1, :));
			t = t | bad;
			mask(j, :) = t;
			i = i + CHUNK;
		end
	end
end

% Correlation.

if any(isfinite(cor(:)))
	for ibeam = 1:4
		theVarname = ['cor' int2str(ibeam)];
		disp([' ## ' theVarname ' ...'])
		data = theData{theVarname};
		mask = vmask{ibeam};
		m = size(data, 1);
		i = 0;
		while i < m
			j = i+1:min(i+CHUNK, nrecords);
			s = data(j, :);
			t = mask(j, :);
			bad = s < min(cor(1, :)) | s > max(cor(1, :));
		%		bad = s < min(cor(ibeam, :)) | s > max(cor(ibeam, :));
		t = t | bad;
			mask(j, :) = t;
			i = i + CHUNK;
		end
	end
end

% Gain (AGC).

if any(isfinite(agc(:)))
	for ibeam = 1:4
		theVarname = ['AGC' int2str(ibeam)];
		disp([' ## ' theVarname ' ...'])
		data = theData{theVarname};
		mask = vmask{ibeam};
		m = size(data, 1);
		i = 0;
		while i < m
			j = i+1:min(i+CHUNK, nrecords);
			s = data(j, :);
			t = mask(j, :);
	%		bad = s < min(agc(ibeam, :)) | s > max(agc(ibeam, :));
			bad = s < min(agc(1, :)) | s > max(agc(1, :));
			t = t | bad;
			mask(j, :) = t;
			i = i + CHUNK;
		end
	end
end

% Percent-good.
% TODO detect non-beam data and treat Pgd accordingly.
if any(isfinite(pgd(:)))
	for ibeam = 1:4
		theVarname = ['PGd' int2str(ibeam)];
		disp([' ## ' theVarname ' ...'])
		data = theData{theVarname};
		mask = vmask{ibeam};
		m = size(data, 1);
		i = 0;
		while i < m
			j = i+1:min(i+CHUNK, nrecords);
			s = data(j, :);
			t = mask(j, :);
%			bad = s < min(pgd(ibeam, :)) | s > max(pgd(ibeam, :));
			bad = s < min(pgd(1, :)) | s > max(pgd(1, :));
			t = t | bad;
			mask(j, :) = t;
			i = i + CHUNK;
		end
	end
end

close(theMask)
close(theData)
