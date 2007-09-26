function itSelf = new(self, varargin)

% new -- No help available.
% new -- Initializer for the "px" class.
%  new(self, ...) initializes self, a px object,
%   and returns a "reference" to self.  The expected
%   usage is "aPXReference = new(px, ...)".  The
%   additional arguments are expected to be cells
%   that contain lists of field/value pairs, with
%   arbitrary nesting.


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
 
% Version of 04-Apr-1997 13:04:03.

if nargin < 1, help(mfilename), end

% Do initialization here.

v = unnest(varargin);
for i = 2:2:length(v)
   theField = v(i-1);
   theValue = v(i);
   pxset(self, theField, theValue);
end

% End of initialization.

if nargout > 0, itSelf = px(self); end
