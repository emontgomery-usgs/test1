function [theResult, isOkay] = getinfo(theInfo, theField)

% getinfo -- Get field value from an "Info" struct.
%  getinfo(theInfo, 'theField') returns the current
%   value of 'theField' in theInfo, a struct that
%   is compatible with the "uigetinfo" function.
%   Non-existent fields return the empty-matrix.
%  [theResult, isOkay] = ... returns isOkay = 0
%   if an error occurred; otherwise, non-zero.


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
% Updated    26-Apr-1999 14:49:30.

if nargin < 2, help(mfilename), return, end

theValue = [];

isOkay = 1;
eval('theValue = getfield(theInfo, theField);', 'isOkay = 0;');

result = theValue;

if all(isOkay)
    switch class(theValue)
    case 'cell'
        if isequal(theValue{1}, 'checkbox') | ...
				isequal(theValue{1}, 'radiobutton')
			if length(theValue) < 2, theValue{2} = 0; end
            result = theValue{2};
        else
			if ~iscell(theValue{1}), theValue = {theValue{1}}; end
			if length(theValue) < 2, theValue{2} = 1; end
            result = theValue{1}{theValue{2}};
        end
    otherwise
        result = theValue;
    end
end

if nargout > 0
    theResult = result;
else
    disp(result)
end
