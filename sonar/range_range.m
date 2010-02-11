function [xc,yc]= range_range(xa,ya,xb,yb,b,a,ew)
% range_range - Simple solution of 3-sided geometry solution
% [xc,yc]= range_range(xa,ya,xb,yb,a,b,ew)
%
% Input:
%   xa, ya, and xb, yb - Coordinates of reference points, where xa and ya
%       must be equal
%   a - Range from xa,ya
%   b - Range from xb,yb
%   Note: nomenclature for a and b are switched at input to correspond to
%   traditional naming convention for sides and angles!
%
% Returned:
%   xc,yc - Location of unknown point
%

%
% Note that the assignment of ranges to reference points is a little
% confusing.
% Reference points: vertex A at xa,ya
%                          B at xb,yb
% Unknown point:    vertex C at xc,yc
% Sides are labelled according to opposing vertices, so:
% Range b is actually from ref. point A
%       a is from ref. point B
% (Note how arguments are switched on input)
% This version assumes A and B are on the N/S line, with A at north
%
% csherwood@usgs.gov

if(xb ~= xa),error('xa and xb must be equal'),end

% subtract x value
xoffset = xa; %
xa = xa-xoffset;
xb = xb-xoffset;

% subtract min y value to prevent negative y values for reference points
yoffset = min( ya, yb);
ya=ya-yoffset;
yb=yb-yoffset;

% c = length of baseline
c = sqrt((xa-xb).^2+ (ya-yb).^2);
alpha = acos((b^2+c^2-a^2)/(2*b*c));
beta  = acos((a^2+c^2-b^2)/(2*a*c));
gamma = acos((a^2+b^2-c^2)/(2*a*b));
switch lower(ew)
    case 'w'
        xc = -(b*sin(alpha));
    case 'e'
        xc = (b*sin(alpha));
end
e = b*cos(alpha);
d = a*cos(beta);
% yc = yb+d; % should be same as next line
yc = ya-e;

% add offset back in  
        yc = yc+yoffset;
        xc = xc+xoffset;
    
