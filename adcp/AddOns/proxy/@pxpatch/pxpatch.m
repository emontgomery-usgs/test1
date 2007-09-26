function theResult = PXPatch(varargin)

% PXPatch -- Constructor for interactive patch.
%  PXPatch(...) creates interactive patches,
%   using the syntax of the Matlab "patch" function.
%   A cell-array of "pxpatch" objects is returned.
%   Use "pxcallback('theCallback')" to set the name
%   of the callback that will be invoked after a
%   mouse-selection has occurred on the line, as
%   feval('theCallback', {thePXPatch}) -- note that
%   the "pxpatch" object is delivered inside a cell,
%   since the callback is not a method of the "pxpatch"
%   class.  Use "pxvalue(thePXPatch)" to get a 1 if
%   the patch is selected; otherwise, 0.
%  PXPatch(nPatches) demonstrates itself.


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

if strcmp(varargin{1}, 'demo'), varargin{1} = 3; end

if length(varargin) == 1 & length(varargin{1}) == 1
   nPatches = varargin{1};
%  theFSW = pxfsw('PXPatch Demo');
   delete(get(gcf, 'Children'))
   x = rand(3, nPatches); y = rand(3, nPatches); z = rand(3, nPatches);
   thePXPatches = cell(1, nPatches);
   for j = 1:nPatches
      p = pxpatch(x(:, j), y(:, j), z(:, j), 'FaceColor', 'flat');
      thePXPatches{j} = p;
   end
   title('PXPatches')
   xlabel('x'), ylabel('y'), zlabel('z')
   figure(gcf)
   if nargout > 0, theResult = thePXPatches; end
   return
end

varargout{1} = [];
v = vargstr('patch', length(varargin), 1);
eval(v);
theData = varargout{1};

for i = 1:length(theData)
   x = get(theData(i), 'XData');
   z = get(theData(i), 'ZData');
   if isempty(z)
      z = zeros(size(x));
      set(theData(i), 'ZData', z);
   end
end

self = cell(size(theData));
for i = 1:length(theData)
   theStruct.itSelf = [];
   self{i} = class(theStruct, 'pxpatch', px(theData(i)));
   self{i}.itSelf = px(self{i});
   pxset(self{i}, 'itsObject', self{i})
   p = px(self{i});
   pxenable(p, p);
   pxenable(p)
   pxset(self{i}, 'itsCallback', '')
   pxset(self{i}, 'itsValue', [])
end

if nargout > 0, theResult = self; end
