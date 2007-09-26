function theSuperObject = super(theObject)

% super -- Super-object of an object.
%  super(theObject) returns the super-object
%   of theObject, or [] if none exists.  The
%   super-object is the bottom-most object
%   in the struct of theObject, if any.


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
 
% Version of 04-Apr-1997 16:51:36.
% Revised    02-Nov-1998 08:26:00.

if nargin < 1, help super, return, end

if isobject(theObject)
   theStruct = struct(theObject);
  else
   theStruct = theObject;
end

s = [];

f = fieldnames(theStruct);
if ~isempty(f)
   s = getfield(theStruct, f{length(f)});
   if ~isobject(s), s = []; end
end

if nargout > 0
   theSuperObject = s;
  else
   disp(s)
end
