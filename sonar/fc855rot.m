function [newx, newy]=fc855rot(trot, add_az_lines)
%fc866rot converts adcp centric world to fan-centered
% requires 2 argument2, the degrees to rotate,
% and whether to add azimuth lines to the plot ('y or 'no')

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
penx=t855.pen(3)-t855.pen(1); peny=t855.pen(4)-t855.pen(2);
[rngs, brng_deg]=pcoord(xs, ys);
[p1r,p1az]=pcoord(penx, peny);
% rngs = 0.5697    1.5187    0.9762    0.5104  0
% brng_deg =  168.8676  182.7173  186.4698  198.1510  0
% do the same for tripod feet
tx=[t855.gr(1) t855.bl(1) t855.rd(1)];
ty=[t855.gr(2) t855.bl(2) t855.rd(2)];
[trng, tbrng_deg]=pcoord(tx, ty);

%now plot the new positions
xoff=t855.fan(1);
yoff=t855.fan(2);

%now rotate the image, converting back to x,y from polar
% ntx, nty ordder: greed, blue, red
% newx, newy order: camera, pen, aqd, fan, adcp
[newx, newy]=xycoord(rngs, brng_deg+trot);
[newtx, newty]=xycoord(trng, tbrng_deg+trot);
[newp1x,newp1y]=xycoord(p1r, p1az+trot);

xoff=newx(4);
yoff=newy(4);
figno=input('what existing figure should the new coordinates go on? ')

figure(figno)
hold on
% plot range circles from center of pencil

if strfind(add_az_lines,'y')
    % to get the line approximating pencil sweep alignment
    % uses technique from plotrange_cdf to fo sweep positions
    % azrotval are the radial slices,
    % same as nc{'azangle'}
    azrotval=[0:3:177]+trot;    % azrotval(1) should be 202
    lx=find(azrotval>360);
    azrotval(lx)=azrotval(lx)-360;
    %beta are the angles downward in each sweep
    % same as nc{'headangle'}
    bt=[-66 -66:.3:66 66];
    beta=repmat(bt,60,1);
    beta = beta.*(pi/180); % convert to radians
    hgt=1.06;       % from nc.Height
    
    Ro = 0.05; %meters, pencil sweep apex offset from azimuth centerline of rotation
    m = hgt.*tan(beta); % horizontal distance from sweep apex to measurement M
    alpha = azrotval; % the azimuth rotation angle, [nAz] positions, on x-y plane
    alpha = alpha.*(pi/180); % convert to radians
    gamma = atan(m./Ro); % angle between points A and M
    for iAz=1:2:60
        x(iAz,:) = sqrt(m(iAz,:).^2+Ro.^2).*sin(gamma(iAz,:)+alpha(iAz));
        y(iAz,:) = sqrt(m(iAz,:).^2+Ro.^2).*cos(gamma(iAz,:)+alpha(iAz));
        x1=x(iAz,:)+newx(2)-xoff;
        y1=y(iAz,:)+newy(2)-yoff;
        if iAz==1
        plot([x1(1) x1(end)],[y1(1) y1(end)],'g')
        else
        plot([x1(1) x1(end)],[y1(1) y1(end)],'y')
        end
    end
    % add offset to pencil center to the x,y positions
end
for icirc = 1:3,
    h = circle(icirc,newx(2)-xoff,newy(2)-yoff);
    set(h,'color','r');
end
% add the tripod stuff over the azimuth lines
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
%pencilrad=rsmak('circle',3,[t855.pen(1) t855.pen(2)]);
%fnplt(pencilrad,'y')
% camera
plot(newx(1)-xoff,newy(1)-yoff,'r^','MarkerFaceColor','r');
% aquadop
plot(newx(3)-xoff,newy(3)-yoff,'g^','MarkerFaceColor','g');
%gtext('pencil= hexagram, fan=diamond, adcp=square, aquadop=red triangle, camera=green triangle')
hold off

