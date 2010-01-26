function fanadcp_off=get_fanadcpoff(orientmeta_name)
%GET_FANADCPOFF computes fan_adcp offset angle from measured x and y positions
%
% usage fanadcp_off=get_fanadcpoff('orientunhmeta')
%  where fanadcp_off is the degrees between the fan 0 and adcp beam 3
%    requires 1 argument the name (string) of the orientmeta file appropriate to
%    the tripod

% read in pre-deployment measurements
position_struct=eval(orientmeta_name);  % returns position_struct structure where if the elements are
% [xposition_under yposition_under xposition_along_zero yposition_along_zero]
%
% make the center of the fan match the center of the adcp- in this case,
% adcp is 0,0
new_fan_00=position_struct.fan-[position_struct.fan(1:2) position_struct.fan(1:2)];

%these have to be column vectors, and put adcp first
y=[position_struct.adcp(4); new_fan_00(4)];
x=[position_struct.adcp(3); new_fan_00(3)];
% then use pcoord to get the azimuth 0-360 from adcp beam3 to fan 0
[r, fanadcp_off]=pcoord(x,y);
