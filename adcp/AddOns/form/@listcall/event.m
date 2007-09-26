function theResult = Event(self)

% ListCall/Event -- Event handler.
%  Event(self) handles mouse events associated
%   with self, a "listcall" object.


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

theList = findobj(theFigure, 'Tag', 'List');
theOkay = findobj(theFigure, 'Tag', 'Okay');
theCancel = findobj(theFigure, 'Tag', 'Cancel');

theTag = get(gcbo, 'Tag');
theValue = get(gcbo, 'Value');

switch lower(theTag)
case 'list'
    theCall = get(gcbo, 'Userdata');
    if ~isempty(theCall)
        eval(theCall);
    else
        theStrings = get(theList, 'String');
        disp([' ## ' theStrings{theValue}])
    end
case {'cancel', 'okay'}
    theStrings = get(theList, 'String');
    set(theOkay, 'UserData', theStrings)
    set(theCancel, 'UserData', [])
    set(theFigure, 'UserData', [])   % Ends "modal" state.
otherwise
end
