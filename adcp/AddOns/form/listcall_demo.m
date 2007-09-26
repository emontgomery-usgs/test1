function theResult = listcall_demo(nItems)

% listcall_demo -- Demonstration of "ListCall".
%  listcall_demo (no argument) demonstrates
%   a 'listcall" modal dialog.  The code given
%   here shows how to capture and update the
%   contents of the "listcall" dialog box.
%   In this example, a three-state system is
%   toggled, using the letter 'X' to show the
%   current state of each item in the list.


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
 
% Version of 13-Jan-1998 20:11:58.

mode = ~isempty(gcbo);

theMark = setstr(165);   % Bullet.
if ~any(findstr(computer, 'MAC'))
    theMark = 'X';
end

switch mode
case 0   % Setup the "listcall" dialog.
    if nargin < 1, nItems = 50; end
    theStrings = cell(nItems, 1);
    for i = 1:length(theStrings);
        s = [theMark ' - - ' int2str(i)];
        theStrings{i} = s;
    end
    theCall = 'listcall_demo';
    thePrompt = 'Toggle';
    theName = 'ListCall Demo';
    a = listcall(theStrings, thePrompt, theName, theCall);
    if nargout > 0
        theResult = a;
    else
        assignin('caller', 'ans', a);
    end
otherwise   % Process the "listcall" picks.
    theGCBO = gcbo;
    theStrings = get(theGCBO, 'String');
    theValue = get(theGCBO, 'Value');
    s = theStrings{theValue};
    code = s(1:5);
    f = find(code == theMark);
    if ~any(f), f = 0; end
    switch f
    case 1
        code = ['- ' theMark ' -'];
    case 3
        code = ['- - ' theMark];
    case 5
        code = [theMark ' - -'];
    otherwise
    end
    s(1:5) = code;
    theStrings{theValue} = s;
    set(theGCBO, 'String', theStrings)
    set(theGCBO, 'Value', theValue)
end
