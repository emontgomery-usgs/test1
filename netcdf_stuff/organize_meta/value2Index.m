function [index_num,dist_to_hit] = value2Index(values,hit_values,max_value);
%
%   [index_num,dist_to_hit] = value2Index(values,hit_values,max_value);
%Program to find the index(indices) of the value in a list closest to a particularly hit
%value, and return the distance from the hit value to the closest value
%
%Soupy Alexander, 10/2001
%US Geological Survey
%This program is not supported or provided with any sort of guarantee by
%either its creator or the USGS.

n = length(hit_values);

if nargin == 2;
    max_value = 5;
end

for index = 1:n;
dists = abs(values - hit_values(index));
[dist_to_hit(index),index_num(index)] = min(dists);
if  dist_to_hit(index) > max_value;
    dist_to_hit(index) = NaN;
    index_num(index) = NaN;
end
clear dists
end