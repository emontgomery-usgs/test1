function plot_fan(settings)
% plot_fan - stripped down script to plot fan-beam images using _raw file
% does rotations on-the-fly and displays- no output file created
% usage: plot_fan(settings)
% where settings contains:
%     settings.ik = 1;
%     settings.plottype = 'polar';
%     %settings.plottype = 'angle'
%     settings.mkplt = 'y';
%     settings.dxy = 0.01;     % cm
%     settings.correct_sr = 1; % 1 = correct for slant range
%     settings.correct_pr = 0; % 1 = correct for pitch and roll
%     settings.Height = 0.594; % distance from floor to center of head
%     settings.heading = 0; % True heading of zero on fan beam
%     settings.pitch = 0;   % Pitch (degrees) in direction of heading
%     settings.roll = 0;    % Roll (degrees) normal to pitch
%     settings.ncfile='unhfan1210b-targ5_raw.cdf';
%     settings.overlayscript = 'unh_tripodovl(5)'
% (see XXX for sign conventions)

if nargin ~= 1; eval(['help ' mfilename]); return; end; 

ncclose
ncr=netcdf(settings.ncfile);
tmp = size(ncr{'raw_image'}(:));
if(length(tmp)==2)
   Ntimes = 1;
   Npoints = tmp(1);
   Nscans = tmp(2);
elseif(length(tmp)==3)
   Ntimes = tmp(1);
   Npoints = tmp(2);
   Nscans = tmp(3);
end
fprintf(1,'Ntimes = %d, Npoints = %d, Nscans = %d\n',Ntimes,Npoints,Nscans)

% Values in settings override values in the netCDF file
% instead of using user supplied settings,  use what's read in the header
% fanbeam sometimes returns .6 for StepSize: we know it should be .15, thus
% the /4
if isfield(settings,'Height')
   hgt=settings.Height;
else
   hgt=ncr.Height(:);
end
if isfield(settings,'dxy')
   dxy=settings.dxy;
else
   dxy=ncr.dxy(:);
end
if isfield(settings,'magnetic_variation')
   mag_var=settings.magnetic_variation;
else
   if ischar(ncr.magnetic_variation(:))
      mag_var=str2num(ncr.magnetic_variation(:));
   else
      mag_var=ncr.magnetic_variation(:);
   end
end
mkplt = 0;
if isfield(settings,'mkplt')
   mkplt=(strcmpi(settings.mkplt,'y'));
end

% These are not in the netCDF file, only in settings
ik = settings.ik;
plottype = settings.plottype;

% nothing trimmed yet, but there are some redundant scans
imagedata = ncr{'raw_image'}(ik,:,1:Nscans);
prange = ncr{'profile_range'}(ik,1:Nscans);

% we calculate this from a snippet of the headangles because
% in at least one case, the recorded StepSize was wrong 
headangle=ncr{'headangle'}(:);
mnStepSize=mean(diff(headangle(10:20)));
mnStepSize_reported = ncr.StepSize;
if(abs(mnStepSize-mnStepSize_reported)> 0.0001 )
   fprintf('WARNING: Calculated and reported step sizes dont match.\n')
end

%[npoints,nangles] = size(imagedata);
slantrange = ncr.Range(:)/Npoints:(ncr.Range(:)/Npoints): ncr.Range(:);

% sectorswept = 1:mnStepSize:ncr.SectorWidth(:)+(mnStepSize)+1;
% sectorswept = sectorswept(2:length(sectorswept)-1);

% trim range to real area of data
nearfieldcutoff = 52;
farfieldcutoff = Npoints;
imagedata = imagedata(nearfieldcutoff:farfieldcutoff,:);
slantrange = slantrange(nearfieldcutoff:farfieldcutoff);
horizrange = real((slantrange.^2 - hgt^2).^(1/2));
horizrange(find(horizrange<=0))=0;
%%
% set up the interplolation grid and pre-allocate Zs
Xplot = (- ncr.Range(:):dxy:ncr.Range(:));
Yplot = Xplot;
Zs=ones(ncr.sweep(:),length(Xplot), length(Yplot));

n=0;
%while(1)
for kk=1:ncr.sweeps(:)
   % assume sweep 1
   imdata=imagedata(:,2:floor(length(imagedata)/2));
   ha=headangle(2:length(imagedata)/2);
   if ncr.sweeps(:)>1 && (mod(kk,2)==0)
      % backsweeps, kk = even number
      imdata=imagedata(:,floor(length(imagedata)/2)+2:end);
      %See if the 1 degree offset seen in tank tests helps overlay
      % 6 steps is .9, 7 is 1.05, 8 is 1.2
      ha=headangle(length(imagedata)/2+2:end)+8*mnStepSize;
   end
   
    % have to flip both headangle and imagedata because interp2 requires 
    % monotonic increasing ha
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
    
    switch plottype
       case 'polar'
          clear thi ri Xi Yi sr fakeheadangle
          
          settings.fillval = 255; % sets value of no-data region to make
          % a white background
          
          % rot is the value to ADD to the angle so that zero is pointed to
          % the heading. rot is simply settings.heading
          rot = settings.heading;
          
          [Xi, Yi] = meshgrid(Xplot,Yplot);
          [ri, thi]=pcoord(Xi, Yi);   %  ri is -180-> 180 cw, with 0 up
          % rotate
          thi = thi+rot;
          thi(thi>180)=thi(thi>180)-360;
          thi(thi< -180)=thi(thi< -180)+360;
          
          % pad ranges for interpolation
          sr = [0,slantrange(1,1)-.1,...
             slantrange(1,:), slantrange(1,npoints)+.1, 9]';
          % treat hr slightly differently so it is monotonic from zero
          hr = [0,0,...
             horizrange(1,:), horizrange(1,npoints)+.1, 9]';
          ihr=find(hr>dxy,1,'first')
          hr(1:ihr)= ((1:ihr)-1)*hr(ihr)/(ihr);
          % first 3 of first image are always the same
          fh=[ha(1:nangles)];
        if (mnStepSize*100 ~= floor(abs(median(diff(fh))*100)))
%        if (diff(diff(fh)) ~= median(diff(fh)))
             fakeheadangle=[ha(1):mnStepSize:ha(nangles-1)+mnStepSize]';
             % there was also often duplication of the first 3
             % headangles, which may account for problems with the size
             % of the computed fakeheadangle, so add angles to the end if
             % needed
             if length(fakeheadangle)< nangles
                nmiss=nangles-length(fakeheadangle);
                for ik=1:nmiss
                   fakeheadangle(end+ik)=fakeheadangle(end)+(ik+1)*mnStepSize;
                end
             end
             lopad = [-179.999 min(fakeheadangle)-mnStepSize];
             hipad = [max(fakeheadangle)+mnStepSize 180];
             nlo = length(lopad);
             nhi = length(hipad);
             fakeheadangle = [lopad fakeheadangle' hipad];
          else
             fakeheadangle=[ha(1:nangles)];
             % pad for the dead zone area
             lopad = [-179.999 min(ha)-mnStepSize];
             hipad = [max(ha)+mnStepSize 180];
             nlo = length(lopad);
             nhi = length(hipad);
             fakeheadangle = [lopad fakeheadangle' hipad];
          end
          
          % pad data
          Zpad = (settings.fillval)*ones(npoints+nlo+nhi,nangles+nlo+nhi);
          imdata(imdata<(0))=(settings.fillval);
          % set the 0's == 1 to allow the log10 to operate correctly and still
          % get the effect of having missing values replaced by a dark pixel
          % instead of a light one
          imdata(imdata==0)=1;
          
          % kludge...last row (449) of range values always seems to be 252
          imdata(449,:)=(settings.fillval);
          Zpad(nlo+1:npoints+nhi,nlo+1:nangles+nhi)=imdata;
          % the log10 is needed to more evenly distribute the data in bins
          % omitting it leads to a very dark image
          Zpad = log10(Zpad);
          
          % interpolate onto x,y grid
          if(settings.correct_sr ~=1 )
             Zi = interp2(fakeheadangle,sr,Zpad, thi,ri);
          elseif(settings.correct_sr == 1)
             Zi = interp2(fakeheadangle,hr,Zpad, thi,ri);
          end

          if( mkplt )
             figure(1)
             imagesc(Xplot,Yplot,Zi)
             set(gca,'ydir','normal') % because imagesc is sidedownup
             colormap gray;
             set(gca,'Fontsize',12);
             set(gca,'Xtick',[-5:1:5])
             set(gca,'Ytick',[-5:1:5])
             
             if(1), % plot range circles
                hold on
                for icirc = 1:5,
                   h = circle(icirc,0,0);
                   set(h,'color',[.7 .7 .6])
                end
             end
             % not corrections
             if(settings.correct_sr)
                ts = 'SR corrected';
             else
                ts = 'Not SR corrected';
             end
             text(0.01,0.05,ts,...
                'units','normalized','color','r','horizontalalignment','left','fontsize',10)
             % indicate sweep
             if kk==1
                swtext='sweep 1, ';
                fh=ones(length(fakeheadangle),2);
             else
                swtext='sweep 2, ';
             end
             axis square
             text(0.01,0.03,[swtext 'rot = ' num2str(rot)],...
                'units','normalized','color','r','horizontalalignment','left','fontsize',10)
             % text(0.8,0.95,'\uparrow North',...
             %     'units','normalized','color','y','fontsize',10)
             % until the time thing in 2009a gets fixed, forced
             % conversion to double
             tt= double(ncr{'time'}(ik))+double(ncr{'time2'}(ik))./86400000;
             ts = datestr(gregorian(tt));
             text(0.99,0.03,ts,...
                'units','normalized','color','r','horizontalalignment','right','fontsize',10)
             fhd(:,kk)=fakeheadangle';  % sometimes needs transpose
             
             % overlay plot (e.g., tripod map)
             if isfield(settings,'overlayscript')
                eval(settings.overlayscript)
             end
             
             pause(.1)
          end
          clear imdata sr ha fakeheadangle xx hfill Zpad
          
       case 'angle'
          pcolorjw(ha,slantrange,imdata)
       otherwise % no plot
          %return values
          Xplot = slantrange;
          Yplot = headangle;
          Zi = imdata;
    end
end
%end
% let the user know where we are
if mod(ik,10) == 0
   disp(['processing record ' num2str(ik) ' of ' num2str(length(ncr{'time'}))])
end
close(ncr)
hold off

clear Xi Yi sr fakeheadangle
