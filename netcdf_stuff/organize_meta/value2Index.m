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


%%% START USGS BOILERPLATE -------------% Program written in Matlab v6x
% Program works in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
% program ran on Redhat Enterprise Linux 4
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
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