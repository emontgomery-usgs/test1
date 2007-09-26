function theResult = PXSurface(varargin)

% PXSurface -- Constructor for interactive surfaces.
%  PXSurface(...) creates an interactive surface,
%   using the syntax of the Matlab "surface" function.
%   A  "pxsurface" object is returned or assigned
%   to "ans".
%   Use "pxcallback('theCallback')" to set the name
%   of the callback that will be invoked after a
%   mouse-selection has occurred on the line, as
%   feval('theCallback', {thePXSurface}) -- note that
%   the "pxsurface" object is delivered inside a cell,
%   since the callback is not a method of the "pxsurface"
%   class.  Use "pxvalue(thePXSurface) to get the indices
%   of selected points in thePXSurface.
%  PXSurface(nSurfaces) demonstrates itself with nSurfaces,
%   whose "pxsurface" objects are returned in a cell-array.


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
 
% Version of 23-Apr-1997 08:16:09.

if nargin < 1, help(mfilename), varargin{1} = 'demo'; end

if nargin > 0 & isstr(varargin{1})
   varargin{1} = eval(varargin{1});
end

if strcmp(varargin{1}, 'demo'), varargin{1} = 2; end

if length(varargin) == 1
   if length(varargin{1}) == 1
      nSurfaces = varargin{1};
      theSize = [10 15];
   elseif length(varargin{1}) == 2
      nSurfaces = 1;
      theSize = varargin{1};
   end
   [x, y] = meshgrid(0:theSize(2), 0:theSize(1));
   z = rand([size(x) nSurfaces]);
   z = z .^ 4;   % Mostly small values.
   z = fix(10 .* z);
   for k = 1:nSurfaces, z(:, :, k) = z(:, :, k) + k; end
   theFSWName = 'PXSurface Demo';
   theFSW = findobj('Type', 'figure', 'Name', theFSWName);
   if ~any(theFSW)
      theFSW = pxfsw(theFSWName, 4);
   end
   c = zeros(10, 3);
   c(:, 1) = ((19:-2:1)./20).';
   c(:, 2) = c(:, 1);
   c(:, 3) = 1;   % Mostly blue.
   c = [[1 1 1]; c; [1 0 0]];
   colormap(c)
   thePXSurfaces = cell(1, nSurfaces);
   delete(findobj(gcf, 'Type', 'axes'))
   subplot
   for k = 1:nSurfaces
      subplot(1, nSurfaces, k)
      thePXSurfaces{k} = pxsurface(x, y, z(:, :, k));
      title(['PXSurface #' int2str(k)])
      xlabel('x'), ylabel('y'), zlabel('z')
      set(gca, 'YDir', 'reverse')
      axis tight
   end
   if nargout > 0
      theResult = thePXSurfaces;
   else
      assignin('base', 'ans', thePXSurfaces)
   end
   return
end

varargout{1} = [];
v = vargstr('surface', length(varargin), 1);
eval(v);
theData = varargout{1};
set(theData, 'Tag', 'pxsurface')
x = get(theData, 'XData');
y = get(theData, 'YData');
z = get(theData, 'ZData');
c = get(theData, 'CData');
if isempty(z)
   z = zeros(size(x));
   set(theData, 'ZData', z);
end
             
% Draw the mask above the data.

xx = bilinterp(x);
yy = bilinterp(y);
zz = bilinterp(z) + 1;
[m, n] = size(zz);
zz(2:2:m, 2:2:n) = NaN;
cc = bilinterp(c);
[m, n] = size(cc);
i = 1:2:m-1; j = 1:2:n-1;
ctemp = cc(i, j);
cc(i+1, j) = ctemp;
cc(i, j+1) = ctemp;
cc(i+1, j+1) = ctemp;

hold on
theMask = surface('XData', xx, ...
                  'YData', yy, ...
                  'ZData', zz, ...
                  'CData', cc, ...
                  'LineWidth', 3.5, ...
                  'UserData', theData, ...
                  'Tag', 'pxsurface_mask');
set(theMask, 'ButtonDownFcn', 'pxevent(get(gcbo, ''UserData''), ''ButtonDownFcn'')')
hold off

theStruct.itSelf = [];
self = class(theStruct, 'pxsurface', px(theData));
self.itSelf = px(self);
pxset(self, 'itsObject', self)
p = px(self);
pxenable(p, p);
pxenable(p)
pxset(self, 'itsCompanion', theMask)
pxset(self, 'itsCallback', '')
pxset(self, 'itsValue', [])
pxset(self, 'itsHandles', theMask)

if nargout > 0
   theResult = self;
  else
   assignin('base', 'ans', self)
end
