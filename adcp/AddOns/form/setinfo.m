function [theResult, isOkay] = setinfo(theInfo, theField, theValue)

% setinfo -- Set field value in an "Info" struct.
%  setinfo(theInfo, 'theField', theValue) updates
%   'theField' to theValue in theInfo, a struct
%   that is compatible with the "uigetinfo" function.
%   If 'theField' does not exist, it will be created
%   to receive theValue.
%  [theResult, isOkay] = ... returns isOkay = 0
%   if an error occurred; otherwise, non-zero.
%  setinfo(theInfo, 'theField') invokes "getinfo".


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
 
% Version of 07-Feb-1998 09:45:56.
% Updated    26-Apr-1999 14:49:30.   % Needs work!!!

if nargin < 2, help(mfilename), return, end

[theVal, isOkay] = getinfo(theInfo, theField);

if nargin == 2
    if nargout > 0
        theResult = theVal;
    else
        disp(theVal)
    end
    return
end

result = theInfo;

if ~all(isOkay)   % Create a new field.
    isOkay = 1;
    eval('result = setfield(theInfo, theField, theValue);', 'isOkay = 0;');
else   % Update an existing field.
	isokay = 1;
	eval('theVal = getfield(theInfo, theField);', 'isOkay = 0;');
	if ~isOkay, theVal = []; end
    switch class(theVal)
	case 'cell'
        if isequal(theVal{1}, 'checkbox') | isequal(theVal{1}, 'radiobutton')
		elseif ~iscell(theVal{1})
			theVal{1} = {theVal{1}};
		end
	end
    switch class(theVal)
    case 'cell'
        if isequal(theVal{1}, 'checkbox') | isequal(theVal{1}, 'radiobutton')
            theVal{2} = any(any(theValue));
        else
            flag = 0;
            for i = 1:length(theVal{1})
                if isequal(theVal{1}{i}, theValue)
                    theVal{2} = i;
                    flag = 1
                end
            end
            if ~any(flag)   % Append.
                theVal{1} = [theVal(:); {theValue}];
                theVal{2} = length(theVal{1});
            end
% else
% theVal{1} = [{theValue}; theVal(:)];
        end
    otherwise
        theVal = theValue;
    end
    isOkay = 1;
    eval('result = setfield(theInfo, theField, theVal);', 'isOkay = 0;');
end

if nargout > 0
    theResult = result;
else
    disp(result)
end
