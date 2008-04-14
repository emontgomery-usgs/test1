function M=sfanmovie(fname,wname)
% Simple fan movie
% reads from the _proc.cdf file

waves = 1;
 fcnt=1; wv_rec=1;
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
       wave_ax=axes('pos',[0.228 0.065 0.62 0.11]);
          
if waves,
   % load the waves during the desired time
   ncw = netcdf(wname);
   julian_wave = ncw{'time'}(:) + ncw{'time2'}(:)/3600/1000/24;
   datenum_wave = datenum(gregorian(julian_wave));
  
   % now get the data, replace fill values w/ nans,
   % linearly interpolate over the nans, remove leftover
   % nans at beginning and end of the timeseries
   ncvarnames = {'wh_4061','wp_4060','wvdir'};
   names = {'Hsig','Tm','wvdir'};
   for n = 1:length(ncvarnames);
     eval([names{n},' = ncw{''' ncvarnames{n} '''}(:);']) 
   end
    close(ncw);
   clear ncw 
end

  p=size(ncf{'sonar_image'});
 %for ik=1:p(1)
 % special purpose to do 6 days following 9/13 (sample 132
   for ik=1:p(1)
     datenum_sonar = datenum_fan(ik);
     axes(sonar_ax);
     imagesc(xx,yy,ncf{'sonar_image'}(ik,1,:,:),'CDataMapping','scaled');
      hold on
    set(gca,'ydir','Normal'); colormap gray;
    axis square
  yl=ylabel('Sonar Range (meters)');
  set(yl,'fontsize',14)
  tt=text(0.8,0.955,'\uparrow North',...
   'units','normalized','color','y','fontsize',14);
  %set(tt,'fontsize',14)
  ts = datestr(datenum_fan(ik));
    tt=text(0.99,0.03,ts,...
     'units','normalized','color','y','horizontalalignment','right','fontsize',12);
 
 % now do the time axis that should have waves stuff but doesn't yet
            axes(wave_ax);  %make the wave axis current
            if ik > 1
                delete(wave_dot)
            end
            beg_fan=find(datenum_wave <= floor(datenum_fan(1)),1,'last');
            end_fan=find(datenum_wave >= ceil(datenum_fan(end)),1,'first');
            plot(datenum_wave(beg_fan:end_fan),Hsig(beg_fan:end_fan)); hold on;
               waveidx1 = find(datenum_wave <= datenum_sonar);
               waveidx2 = find(datenum_wave >= datenum_sonar);
               if ~isempty(waveidx1) && ~isempty(waveidx2)
                  if abs(datenum_sonar-datenum_wave(waveidx1(end))) < abs(datenum_wave(waveidx2(1))-datenum_sonar)
                     waveidx = waveidx1(end);
                  else
                     waveidx = waveidx2(1);
                  end
               end
        
            if ~isempty(waveidx1) && ~isempty(waveidx2) 
                wave_dot = plot(datenum_wave(waveidx),Hsig(waveidx),'ro','markersize',4,'MarkerFaceColor','r');
                 wv_rec=wv_rec+1;
            end
                  set (wave_ax,'FontSize',14);
                 yl=ylabel({'Significant','wave','height (m)'});
                 set(yl,'fontsize',14)
                 set(yl,'units','normalized')
                 set(yl,'position',[-.07 .49 0])
                 set(wave_ax,'xlim',[datenum_wave(beg_fan) datenum_wave(end_fan)])
                 % datetick('x',1,'keeplimits')
                 set(wave_ax,'Ylim',[0 2.0])
                 set(wave_ax,'xticklabel',[])
                 xt = get(wave_ax,'xtick');
                 for t = [1 3 5 length(xt)-1]
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
