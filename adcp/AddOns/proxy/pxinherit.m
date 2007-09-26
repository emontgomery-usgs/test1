function theResult = PXInherit(theObject, theMethod, varargin)

% Inherit -- Inheritance of "px" superclass method.
%  Inherit(theObject, 'theMethod', varargin) calls 'theMethod'
%   of the first-most "px" superclass of theObject, scanning
%   from the top of the struct(theObject).


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
 
% Version of 05-Apr-1997 10:41:00.

if nargin < 3, help(mfilename), return, end

result = [];

theFields = fields(theObject);

for i = 1:length(theFields)
   s = ['theObject.' char(theFields(i))];
   f = eval(s);
   if isa('px')
      t = '';
      if nargout > 0, t = ['result=' t]; end
      t = [t char(theMethod) '(f'];
      for j = 1:length(varargin)
         t = [t ','];
         t = [t 'varargin(' int2str(j) ')'];
      end
      t = [t ');'];
      eval(t);
      s = [s ' = result;'];
      eval(s)
      break
   end
end

if nargout > 0, theResult = result; end
