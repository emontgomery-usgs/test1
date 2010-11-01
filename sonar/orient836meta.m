function t836=orient836meta(mk_plts)
%orient836meta creates a structure containing measured x,y coordinates 
% measured pre-deployment for hatteras 09 experiment
% the vectors are named by instrument and will contain 2 or 4 elemnts
% [inst_center_x inst_center_y inst_zero_vect_x inst_zero_vect_y]

if nargin~=1
    mk_plts='n';
end

%legs (b=blue, g=green, r=red, dist=distance
t836.bgdist=2.37;
t836.brdist=2.27;
t836.grdist=2.26;

% leg positions- from sonar_tripod_plot07 [trix triy]
% where 1=G, 2=B, 3=R

t836.gr=[-0.4561 -1.3944];
t836.bl= [1.1587 -0.4569];
t836.rd=[-0.4692 0.5027];
% when there are 4 things, it's [x1,y1, x2, y2]
% adcp - from sonar_tripod_plot07 [ax ay]
t836.adcp=[0 0 0 0.30];
% pencil beam - from sonar_tripod_plot07 [px py px0 py0]
t836.pen=[0.5813 -1.4368 0.9299 -1.8707];
% fan sonar - from sonar_tripod_plot07 [fx yy fx0 fy0]
t836.fan=[0.0983 -0.4802 .6175 -1.4795];

if ~(strcmpi(mk_plts,'n'))
figure
% now plot
plot(t836.bl(1),t836.bl(2),'bo','MarkerSize',10);
hold on
plot(t836.bl(1),t836.bl(2),'bo','MarkerSize',12);
plot(t836.gr(1),t836.gr(2),'go','MarkerSize',12);
plot(t836.rd(1),t836.rd(2),'ro','MarkerSize',12);
plot(t836.gr(1),t836.gr(2),'go','MarkerSize',10);
plot(t836.rd(1),t836.rd(2),'ro','MarkerSize',10);
plot([t836.bl(1) t836.rd(1) t836.gr(1) t836.bl(1)],...
    [t836.bl(2) t836.rd(2) t836.gr(2) t836.bl(2)],'k--')
plot(t836.adcp(1),t836.adcp(2),'ks','MarkerFaceColor','k');
plot([t836.adcp(1) t836.adcp(3)],[t836.adcp(2) t836.adcp(4)],'k');
% fanbeam
plot(t836.fan(1),t836.fan(2),'md','MarkerFaceColor','m');
plot([t836.fan(1) t836.fan(3)],[t836.fan(2) t836.fan(4)],'k');
%fanrad=rsmak('circle',5,[t836.fan(1) t836.fan(2)]);
%fnplt(fanrad,'m');
% pencil
plot(t836.pen(1),t836.pen(2),'ch','MarkerFaceColor','c');
plot([t836.pen(1) t836.pen(3)],[t836.pen(2) t836.pen(4)],'k');
%pencilrad=rsmak('circle',3,[t836.pen(1) t836.pen(2)]);
%fnplt(pencilrad,'y')
% camera
%plot(t836.cam(1),t836.cam(2),'r^','MarkerFaceColor','r');
% aquadop
%plot(t836.aqd(1),t836.aqd(2),'g^','MarkerFaceColor','g');
%plot([t836.aqd(1) t836.aqd(3)],[t836.aqd(2) t836.aqd(4)],'k');

% %
%plot([0 0],[-2 .8],'r')
%text(0.1,-1.8,'red is reference line')
%grid on
%hold off
% to get range and bearing, do this:
% r_ay=sqrt(t836.advy(1)^2+t836.advy(2)^2)
% b_ay=atand(t836.advy(2)/t836.advy(1))

title('tripod 836- for MVCO-07')

[adcp_th,adcp_rng]=cart2pol(t836.adcp(3)-t836.adcp(1),t836.adcp(4)-t836.adcp(2));
[fan_th,fan_rng]=cart2pol(t836.fan(3)-t836.fan(1),t836.fan(4)-t836.fan(2));
[pen_th,pen_rng]=cart2pol(t836.pen(3)-t836.pen(1),t836.pen(4)-t836.pen(2));
%[aqd_th,aqd_rng]=cart2pol(t836.aqd(3)-t836.aqd(1),t836.aqd(4)-t836.aqd(2));
figure
h2=polar(pen_th, pen_rng,'ch');
set(h2,'MarkerFaceColor','c')
hold on 
h1=polar(adcp_th, adcp_rng,'ks');
set(h1,'MarkerFaceColor','k')
h3=polar(fan_th, fan_rng,'md');
set(h3,'MarkerFaceColor','r')
%h3=polar(aqd_th, aqd_rng,'g^');
%set(h3,'MarkerFaceColor','g')
 xlabel('adcp=square, pencil= hexagram, fan=diamond')
hold off
title('tripod 836- for MVCO-07')

%here's how to compute fan_adcp_offset 
% make the center of the fan match the center of the adcp- in this case,
% adcp is 0,0
%  new_fan_00=t836.fan-[t836.fan(1:2) t836.fan(1:2)];
% create x, and y vectors (column!)
%  y=[t836.adcp(4); new_fan_00(4)]
%  x=[t836.adcp(3); new_fan_00(3)]

%  [r, az]=pcoord(x,y);
% az returned is 102.90952 !!!
end

