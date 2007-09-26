function s = Var2Str(x)

% Var2Str -- String equivalent to a matrix.
%  Var2Str(x) converts variable x to a one-line
%   string which is roughly equivalent
%   to x, for display purposes.  If x is
%   larger than a scalar, then its values are
%   written between square brackets.


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

 
% Copyright (C) 1991 Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1
   help(mfilename)
   x = [1 2 3; pi inf nan];
   disp(' The matrix:'), disp(' ')
   disp(x), disp(' becomes the string:'), disp(' ')
   disp([' ' var2str(x)])
   return
end

if isempty(x)
   if isstr(x)
      s = '''''';
     else
      s = '[]';
   end
   return
end

quote = '''';

[m, n] = size(x);

s = '';
bracket = isstr(x) & m > 1 | ~isstr(x) & length(x) > 1;
if bracket, s = ['[']; end

for i = 1:m
   if isstr(x)
      t = [quote x(i, :) quote];
      s = [s t];
     else
      for j = 1:n
         z = x(i, j);
         if isnan(z)
            t = 'nan';
           elseif z == inf
            t = 'inf';
           elseif z == -inf
            t = '-inf';
           elseif z == fix(z)
            t = int2str(z);
           else
            t = num2str(z);
         end
         s = [s t];
         if j < n, s = [s ' ']; end
      end
   end
   if i < m, s = [s '; ']; end
end

if bracket, s = [s ']']; end
