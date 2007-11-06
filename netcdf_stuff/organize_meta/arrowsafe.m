function [x, y] = arrowsafe(x0, y0, theLength, theAngle, theHeadSize)

% arrowsafe -- Intelligent, oriented arrows.
%  arrowsafe('demo') demonstrates itself with arrows centered
%   on the origin, each one-unit long.
%  arrowsafe(N) demonstrates itself with N arrows.
%  arrowsafe(x0, y0, theLength, theAngle, theHeadSize) draws
%   arrows that start at (x0, y0), with theLength (in y-axis units),
%   theAngle (degrees, counter-clockwise from +x), and theHeadSize
%   (in y-axis units).  The variables should be the same size, but
%   any can be a scalar, just so long as the x0 and/or y0 array is
%   the full size.  The "ResizeFcn" of the figure is set to update
%   the arrows automatically.  The "Tag" is the mfilename.
%  h = arrowsafe(...) draws the arrows and returns the handle.
%  [x, y] = arrowsafe(...) returns the (x, y) data for the
%   arrows, one column per arrow, but does not draw them.
%  arrowsafe (no argument) redraws existing arrows. This is
%   useful whenever the window is resized or the x or y limits
%   change.  (Recall that printing causes the "ResizeFcn" to
%   be called twice.)
%
% Note: this routine leaves the axes in "manual" mode.  Use
%  "axis auto" to revert to automatic axis limits.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jan-2000 14:22:59.
% Updated    20-Feb-2002 16:22:49.

RCF = 180 / pi;

% Resize.

if nargin < 1
	oldGCA = gca;
	h = findobj(gcf, 'Type', 'line', 'Tag', mfilename);
	for i = 1:length(h)
		p = get(h(i), 'Parent');
		axes(p)
		u = get(h(i), 'UserData');
		[xx, yy] = feval(mfilename, u(:, 1), u(:, 2), ...
							u(:, 3), u(:, 4), u(:, 5));
		set(h(i), 'XData', xx(:), 'YData', yy(:));
	end
	axes(oldGCA)
	return
end

% Demonstration.

if nargin == 1
	if isequal(x0, 'demo')
		help(mfilename)
		x0 = 16;
	elseif ischar(x0)
		x0 = eval(x0);
	end
	theName = [mfilename ' demo'];
	f = findobj('Type', 'figure', 'Name', theName);
	if ~any(f)
		f = figure('Name', theName);
	end
	figure(max(f))
	delete(get(f, 'Children'))
	n = max(1, round(x0));
	offset = 0;
	x0 = zeros(1, n) + offset;
	ang = linspace(0, 360, length(x0)+1);
	ang(end) = [];
	h = feval(mfilename, x0, 0, 1, ang);
	set(gca, 'Xlim', [-n n], 'YLim', [-2 2])
	feval(mfilename)
	set(gcf, 'WindowButtonDownFcn', ...
			['if zoomsafe(''down''), ' mfilename ', end'])
	if nargout > 0, x = h; end
	return
end

% Initialize.

if nargin > 1
	if nargout == 2, x = []; y = []; end
	if length(x0) == 1
		x0 = x0 * ones(size(y0));
	elseif length(y0) == 1
		y0 = y0 * ones(size(x0));
	end
	x0 = reshape(x0, [1 prod(size(x0))]);
	y0 = reshape(y0, size(x0));
	if nargin < 3, theLength = 1; end
	if nargin < 4, theAngle = 0; end
	if nargin < 5, theHeadSize = 0.1 .* theLength; end
	if length(theLength) == 1
		theLength = theLength * ones(size(x0));
	end
	if length(theAngle) == 1
		theAngle = theAngle * ones(size(x0));
	end
	if length(theHeadSize) == 1
		theHeadSize = theHeadSize * ones(size(x0));
	end

	theLength = reshape(theLength, size(x0));
	theAngle = reshape(theAngle, size(x0));
	theHeadSize = reshape(theHeadSize, size(x0));

	axes(gca)
	oldUnits = get(gca, 'Units');
	set(gca, 'Units', 'pixels')
	thePosition = get(gca, 'Position');
	set(gca, 'Units', oldUnits)
	theWidth = thePosition(3);   % pixels.
	theHeight = thePosition(4);   % pixels.
	
	axis('manual')
	dx = diff(get(gca, 'XLim'));
	dy = diff(get(gca, 'YLim'));
	dydx = dy / dx;   % Not used.
	dxdp = dx / theWidth;   % sci/pixel.
	dydp = dy / theHeight;   % sci/pixel.
	scale = dxdp / dydp;   %% <== Scale-factor.

	xa = [-10; -20; 0; -20; -10]/20;   % Arrowhead.
	ya = [0; 10; 0; -10; 0]/20;
	
	m = length(xa);
	n = prod(size(x0));
	repeats = [m 1];
	
	ang = repmat(theAngle, repeats);
	len = repmat(theLength, repeats);
	head = repmat(theHeadSize, repeats);
	
	xa = repmat(xa, [1 n]);
	ya = repmat(ya, [1 n]);
	
	xa = xa .* head;
	ya = ya .* head;
	
	xa = xa + len;
	
	za = xa + sqrt(-1) * ya;
	
	za = [zeros(1, n); za];
	
	ang = repmat(theAngle, [size(za, 1) 1]);
	len = repmat(theLength, [size(za, 1) 1]);
	head = repmat(theHeadSize, [size(za, 1) 1]);
	xx0 = repmat(x0, [size(za, 1) 1]);
	yy0 = repmat(y0, [size(za, 1) 1]);
	
	za = exp(sqrt(-1) * ang / RCF) .* za;
	xx = real(za);
	yy = imag(za);
	
	nans = zeros(1, n) + NaN;
	
	xx = [xx; nans];
	yy = [yy; nans];

	zz = xx + sqrt(-1) .* yy;

	xx0 = repmat(x0, [size(zz, 1) 1]);
	yy0 = repmat(y0, [size(zz, 1) 1]);

	xx = xx0 + real(zz) * scale;   % <== Scaling.
	yy = yy0 + imag(zz);
	
	parameters = [x0(:) y0(:) theLength(:) theAngle(:) theHeadSize(:)];
	
	if nargout < 2
		h = line(xx(:), yy(:), ...
			'Tag', mfilename, ...
			'UserData', parameters);
		if nargout > 1, x = h; end
	elseif nargout == 2
		x = xx;
		y = yy;
	end
	set(gcf, 'ResizeFcn', mfilename)
	
	if nargout == 1, x = h; end
end
