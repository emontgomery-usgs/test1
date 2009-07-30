function fanadcp_off=get_fanadcpoff
%computes fan_adcp_offset from measured x and y positions

% read in pre-deployment measurements
orient855meta  % returns t855 structure where if the elements are
% [xposition_under yposition_under xposition_along_zero yposition_along_zero]
%
% make the center of the fan match the center of the adcp- in this case,
% adcp is 0,0
new_fan_00=t855.fan-[t855.fan(1:2) t855.fan(1:2)];

%these have to be column vectors, and put adcp first
y=[t855.adcp(4); new_fan_00(4)]
x=[t855.adcp(3); new_fan_00(3)]
% then use pcoord to get the azimuth 0-360 from adcp beam3 to fan 0
[r, fanadcp_off=]=pcoord(x,y)
