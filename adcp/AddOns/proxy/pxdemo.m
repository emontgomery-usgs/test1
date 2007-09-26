function PXDemo

% PXDemo -- Demonstration of basic PX behaviors.


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
 
% Version of 04-Apr-1997 14:09:46.

setdef(mfilename)

help(mfilename)

theContainer = findobj('Type', 'figure', 'Name', 'PXDemo');

if isempty(theContainer)
   figure('Name', 'PXDemo', ...
      'Position', [16 48 128 32], ...
      'NumberTitle', 'off', ...
      'MenuBar', 'none');
   set(gca, 'Visible', 'off')
end

if (1)

disp(' ')
disp(' ## PXDemo')

disp(' ')
disp(' ## Base Class:')
disp(' ')
a = pxnew(px);   % A reference to a "px" object.
disp(px(a))    % "px" used for dereferencing.

disp(' ')
disp(' ## Subclass and Hello:')
disp(' ')
b = pxnew(qx);
bb = px(b); bb.itsGreeting = 'Hello World!';
disp(px(b))

disp(' ')
disp(' ## Clone and Goodbye:')
disp(' ')
c = px(b, []);
cc = px(c); cc.itsGreeting = 'Goodbye World!';
disp(px(c))

delete([a b c])

end

if isempty(theContainer), delete(gcf), end

nofigs

if (0)

a = pxnew(px(figure('Name', 'PXDemo -- Please Click In The Window', ...
                  'Visible', 'off', 'NumberTitle', 'off')));

pxenable(a, a)

pxenable(a, 'WindowButtonDownFcn')
pxenable(a, 'WindowButtonUpFcn')
pxenable(a, 'ResizeFcn')

end

a = pxnew(pxwindow('PXDemo -- Please Click In The Window', 'YX'));

symbol = '^v<>';
for i = 1:4
   subplot(2, 2, i)
   x = 0:10*i; y = x;
   plot(x, y, [symbol(i)])
end

if (0)

x = new(pxscrollbar('XScroll'));
pxenable(x, x);
y = new(pxscrollbar('YScroll'));
pxenable(y, y);

end

pxresize(a)

set(a, 'Visible', 'on')
