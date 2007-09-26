function [x, y] = arrowsafe(x0, y0, theLength, theAngle, theHeadSize)

% arrowsafe -- Intelligent arrows.
%  arrowsafe('demo') demonstrates itself with arrows centered
%   on the origin, each one-unit long.
%  arrowsafe(N) demonstrates itself with N arrows.
%  arrowsafe(x0, y0, theLength, theAngle, theHeadSize) draws arrows
%   that start at (x0, y0), with theLength (y-axis units), theAngle
%   (degrees, counter-clockwise from +x), and theHeadSize (y-axis
%   units).  The variables should be the same size, but any can be
%   a scalar, just so long as the x0 or y0 array is the full size.
%   The "ResizeFcn" of the figure is set to update the arrows
%   automatically.  The "Tag" of each arrow is the mfilename.
%   Properties of the arrows, such as "color", can be adjusted
%   at any time.
%  h = arrowsafe(...) draws the arrows and returns their handle(s).
%  [x, y] = arrowsafe(...) returns the (x, y) data for such
%   an arrow, but does not draw it.
%  arrowsafe (no argument) redraws existing arrows. This is
%   useful whenever the window is resized or the x or y limits
%   change.  (Recall that printing causes the "ResizeFcn" to
%   be called twice.)
%
% Note: this routine leaves the "XLimMode" and "YLimMode" of
%  the participating axes set to 'manual'.


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

  
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jan-2000 14:22:59.
% Updated    13-Jan-2000 09:08:15.

% This code can be modified to set the size
%  of the arrow-head in terms of pixels or
%  some other units, such as the font-size,
%  or the size of markers used in lines.

RCF = 180 / pi;

if nargin < 1
	h = findobj(gcf, 'Type', 'line', 'Tag', mfilename);
	if any(h)
		for i = 1:length(h)
			p = get(h(i), 'Parent');
			axes(p)
			u = get(h(i), 'UserData');
			[xx, yy] = feval(mfilename, u(1), u(2), u(3), u(4), u(5));
			set(h(i), 'XData', xx, 'YData', yy);
		end
	end
	return
end

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
	n = round(x0);
	x0 = zeros(1, n);
	ang = linspace(0, 360, length(x0)+1);
	ang(end) = [];
	feval(mfilename, x0, 0, 1, ang, 0.1)
	set(gca, 'Xlim', [-n n], 'YLim', [-2 2])
	feval(mfilename)
	return
end

if nargin > 1
	if length(x0) == 1
		x0 = x0 * ones(size(y0));
	elseif length(y0) == 1
		y0 = y0 * ones(size(x0));
	end
	if nargin < 3, theLength = 1; end
	if nargin < 4, theAngle = 0; end
	if nargin < 5, theHeadSize = 1/10; end
	if length(theLength) == 1
		theLength = theLength * ones(size(x0));
	end
	if length(theAngle) == 1
		theAngle = theAngle * ones(size(x0));
	end
	if length(theHeadSize) == 1
		theHeadSize = theHeadSize * ones(size(x0));
	end
	h = zeros(size(x0));
	axes(gca)
	oldUnits = get(gca, 'Units');
	set(gca, 'Units', 'pixels')
	thePosition = get(gca, 'Position');
	set(gca, 'Units', oldUnits)
	theWidth = thePosition(3);   % pixels.
	theHeight = thePosition(4);   % pixels.
	oldXLimMode = get(gca, 'XLimMode');
	oldYLimMode = get(gca, 'YLimMode');
	set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual')
	dx = diff(get(gca, 'XLim'));
	dy = diff(get(gca, 'YLim'));
	dydx = dy / dx;   % Not used.
	dxdp = dx / theWidth;   % sci/pixel.
	dydp = dy / theHeight;   % sci/pixel.
	
	scale = dxdp / dydp;  % We are missing something here.
	
	rot = exp(sqrt(-1) .* theAngle ./ RCF);
	
% Much of the following can be vectorized by
%  turning the data into column vectors.

	for i = 1:prod(size(x0))
		xx = [-10 -20 0 -20 -10]/20;
		yy = [0 10 0 -10 0]/20;
		zz = xx + yy*sqrt(-1);
		zz = zz * rot(i) * theHeadSize(i);
		len = theLength(i) * rot(i);
		ylen = imag(len);
		xx = (real(len) + real(zz)) * scale;
		yy = imag(len) + imag(zz);
		xx = [0 xx] + x0(i);
		yy = [0 yy] + y0(i);
		if nargout == 2
			x = xx;
			y = yy;
		else
			h(i) = line(xx, yy, ...
					'Tag', mfilename, ...
					'UserData', ...
						[x0(i) y0(i) theLength(i) ...
							theAngle(i) theHeadSize(i)]);
		end
	end
%	set(gca, 'XLimMode', oldXLimMode, 'YLimMode', oldYLimMode)
	set(gcf, 'ResizeFcn', mfilename)
	if nargout == 1, x = h; end
end
