function UNH_TRIPODOVL(targ_no)
% overplot tripod used for UNH tank tests
% requires one argument, the target number for use in definition file name
%  gets definitions of arrangements in target#_def.m, then plots
%  called by plot_fan
%  usage : unh_tripodovl(5)

% csherwood@usgs.gov, modified, etm 1/5/09

target = targ_no;
iref = 5; % fan beam
jref = 5;
rtd = 180/pi;   %rtd is radians to degrees
%% Particle tripod
% Location of instruments before deployment in tank
% Origin is ground zero beneath ADCP.
% Positive y axis is beneath ADCP beams 3 (parallel to side of tank,
% towards bay door) (approx. 20 degrees magnetic, based on hand compass)
% Positive x axis is toward tank, origin is under ADCP pressure case
% Distances are in m

% build a structure array where elements are the instruments to be located
% and fields of each element are:
% n=short name
% ln=longer name
% xm=x distance from origin (meters)
% ym=y distance from origin (meters)\
% zm is height above floor
% azm is direction to where the instrument 0 points-  The complication here
% is getting whether it's 180 - or 180 + {atan(x,y)} right
%
% fields for the tilt, roll and pitch of the sonar heads don't exist yet.
%
p(1).n = 'R';
p(1).ln = 'red armpit';
p(1).xm = .96;
p(1).ym = -1.076;
p(1).zm = 0;

p(2).n = 'G';
p(2).ln = 'green armpit';
p(2).xm = -1.25;
p(2).ym = -1.167;
p(2).zm = 0;

p(3).n = 'B';
p(3).ln = 'blue armpit';
p(3).xm = -0.14;
p(3).ym = 0.892;
p(3).zm = 0;

p(4).n = 'PB';
p(4).ln = 'Dual-axis Pencil Beam';
p(4).xm = -0.14;
p(4).ym = -1.529;
p(4).zm = 1.055;
p(4).az = 180-rtd*atan(1.2/19.5);

p(5).n = 'FB';
p(5).ln = 'Fan Beam';
p(5).xm = -.197;
p(5).ym = -.512;
p(5).zm = 0.594;
p(5).az = 180+rtd*atan(23/12.3);
% p(5).az = p(5).az-2 % FUDGE ALERT ad hoc adjustment!

p(6).n = 'ADCP';
p(6).ln = 'ADCP';
p(6).xm = 0;
p(6).ym = 0;
p(6).zm = 1.54;
[r,az]=pcoord(0,1); % orientation of beam 3
p(6).az = az;

% EZ compass
p(7).n = 'EZ';
p(7).ln = 'EZ Compass';
p(7).xm = .186;
p(7).ym = -.728;
p(7).zm = 1.391;
p(7).az = 180 + rtd*atan(3/19.5);

% gets the info for the desired targets- names must take the form
% target1_def.m (where 1 changes)
eval(['target' num2str(targ_no) '_def'])


%% relocate origin and rotate
% offset, rotated points p and m will end up in pn and mn
if(1)
   % adjust x,y location of instruments
   xoff = p(iref).xm;
   yoff = p(iref).ym;
   for i=1:length(p)
      pn(i).xm=p(i).xm-xoff;
      pn(i).ym=p(i).ym-yoff;
   end
   for i=1:length(m)
      mn(i).xm=m(i).xm-xoff;
      mn(i).ym=m(i).ym-yoff;
   end
   % rotate instruments and targets wrt to some data
   prot = -p(jref).az;
   for i=1:length(p)
      [r,az]=pcoord(pn(i).xm,pn(i).ym);
      azr = az+prot;
      [pn(i).xm,pn(i).ym]=xycoord(r,azr);
      pn(i).az= p(i).az+prot;
      pn(i).az = pn(i).az+360*(pn(i).az<0);
   end
   for i=1:length(m)
      [r,az]=pcoord(mn(i).xm,mn(i).ym);
      azr = az+prot;
      [mn(i).xm,mn(i).ym]=xycoord(r,azr);
   end
else
   iref = 1;
   jref = 1;
   ref_az = 0;
end

%% plot sonar tripod
hold on

xoff = .05;
yoff = .05;
textcolor = [1 1 0];
textfontsize = 10
for i=4:length(p)
   plot(pn(i).xm,pn(i).ym,'xc')
   hh=text(pn(i).xm+xoff,pn(i).ym+yoff,p(i).n);
   set(hh,'color',textcolor,'fontsize',textfontsize)
end
% plot instruments with vectors for orientation
for iv=[4:7]
   h=arrow(pn(iv).xm,pn(iv).ym,.5,pn(iv).az);
   set(h,'linestyle','--','color','c');
end

% plot legs
lcolor = [1 0 0;0 1 0;0 0 1];
for i=1:3
   h=plot(pn(i).xm,pn(i).ym,'o');
   set(h,'color',lcolor(i,:))
   hh=text(pn(i).xm+xoff,pn(i).ym+yoff,p(i).n);
   set(hh,'color',textcolor,'fontsize',textfontsize)
end

plot([mn([1:4]).xm], [mn([1:4]).ym] ,'-r')
plot([mn([5:8]).xm mn([5]).xm],[mn([5:8]).ym mn([5]).ym],'-y')
plot([mn([9:15]).xm mn([9]).xm],[mn([9:15]).ym mn([9]).ym],'-c')
plot([mn([2]).xm mn([19]).xm],[mn([2]).ym mn([19]).ym],'g--')
plot([mn([16]).xm mn([17]).xm],[ mn([16]).ym mn([17]).ym],'g--')

% plot bricks
plot( [[mn(20:23).xm] mn(20).xm],[[mn(20:23).ym] mn(20).ym],'-r')
plot( [[mn(24:27).xm] mn(24).xm],[[mn(24:27).ym] mn(24).ym],'-r')

plot( [mn(28:35).xm],[mn(28:35).ym],'g.')
if targ_no > 1
plot([mn(36:41).xm], [mn(36:41).ym],'r*')
plot([mn(38:39).xm], [mn(38:39).ym],'r-')
plot([mn(40:41).xm], [mn(40:41).ym],'r-')

%draw single long wave sheet in dead zone
if targ_no >= 3
plot([mn(42:44).xm], [mn(42:44).ym],'g')
if targ_no > 4
%draw outer btick line at dead zone
plot([mn(45:46).xm], [mn(45:46).ym],'co')
plot([mn(45:46).xm], [mn(45:46).ym],'c')
plot([mn(47:54).xm], [mn(47:54).ym],'c.')
end
end
end
% text
if(0)
   yval = 2.2;
   ts = sprintf('Tripod oriented to %s with az = %5.1f',...
      p(jref).ln,ref_az);
   text(-2.4,yval,sprintf('Tripod oriented to %s with az = %5.1f',...
      p(jref).ln,ref_az));
   for iv=[4:7],
      yval = yval-.2;
      azcorr = p(iv).az;
      if azcorr >= 360, azcorr=azcorr-360; end
      if azcorr < 0, azcorr=azcorr+360; end
      text(-2.4,yval,sprintf('%s, az = %5.1f',p(iv).ln,azcorr));
   end
end

axis square
axis([-5 5 -5 5])
yt=get(gca,'ytick');
set(gca, 'xtick',yt)
title(['UNH Test Tank - arrangement ' num2str(target)])

%% list directions from legs to instruments
if(0)
   for inst=1:4,
      leglist = (1:3);
      for ileg = 1:3,
         xd = p(inst).xm - p(leglist(ileg)).xm;
         yd = p(inst).ym - p(leglist(ileg)).ym;
         [rg,br]=pcoord(xd,yd);
         fprintf(1,'From %s to %s: %4.1f, %4.0f\n',...
            p(leglist(ileg)).ln,p(inst).ln,rg,br)
      end
      fprintf(1,'\n')
   end
end
hold off
