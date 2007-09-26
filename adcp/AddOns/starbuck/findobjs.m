function theResult = findobjs(varargin)

% findobjs -- Smart "findobj" with relational operators.
%  findobjs(...) returns handles in the same fashion
%   as "findobj", with the added feature of allowing
%   a relational-operator to be appended to each
%   property-name, as in "findobjs('Type~=', 'line')".
%   The  "~=" relationship is processed with the
%   Matlab "isequal" function; all others rely on
%   "feval('operator', ...)".  Handles that do not
%   possess the given property-names are ignored,
%   as are illegal operators.
%  findobj('demo') demonstrates itself.
%
% Also see: "help findobj".


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

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 10-Dec-1999 11:26:09.
% Updated    10-Dec-1999 14:42:23.

if nargout > 0, theResult = []; end

if nargin < 1, varargin = {}; end
if isempty(varargin), varargin = {'demo'}; end

% Demonstration.

if isequal(varargin{1}, 'demo')
	disp(' ')
	disp(' ## findobjs demo')
	delete(get(gcf, 'Children'))
	set(gcf, 'Name', 'findobjs demo')
	disp(' ')
	s = 'plot(0:10, rand(1, 11), ''o-'')';
	disp([' ## ' s])
	eval(s)
	disp(' ')
	figure(gcf)
	s = 'findobjs(0)';
	disp([' ## ' s])
	eval(s)
	disp(' ')
	s = 'findobjs(0, ''Type~='', ''axes'', ''Type~='', ''line'')';
	disp([' ## ' s])
	eval(s)
	disp(' ')
	return
end

% Get the starting handle.

theHandle = 0;
if ~ischar(varargin{1}) & ishandle(varargin{1})
	theHandle = varargin{1};
	varargin(1) = [];
end

% Parse the relational operators, setting
%  "==" to the empty-string ''.

s = [];
for i = 2:2:length(varargin)
	k = i/2;
	name = lower(varargin{i-1});
	relop = name(name < 'a' | name > 'z');
	if isequal(relop, '=='), relop = ''; end
	name = name(name >= 'a' & name <= 'z');
	value = varargin{i};
	s(k).name = name;
	s(k).value = value;
	s(k).relop = relop;
end

% Separate the equalities from the others.

t = s;
for i = length(s):-1:1
	if isempty(s(i).relop)
		s(i) = [];   % Equality.
	else
		t(i) = [];   % Other.
	end
end

% Get the handles for the equalities, or
%  everything if no equalities are given.

u = [];
for i = 1:length(t)
	u{end+1} = t(i).name;
	u{end+1} = t(i).value;
end
if isempty(u)
	result = findobj(theHandle);
else
	result = findobj(theHandle, u{:});
end

% Isolate the relational subset, if any.

if length(s) > 0
	for k = length(result):-1:1
		okay = 0;
		try
			for i = 1:length(s)
				try
					val = get(result(k), s(i).name);
				catch
					break
				end
				value = s(i).value;
				relop = s(i).relop;
				
				switch relop
				case '~='
					okay = ~isequal(val, value);
				otherwise
					try
						okay = feval(relop, val, value);
					catch
					end
				end
				
				if ~okay, break, end
			end
		catch
		end
		if ~all(okay(:))
			result(k) = [];
		end
	end
end

% Done.

if nargout > 0
	theResult = result;
else
	assignin('caller', 'ans', result)
	if isempty(result)
		disp('   Empty matrix: 0-by-1')
	else
		for i = 1:length(result)
			disp([' ##    ' num2str(result(i), 16) ': ' get(result(i), 'Type')])
		end
	end
end
