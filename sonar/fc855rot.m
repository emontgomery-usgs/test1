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
    for icirc = 1:2,
        h = circle(icirc,newx(2)-xoff,newy(2)-yoff);
        set(h,'color','r');
    end
    if strfind(add_az_lines,'y')
        % to get the line approximating pencil sweep alignment
        % this is not cleverly done and must be adjusted after the rest looks
        % right
        pen_adcp_off=brng_deg(2)-brng_deg(5)+trot;
        
        azrotval=[0:3:177]+pen_adcp_off;    % azrotval(1) should be 202
        lx=find(azrotval>360);
        azrotval(lx)=azrotval(lx)-360;
        % the next two obtain the x and y positions under the head for each
        % angle.  The result is on a unit circle, which we can use as 1m
        nypos=cosd(azrotval);
        nxpos=sind(azrotval);
        
        for ik=1:length(azrotval)
            if ik ==1
                col1='g';
                col2='c'
            elseif ik ==60
                col1='r';
                col2='m'
            else
                col1='y'; col2=col1;
            end
            % if we say the offset from the axis of rotation to under the
            % center of the head is 10 cm, a factor of .1 is needed.  if 5 cm,
            % use .05
            h1=arrow([newx(2)-xoff+(.05*nxpos(ik))],[newy(2)-yoff+(.05*nypos(ik))],1.5,+90+azrotval(ik));
            h2=arrow([newx(2)-xoff+(.05*nxpos(ik))],[newy(2)-yoff+(.05*nypos(ik))],1.5,-90+azrotval(ik));
            set(h1,'color',col1)
            set(h2,'color',col2)
        end
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
    
