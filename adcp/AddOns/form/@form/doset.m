function [theFunction, theInputs, theOutputs] = doset(self, varargin)

% form/doset -- Initialize the input fields of a Form.
%  doset(self, ...) sets the fields of self, a Form,
%   to the given {varargin} values, in the sequence
%   supplied, from top to bottom.
%  [theFunction, theInputs, theOutputs] = doset(self)
%   returns theFunction and the input and output fields
%   of self, a Form.


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
 
% Version of 22-May-1997 11:07:38.

if nargin < 1, help(mfilename), return, end

if nargin > 1
   while iscell(varargin{1})
      varargin = varargin{1};
   end
  else
   theFunction = '';
   theIns = cell(1, 0);
   theOuts = cell(1, 0);
end

theFigure = self.itSelf;

f = findobj(theFigure, 'Type', 'uicontrol', 'Style', 'frame');
c = get(f, 'UserData');

theOutputFlag = 0;
k = 0;
for i = 1:length(c)
   theTag = get(c(i), 'Tag');
   if i == 1
      theFcn = theTag;
     elseif strcmp(theTag, '=')
      theOutputFlag = 1;
     elseif ~isempty(theTag)
      k = k + 1;
      if nargin > 1
         switch class(varargin{k})
         case 'cell'
            theString = varargin{k};
            for index = 1:length(theString)
               switch class(theString{index})
               case 'char'
                  theString{index} = ['''' theString{index} ''''];
               case 'double'
                  theString{index} = mat2str(theString{index});
               otherwise
               end
            end
         case 'char'
            theString = ['''' varargin{k} ''''];
         case 'double'
            theString = mat2str(varargin{k});
         otherwise
         end
         theStyle = get(c(i), 'Style');
         switch theStyle   % Set the controls.
         case 'pushbutton'
         case {'checkbox', 'radiobutton'}
            theValue = 0;
            switch class(theString)
            case 'cell'
               theValue = eval(theString{1});
            case 'char'
               theValue = eval(theString);
            otherwise
            end
            set(c(i), 'Value', theValue, 'String', '0 or 1')
         case 'popupmenu'
            s = get(c(i), {'String'});
            if isequal(s, {'-'})
               set(c(i), 'String', theString, 'Value', 1)
            end
         otherwise
            set(c(i), 'String', theString)
         end
        elseif theOutputFlag == 0
         theStyle = get(c(i), 'Style');
         switch theStyle
         case 'pushbutton'
            theString = get(c(i), 'UserData');
            theIns = [theIns; {theString}];
         case {'checkbox', 'radiobutton'}
            theValue = get(c(i), 'Value');
            if theValue == 0
               theString = {0; 1};
              else
               theString = {1; 0};
            end
            theIns = [theIns; {theString}];
         case 'popupmenu'
            theValue = get(c(i), 'Value');
            theString = get(c(i), {'String'});
            theString = theString{1};
            if (1)  % Put selection on top.
               index = 1:length(theString);
               index(theValue) = [];
               index = [theValue index];
               theString = theString(index);
               for index = 1:length(theString)
                  theString{index} = eval(theString{index});
              end
           else   % Something else, not yet certain.
              theString = {theString, theValue};
           end
            theIns = [theIns; {theString}];
         otherwise
            theString = get(c(i), 'String');
            theString = eval(theString);
            theIns = [theIns; {theString}];
         end
        elseif theOutputFlag == 1
         theString = eval(get(c(i), 'String'));
         theOuts = [theOuts; {theString}];
      end
      if nargin > 1 & k >= length(varargin), break, end
   end
end

if nargout > 0
   theFunction = '';
   theInputs = [];
   theOutputs = [];
   if nargin < 2
      theFunction = theFcn;
      theInputs = theIns;
      theOutputs = theOuts;
   end
  elseif nargin < 2
   theFunction = theFcn;
   theInputFields = theIns
   theOutputFields = theOuts
end
