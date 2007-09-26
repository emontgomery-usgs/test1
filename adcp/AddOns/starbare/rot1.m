function [rx, ry] = rot1(x, y, deg)

% ROT1 Planar rotation by an angle in degrees.
%  [RX,RY]=ROT1(X,Y,DEG) rotates point X toward
%   Y by angle DEG (in degrees).
%  ROT1 (no arguments) demonstrates itself.


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

 
% Uses: BOX.
 
% Copyright (C) 1992 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

% Version of 6-Jul-92 at 22:12:09.633.

if nargin < 1
   [x, y, z] = box(1, 2, 3);
   [x, y] = rot1(x, y, 10);
   [y, z] = rot1(y, z, 20);
   [z, x] = rot1(z, x, 30);
   subplot
   subplot(221)
   plot(x, y, '-'), title('Top View'), xlabel('x'), ylabel('y')
   subplot(223)
   plot(x, z, '-'), title('Front View'), xlabel('x'), ylabel('z')
   plot(y, z, '-'), title('Right View'), xlabel('y'), ylabel('z')
   subplot(222)
   title('This is a BOX.')
   subplot
   return
end

if nargin > 2
   xy = [x(:) y(:)].';
  else
   xy = x;
   deg = y;
end

rcf = 180 ./ pi;
rad = deg ./ rcf;
c = cos(rad); s = sin(rad);

r = [c -s; s c];

z = r * xy;

if nargout < 2
   rx = z;
  else
   rx = z(1, :); ry = z(2, :);
end
