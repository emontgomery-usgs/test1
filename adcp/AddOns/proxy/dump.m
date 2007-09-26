function dump(varargin)

% Dump -- Dump a matrix into a text file.
%  Dump(...) shows each of the numerical matrices
%   into an edit window, with row and column numbers
%   pre-pended.  After loading the matrix back into
%   Matlab, be sure to strip off the row and column
%   numbers.


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
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
 
% Version of 23-Apr-1997 16:40:45.

if nargin < 1, help(mfilename), return, end

NL = sprintf('\n');

for k = length(varargin):-1:1
   theMatrix = varargin{k};
   if isstr(theMatrix), theMatrix = abs(theMatrix); end
   [m, n] = size(theMatrix);
   max_row = length(int2str(m));
   theMatrix = [(1:m).' theMatrix];
   theMatrix = [0:n; theMatrix];
   s = mat2str(theMatrix(:), 4);
   s(1) = ' '; s(length(s)) = ';';
   f = find(s == ';'); f = [0 f];
   max_len = max(diff(f)) - 1;
   [m, n] = size(theMatrix);
   s = '';
   for i = 1:m
      for j = 1:n
         t = num2str(theMatrix(i, j), 4);
         if j == 1
            while length(t) < max_row,  t = [' ' t]; end
           else
            while length(t) < max_len,  t = [' ' t]; end
         end
         s = [s t];
      end
      s = [s NL];
   end
   theMatrixName = inputname(k);
   if isempty(theMatrixName)
      theMatrixName = ['matrix_' int2str(k)];
   end
   theOutputName = [theMatrixName '.dump'];
   fp = fopen(theOutputName, 'w');
   if fp >= 0
      fprintf(fp, s);
      fclose(fp);
      edit(theOutputName)
     else
      disp([' ## Unable to write ' theMatrixName ' to ' theOutputName ','])
      disp([' ##    because the file may already be open.'])
   end
end
