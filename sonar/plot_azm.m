function plot_azm(fname,da)
% plot_azm Experiment with processing and plotting azimuth drive pencil-beam sonar
%
%  two input arguments are required- the azimuth raw .cdf file to open, and
%  the tilt pencil head (should make initial image flat)
% csherwood
% mods emontgomery 7/30/09
% treats one file at a time- removed looping

if nargin ~=2; help mfilename; return; end

% switches
do_raw = 1; % 1 = process raw data, otherwise work with 'profile_range')
make_plots = 0;

ipr = 1; % counter for final plots
%for mm=9, % loop through months
%   for dd = 27% 1:30, %10 %27 % loop through days
if ~exist('fname','var')
    fname='dummy';
else
    if exist(fname, 'file') < 2 || isempty(fname)
        disp('The file name does not exist, please choose another raw cdf file.')
        [fname,PathName,FilterIndex] = uigetfile('*');
        fname=[PathName fname];
    end
end
      ncload(fname,'time','time2','scan','points','rots','headangle','azangle','profile_range');
      nc = netcdf(fname);
      
      jt = time+time2/(1000*24*3600);
      factor = 0.002; % converts profile_range to meters
      rfactor = 0.005; % converts scan count to range in meters (I hope...not sure what this number should be)
      % empirical correction to headangle
      % this is the value that keeps the bottom flat
      % da = -2.5
      % dimensions are time, rotation angle, points in sweep
      % variable names here should reflect that
      [nt naz nang]=size(headangle);
      if find(isnan(headangle(1,1,:)))
          nang=find(isnan(headangle(1,1,:)),1,'first');
      end
      
      % for practice, just use first one
      headangle=headangle(1,:,1:nang);
      profile_range=profile_range(1,:,1:nang);
      azangle=azangle(1,:);
      
          % find distance and elevation (wrt arbitrary vertical datum da)
          ya = sin((pi/180)*(headangle+da)).*(factor*profile_range);
          za = cos((pi/180)*(headangle+da)).*(factor*profile_range);
          az = repmat(azangle,[1,1,nang]);
          % calc. x,y location for elevation data
          [x,y]=xycoord(ya,az);
          % remove elevation data that is too high
          za(za<.75)=NaN;       
 
      if(do_raw)
          % dimension arrays to hold data extracted from raw returns
          % (these should be same size as 'profile_range')
          bs=zeros(nt,naz,nang);
          pr=zeros(nt,naz,nang);
          % CRS had 100 here, but I think it's the wrong dimension
          imin_range = 1; % ignore data at short range
          %h = ones(5,5); % square (boxcar) 2D filter
          h = ones(3,3); % square (boxcar) 2D filter
          h = h./(sum(sum(h))); % normalize
          
          % experimental processing of raw data to get equiv. of
          figure(1);clf
          %  for i=1:nt, %4
          i=1;
          for irot=1:length(rots)
              raw = nc{'raw_image'}(i,irot,:,:);
              %rawf = filter2(h,raw(:,imin_range:end));
              rawf = raw(:,imin_range:end); % no filter
              % bst is the value of the max value, prt is the index
              [bst,prt]=max(rawf,[],1);
              % remove values with low backscatter or near head
              locs=(find(bst<20 | prt<30));
              prt(locs)=NaN;
              bs(i,irot,:)=bst;
              % add the missing bins back in and convert to meters (I hope)
              pr(i,irot,:)=rfactor*((imin_range-1)+prt);
              ixp = 1:length(prt);
              figure(1);hold on;cdot(ixp(:),prt(:),bst(:),jet,10,0,[0 80]);
          end
          hold off
          bs=bs(1,:,:);pr=pr(1,:,:);
          %   end
          % find distance and elevation (wrt arbitrary vertical datum da)
          % (this replaces calcs from 'profile_range' when do_raw is set
          ya = sin((pi/180)*(headangle+da)).*pr;
            % ya is constant in all rotation angles
          za = cos((pi/180)*(headangle+da)).*pr;
          az = repmat(azangle,[1,1,nang]);
          % calc. x,y location for elevation data
          [x,y]=xycoord(ya,az);
          % remove elevation data that is too high
          za(za<.75)=NaN;
      end
      
      for i=1 %1:nt
         if(1)
            figure(2); clf
            plot3(squeeze(x(i,:,:)),squeeze(y(i,:,:)),-squeeze(za(i,:,:)),'.k')
            axis([-2.5 2.5 -2.5 2.5 -1.5 -.5])
         end
         if(1) % process the elevation data in za to make map
            ts = datestr(datenum(gregorian(jt(i))),'mmm dd HHMM')
            x1 = squeeze(x(i,:,:));
            y1 = squeeze(y(i,:,:));
            z1 = squeeze(za(i,:,:));
            b1 = squeeze(bs(i,:,:));
            h1 = squeeze(headangle(i,:,:));
            x1( find(x1>1.5) )=NaN;
            y1( find(y1>1.5) )=NaN;
            z1( find(z1>1.0) )=NaN;
            x1( find(x1<-1.5) )=NaN;
            y1( find(y1<-1.5) )=NaN;
            z1( find(z1<-1.0) )=NaN;
            
            % NaN out values near tripod feet
            % this foot-detector doesn't work for hatteras data
            r1 = sqrt( (x1- -.31).^2 + (y1-(-1.19)).^2 );
            %r1( find(r1<.2) )= NaN;
            r2 = sqrt( (x1- -.47).^2 + (y1-(1.07)).^2 );
            %r2( find(r2<.2) )= NaN;
            
            % make indices to non-NaN data
            ok = find(isfinite(x1(:)+y1(:)+z1(:)+r1(:)+r2(:)));
            okb = find(isfinite(x1(:)+y1(:)+z1(:)+b1(:)));
            % Fit a plane to the recorded elevation data
            % (I did this once, and kept the values for the rest of the
            % deployment, so it is commented out)
            %[x0 a d normd]=lsplane([x1(ok),y1(ok),-z1(ok)]);
            % a = [-0.0249 -0.0089 0.9996]; % cosines of normal of best fit from first scan on Sep-01
            % since we don't know what to use for hatteras, set to 0
            a=[.01 .01 1];
            zf = a(1)*x1(ok)+a(2)*y1(ok)+a(3)*(-z1(ok));
            % non-NaN backscatter values may have diff. number of values
            bsf = b1(okb);
            if(1)
               figure(3); clf
               plot3(x1(ok),y1(ok),zf,'.k');
               xlabel('x (m)');ylabel('y (m)')
               shg
               %plot3(x1(ok(out)),y1(ok(out)),zf(out),'.r');
            end
            
            % fit a surface to the elevation data points
            [zg,xg,yg] = gridfit(x1(ok),y1(ok),zf,[-1.3:.02:1.5],[-1.5:.02:1.5],'smooth',.1);
            % fit a surface to the backscatter data
            [zgb,xgb,ygb] = gridfit(x1(ok),y1(ok),b1(ok),[-1.3:.02:1.5],[-1.5:.02:1.5],'smooth',.1);
            [zgbtrend,xgbs,ygbs] = gridfit(x1(ok),y1(ok),b1(ok),[-1.3:.02:1.5],[-1.5:.02:1.5],'smooth',2);
            if(1)
               figure(2); clf
               surf(xg,yg,zg)
               shading flat
               if(1)
                  hh = findobj('Type','surface');
                  set(hh,'Cdata',zgb-zgbtrend,'Facecolor','texturemap')
                  colormap gray
                  gmap = colormap;
                  colormap(flipud(gmap))
               else
                  colormap gray
                  %lighting gouraud
                  %material dull
               end
               axis([-1.5 1.5 -1.5 1.5 -1.3 -.8])
               % view(-68.5, 62)
               % text(1.3,2.8,-1,ts,'fontsize',14)
               view(-122.5,62)
               text(1.9,1.5,-.6,ts,'fontsize',14)
               xlabel('Onshore (North, m)','fontsize',12)
               ylabel('Alongshore (West, m)','fontsize',12)
               zlabel('Elev (m)','fontsize',12)
               shg
               %pfn = sprintf('print -dpng d:/crs/proj/MVCO/2007_Ripples_DRI_Experiment/data_proc/azsonar/frames/az%03d.png',ipr)
               pfn = sprintf('print -dpng d:/crs/proj/MVCO/2007_Ripples_DRI_Experiment/data_proc/azsonar/frames2/az%03d.png',ipr)
               if(make_plots)
                  eval(pfn)
               end
               pause
            end
            if(1)
               figure(5); clf
               pcolorjw(-yg,xg,zg)
               %mesh(xg,yg,zg)
               colormap gray
               shading flat
               ylim([-1.3 1.5])
               axis([-1.5 1.5 -1.3 1.5 ])
               axis equal
               title(ts,'fontsize',14)
               ylabel('Onshore (North, m)','fontsize',12)
               xlabel('Alongshore (West, m)','fontsize',12)
               % caxis([-1.1 -.9])
               colorbar
               shg
               %pfn = sprintf('print -dpng d:/crs/proj/MVCO/2007_Ripples_DRI_Experiment/data_proc/azsonar/frames/faz%03d.png',ipr)
               pfn = sprintf('print -dpng d:/crs/proj/MVCO/2007_Ripples_DRI_Experiment/data_proc/azsonar/frames2/faz%03d.png',ipr)
               if(make_plots)
                  eval(pfn)
               end
               %pause
            end
            ipr = ipr+1;
         end
      end
      close (nc)
%   end
%end
