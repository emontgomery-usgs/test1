function theResult = update(self)

% starbeam/update -- Update the "StarBeam" window.
%  update(self) updates the window associated with self,
%   a "starbeam" object.


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
 
% Version of 03-Apr-1998 11:44:55.

if nargin < 1, help(mfilename), return, end

busy

% Data ranges and other parameters.

theData = pxget(self, 'itsData');

theTimeName = pxget(self, 'itsTimeName');
theTimeSampling = pxget(self, 'itsTimeSampling');

theDepthName = pxget(self, 'itsDepthName');

theVariables = pxget(self, 'itsVariables');
len = length(theVariables);
for k = 1:len
	if ischar(theVariables{k})
		theVariables{k} = theData{theVariables{k}};
	end
end

theTransform = theData.transform(:);
isBeam = isequal(lower(theTransform), 'beam');

isVelocity = zeros(1, 4);
for k = 1:len
	isVelocity(k) = any(findstr(name(theVariables{k}), 'vel'));
end

isVelocities = all(isVelocity);

isAllSameKind = 1;
for k = 2:len
	a = name(theVariables{k-1});
	b = name(theVariables{k});
	a(length(a)) = '';
	b(length(b)) = '';
	if ~isequal(a, b), allSameKind = 0; end
end

isEnsembleAveraging = pxget(self, 'itIsEnsembleAveraging');
theEnsembleStart = pxget(self, 'itsEnsembleStart');
theEnsembleCount = pxget(self, 'itsEnsembleCount');
theEnsembleStep = pxget(self, 'itsEnsembleStep');
theEnsembleMax = pxget(self, 'itsEnsembleMax');

theBinStart = pxget(self, 'itsBinStart');
theBinCount = pxget(self, 'itsBinCount');
theBinStep = pxget(self, 'itsBinStep');
theBinMax = pxget(self, 'itsBinMax');

theColor = pxget(self, 'itsColor');
theLineStyle = pxget(self, 'itsLineStyle');
theMarker = pxget(self, 'itsMarker');

theColorBars = lower(pxget(self, 'itsColorBars'));

thePlotStyle = lower(pxget(self, 'itsPlotStyle'));
isImage = isequal(lower(thePlotStyle), 'image');
isContour = isequal(lower(thePlotStyle), 'contour');
isImage = isImage | isContour;
isScatter = isequal(lower(thePlotStyle), 'scatter');
isProgressive = isequal(lower(thePlotStyle), 'progressive');
isWiggle = any(findstr(lower(thePlotStyle), 'wiggle'));

if isScatter & ~isVelocities
	disp(' ## Only velocities can be scatter-plotted.')
	idle
	return
end

if isProgressive & ~isVelocities
	disp(' ## Only velocities can be progressive-vector plotted.')
	idle
	return
end

theRotationAngle = pxget(self, 'itsRotationAngle');   % degrees.
theColorFactor = pxget(self, 'itsColorFactor');

% Adjust scrollbars.

h = findobj(gcf, 'Style', 'slider', 'Tag', 'XScroll');
p = px(h);
p.Value = theEnsembleStart;
p.SliderStep = [0.25 1] * theEnsembleStep*theEnsembleCount/theEnsembleMax;

h = findobj(gcf, 'Style', 'slider', 'Tag', 'YScroll');
p = px(h);
p.Value = theBinStart;
p.SliderStep = [theBinStep theBinStep*theBinCount]/theBinMax;

e1 = theEnsembleStart;
e2 = theEnsembleStep;
e3 = e1 + e2*(theEnsembleCount-1);
e = e1:e2:e3;
if e3 > theEnsembleMax
	e3 = theEnsembleMax;
	e1 = max(theEnsembleMax-e2*(theEnsembleCount-1), 1);
	e = fliplr(e3:-e2:e1);
end

b1 = theBinStart;
b2 = theBinStep;
b3 = b1 + b2*(theBinCount-1);
b = b1:b2:b3;
if b3 > theBinMax
	b3 = theBinMax;
	b1 = max(theBinMax-b2*(theBinCount-1), 1);
	b = fliplr(b3:-b2:b1);
end

nBins = length(b);

hasDepth = 0;

% Accumulate and adjust the data to be plotted.

for k = 1:len
	v = theVariables{k};
	if ischar(v), v = theData{v}; end
	if ~isempty(v)
		x{k} = e;
		s = ncsize(v);
		if length(s) == 1
			z{k} = v(e);
			theFillValue = fillval(v);
			if ~isempty(theFillValue)
				z{k}(z{k} == theFillValue) = NaN;
			end
			if isVelocity(k), z{k} = z{k}/10; end   % cm/s.
		elseif ~isEnsembleAveraging
			y{k} = b; z{k} = v(e, b).';
			if ~isempty(z{k})
				theFillValue = fillval(v);
				if ~isempty(theFillValue)
					z{k}(z{k} == theFillValue) = NaN;
				end
			end
			if isVelocity(k), z{k} = z{k}/10; end   % cm/s.
		else   % Average ensembles.
			y{k} = b;
			indices = min(e):max(e);
			z{k} = v(indices, b);
			if ~isempty(z{k})
				theFillValue = fillval(v);
				if ~isempty(theFillValue)
					z{k}(z{k} == theFillValue) = NaN;
				end
				p = isnan(z{k});
				z{k}(p) = 0;
				z{k} = cumsum(z{k});   % Quick-and-dirty.
				indices = e - e(1) + 1;
				z{k} = z{k}(indices, :);
				p = cumsum(1-p);
				p = diff(p(indices, :));
				p(p == 0) = NaN;
				z{k} = (diff(z{k})./p).';
				n = length(x{k});
				x{k} = 0.5 * (x{k}(1:n-1) + x{k}(2:n));
				if isVelocity(k), z{k} = z{k}/10; end   % cm/s.
			end
		end
	end
end

% Rotate horizontal velocities.
%  A positive angle rotates the x-component
%   of velocity counter-clockwise toward y.

if isVelocities & ~isBeam & any(theRotationAngle)
	theArg = exp(sqrt(-1) * theRotationAngle * pi / 180);
	theRotated = theArg * (z{1} + sqrt(-1) * z{2});
	z{1} = real(theRotated);
	z{2} = imag(theRotated);
end

% If wiggle-plots, scale the data.

if ~isScatter & ~isProgressive
	s = size(theVariables{1});
	if length(s) > 1 & length(b) > 1 & ~isImage
		s = zeros(1, len);
		for k = 1:len
			i = isfinite(z{k});
			if any(i)
				temp = z{k}(i);
				s(k) = std(temp(:));
			end
		end
		if isAllSameKind, s(:) = max(s); end
		for k = 1:len
			if any(s(k)), z{k} = z{k} / s(k); end
		end
	end
end

% Plot the data.

% Scatter or progressive-vector plot.

if (isScatter | isProgressive) & isVelocities
	subplot(1, 1, 1)
	hasDepth = 0;
	x = z{1}.';
	y = z{2}.';
	if isProgressive
		dt = theTimeSampling;
		if ischar(dt), dt = dhms(dt); end
		scale = dt*86400;
		f = find(isnan(x) | isnan(y));
		x(isnan(x)) = 0;
		y(isnan(y)) = 0;
		x = cumsum(x*scale);
		y = cumsum(y*scale);
		x(f) = nan;
		y(f) = nan;
	end
	h = plot(x, y, '-');
	set(h, 'LineStyle', theLineStyle, 'Marker', theMarker)
	set(h, 'Tag', 'StarBeam')
	if isequal(theLineStyle, 'line')
		[m, n] = size(y);
		for j = 1:n
			f = find(isfinite(x(:, j)) & isfinite(y(:, j)));
			if any(f)
				hold on
				i1 = f(1); i2 = f(length(f));
				g = plot(x(i1, j), y(i1, j), 'ro', x(i2, j), y(i2, j), 'r*');
				set(g, 'Color', get(h(j), 'Color'))
				hold off
			end
		end
	end
	axis equal
	u = theVariables{1};
	if ischar(u), u = theData{u}; end
	theUnits = u.units(:);
	if isProgressive
		theUnits = 'cm';
	else
		theUnits = strrep(theUnits, 'mm', 'cm');
	end
	s = name(u);
	if ~isBeam, s = 'East'; end
	if ~isempty(theUnits)
		s = [s ' (' theUnits ')'];
	end
	xlabel(labelsafe(s))
	v = theVariables{2};
	if ischar(v), v = theData{v}; end
	theUnits = v.units(:);
	if isProgressive
		theUnits = 'cm';
	else
		theUnits = strrep(theUnits, 'mm', 'cm');
	end
	s = name(v);
	if ~isBeam, s = 'North'; end
	if ~isempty(theUnits)
		s = [s ' (' theUnits ')'];
	end
	ylabel(labelsafe(s))
	theTitle = name(theData);
	if nBins == 1
		theTitle = [theTitle ' -- Bin ( ' int2str(b) ' )'];
	else
		b1 = min(b);
		b2 = 1;
		if length(b) > 1, b2 = diff(b(1:2)); end
		b3 = max(b);
		theTitle = [theTitle ' -- Bins ( ' ...
				int2str(b1) ' : ' int2str(b2) ' : ' int2str(b3) ' )'];
	end
	title(labelsafe(theTitle))
	theUnits = get(gca, 'Units');
	set(gca, 'Units', 'characters')
	thePosition = get(gca, 'Position');
	thePosition([2 4]) = thePosition([2 4]) + [1 -1];
	set(gca, 'Position', thePosition)
	set(gca, 'Units', theUnits)
	findpt
	zoomsafe on all
	idle
	return
end

% Other plot styles.

for k = 1:len
	h = [];
	subplot(len, 1, k)
	set(gca, 'XGrid', 'off', 'YGrid', 'off')
	v = theVariables{k};
	if ischar(v), v = theData{v}; end
	if ~isempty(v)
		s = ncsize(v);
		if length(s) == 1
			nBins = 0;
			h = plot(x{k}, z{k});
			set(gca, 'XGrid', 'on', 'YGrid', 'on')
		else
			if ~isempty(z{k})
				switch isImage
				case logical(1)   % Images and contours.
					if length(b) > 1
						hasDepth = 1;
						h = imagesc(x{k}, y{k}, z{k});
						if isContour
							hold on
							contour(x{k}, y{k}, z{k}, [0 0], 'k-')
							hold off
						end
					else
						nBins = 1;
						h = plot(x{k}, z{k});
						set(gca, 'XGrid', 'on', 'YGrid', 'on')
					end
				otherwise   % Wiggles.
					if length(b) > 1
						hasDepth = 1;
						if isequal(thePlotStyle, 'plot')
							z{k} = z{k}*theEnsembleStep;
							h = wigglex(x{k}, y{k}, z{k});
						elseif isequal(thePlotStyle, 'wigglesx')
							z{k} = z{k}*theEnsembleStep;
							h = wigglex(x{k}, y{k}, z{k});
						elseif isequal(thePlotStyle, 'wigglesy')
							z{k} = z{k}*theBinStep;
							h = wiggley(x{k}, y{k}, z{k});
						end
						if any(h)
							ee = 0 * get(h(1), 'XData');
							for i = 1:length(h)
								ee(:) = e(i);
								set(h(i), 'ZData', ee)
							end
						end
					else
						nBins = 1;
						h = plot(x{k}, z{k});
					end
				end
			end
		end
	end
	if ~isempty(h)
		s = name(v);
		if ~isequal(get(h(1), 'Type'), 'image')
			theUnits = v.units(:);
			theUnits = strrep(theUnits, 'mm', 'cm');
			if ~isempty(theUnits)
				s = [s ' (' theUnits ')'];
			end
		end
		ylabel(labelsafe(s))
		if k == 1
			theTitle = name(theData);
			if nBins == 1
				theTitle = [theTitle ' -- Bin ' int2str(b)];
			else
				b1 = min(b);
				b2 = 1;
				if length(b) > 1, b2 = diff(b(1:2)); end
				b3 = max(b);
				theTitle = [theTitle ' -- Bins ( ' ...
						int2str(b1) ' : ' int2str(b2) ' : ' int2str(b3) ' )'];
			end
			title(labelsafe(theTitle))
		end
	end
	if ~isempty(h)
		set(h, 'Tag', 'StarBeam')
		if ~isequal(get(h(1), 'Type'), 'image')
			set(h, 'LineStyle', theLineStyle)
			set(h, 'Marker', theMarker)
			set(h, 'Color', theColor)
		end
    end
    %set(gca,'YDir','reverse') %for downlooking
	set(gca, 'YDir', 'normal') %for uplooking 
	if k == len
		if ~isempty(h) & ~isequal(get(h(1), 'Type'), 'image')
			isImage = 0;
		end
	end
end

% Color-limits for velocities.
%  In "beam" coordinates, beams 1-2 are colored
%  independently of beams 3-4.  In "earth"
%  coordinates, the vertical velocity and error
%  are scaled ten-times larger than the actual
%  values.

if isImage
	theCLim = zeros(len, 2);
	for k = 1:len
		subplot(len, 1, k)
		theCLim(k, :) = get(gca, 'CLim');
	end
	theImageDataLimits = theCLim;
	if isVelocities
		if isBeam | ~any(theColorFactor)
			mx = max(max(abs(theCLim(1:2, :))));
			theCLim(1:2, :) = mx * [-1 1; -1 1];
			mx = max(max(abs(theCLim(3:4, :))));
			theCLim(3:4, :) = mx * [-1 1; -1 1];
		else
			mx = max(max(abs(theCLim)));
			f = 1/theColorFactor;
			theCLim = mx * [-1 1; -1 1; -f f; -f f];
		end
		for k = 1:len
			subplot(len, 1, k)
			set(gca, 'CLim', theCLim(k, :))
		end
	end
	theImageColorLimits = theCLim;
end

% Same XLim for all.

theXLim = [e1-e2 e3+e2];
for k = 1:len
	subplot(len, 1, k)
	axis tight
	if ~isImage, set(gca, 'XLim', theXLim), end
end

% Same YLim range.

if isAllSameKind & nBins == 1 & ~isScatter
	for k = 1:len
		subplot(len, 1, k)
		theYLim(k, :) = get(gca, 'YLim');
	end
	if isVelocities   % Center range about mean.
		theMean = 0.5 * theYLim * [1; 1];
		theRange = 0.5 * max(theYLim * [-1; 1]);
		for k = 1:len
			theYLim(k, :) = theMean(k) + [-1 1] * theRange;
		end
	else   % Use extreme limits.
		theYLim(:, 1) = min(min(theYLim));
		theYLim(:, 2) = max(max(theYLim));
	end
	for k = 1:len
		subplot(len, 1, k)
		set(gca, 'YLim', theYLim(k, :));
	end
end

% XTickLabel and YTickLabel adjustment.

timeaxis(self)
if hasDepth, depthaxis(self), end

% Draw colorbars.

if isImage & isequal(theColorBars, 'on')
	len = length(theVariables);
	for k = 1:len
		v = theVariables{k};
		subplot(len, 1, k)
		h = colorbar;
		theUnits = v.units(:);
		if isempty(theUnits), theUnits = 'no units'; end
		if isVelocity(k)
			theUnits = strrep(theUnits, 'mm', 'cm');   % cm/s.
		end
		axes(h)
		ylabel(theUnits)
	end
end

findpt
zoomsafe on all

idle
