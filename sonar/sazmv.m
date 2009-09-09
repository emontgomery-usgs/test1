function M=sazmv(dname,wname,outfile_avi,start,stop)
% SAZMV: Create a simple movie of azimuth images created by plotrange_dcf
% Usage: sazmv(fname,wname,outfile_avi,[start],[stop])
%    Inputs: dname = directory where azimuth sonar netcdf files are stored
%            wname = wave netcdf file
%            outfile_avi = name of output avi file
%            [start]= [yyyy mm dd HH MM SS] (default is entire record)
%            [stop] = [yyyy mm dd HH MM SS] (default is entire record)
%    Output: AVI file 'outfile_avi' written to disk
% Example:
% dname= 'Z:\data\hatteras09\855NorthMinipod\855sonar\azimuth\'
% wname='timwvht_41025_all';
% output_avi='allAz.avi';
% if you do one of the optional time constraints, you have to use both.
% [start=[2009 01 13 01 56 00];]
% [stop= [2009 03 14 14 56 00];]
%   usage: sazmv(dname,wname,output_avi)

% The output file is written with 'compression'='none' so that the images
% and text are lossless.
%
% Matlab does not support the RLE Codec that is appropriate for this
% movie, so we convert the uncompressed avi using a 3rd party program
% like Videomach.

% save cwd
wd_home=pwd;
ccol='y';  % color for date and arrow on sonar plot
waves = 1; % use waves
isweep = 1; % use sweep 1 data

clf
% set the text color
ccol='k';

% get the axes organized
set(gcf,'Position',[100 50 800 660])
sonar_ax=axes('pos',[0.16 0.22 0.73 0.73]);
axis square
wave_ax=axes('pos',[0.22 0.062 0.62 0.09]);

if waves,
    % load the waves during the desired time
    % waves file contains all of February, so have to limit by data
   load(wname);
    julian_wave = buoy_jday;
    datenum_wave = buoydat;
    iwaves=find(datenum_wave>=floor(datenum(start))& ...
        datenum_wave<=ceil(datenum(stop)));
    %temporarily replace this
    %waves=[1:1:length(wvht)];
    datenum_wave=datenum_wave(iwaves);
    Hsig=wvht(iwaves);
end
%
    fcnt=1;   % initialize frame count
    %set up the parameters for plotrange_cdf
    autonan_on
    seta.Pencil_tilt=0;
    seta.rot2compass=20;
    seta.plottype='3d_frm_img';
    seta.dxy=.02;
% azimuth data is one file per day, so you have to work with multiple files
eval(['cd ' dname])
dlist=dir('az*_raw.cdf');
fnLen=length(dlist);

% treat each file
for jj=1:fnLen
    fname=dlist(jj).name;
    ncf=netcdf(fname);
    timeobj = ncf{'time'};
    time2obj = ncf{'time2'};
    tj=timeobj(:)+time2obj(:)./(3600*1000*24);
    datenum_az=datenum(gregorian(tj));
    if nargin==3,
        isonar=1:length(datenum_az);
    else
        % select all within an hour of start & stop
        isonar=find(datenum_az>=datenum(start)-60*60/86400 & datenum_az<=datenum(stop)+60*60/86400);
    end
    close(ncf)  % plotrange_cdf does it's own opening and closeing

% loop through the images in the file
    for i=1:length(isonar)
        ik=isonar(i);
        datenum_sonar = datenum_az(ik);
        axes(sonar_ax);
        plotrange_cdf(fname,i,seta)
        set(gca,'tickdir','out');
        %set(gca,'xticklabel',' ');
        xlabel('Distance (m)')
        % set(gca,'ydir','Rev');
        colormap jet;
        caxis ([-1.3 -.5])
        axis square
        axis([-2.5 2.5 -2.5 2.5])
        colorbar
        set(gcf,'color','white');
        yl=ylabel('Sonar Range (m)');
        set(yl,'fontsize',14)
        %tt=text(0.8,0.955,'\uparrow North',...
        %    'units','normalized','color',ccol,'fontsize',14);
        ts=datestr(datenum_az(ik),'dd-mmm-yy HH:MM');
        tt=text(.28,0.03,ts,...
            'units','normalized','color','k',...
            'horizontalalignment','right','fontsize',12); 
        tt=text(.98,0.93,'North is UP',...
            'units','normalized','color','k',...
            'horizontalalignment','right','fontsize',12);
         tt=text(1.05,-0.035,'depth (m)','units','normalized',...
             'color','k','fontsize',12);
        title('Hatteras 2009 Azimuth sonar images')
        
        axes(wave_ax);  %make the wave axis current
        hpp=plot(buoydat,wvht,'k');
        hold on;
        set(hpp,'linewidth',2);
        hsigw=interp1(datenum_wave,Hsig,datenum_az(ik));
        wave_dot = plot(datenum_az(ik),hsigw,'ro',...
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
        % stuff it into the movie matrix
        h=gcf;
        M(fcnt)=getframe(h);    % add the gcf to get the entire window
        %delete(himage);
        fcnt=fcnt+1;
    end
end

disp([num2str(fcnt-1) ' frames written'])
hold off
%
% Use no compression here so we have flexibility
% in using a greater number of AVI CODECs outside of Matlab
movie2avi(M,outfile_avi,'compression','none')

%return to initial location
eval(['cd ' wd_home])


