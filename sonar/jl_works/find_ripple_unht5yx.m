function [LAM,THETA,PPP, Xmm, Ymm]=find_ripple_unht5yx(fname,time_ind)
% FIND_RIPPLE_unh_tank uses 2D FFT to estimate wavelength and direction of 
%  ripples from the USGS _proc sonar image.
%  This version optimized for two wavelengths (different sized of corrugated 
%  metal sheets) in the 1st taget arrangement at UNH. 
%
% em 1/20/09
%
% usage : [LAM,THETA,PPP, Xm, Ym]=find_ripple_unht5yx('unhfan1209a-target_proc.cdf',1)
% Inputs
%         fname: filename of cdf file with processed fan data
%         (optional) time_ind  : (default if not given = all times) - use
%         the sequence number for time, not the values in time & time2
% Outputs
%         LAM   : Wave length of ripple (in m)
%         THETA : Angle of ripple crest-line from North
%         PPP   : Spectral Power value
%         Xm   : Xm matrix of boxes Spectra frequency X
%         Ym   : Ym matrix oboxes Spectra frequency Y
%    these are dimensioned ntimes x nboxes, where the column index corresponds to
%    the box number. For unh, 3 boxs were specified based on the x,y position 
%    of pattern center, using time_ind=1 produces variables (1,2)
%
%  Removed Jordan's averaging code since we've got two distinctly different
%  patterns at different orientations- no assumed field consistency.
%
% If you want to visually see the results set variable plotme to 1.
%
% uses ndetrend.m, spectrum2d.m find_good_squares.m
%
% Jordan Landers based on G. Voulgaris, April 27, 2007
%  Changed April 30, 2007
% Modifed by T. Nelson, September 6, 2007
%
% -----  USER DEFINED PARAMETERS FOR ANALYSIS   ----
plotme=1;
%plotme=1;  % set to 1 to see plots and 0, if not
%                be set to avoid an infinite loop.
Rsq=5;         % Image range (m)
z = 0.31;      % Sonar head height above bed (m)
dx=0.01;       % x resolution of interpolated image
dy=0.01;       % y resolution of interpolated image
m=128;          % points of fft transform in the x direction
n=128;          % points of fft transform in the y direction
Squares=3;     % No of sub-sampled domains to be analyzed
Sm = .5*max(m*dx,n*dy); % Side of each sub-domain (Square) in meters
%
WLim=3.0;         % Max Wave number limit (avoids the highs around the DC level)l(['load ',fname])
%
warning off all

% deal with lack of inputs or arguments
miss_rng=0;
if nargin ==0
    help fmilename; return;
elseif nargin < 2
    miss_rng=1;
end

% this program does all 8 boxes and does no elimination at this step
% Open the file
proc=netcdf(fname);

% default is to treat all images
if miss_rng
    time_ind=[1:1:length(proc{'time'}(:))];
end
%total=length([time_ind(1):1:time_ind(end)]);
total=length(time_ind);
LAM=NaN(total,Squares);
THETA=NaN(total,Squares);
PPP=NaN(total,Squares);
Xm=NaN(total,Squares);
Ym=NaN(total,Squares);

% read the sonar_image into a matrix- use squeeze to get 2-d instead of 4
for ia=1:length(time_ind)
    Z=squeeze(proc{'sonar_image'}(time_ind(ia),1,:,:));
    % sonar_image is defined as (time, sweep, y,x), So references to x and
    % y are in axis space (x is horizontal, y is vertical), but Z is y,x,
    % so when getting the box contents reverse the indices.
    
    % this part is customized for UNH tank arrangement 1
        Yc=[1.5 1.0 2.9];        % these are the center points of two boxes
        Xc=[3.1 -0.8 -1.6];
%  alternate boxes over brighter part of the longer wavelength target- 
%  none of these seems to get the correct wavelength and angle
%     Yc=[2.2 2.4 2.6]; Xc=[3.2 3.4 3.6];
    for k=1:3
        % XX and YY are lower left and top right of a box
         XX(k,1:2)=[Xc(k)-2*Sm/2 Xc(k)+2*Sm/2];
         YY(k,1:2)=[Yc(k)-2*Sm/2 Yc(k)+2*Sm/2];
    end
      % verify that we've got what we think,and that the boxes cover the
      % targets centeres on the two kinds of sheet metal
       figure  % this part overlays OK, whether pcolor or imagesc is used
       pcolor(proc{'x'}(:), proc{'y'}(:),Z); shading flat
       hold on
        % this makes a simple plot of the boxes 
        plot([Xc(3)-.6 Xc(3)-.6 Xc(3)+.6 Xc(3)+.6 Xc(3)-.6],[Yc(3)-.6 Yc(3)+.6 Yc(3)+.6 Yc(3)-.6 Yc(3)-.6],'k')
        plot([Xc(2)-.6 Xc(2)-.6 Xc(2)+.6 Xc(2)+.6 Xc(2)-.6],[Yc(2)-.6 Yc(2)+.6 Yc(2)+.6 Yc(2)-.6 Yc(2)-.6],'k')
        plot([Xc(1)-.6 Xc(1)-.6 Xc(1)+.6 Xc(1)+.6 Xc(1)-.6],[Yc(1)-.6 Yc(1)+.6 Yc(1)+.6 Yc(1)-.6 Yc(1)-.6],'k')
      plot(XX,YY, 'k*')
       
    %now here's where the boxes get overlaid on the data
    io=1;     PXY=zeros(m,n);
    while io<Squares+1
        % the contents of proc{'x'} and proc{'y'} are vectors & are equal
        [indx]=find( (proc{'x'}(:)>=XX(io,1) & proc{'x'}(:)<=XX(io,2)) );
        [indy]=find( (proc{'y'}(:)>=YY(io,1) & proc{'y'}(:)<=YY(io,2)) );
        % because the image is defined as time, sweep, y, x, the image must
        % be indexed using (y,x) instead of (x,y).
        % this works even though it looks  backwards, shape and orientation are OK
        ZI=Z(indy, indx);
         if plotme
            figure
             pcolor(proc{'x'}(indx),proc{'y'}(indy),ZI); shading flat
            title(['box ' num2str(io)])
        end
        %run anaylysis analysis script on the current box
        [kx,ky,Pxy]=spectrum2d(ZI,m,n,dx,dy);
        % stuff the result into an array
        Pxy_array(io,:,:)=Pxy;
        gkx=repmat(kx,128,1);
        gky=repmat(ky,128,1)';
        [Xm,Ym,Zm]=max2d(gkx,gky,squeeze(Pxy_array(io,:,:)),0);
        % need to repeat for the individual boxes
        KXX=Xm; KYY=Ym;
        % save the evidence so LAM and THETA may be recomputed
        Xmm(ia,io)=Xm;
        Ymm(ia,io)=Ym;
        LAM(ia,io)=2.*pi./sqrt(KXX.^2+KYY.^2);

        % here you'd normally want x/y, but because of the image indexing,
        % we use y/x for the tangent computation.
        Angle=atand(abs(KYY/KXX));
        % then we want the perpendicular to the direction of the ripple
        % alignment
        if(KXX>=0) && (KYY>0)
            Angle=90-Angle;
        elseif(KXX<0) && (KYY>0)
            Angle=90+Angle;
        elseif(KXX>0) && (KYY<0)
            Angle=90-Angle;
        elseif(KXX<0) && (KYY<0)
            % do nothing- this is perpendicular to the ridges already
        end
        
        THETA(ia,io)=Angle;
        PPP(ia,io)=Zm;
 
        io=io+1;
    end
       PXY=zeros(m,n);  % zero out the accumulation variable
        clear mean_PXY
    %close all
end
close(proc)
warning on all


