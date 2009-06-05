function M=sfanmv(fname,wname,outfile_avi,start,stop)
% SFANMOVIE: Create a simple fan beam movie
% Usage: sfanmovie(fname,wname,outfile_avi,[start],[stop])
%    Inputs: fname = fanbeam sonar netcdf file
%            wname = wave netcdf file
%            outfile_avi = name of output avi file
%            [start]= [yyyy mm dd HH MM SS] (default is entire record)
%            [stop] = [yyyy mm dd HH MM SS] (default is entire record)
%    Output: AVI file 'outfile_avi' written to disk
% Example:
% cwd is C:\home\data\processing\Hatteras09\855NorthMinipod\855sonar\
% fname='midfeb_855_proc.cdf';
% wname='timwvht_41025';
% output_avi='cccp_midfeb.avi';
% sfanmv(fname,wname,output_avi,[2009 2 7 4 56 0],[2009 2 28 0 56 0])

% The output file is written with 'compression'='none' so that the images
% and text are lossless.
%
% Matlab does not support the RLE Codec that is appropriate for this
% movie, so we convert the uncompressed avi using a 3rd party program
% like Videomach.

ccol='w';  % color for date and arrow on sonar plot
waves = 1; % use waves
isweep = 1; % use sweep 1 data


%open the sonar file
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

% set the text color
ccol='k';

% get the axes organized
set(gcf,'Position',[100 50 800 660])
sonar_ax=axes('pos',[0.16 0.22 0.75 0.75]);
axis square
wave_ax=axes('pos',[0.228 0.065 0.62 0.11]);


if waves,
    % load the waves during the desired time
   load(wname);
    julian_wave = buoy_jday;
    datenum_wave = buoydat;
    iwaves=find(datenum_wave>=datenum_fan(isonar(1))& ...
        datenum_wave<=datenum_fan(isonar(end)));
    datenum_wave=datenum_wave(iwaves);
    Hsig=wvht(iwaves);
end

fcnt=1;   % initialize frame count
p=size(ncf{'sonar_image'});
for i=1:length(isonar)
    ik=isonar(i);
    datenum_sonar = datenum_fan(ik);
    axes(sonar_ax);
    sonar_image=ncf{'sonar_image'}(ik,isweep,:,:);
    himage=imagesc(xx,yy,sonar_image,'CDataMapping','scaled');
    set(gca,'tickdir','out');
    set(gca,'xticklabel',' ');
    set(gca,'ydir','Normal');
    colormap gray;
    axis square
    set(gcf,'color','white');
    yl=ylabel('Sonar Range (m)');
    set(yl,'fontsize',14)
    %tt=text(0.8,0.955,'\uparrow North',...
    %    'units','normalized','color',ccol,'fontsize',14);
    ts=datestr(datenum_fan(ik),'dd-mmm-yy HH:MM');
    tt=text(.99,0.03,ts,...
        'units','normalized','color',ccol,...
        'horizontalalignment','right','fontsize',12);

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
    % stuff it into the movie matrix
    h=gcf;
    M(fcnt)=getframe(h);    % add the gcf to get the entire window
    delete(himage);
    fcnt=fcnt+1;
end

disp([num2str(fcnt-1) ' frames written'])
close(ncf)
%
% Use no compression here so we have flexibility
% in using a greater number of AVI CODECs outside of Matlab
movie2avi(M,outfile_avi,'compression','none')


