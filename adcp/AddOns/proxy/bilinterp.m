function theResult = bilinterp(x)

% bilinterp -- Bilinear interpolation.
%  bilinterp(x) bilinearly interpolates matrix x;
%   that is, it inserts the mean value of the pair
%   between every pair of points.


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
 
% Version of 11-Jun-1997 14:03:02.

if nargin < 1, help(mfilename), return, end

[m, n] = size(x);
y = zeros(2*m-1, n);
[mm, nn] = size(y);

y(1:2:mm, :) = x;
a = (x(1:m-1, :) + x(2:m, :)) / 2;
y(2:2:mm, :) = a;

[m, n] = size(y);
z = zeros(m, 2*n-1);
[mm, nn] = size(z);
z(:, 1:2:nn) = y;
a = (y(:, 1:n-1) + y(:, 2:n)) / 2;
z(:, 2:2:nn) = a;

if nargout > 0
   theResult = z;
  else
   disp(z)
end
