function theResult = vartrim(self, theIndices)

% epic/vartrim -- Trim EPIC variables along the "time" dimension.
%  vartrim(self, theIndices) trims the time-variables of self,
%   an "epic" object", to theIndices (base-1).


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
 
% Version of 13-May-1997 11:30:01.

if nargin < 1, help(mfilename), return, end

result = [];
if nargout > 0, theResult = result; end

theClipboard = netcdf('ep_clipboard.nc', 'clobber');
if isempty(theClipboard), return, end

if nargin < 2, theIndices = 1:prod(size(self('time'))); end

% Copy the global attributes.

VERBOSE = 0;
VERBOSE = 1;

if (VERBOSE), disp(' ## Copying global attributes...'), end

a = att(self);
for k = 1:length(a), theClipboard < a{k}; end

% Copy the dimensions.

if (VERBOSE), disp(' ## Copying dimensions...'), end

d = dim(self);
for k = 1:length(d)
   theDimname = name(d{k})
   switch theDimname
   case 'time'
      theClipboard(theDimname) = length(theIndices);
   otherwise
      theClipboard < d{k};
   end
end

if (0), ncclose, return   % Debug.

% Define the variables.

if (VERBOSE), disp(' ## Defining variables...'), end

v = var(self);
for k = 1:length(v)
   src = v{k}
   copy(v{k}, theClipboard, 0, 1)
end

% Copy the variable data.

if (VERBOSE), disp(' ## Copying variable data...'), end

COPY_DATA = 0;
COPY_DATA = 1;

if (COPY_DATA)
for k = 1:length(v)
   src = v{k}
   theVarname = name(src)
   dst = theClipboard{theVarname};
   d = dim(src)
   if ~isempty(d)
      theDimname = name(d{1})
      switch theDimname
      case 'time'
         x = src(theIndices, :);
         dst(1:length(theIndices), :) = x;
      otherwise
         theSize = size(src);
         if isempty(theSize), theSize = 1; end
         for i = 1:theSize(1)
            theData = src(i, :);
            dst(i, :) = theData;
         end
      end
   end
end
end

s = name(self);
c = name(theClipboard);

theStatus = close(theClipboard);
if ~isempty(theStatus), return, end
theStatus = close(self);
if ~isempty(theStatus), return, end

fcopy(c, s);

delete(c)

self = netcdf(s, 'write');

if nargout > 0, theResult = self; end
