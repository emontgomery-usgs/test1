function omat = plotfan08(nc, plottype, settings);
% PLOTFAN08 - Plot Imagenex imaging sonar data
%  called by do_fan_rots.m - follows execution of mk_rawcdf_08
% [x,y,z,settings] = plotfan07(nc, plottype, settings)
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
%    instrument installed height, adcdp compass value, declination
%   these usually come from the metafile
%
% outputs:
% ???

tmp = size(nc{'raw_image'});
ntimes=tmp(1); NPoints=tmp(2); nscans=tmp(3);
% instead of using user supplied settings,  use what's read in the header
slantrange = nc.Range(:)/NPoints:(nc.Range(:)/NPoints): nc.Range(:);
% fanbeam sometimes returns .6 for StepSize: we know it should be .15, thus the /4
% sectorswept = 1:(HeaderData.StepSize/4):HeaderData.SectorWidth+(HeaderData.StepSize/4)+1;

% compute head angle here, if you want to use something other than what is
% read
headangle=nc{'headangle'}(2:nscans-1);

% loop through each time step
for ik=1:ntimes
% trim the redundant first and last ping
  imagedata = nc{'raw_image'}(ik,:,2:nscans-1);
%  headangle=HeaderData(:).HeadAngle(2:nscans-1);
  prange = nc{'profile_range'}(ik,2:nscans-1);
  mnStepSize=mean(diff(headangle(10:20)));
% must check how many images are stored in the fil
   sweepsPerImage=(nc.SectorWidth(:)/nc.DegPerStep(:))+2;
   imgsPerFile=floor(nscans/sweepsPerImage);

sectorswept = 1:mnStepSize:nc.SectorWidth(:)+(mnStepSize)+1;
sectorswept = sectorswept(2:length(sectorswept)-1);
% trim range to real area of data
nearfieldcutoff = 52;
farfieldcutoff = NPoints;
imagedata = imagedata(nearfieldcutoff:farfieldcutoff,:);
slantrange = slantrange(nearfieldcutoff:farfieldcutoff);

% other calculations
%horizrange = slantrange.*acos(asin((settings.Height./slantrange)));
%horizrange = settings.Height.*cos(asin(slantrange./settings.Height));
horizrange = real((slantrange.^2 - settings.Height^2).^(1/2));

%etm fix 3/27/07
%   ** simply flipping the image puts the tray on the correct side.
%    imagedata=flipud(imagedata);
% but making [ripad and thipad] from positive to negative does the same
% thing. I guess it depends on what sweep direction we believe happened

n=1;
for ik=1:imgsPerFile
    if imgsPerFile > 1
      imdata=imagedata(:,n+1:(length(sectorswept)*ik)+(1*ik));
      ha=headangle(n+1:(length(sectorswept)*ik)+(1*ik));
    else
      imdata=imagedata;
      ha=headangle;
    end    
    % have to flip both because interp2 requires monotonic increasing ha
    if (mod(ik,2)==0)
        imdata=fliplr(imdata);
        ha=fliplr(ha);
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
    settings.fillval = 4; % sets value of no-data region
	
    %  new way : have this program compute rot rather than have the user!!! 
    %    -90 is needed to go from math convention where 0 is horizontal +
    %    to map or geographic wher 0 is UP.
%    rot = -90 + ((settings.adcp3val-360) + settings.magnetic_variation + settings.fanadcp_off);
%    rot=0       % apply NO rotation to display raw image.
     rot= settings.fanadcp_off;  % should be opposite sign since matlab + angle is cartisian !
%    convention is ccw is + from 0 at x
    if rot > 360; rot=rot-360; end
    if rot < -360; rot=rot+360; end
    
    Xplot = (- HeaderData.Range(1):settings.dxy:HeaderData.Range(1));
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
    if ik == 1
      xx=[ha(3):.15:ha(nangles-1)+settings.DegPerStep];
      hfill=[ha(3)-(2*settings.DegPerStep) ha(3)-settings.DegPerStep];
      fakeheadangle=[hfill xx];
    else
      fakeheadangle=[ha(1):.15:ha(nangles-1)+settings.DegPerStep];
    end
      lopad = [-179.999 fakeheadangle(1)-.01];
      hipad = [fakeheadangle(nangles)+.01 180];
      nlo = length(lopad);
      nhi = length(hipad);
      fakeheadangle = [lopad fakeheadangle hipad];
    
    % pad data
    Zpad = (settings.fillval)*ones(npoints+4,nangles+nlo+nhi);       
    imdata(imdata<(1))=(settings.fillval);
   
    % kludge...last range values always seems to be 252
    imdata(449,:)=(settings.fillval);
    Zpad(3:npoints+nlo,nlo+1:nangles+nlo)=imdata;
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
    if ik==1
        swtext=':sweep 1';
    else
        swtext=':sweep 2';
    end
    text(0.01,0.03,[HeaderData.FileName(end-11:end) swtext],...
	 'units','normalized','color','y','horizontalalignment','left','fontsize',10)
    text(0.8,0.95,'\uparrow North',...
    	 'units','normalized','color','y','fontsize',10)
     
     ts = datestr(gregorian(HeaderData.FanTime));
    text(0.99,0.03,ts,...
	 'units','normalized','color','y','horizontalalignment','right','fontsize',10)
    
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
 Zs{ik}=Zi;
 % increment n for next image
 n=n+length(sectorswept)+1
end
end
% keep3 imdata Xplot Yplot Zi FanData settings
