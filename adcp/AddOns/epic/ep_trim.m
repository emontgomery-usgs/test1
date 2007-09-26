function theResult = EP_Trim(theSource, theDestination, theIndices)

% EP_Trim -- Trim an EPIC file.
%  EP_Trim('theSource', 'theDestination', theIndices) writes
%   the time-records associated with theIndices (base-1) in
%   'theSource' to 'theDestination'.  Other entities are
%   written without change.


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
 
% Version of 13-May-1997 15:06:13.

result = -1;
if nargout > 0, theResult = result; end

if nargin < 2, help(mfilename), return, end

fcopy(theSource, theDestination)

dst = epic(theDestination, 'write');
if isempty(dst), return, end

if nargin < 3, theIndices = 1:size(dst('time')); end

vartrim(dst, theIndices)

dst = close(dst);

if isempty(dst) & nargout > 0, theResult = []; end
