function M=sfanmovie(fname,wname,outfile_avi)
% SFANMOVIE: Create a simple fan beam movie
% Usage: sfanmovie(fname,wname)
%    Inputs: fname = fanbeam netcdf file
%            wname = wave netcdf file
%            outfile_avi = name of output avi file 
% Example:
% fname='c:\rps\mvco\8369fan0411_hrproc.cdf';
% wname='c:\rps\mvco\8361whp-cal.nc';
% fanmovie(fname,wname,'my_movie.avi')
%
% The output file is written with 'compression'='none' so that the images
% and text are lossless.
%
% Matlab does not support the RLE Codec that is appropriate for this
% movie, so we convert the uncompressed avi using a 3rd party program
% like Videomach.

 waves = 1;
 fcnt=1; wv_rec=1;
 %open the processed fan file
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
 
% getting the wave height from the adcp wave data is hardwired as ON         
if waves,
   % load the waves during the desired time
   ncw = netcdf(wname);
   julian_wave = ncw{'time'}(:) + ncw{'time2'}(:)/3600/1000/24;
   datenum_wave = datenum(gregorian(julian_wave));
  
   % now get the data, 
   ncvarnames = {'wh_4061','wp_4060','wvdir'};
   names = {'Hsig','Tm','wvdir'};
   for n = 1:length(ncvarnames);
     eval([names{n},' = ncw{''' ncvarnames{n} '''}(:);']) 
   end
    close(ncw);
   clear ncw 
end

  p=size(ncf{'sonar_image'});
 
 % special purpose to do 6 days following 9/13 (sample 132-181)
 % that were written into elements 1-50 of the _hrproc file
   for ik=1:p(1)
     datenum_sonar = datenum_fan(ik);
     axes(sonar_ax);
     sonar_image=ncf{'sonar_image'}(ik,1,:,:);
     imagesc(xx,yy,sonar_image,'CDataMapping','scaled');
%      hold on
    set(gca,'ydir','Normal'); colormap gray;
    axis square
  yl=ylabel('Sonar Range (m)');
  set(yl,'fontsize',14)
  tt=text(0.8,0.955,'\uparrow North',...
   'units','normalized','color','k','fontsize',14);
  %set(tt,'fontsize',14)
 % ts = datestr(datenum_fan(ik));
    ts=datestr(datenum_fan(ik),'dd-mmm-yy HH:MM');
    tt=text(.99,0.03,ts,...
     'units','normalized','color','k','horizontalalignment','right','fontsize',12);
%   hold off
 % now do the time axis that should have waves stuff but doesn't yet
            axes(wave_ax);  %make the wave axis current
            if ik > 1
                delete(wave_dot)
            end
            beg_fan=find(datenum_wave <= floor(datenum_fan(1)),1,'last');
            end_fan=find(datenum_wave >= ceil(datenum_fan(end)),1,'first');
            hpp=plot(datenum_wave(beg_fan:end_fan),Hsig(beg_fan:end_fan)); 
              hold on;
            set(hpp,'linewidth',2);
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
                wave_dot = plot(datenum_wave(waveidx),Hsig(waveidx),'ro','markersize',8,'MarkerFaceColor','r');
                 wv_rec=wv_rec+1;
            end
                  set (wave_ax,'FontSize',14);
                 yl=ylabel({'Significant','Wave','Height (m)'});
                 set(yl,'fontsize',14)
                 set(yl,'units','normalized')
                 set(yl,'position',[-.07 .49 0])
                 set(wave_ax,'xlim',[datenum_wave(beg_fan) datenum_wave(end_fan)])
                 % datetick('x',1,'keeplimits')
                 set(wave_ax,'Ylim',[0 2.0])
                 set(wave_ax,'xticklabel',[])
                 xt = get(wave_ax,'xtick');
                 for t = [1:2:length(xt)-1]
%                   label = strvcat([datestr(xt(t),7),'-',datestr(xt(t),3),'-',datestr(xt(t),10)]);
                    label = datestr(xt(t),'dd-mmm-yyyy');
                    text(xt(t),-0.8,label,'horizontalalignment','center','fontsize',12)
                 end
  hold off
 
 % stuff it into the movie matrix
  % be careful that no other windows get on top of the matlab figure window
  % because it will show up in the movie- this includes locking the screen
  h=gcf;
  M(fcnt)=getframe(h);    % add the gcf to get the entire window
 fcnt=fcnt+1;
 end

   disp([num2str(fcnt-1) ' frames written'])
  close(ncf)
 % now do the movie stuff
    % eval(['save ' outRoot '_movie M']);
    movie2avi(M,outfile_avi,'compression','none')     % this works for sure
    %eval(['movie2avi(M, ''' outRoot '_frames.avi'')'])  % this may not
