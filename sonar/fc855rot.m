function [newx, newy]=fc855rot(trot) 
%fc866rot converts adcp centric world to fan-centered
% requires one argument, the degrees to rotate

%Sxlim([-6 6]);ylim([-6 6]);daspect([1 1 1]);hold on;
% get the data from the adcp-centric world
% will generate 2 plots here, unless you say 'n')
t855=orient855meta('n');
%
% use pcoord to get ranges and bearings
% because we measured from the adcp as (0,0) it is the from for all the
% resulting vectors.  bearing is in degrees from up- all will be positive
% rotation from "up" or 'N' (or Matlab's 90)
xs=[t855.cam(1) t855.pen(1) t855.aqd(1) t855.fan(1) t855.adcp(1) t855.pen(3)];
ys=[t855.cam(2) t855.pen(2) t855.aqd(2) t855.fan(2) t855.adcp(2) t855.pen(4)];
[rngs, brng_deg]=pcoord(xs, ys);
   % rngs = 0.5697    1.5187    0.9762    0.5104  0
   % brng_deg =  168.8676  182.7173  186.4698  198.1510  0
  tx=[t855.gr(1) t855.bl(1) t855.rd(1)];
 ty=[t855.gr(2) t855.bl(2) t855.rd(2)];
 [trng, tbrng_deg]=pcoord(tx, ty);
    
%now plot the new positions 
xoff=t855.fan(1);
yoff=t855.fan(2);

% subtract fan x and fany from each (x,y) to make fan-centric
%figure (2)
%hold on
%plot(t855.bl(1)-xoff,t855.bl(2)-yoff,'bo','MarkerSize',10);
%plot(t855.bl(1)-xoff,t855.bl(2)-yoff,'bo','MarkerSize',12);
%plot(t855.gr(1)-xoff,t855.gr(2)-yoff,'go','MarkerSize',12);
%plot(t855.rd(1)-xoff,t855.rd(2)-yoff,'ro','MarkerSize',12);
%plot(t855.gr(1)-xoff,t855.gr(2)-yoff,'go','MarkerSize',10);
%plot(t855.rd(1)-xoff,t855.rd(2)-yoff,'ro','MarkerSize',10);
%plot([t855.bl(1)-xoff t855.rd(1)-xoff t855.gr(1)-xoff t855.bl(1)-xoff],...
%    [t855.bl(2)-yoff t855.rd(2)-yoff t855.gr(2)-yoff t855.bl(2)-yoff],'k--')
%plot(t855.adcp(1)-xoff,t855.adcp(2)-yoff,'ks','MarkerFaceColor','k');
%plot([t855.adcp(1)-xoff t855.adcp(3)-xoff],[t855.adcp(2)-yoff t855.adcp(4)-yoff],'k');
% fanbeam
% plot(t855.fan(1)-xoff,t855.fan(2)-yoff,'md','MarkerFaceColor','m');
% plot([t855.fan(1)-xoff t855.fan(3)-xoff],[t855.fan(2)-yoff t855.fan(4)-yoff],'k');
% %fanrad=rsmak('circle',5,[t855.fan(1) t855.fan(2)]);
% %fnplt(fanrad,'m');
% plot(t855.pen(1)-xoff,t855.pen(2)-yoff,'ch','MarkerFaceColor','c');
% plot([t855.pen(1)-xoff t855.pen(3)-xoff],[t855.pen(2)-yoff t855.pen(4)-yoff],'k');
% %pencilrad=rsmak('circle',3,[t855.pen(1) t855.pen(2)]);
% %fnplt(pencilrad,'y')
% % camera
% plot(t855.cam(1)-xoff,t855.cam(2)-yoff,'r^','MarkerFaceColor','r');
% % aquadop
% plot(t855.aqd(1)-xoff,t855.aqd(2)-yoff,'g^','MarkerFaceColor','g');
% plot([t855.aqd(1)-xoff t855.aqd(3)-xoff],[t855.aqd(2)-yoff t855.aqd(4)-yoff],'k');
% axis square
% hold off

%now rotate the image
% ntx, nty ordder: greed, blue, red
% newx, newy order: camera, pen, aqd, fan, adcp
 [newx, newy]=xycoord(rngs, brng_deg+trot);
  [newtx, newty]=xycoord(trng, tbrng_deg+trot);
 
 xoff=newx(4);
 yoff=newy(4);
figno=input('what existing figure should the new coordinates go on? ')

figure(figno)
hold on
plot(newtx(2)-xoff,newty(2)-yoff,'bo','MarkerSize',10);
plot(newtx(2)-xoff,newty(2)-yoff,'bo','MarkerSize',12);
plot(newtx(1)-xoff,newty(1)-yoff,'go','MarkerSize',12);
plot(newtx(3)-xoff,newty(3)-yoff,'ro','MarkerSize',12);
plot(newtx(1)-xoff,newty(1)-yoff,'go','MarkerSize',10);
plot(newtx(3)-xoff,newty(3)-yoff,'ro','MarkerSize',10);
plot([newtx(2)-xoff newtx(3)-xoff newtx(1)-xoff newtx(2)-xoff],...
    [newty(2)-yoff newty(3)-yoff newty(1)-yoff newty(2)-yoff],'k--')
% now do the insturmens
plot(newx(5)-xoff,newy(5)-yoff,'ks','MarkerFaceColor','k');
% fanbeam
plot(newx(4)-xoff,newy(4)-yoff,'md','MarkerFaceColor','m');
%fanrad=rsmak('circle',5,[xoff yoff]);
%fnplt(fanrad,'m');
%pencil
plot(newx(2)-xoff,newy(2)-yoff,'ch','MarkerFaceColor','c');
% add 1 meter radius circles around the pencil beam
for icirc = 1:3,
    h = circle(icirc,newx(2)-xoff,newy(2)-yoff);
    set(h,'color','r');
end
 % to get the line approximating pencil sweep alignment
 % this is not cleverly done and must be adjusted after the rest looks
 % right
 arrow([newx(2)-xoff],[newy(2)-yoff],1.5,105)
 arrow([newx(2)-xoff],[newy(2)-yoff],1.5,285)

%pencilrad=rsmak('circle',3,[t855.pen(1) t855.pen(2)]);
%fnplt(pencilrad,'y')
% camera
plot(newx(1)-xoff,newy(1)-yoff,'r^','MarkerFaceColor','r');
% aquadop
plot(newx(3)-xoff,newy(3)-yoff,'g^','MarkerFaceColor','g');
%gtext('pencil= hexagram, fan=diamond, adcp=square, aquadop=red triangle, camera=green triangle')
hold off

