function status = Desc(theItem, howMuch)

% Desc -- Description of an object.
%  Desc('theFunction') shows help for 'theFunction'.
%  Desc(theObject) describes theObject itself, but not
%   its inherited parts.
%  Desc(theObject, 'full') describes theObject fully.
%  Desc(theNonObject, ...) describes theNonObject.


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

 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end
if nargin < 2, howMuch = ''; end

theName = inputname(1);

if isstr(theItem)
   help(theItem)
  elseif isobject(theItem)
   disp(' ')
   if ~isempty(theName)
      disp([' ## Name: ' theName])
   end
   if isobject(theItem)
      disp([' ## Public Class: ' class(theItem)])
      s = super(theItem);
      while isobject(s)
         disp([' ## Public SuperClass: ' class(s)])
         s = super(s);
      end
      disp([' ## Protected Methods:'])
      theMethods = methods(class(theItem));
      for i = 1:length(theMethods)
         if strcmp(class(theItem), theMethods{i})
            disp(['    ' class(theItem) '/' theMethods{i} '() // Constructor'])
           else
            disp(['    ' class(theItem) '/' theMethods{i} '()'])
         end
      end
      disp([' ## Private Fields:']), disp(struct(theItem))
      if strcmp(lower(howMuch), 'full')
         if isobject(super(theItem))
            disp([' ## Inherited by ' class(theItem) ':'])
            desc(super(theItem), 'full')
            theItem = super(theItem);
         end
      end
   end
  else
   disp([' ## Name: ' theName])
   disp([' ## Class: ' class(theItem)])
   disp([' ## Value:'])
   disp(theItem)
end
