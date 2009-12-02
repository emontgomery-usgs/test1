function [Xplot, Yplot, thi, ri, Zs] = procfan08(ncr, plottype, settings);
% PROCFAN08 - Plot Imagenex imaging sonar data
%  called by do_fan_rots.m - follows execution of mk_rawcdf_08
% [x,y,thi, ri, zs] = procfan08(nc, plottype, settings)
%
% older version- use procfan instead!
%
% reads netcdf file created by mk_rawcdf
% nc{'imagedata'}(time,points,scan) image data with header removed
% nc{'head_pos'}(time,scan) head position in counts
% nc{'headangle'}(scan) head rotation angle in degrees
% nc{'profile_range'}(time,scan) Imagenex computed range to surface
% nc{'nDataBytes'}(scan) = number of byte in the ping
% nc.HeadType. = IGX/IMX etc.
% nc.HeadID. = ID number
% nc.Range = range setting
% nc.NReturnBytes = number of bytes in the ping + header
% nc.DegPerStep = from FanSwitches.StepSize;
% nc.SectorWidth = from FanSwitches.SectorWidth;
% plottype = 'square' | 'polar' | 'prange'
% still need to pass 'settings' to get these params: 
%    instrument installed height,
%    adcp compass value, 
%    declination
%   these should come from the metafile
%
% outputs:
% Single matrices of Xplot and Yplot interpolated into 
% Single matrices of thi and rho, after rotation
% zs holds the interpolated images, size is {ntimes x nsweeps}
%
%  emontgomery@usgs.gov
%  April 2, 2008

tmp = size(ncr{'raw_image'});
ntimes=tmp(1); NPoints=tmp(2); nscans=tmp(3);
% instead of using user supplied settings,  use what's read in the header
% fanbeam sometimes returns .6 for StepSize: we know it should be .15, thus the /4

% replace ncr.fanadcp_off if there's a settings value to use
  if settings.fanadcp_off
    rval=settings.fanadcp_off;
  else
    rval=ncr.fanadcp_off(:);
  end
% loop through each time step
for ik=1:ntimes
% trim the redundant first and last ping
  imagedata = ncr{'raw_image'}(ik,:,2:nscans-1);
%  headangle=HeaderData(:).HeadAngle(2:nscans-1);
  prange = ncr{'profile_range'}(ik,2:nscans-1);
  headangle=ncr{'headangle'}(2:nscans-1);
  mnStepSize=mean(diff(headangle(10:20)));
  [npoints,nangles] = size(imagedata);  % necessary to 
   slantrange = ncr.Range(:)/NPoints:(ncr.Range(:)/NPoints): ncr.Range(:);

sectorswept = 1:mnStepSize:ncr.SectorWidth(:)+(mnStepSize)+1;
sectorswept = sectorswept(2:length(sectorswept)-1);
% trim range to real area of data
nearfieldcutoff = 52;
farfieldcutoff = NPoints;
imagedata = imagedata(nearfieldcutoff:farfieldcutoff,:);
slantrange = slantrange(nearfieldcutoff:farfieldcutoff);

% other calculations
%horizrange = slantrange.*acos(asin((settings.Height./slantrange)));
%horizrange = settings.Height.*cos(asin(slantrange./settings.Height));
horizrange = real((slantrange.^2 - ncr.Height^2).^(1/2));

%etm fix 3/27/07
%   ** simply flipping the image puts the tray on the correct side.
%    imagedata=flipud(imagedata);
% but making [ripad and thipad] from positive to negative does the same
% thing. I guess it depends on what sweep direction we believe happened

n=0;
for kk=1:ncr.sweep(:)
    if ncr.sweep(:) > 1
      imdata=imagedata(:,n+1:(length(sectorswept)*kk)+(kk));
      ha=headangle(n+1:(length(sectorswept)*kk)+(kk));
    else
      imdata=imagedata;
      ha=headangle;
    end    
    % have to flip both because interp2 requires monotonic increasing ha
    if (mod(kk,2)==0)
        imdata=fliplr(imdata);
        %ha must be flipped to get monotonic increase for the interp
        % first sweep is always - to +, 2nd, 4th, etc are + to -
        ha=flipud(ha);
      % in back sweep ha never gets to -174.  To get sweep 1 & 2 images to
      % overlay after interp, have to decrease all by .15
      % ha=ha+1.05;   % I think there's about a 7 step lag
      ha=ha-mnStepSize;
    end
    if (ha(1)== ha(2))
       ha(1)=ha(2)-mnStepSize;
    end
    if (ha(end)== ha(end-1))
       ha(end)=ha(end)+mnStepSize;
    end

% now get the new size for plotting
[npoints,nangles] = size(imdata);

if exist('plottype') == 1,
  switch plottype
   case 'square'
    % plot linear 
    set(gcf,'name','Square')
    set(gcf,'numbertitle','off')
    clims = [0 190];
    imagesc(headangle,horizrange,imagedata',clims)
    colormap(bone);
    colorbar
    ylabel('Horizontal Range, meters')
    xlabel('Head Position, degrees')
    text(0.01,0.05,[fname,' Fan beam image taken ',...
		    datestr(datenum(gdate))],...
	 'units','normalized','color','w')
   case 'polar'
     clear thi ri Xplot Yplot Xi Yi sr fakeheadangle 

    settings.fillval = 4; % sets value of no-data region
	
    %  new way : have this program compute rot rather than have the user!!! 
    %    -90 is needed to go from math convention where 0 is horizontal +
    %    to map or geographic wher 0 is UP.
%    rot = -90 + ((settings.adcp3val-360) + settings.magnetic_variation + settings.fanadcp_off);
%    rot=0       % apply NO rotation to display raw image.
     rot= rval+ncr.magnetic_var(:);  % should be opposite sign since matlab + angle is cartisian !
%    convention is ccw is + from 0 at x
    if rot > 360; rot=rot-360; end
    if rot < -360; rot=rot+360; end
    
    Xplot = (- ncr.Range(:):ncr.dxy(:):ncr.Range(:));
    Yplot = Xplot;
    [Xi, Yi] = meshgrid(Xplot,Yplot);
    % [thi, ri]=cart2pol(Xi,Yi); 
    % with outputs cartesian coords, so don't have to fuss with math coords
    [ri, thi]=pcoord(Xi, Yi);   %  ri is -180-> 180 cw, with 0 up
            
       % convert radians to degrees, then add the rotation offset
       %thi = (thi/pi)*180;  %thi = thi*180/pi;
       thi = thi+rot;
    thi(thi>180)=thi(thi>180)-360;
    thi(thi< -180)=thi(thi< -180)+360;

    % pad ranges and angle of sweep
    % headangle(1)=-174; headangle(nangles)=161.25
    % fakeheadangle = linspace(headangle(1), headangle(nangles), ...
	%		     nangles)';
    sr = [0,slantrange(1,1)-.1,...
		  slantrange(1,:), slantrange(1,npoints)+.1, 9]';
   % pad angles to get complete circle
   % first 3 of first image are always the same
    %if kk == 1
      %xx=[ha(3):mnStepSize:ha(nangles-1)+mnStepSize];
      %hfill=[ha(3)-(2*mnStepSize) ha(3)-mnStepSize];
      fakeheadangle=[ha(1:nangles)];
    %else
    %  fakeheadangle=[ha(1):mnStepSize:ha(nangles-1)+mnStepSize];
    %end
      % pad for the dead zone area
      lopad = [-179.999 min(ha)-mnStepSize];
      hipad = [max(ha)+mnStepSize 180];
      nlo = length(lopad);
      nhi = length(hipad);
      fakeheadangle = [lopad fakeheadangle' hipad];
    
    % pad data
    Zpad = (settings.fillval)*ones(npoints+nlo+nhi,nangles+nlo+nhi);       
    %Zpad = (settings.fillval)*ones(npoints+4,nangles);       
    imdata(imdata<(1))=(settings.fillval);
   
    % kludge...last range values always seems to be 252
    imdata(449,:)=(settings.fillval);
    Zpad(nlo+1:npoints+nhi,nlo+1:nangles+nhi)=imdata;
    Zpad = log10(Zpad);
    
    % interpolate onto polar shape
    Zi = interp2(fakeheadangle,sr,Zpad, thi,ri);
%    Zi(Zi<1)=(8); % produces weird contrasty plot
    imagesc(Xplot,Yplot,Zi)
    set(gca,'ydir','normal') % because imagesc is sidedownup
    colormap gray;
    set(gca,'Fontsize',12);
    set(gca,'Xtick',[-5:1:5])
    set(gca,'Ytick',[-5:1:5])
     %   title('plotfan07 : imagesc with ydir normal')
    %figure
    %%axis equal tight
    %pcolor(Xplot,Yplot,Zi); shading flat
    %colormap gray;
    %set(gca,'Fontsize',12);
    %set(gca,'Xtick',[-5:1:5])
    %set(gca,'Ytick',[-5:1:5])
    %title('plotfan07 : pcolor with NO ydir normal')

    if(1), % plot range circles
      hold on
      for icirc = 1:5,
	h = circle(icirc,0,0);
	set(h,'color',[.7 .7 .6])
      end
    end
    % add something to indicate which sweep
    if kk==1
        swtext='sweep 1-';
        fh=ones(length(fakeheadangle),2);
    else
        swtext='sweep 2-';
    end
    text(0.01,0.03,[swtext 'rotation used = ' num2str(rot)],...
  	 'units','normalized','color','y','horizontalalignment','left','fontsize',10)
    text(0.8,0.95,'\uparrow North',...
    	 'units','normalized','color','y','fontsize',10)
    tt= ncr{'time'}(ik)+ncr{'time2'}(ik)./86400000;
     ts = datestr(gregorian(tt));
    text(0.99,0.03,ts,...
	 'units','normalized','color','y','horizontalalignment','right','fontsize',10)
     fh(:,kk)=fakeheadangle';
   clear imdata sr ha fakeheadangle xx hfill Zpad

  case 'glacial' % this is really slow
    set(gcf,'name','Polar')
    set(gcf,'numbertitle','off')
    [th, r] = meshgrid(sectorswept.*(pi/180), horizrange);
    [X, Y] = pol2cart(th, r);
    %Z = imdata';
    Z = log10(imdata+eps)';
    surf(X, Y, Z)
    view([0 90]); % az, el
    shading flat
    colormap jet
    text(0.01,0.05,[fname,' Fan beam image taken ',datestr(datenum(gdate))],...
                'units','normalized','color','k','fontsize',9)
    %axis equal tight
    %set(gca,'xlim',[0 settings.Height+0.5]);

   case 'prange'
    % plot headposition and prange
    [ax, h1, h2] = plotyy(1:nangles,headangle,1:nangles,prange);
    title([fname,' Fan beam image taken ',datestr(datenum(gdate))])
    xlabel('Head position and profile range by ping')
    ylabel('Deg')
    %set(ax(2),'ylabel',text(0,0,'string','Prange'))
   otherwise % no plot
    %return values
    Xplot = slantrange;
    Yplot = headangle;
    Zi = imdata;
  end
end
 % put Zi into a structure, so both images may be accessed
 Zs{ik,kk}=Zi;
 % increment n for next image
  n=n+length(sectorswept)+1;
end
 % let the user know where we are
  if mod(ik,10) == 0
        disp(['processing record ' num2str(ik) ' of ' num2str(length(ncr{'time'}))])
   end
   clear Xi Yi headangle sr fakeheadangle slantrange
end
end
% keep3 imdata Xplot Yplot Zi FanData settings
