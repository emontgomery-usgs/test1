function theResult = Browse(varargin)

% Browse -- Browse line-data.
%  Browse(...) uses the syntax of "pxline" to create
%   an interactive line in a scrolling window named
%   "Browse".  The returned "pxline" object permits
%   conventionally-indexed references and assignments
%   to the pseudo-fields "x", "y", "z", and "s" (selected),
%   as in "x = theObject.x" and "theObject.x = x".


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
 
% Version of 19-Jun-1997 14:48:18.

if nargin < 1, help(mfilename), varargin{1} = 'demo'; end

switch class(varargin{1})
case 'line'
   h = varargin{1};
   x = get(h, 'XData');
   y = get(h, 'YData');
   z = get(h, 'ZData');
   c = get(h, 'Color');
   switch isempty(z)
   case 0
      result = browse(x, y, 'Color', c);
   otherwise
      result = browse(x, y, z, 'Color', c);
   end
   if nargout > 0, theResult = result; end
   return
otherwise
end

if strcmp(varargin{1}, 'demo')
   x = cumsum(rand(100, 1) - 0.75);
   y = cumsum(rand(100, 1) - 0.6);
   theDemoLine = browse(x, y);
   if nargout > 1
      theResult = theDemoLine;
     else
      assignin('base', 'ans', theDemoLine)
   end
   return
end

f = findobj('Type', 'figure', 'Name', 'Browse');
if ~any(f), f = pxfsw('Browse'); end
f = findobj('Type', 'figure', 'Name', 'Browse');
figure(f(1))

varargout = cell(1, 1);

v = vargstr('pxline', length(varargin), 1);
eval(v)

theObject = varargout{1};

zoomsafe

if nargout > 0
   theResult = theObject;
  else
   assignin('base', 'ans', theObject)
end
