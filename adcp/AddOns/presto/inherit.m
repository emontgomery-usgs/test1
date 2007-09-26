function [varargout] = inherit(theMethod, self, varargin)

% inherit -- Inherit a superclass method.
%  [varargout] = inherit('theMethod', self, varargin) calls
%   the superclass 'method' of self, an object, with the
%   given input and output arguments.  The routine
%   climbs the inheritance tree if needed.  (Multiple
%   inheritance is not supported here.)


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

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Dec-1999 22:50:19.
% Updated    08-Dec-1999 11:31:36.

if nargin < 2, help(mfilename), return, end

if ~isobject(self), return, end

% Clean up the name of the method.

f = find(theMethod =='/');
if any(f), theMethod(1:f(end)) = ''; end

theSuperObject = super(self);
varargout = cell(1, nargout);
varargin = [{theMethod}; varargin(:)];

while isobject(theSuperObject)
	varargin{1} = theSuperObject;
	try
		if nargout > 0
			[varargout{:}] = feval(theMethod, varargin{:});
		else
			feval(theMethod, varargin{:})
		end
	catch
	end
   theSuperObject = super(theSuperObject);
end
