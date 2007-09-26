function h = PXMkMenu(theHandle, xa, xb, xc, xd, xe, xf, ...
                xg, xh, xi, xj, xk, xl, xm, xn, xo, xp, ...
                xq, xr, xs, xt, xu, xv, xw, xx, xy, xz)

% PXMkMenu -- No help available.
% PXMkMenu -- Add new menus to the menubar.
%  PXMkMenu(theHandle, xa, xb, ...) appends the given menu
%   labels to theHandle (a figure or menu).  The menu level
%   is specified by one or more '>' symbols prepended to the
%   label.  To invoke a separator, use '-' symbols instead.
%   The top-level menu has no prepended symbols.  The menu
%   handles are returned, arranged from earliest to latest.
%   Compound labels are allowed, either as a string matrix
%   of labels, or as a string with '|' separators between
%   labels.
%  PXMkMenu (no argument) demonstrates itself.


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

  
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1, help(mfilename), return, end

% Find the parent figure.

theFigure = theHandle;
theLevel = 1;
theParents(theLevel) = theFigure;
while ~strcmp(get(theFigure, 'Type'), 'figure')
   theFigure = get(theFigure, 'Parent');
   theLevel = theLevel + 1;
   theParents(theLevel) = theFigure;
end
theParents = theParents(length(theParents):-1:1);

figure(theFigure)

% Delete existing menu children.

if theFigure == theHandle
   theMenuName = xa;
   f = findobj(theFigure, 'Type', 'uimenu', ...
                          'Label', theMenuName, ...
                          'Parent', theFigure);
   if any(f), delete(f), end
end

k = 0;
for j = 1:nargin-1
   theLabel = eval(['x' setstr(abs('a')-1+j)]);
   while theLabel(1) == '|', theLabel(1) = []; end
   while theLabel(length(theLabel)) == '|'
      theLabel(length(theLabel)) = [];
   end
   f = find(theLabel == '|');
   if any(f)
      g = find(theLabel ~= ' ' & theLabel ~= 0);
      if any(g), theLabel = theLabel(g(1):g(length(g))); end
      g = 0;
      if(theLabel(1) == '|'), g = 1; end
      f = find(theLabel == '|');
      if theLabel(length(theLabel)) ~= '|'
         f = [f(:); length(theLabel)+1];
      end
      temp = '';
      for i = 1:length(f)
         s = theLabel(g+1:f(i)-1);
         temp(i, 1:length(s)) = s;
         g = f(i);
      end
      theLabel = temp;
   end
   [m, n] = size(theLabel);
   for i = 1:m
      theSeparator = 'off';
      theLab = theLabel(i, :);
      f = find(theLab ~= ' ' & theLab ~= 0);
      if any(f), theLab = theLab(f(1):f(length(f))); end
      if theLab(1) == '-', theSeparator = 'on'; end
      f = find(theLab ~= '>' & theLab ~= '-');
      if any(f), theLab = theLab(f(1):length(theLab)); end
      theLevel = 1;
      if any(f), theLevel = f(1); end
      theParent = theParents(theLevel);
      if ~strcmp(get(theParent, 'Type'), 'figure')
         set(theParent, 'Callback', '')
      end
      theAction = theLab(theLab ~= ' ' & ...
                         theLab ~= '.' & ...
                         theLab ~= '-');
      theHandle = uimenu('Parent', theParent, ...
                         'Label', theLab, ...
                         'Separator', theSeparator);
      pxenable(theHandle, theAction)
      theParents(theLevel+1) = theHandle;
      k = k + 1;
      hh(k) = theHandle;
   end
end

if nargout > 0, h = hh(:); end
