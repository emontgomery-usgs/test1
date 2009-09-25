function ht_plt_mvco

load('ht_evol_mv')
subplot(2,1,1)
 plot(dt_mvco, -ht_mvco/100)
 axis([dt_mvco(1) dt_mvco(end) -.93 -.83])
 xt = get(gca,'xtick');
 set(gca,'xticklabel',[])
for t = [1:1:length(xt)]
label(t,:) = datestr(xt(t),'mm/dd');
end
set(gca,'xticklabel',label)
%xlabel('date in 2007')
ylabel('distance to seafloor (m)')
title('MVCO\_07 tripod 836, seafloor height from azimuth sonar and waves')
grid
%
ncw=netcdf('8361whp-cal.nc');
wvht=ncw{'wh_4061'}(:);
wvdir_adj=ncw{'wvdir'}(:);
%wvdir_adj(loc)=wvdir_adj(loc)-360;
tt=ncw{'time'}(:)+(ncw{'time2'}(:)./86400000);
close(ncw);
stop_idx=find(tt > dt_mvco(end),1,'first');
start_idx=find(tt >= dt_mvco(1),1,'first');
subplot(4,1,3)
plot(tt(start_idx:stop_idx),wvht(start_idx:stop_idx))
axis([dt_mvco(1) dt_mvco(end) 0 2])
grid
set(gca,'xticklabel',label)
ylabel('wave height (m)')
%
subplot(4,1,4)

plot(tt(start_idx:stop_idx),wvdir_adj(start_idx:stop_idx))
axis([dt_mvco(1) dt_mvco(end) 0 300])
set(gca,'xticklabel',label)
ylabel('wave direction (degrees)')
 xlabel('date in 2009')
 grid
 