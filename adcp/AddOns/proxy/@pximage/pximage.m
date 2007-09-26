function theResult = PXImage(varargin)

% PXImage -- Constructor for interactive image.
%  PXImage(...) creates an interactive image,
%   using the syntax of the Matlab "image" function.
%  PXImage('demo') demonstrates "pximage".
%
%   -- A "pximage" object is returned; "ans" is used
%   if no output argument is provided.
%
%   -- Use "pxcallback('theCallback')" to set the name
%   of the callback that will be invoked after a
%   mouse-selection has occurred on the line, as
%   feval('theCallback', {thePXImage}) -- note that
%   the "pximage" object is delivered inside a cell,
%   since the callback is not a method of the "pximage"
%   class.
%
%   -- Use "pxvalue(thePXImage) to get the indices
%   of selected points in thePXImage.
%
%   -- The pseudo-fields "x", "y", "c", and "s" (selected)
%   of the "pximage" object can be referenced and assigned
%   with conventional indices, as in "x = theObject.x" and
%   "theObject.x = x".


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
 
% Version of 23-Apr-1997 08:16:09.

if nargin < 1, help(mfilename), varargin{1} = 'demo'; end

if isequal(varargin{1}, 'demo')
	varargin{1} = [10 20];
end

if ischar(varargin{1})
	varargin{1} = eval(varargin{1});
end

if length(varargin{1}) == 2
	result = pximage(rand(varargin{1})*32+10);
	if nargout > 0
		theResult = result;
	else
		assignin('caller', 'ans', result)
	end
	return
end

if length(varargin{1}) < prod(size(varargin{1}))
	[m, n] = size(varargin{1});
	theXData = 1:n;
	theYData = 1:m;
	varargin = [{theXData} {theYData} varargin];
end

theXData = varargin{1};
theYData = varargin{2};
theCData = varargin{3};
theSData = zeros(size(theCData));   % Selections.

% Create the image.

varargin{3} = theCData;
theImage = image(varargin{:});
set(theImage, ...
			'EraseMode', 'xor', ...   % What EM is best?
			'ButtonDownFcn', 'disp(''pximage_data'')', ...
			'Tag', 'pximage_data', ...
			'CDataMapping', 'scaled');
			
theCLim = get(gca, 'CLim');
[m, n] = size(colormap);
theCLim(1) = theCLim(1) - diff(theCLim) ./ (m - 1);
set(gca, 'CLim', theCLim)

theStruct.itSelf = [];
self = class(theStruct, 'pximage', px(theImage));
self.itSelf = px(self);
pxset(self, 'itsObject', self)
p = px(self);
pxenable(p, p);
pxenable(p)

pxset(self, 'itsXData', theXData)
pxset(self, 'itsYData', theYData)
pxset(self, 'itsCData', theCData)
pxset(self, 'itsSData', theSData)
pxset(self, 'itHasChanged', 0)
pxset(self, 'itsCallback', '')
pxset(self, 'itsValue', [])
pxset(self, 'itsHandles', [])
result = self;

pxenable(p, 'ButtonDownFcn')

pxevent(self, 'Refresh')
   
if nargout > 0
   theResult = result;
  else
   assignin('base', 'ans', result)
end
