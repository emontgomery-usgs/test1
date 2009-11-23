function M=famv855_2sweep(fname,wname,outfile_avi,start,stop)
% FANMV855_2sweep: Create a fan beam movie, with tripod items overlaid
% Usage: fanmv855_overlay(fname,wname,outfile_avi,[start],[stop])
%    Inputs: fname = fanbeam sonar netcdf file
%            wname = wave file (.mat from buoy data)
%            outfile_avi = name of output avi file
%            [start]= [yyyy mm dd HH MM SS] (default is entire record)
%            [stop] = [yyyy mm dd HH MM SS] (default is entire record)
%    Output: AVI file 'outfile_avi' written to disk
% Example:
% cwd is C:\home\data\processing\Hatteras09\855NorthMinipod\855sonar\
% fname='8558fan_proc.cdf';
% wname='timwvht_41025';
% output_avi='cccp_fan.avi';
% fanmv855_overlay(fname,wname,output_avi,[2009 2 7 4 56 0],[2009 2 28 0 56 0])

% The output file is written with 'compression'='none' so that the images
% and text are lossless.
%
% Matlab does not support the RLE Codec that is appropriate for this
% movie, so we convert the uncompressed avi using a 3rd party program
% like Videomach.

ccol='y';  % color for date and arrow on sonar plot
waves = 0; % use waves

%open the sonar file
ncf=netcdf(fname);

magvar=str2double(ncf.magnetic_variation(:));

timeobj = ncf{'time'};
time2obj = ncf{'time2'};
tj=timeobj(:)+time2obj(:)./(3600*1000*24);
datenum_pen=datenum(gregorian(tj));
if nargin==3,
    isonar=1:length(datenum_pen);
else
    isonar=find(datenum_pen>=datenum(start) & datenum_pen<=datenum(stop));
end
% get the x and y axis values
xx=ncf{'x'}(:);
yy=ncf{'y'}(:);
clf

% set the text color
ccol='k';

% get the axes organized
set(gcf,'Position',[100 50 800 660])
sonar_ax=axes('pos',[0.16 0.22 0.73 0.73]);
axis square

if waves,
    wave_ax=axes('pos',[0.22 0.062 0.62 0.09]);
    % load the waves during the desired time
    % waves file contains all of February, so have to limit by data
    load(wname);
    julian_wave = buoy_jday;
    datenum_wave = buoydat;
    iwaves=find(datenum_wave>=floor(datenum_pen(isonar(1)))& ...
        datenum_wave<=ceil(datenum_pen(isonar(end))));
    datenum_wave=datenum_wave(iwaves);
    Hsig=wvht(iwaves);
end

fcnt=1;   % initialize frame count
p=size(ncf{'sonar_image'});
for i=1:length(isonar)
    for jj=1:2      % put both sweeps in
        ik=isonar(i);
        datenum_sonar = datenum_pen(ik);
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
        ts=datestr(datenum_pen(ik),'dd-mmm-yy HH:MM');
        tt=text(.99,0.93,ts,...
            'units','normalized','color','k',...
            'horizontalalignment','right','fontsize',12);
        title('Hatteras 2009 fan sonar images')
    end
    if waves
        axes(wave_ax);  %make the wave axis current
        hpp=plot(buoydat,wvht,'k');
        hold on;
        set(hpp,'linewidth',2);
        hsigw=interp1(datenum_wave,Hsig,datenum_pen(ik));
        wave_dot = plot(datenum_pen(ik),hsigw,'ro',...
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
    h=gcf;
    M(fcnt)=getframe(h);    % add the gcf to get the entire window
    delete(himage);
    fcnt=fcnt+1;
end

disp([num2str(fcnt-1) ' frames written'])
close(ncf)
hold off
%
% Use no compression here so we have flexibility
% in using a greater number of AVI CODECs outside of Matlab
movie2avi(M,outfile_avi,'compression','none')


