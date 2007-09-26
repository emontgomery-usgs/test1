function theEvalString = VargStr(fcn, nvarargin, nvarargout)

% VargStr -- Eval-string for varargin and varargout.
%  VargStr('fcn', nvarargin, nvarargout) returns a string
%   that calls the 'fcn' function when eval-ed.  The input
%   arguments are expressed as vargargin{...} and varargout{...},
%   respectively.  If nvarargin or nvarargout is a cell-object,
%   its length is used.  The argument-counts default to zero.


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
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

if nargin < 2, nvarargin = 0; end
if nargin < 3, nvarargout = 0; end

if isa(nvarargin, 'cell')
   nvarargin = length(nvarargin);
end

if isa(nvarargout, 'cell')
   nvarargout = length(nvarargout);
end

s = '';

if nvarargout > 0
   s = [s '['];
   for i = 1:nvarargout
      if i > 1, s = [s ',']; end
      s = [s 'varargout{' int2str(i) '}'];
   end
   s = [s ']'];
end

if ~isempty(fcn)
   if nvarargout > 0, s = [s '=']; end
   s = [s fcn];
end

if nvarargin > 0
   s = [s '('];
   for i = 1:nvarargin
      if i > 1, s = [s ',']; end
      s = [s 'varargin{' int2str(i) '}'];
   end
   s = [s ')'];
end

if ~isempty(fcn), s = [s ';']; end

if nargout > 0
   theEvalString = s;
  else
   disp(s)
end
