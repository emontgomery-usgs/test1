% clip - Remove entire bursts whose mean falls outside a given range
%
% [xclean,Qa]=clip(x,settings);
%
% Inputs
% x = the dirty data set, a structure defined as
% settings = the fine controls
%   settings.min = miniumum acceptable value for data
%   settings.max = maximum acceptable value for data
%   settings.rvalue = NaN; % replacement value to use instead of NaN
%                             % can be 'mean', 'median' or a value
%
% xclean = the fixed data set
% Qa = the feedback on what happened
%   Qa.removed = if the burst data were removed

% written by Marinna Martini

function [xclean,Qa] = clip(x,settings)

% check inputs
if exist('settings', 'var'),
    if isfield(settings,'min'), dmin = settings.min; end
    if isfield(settings,'max'), dmax = settings.max; end
    if isfield(settings, 'rvalue'), rvalue = settings.rvalue; end
end
if exist('rvalue','var')~=1, rvalue = NaN; end
Qa.removed = 0.0;

warning off MATLAB:divideByZero;

% make sure the shape is consistent
nrows = size(x, 1);
if nrows == 1, x = x'; end
xclean = x;
meanx = gmean(x);
medx = gmedian(x);

% use the settings to find the bad stuff
locs=find(x < dmin | x > dmax);
if size(locs) > 0
      Qa.removed = 1.0;
      xclean(locs)=ones(size(locs)).*rvalue;
else
  if meanx < dmin || meanx > dmax,
    Qa.removed = 1.0;
    if ~ischar(rvalue),
        xclean = ones(size(x)).*rvalue;
    elseif strcmp(rvalue, 'median'),
        xclean = ones(size(x)).*medx;
    else
        xclean = ones(size(x)).*meanx;
    end
  end
end
