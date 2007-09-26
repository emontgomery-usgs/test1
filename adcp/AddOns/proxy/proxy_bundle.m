function proxy_bundle

% Proxy_Bundle -- Bundler for "proxy" toolbox.


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
 
% Version of 25-Jul-1997 10:16:03.

fclose('all');

setdef(mfilename)

tic

dstname = 'proxy_install';

delete([dstname '.m'])
delete([dstname '.p'])
target = '';
bundle(dstname, target)
dst = which(dstname);
dst = strrep(dst, '.m', '')

theUtilities = {'begets',
                'bilinterp',
                'bithist',
                'browse',
                'busy',
                'counts',
                'desc',
                'dump',
                'editmenu',
                'filemenu',
                'fixnl',
                'idle',
                'ispx',
                'labelsafe',
                'maprect',
                'makedir',
                'modplot',
                'plot1',
                'plot2',
                'proxy',
                'proxy_bundle',
                'pxcall',
                'pxclone',
                'pxdemo',
                'pxderef',
                'pxget',
                'pxhome',
                'pxinherit',
                'pxmkmenu',
                'pxowner',
                'pxresize',
                'pxscroll',
                'pxset',
                'pxshrink',
                'pxuget',
                'pxui',
                'pxuset',
                'pxverbose',
                'pxzoom',
                'pxzoomx',
                'pxzoomy',
                'rbline',
                'rbrect',
                'setdef',
                'silent',
                'super',
                'uigetparm',
                'uilayout',
                'uisetdir',
                'unnest',
                'up',
                'var2str',
                'vargstr',
                'viewmenu',
                'zoomsafe'
                };

addpath(pwd)
bundle(dst, 'makedir', target)
bundle(dst, 'eval', target, ['makedir proxy']);
bundle(dst, 'eval', target, ['cd proxy']);
addpath(pwd)
bundle(dst, 'makedir', target)

for i = 1:length(theUtilities)
%  disp([' ## Trying to bundle: ' theUtilities{i}])
   bundle(dst, theUtilities{i}, target)
end

theClasses = {'form',
              'listpick',
              'px',
              'pxenable',
              'pxevent',
              'pxfsw',
              'pxhist',
              'pximage',
              'pxlayout',
              'pxline',
              'pxmenu',
              'pxpatch',
              'pxscrollbar',
              'pxsurface',
              'pxtask',
              'pxwindow'
              };

if (0)
for i = 1:length(theClasses)
   bundle(dst, 'matlab', target, ['makedir @' theClasses{i}])
end
end

for i = 1:length(theClasses)
if (1)
   bundle(dst, ['@' theClasses{i}])
else
   setdef(theClasses{i})
   bundle(dst, 'eval', target, ['cd @' theClasses{i}])
   theMethods = methods(theClasses{i});
   for j = 1:length(theMethods)
      bundle(dst, theMethods{j}, target)
   end
   bundle(dst, 'eval', target, ['cd ..'])
   cd ..
end
   toc
end

bundle(dst, 'matlab', target, ['cd ..'])
bundle(dst, 'eval', target, 'Success')

theVersion = version;
if strcmp(theVersion(1:3), '5.1')
   theVersion
   disp([' ## Use Matlab 5.0 to make the P-code file for ' dstname])
else
   disp([' ## Creating P-code for Matlab version ' theVersion])
   pcode(dstname)
end
