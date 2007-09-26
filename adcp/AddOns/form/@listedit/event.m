function theResult = Event(self)

% ListEdit/Event -- Event handler.
%  Event(self) handles mouse events associated
%   with self, a "listedit" object.


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
 
% Version of 13-Jan-1998 17:58:49.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theMode = 'normal'; end

theFigure = self.itSelf;

theSource = findobj(theFigure, 'Tag', 'Source');
theEdit = findobj(theFigure, 'Tag', 'Edit');
theOkay = findobj(theFigure, 'Tag', 'Okay');
theCancel = findobj(theFigure, 'Tag', 'Cancel');

theSrcString = get(theSource, 'String');
theSrcValue = get(theSource, 'Value');
theEditString = get(theEdit, 'String');

theTag = get(gcbo, 'Tag');
theValue = get(gcbo, 'Value');
theOldValue = get(gcbo, 'UserData');
set(gcbo, 'UserData', theValue)

switch lower(theTag)
case 'source'
   theSrc = theSource;
   set(theSrc, 'UserData', theValue)
   set(theEdit, 'String', theSrcString{theValue})
case 'edit'
    theSrcString{theSrcValue} = get(theEdit, 'String');
    set(theSource, 'String', theSrcString)
case {'cancel', 'okay'}
    set(theOkay, 'UserData', theSrcString)
    set(theCancel, 'UserData', [])
    set(theFigure, 'UserData', [])   % Ends "modal" state.
otherwise
end
