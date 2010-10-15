function M=sfanmv_unh_2sweep(fname,wname,outfile_avi)
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

 waves = 0;
 fcnt=1; wv_rec=1;
 %open the processed fan file
 ncf=netcdf(fname);
 
 timeobj = ncf{'time'};
 time2obj = ncf{'time2'};
  tj=timeobj(:)+time2obj(:)./(3600*1000*24);
  datenum_fan=datenum(gregorian(tj));
 if nargin==3,
    isonar=1:length(datenum_fan);
else
    isonar=find(datenum_fan>=datenum(start) & datenum_fan<=datenum(stop));
end
% get the x and y axis values
  xx=ncf{'x'}(:);
  yy=ncf{'y'}(:);
      clf
 
  % get the axes organized 
       set(gcf,'Position',[100 50 800 660])
       sonar_ax=axes('pos',[0.16 0.22 0.75 0.75]);  axis square
 
% getting the wave height from the adcp wave data is hardwired as ON         
if waves,
   wave_ax=axes('pos',[0.228 0.065 0.62 0.11]);
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
for i=1:length(isonar)
    for jj=1:2      % put both sweeps in
        ik=isonar(i);
        datenum_sonar = datenum_fan(ik);
        axes(sonar_ax);
        sonar_image=ncf{'sonar_image'}(ik,jj,:,:);
        %himage=pcolor(xx,-yy,sonar_image,'CDataMapping','scaled');
        locs=find(sonar_image < 0);
        sonar_image(locs)=NaN;
        himage=imagesc(xx,yy,sonar_image); shading flat;
        set(gca,'tickdir','out');
        %set(gca,'xticklabel',' ');
        xlabel('Distance (m)')
        set(gca,'ydir','Normal');
        colormap copper;
        axis square
        colorbar
        set(gcf,'color','white');
        yl=ylabel('Sonar Range (m)');
        set(yl,'fontsize',14)
        %fc855rot is specific to tripod 855- need to make an equivalent to use
        %with other tripods, second argument is whether to add azimuth lines
        % currently asks which figure to put stuff on every frame, so best not
        % to use in Movie makeing
        % fc855rot(-magvar+10,'n');
        tt=text(0.85,0.965,'\uparrow North',...
            'units','normalized','color','k','fontsize',14);
        ts=datestr(datenum_fan(ik),'dd-mmm-yy HH:MM');
        tt=text(.99,0.93,ts,...
            'units','normalized','color','k',...
            'horizontalalignment','right','fontsize',12);
        title('UNH tank- Dec. 2009 fan sonar images')
    if waves
        axes(wave_ax);  %make the wave axis current
        hpp=plot(buoydat,wvht,'k');
        hold on;
        set(hpp,'linewidth',2);
        hsigw=interp1(datenum_wave,Hsig,datenum_fan(ik));
        wave_dot = plot(datenum_fan(ik),hsigw,'ro',...
            'markersize',8,'MarkerFaceColor','r');
        hold off
        set (wave_ax,'FontSize',14);
        yl=ylabel({'Significant','Wave','Height (m)'});
        set(yl,'fontsize',14)
        set(yl,'units','normalized')
        set(yl,'position',[-.07 .49 0])
        set(wave_ax,'xlim',[datenum_wave(1) datenum_wave(end)])
        set(wave_ax,'Ylim',[0 5.0])
        set(wave_ax,'xticklabel',[])
        xt = get(wave_ax,'xtick');
        grid
        for t = [1:1:length(xt)]
            label = datestr(xt(t),'mm/dd');
            text(xt(t),-0.7,label,...
                'horizontalalignment','center','fontsize',12)
        end
    end

 % stuff it into the movie matrix
  % be careful that no other windows get on top of the matlab figure window
  % because it will show up in the movie- this includes locking the screen
  h=gcf;
  M(fcnt)=getframe(h);    % add the gcf to get the entire window
 fcnt=fcnt+1;
 end
end
   disp([num2str(fcnt-1) ' frames written'])
  close(ncf)
 % now do the movie stuff
    % eval(['save ' outRoot '_movie M']);
    movie2avi(M,outfile_avi,'compression','none')     % this works for sure
    %eval(['movie2avi(M, ''' outRoot '_frames.avi'')'])  % this may not
