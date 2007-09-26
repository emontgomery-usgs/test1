function status = DoShrink(theAxes, theDirection)

% DoShrink -- No help available.
% DoShrink -- Strink axes to fit plotted data.
%  DoShrink(theAxes, theDirection) shrinks theAxes to
%   fit the plotted data exactly along theDirection
%   ('x' or 'y').  TheDirection defaults to 'xy',
%   which processes both axis directions.


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
% All Rights Reserved.
 
% Version of 28-May-96 at 13:44:35.22.

if nargin < 1
   theAxes= get(gcf, 'Children');
end
if nargin < 2, theDirection = 'xy'; end

if ~isempty(theAxes)
   for i = 1:length(theAxes)
      if ~strcmp(get(theAxes(i), 'Type'), 'axes')
         theAxes(i) = 0;
      end
   end
   theAxes(theAxes == 0) = [];
end

if isempty(theAxes), return, end

for j = 1:length(theAxes)
   x = []; y = []; z = []; c = [];
   xmin = []; xmax = [];
   ymin = []; ymax = [];
   zmin = []; zmax = [];
   cmin = []; cmax = [];
   h = get(theAxes(j), 'Children');
   for i = 1:length(h)
      theType = get(h(i), 'Type');
      if strcmp(theType, 'image') | ...
         strcmp(theType, 'line') | ...
         strcmp(theType, 'patch') | ...
         strcmp(theType, 'surface')
         x = get(h(i), 'XData'); x = x(finite(x));
         y = get(h(i), 'YData'); y = y(finite(y));
         if ~strcmp(theType, 'image')
            z = get(h(i), 'ZData'); z = z(finite(z));
         end
         c = get(theAxes(j), 'CLim'); c = c(finite(c));
         if i == 1
            if ~isempty(x)
               xmin = min(min(x)); xmax = max(max(x));
            end
            if ~isempty(y)
               ymin = min(min(y)); ymax = max(max(y));
            end
            if ~isempty(z)
               zmin = min(min(z)); zmax = max(max(z));
            end
            if ~isempty(c)
               cmin = min(min(c)); cmax = max(max(c));
            end
           else
            if ~isempty(x)
               xmin = min(min(min(x)), xmin);
               xmax = max(max(max(x)), xmax);
            end
            if ~isempty(y)
               ymin = min(min(min(y)), ymin);
               ymax = max(max(max(y)), ymax);
            end
            if ~isempty(z)
               zmin = min(min(min(z)), zmin);
               zmax = max(max(max(z)), zmax);
            end
            if ~isempty(c)
               cmin = min(min(min(c)), cmin);
               cmax = max(max(max(c)), cmax);
            end
         end
      end
   end
   for i = 1:length(theDirection)
      if any(theDirection(i) == 'xX')
         if ~isempty(xmin)
            if xmin < xmax
               set(theAxes(j), 'XLim', [xmin xmax])
            end
         end
      end
      if any(theDirection(i) == 'yY')
         if ~isempty(ymin)
            if ymin < ymax
               set(theAxes(j), 'YLim', [ymin ymax])
            end
         end
      end
      if any(theDirection(i) == 'zZ')
         if ~isempty(zmin)
            if zmin < zmax
               set(theAxes(j), 'ZLim', [zmin zmax])
            end
         end
      end
      if any(theDirection(i) == 'cC')
         if ~isempty(cmin)
            if cmin < cmax
               set(theAxes(j), 'CLim', [cmin cmax])
            end
         end
      end
   end
end
