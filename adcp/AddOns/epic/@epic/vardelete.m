function theResult = vardelete(self, theVariables)

% epic/vardelete -- Delete EPIC variables.
%  vardelete(self, {theVariables}) deletes the given
%   variables (names) from self, an "epic" object.


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
 
% Version of 12-Aug-1997 11:23:38.

result = self;
if nargout > 0, theResult = result; end

if nargin < 1, help(mfilename), return, end
if nargin < 2, return, end

theClipboard = 'ep_clipboard.nc';
cb = epic(theClipboard, 'clobber');
if isempty(cb), return, end

% Cull the list of variables.

u = var(self);
v = u;
for k = length(u):-1:1
   for i = 1:length(theVariables)
      if strcmp(name(u{k}), theVariables{i})
         v(k) = [];
      end
   end
end

% Copy NetCDF entities.

cb < att(self);        % All global attributes.
cb < dim(self);        % All dimensions.

for i = 1:length(v)
   copy(v{i}, cb, 0, 1)   % Variable definitions and attributes.
end

for i = 1:length(v)
   copy(v{i}, cb, 1, 0)   % Variable data.
end

% Close.

theClipboard = name(cb);
theDestination = name(self);
thePermission = permission(self);
close(cb)
close(self)

% Copy file.

fcopy(theClipboard, theDestination)   % Rename.
delete(theClipboard)

% Reopen.

self = epic(theDestination, thePermission);

if nargout > 0
   theResult = self;
else
   ncans(self)
end
