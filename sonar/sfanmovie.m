function M=sfanmovie(fname)
% Simple fan movie
% reads from the _proc.cdf file

 fcnt=1;
 %open the file
 ncf=netcdf(fname);
 timeobj = ncf{'time'};
 time2obj = ncf{'time2'};
  tj=timeobj(:)+time2obj(:)./(3600*1000*24);
  datenum_fan=datenum(gregorian(tj));
 % get the x and y axis values
  xx=ncf{'x'}(:);
  yy=ncf{'y'}(:);
      clf
 
  % get the axes organized 
       set(gcf,'Position',[100 50 800 660])
       sonar_ax=axes('pos',[0.16 0.22 0.75 0.75]);  axis square
       wave_ax=axes('pos',[0.228 0.055 0.62 0.11]);
 

  p=size(ncf{'sonar_image'});
 for ik=1:p(1)
     datenum_sonar = datenum_fan(ik);
     axes(sonar_ax);
     imagesc(xx,yy,ncf{'sonar_image'}(ik,1,:,:),'CDataMapping','scaled');
      hold on
    set(gca,'ydir','Normal'); colormap gray;
    axis square
  yl=ylabel('Fan Beam Sonar, range in meters');
  set(yl,'fontsize',14)
  tt=text(0.8,0.955,'\uparrow North',...
   'units','normalized','color','y','fontsize',14);
  %set(tt,'fontsize',14)
  ts = datestr(datenum_fan(ik));
    tt=text(0.99,0.03,ts,...
     'units','normalized','color','y','horizontalalignment','right','fontsize',12);
 
 % now do the time axis that should have waves stuff but doesn't yet
            axes(wave_ax);  %make the wave axis current
              plot(datenum_fan,ones(length(datenum_fan),1))
               hold on;
                  dot = plot(datenum_fan(ik),1,'ro','markersize',4,'MarkerFaceColor','r');
                  set (wave_ax,'FontSize',14);
                 yl=ylabel('time');
                 set(yl,'fontsize',14)
                 set(yl,'units','normalized')
                 set(yl,'position',[-.07 .49 0])
                 set(wave_ax,'xlim',[datenum(ncf.FirstSonarDay(:)) datenum(ncf.LastSonarDay(:))+1])
                 % datetick('x',1,'keeplimits')
                 set(wave_ax,'Ylim',[0 2.0])
                 set(wave_ax,'xticklabel',[])
                 xt = get(wave_ax,'xtick');
                 for t = [1 3 5 length(xt)]
                     label = strvcat([datestr(xt(t),7),'-',datestr(xt(t),3),'-',datestr(xt(t),10)]);
                     text(xt(t),-0.8,label,'horizontalalignment','center','fontsize',12)
                 end

  % stuff it into the movie matrix
  h=gcf;
  M(fcnt)=getframe(h);    % add the gcf to get the entire window
 fcnt=fcnt+1;
 end

   disp([num2str(fcnt-1) ' frames written'])
  close(ncf)
 % now do the movie stuff
    % eval(['save ' outRoot '_movie M']);
    movie2avi(M, 'tmp_run0404.avi')     % this works for sure
    %eval(['movie2avi(M, ''' outRoot '_frames.avi'')'])  % this may not
