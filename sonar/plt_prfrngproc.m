function plt_prfrngproc(PenData, PenHeader, PenSwitches)  
%  generates plots of the images with ProfileRange from the header 
%  overlaying the image for validation of the algorythms and factors used
% do [PenData, PenHeader, PenSwitches] = readpencil('t205m.81a'); first
   % 
   % emontgomery 7/24/07
figure(2)
     hpangle1=PenHeader.HeadAngle;
ik=1;
    mx=max(hpangle1);
    mn=min(hpangle1);
    mxind=find(hpangle1==mx);
    mnind=find(hpangle1==mn);    
    % sometimes you get several max and mins before turns around:
      lx=find(diff(mnind)==1);
         mnind(lx)=[];
         clear lx
      lx=find(diff(mxind)==1);
         mxind(lx)=[];
    sweep_strt=sort([mxind mnind]);
     len_swp=sweep_strt(2)-sweep_strt(1);

    % try the equivalent of proc \for megansett data
    SampPerMeter=PenHeader.NPoints/(PenHeader.Range(250));  %range settings should all be same
     hd_angle=PenHeader.HeadAngle;
     ha=(hd_angle(sweep_strt(ik):sweep_strt(ik+1)-1));
     gd_locs=find(ha > -75 & ha < 75);
     hang=(ha/180)*pi;  % has to be radians for trig functions                                   
     ha_gd=hang(gd_locs);
      r  = 1:PenHeader.NPoints;    %because the last point is already removed from imagedata
      rr = r./SampPerMeter(1);
	    Yr = rr'*cos(ha_gd);
	    Xr = rr'*sin(ha_gd);

       prm=PenHeader.ProfileRange(sweep_strt(1):sweep_strt(2)-1);
       raw = PenData.imagedata(:,sweep_strt(ik):sweep_strt(ik+1)-1);  
        raw_gd=raw(1:end-21,gd_locs);
         Dz = find(raw_gd<0);							% Make all values below
       raw_gd(Dz) = 0;									% threshold = 0
        [fx,fy]=gradient(raw_gd);
        [p,q]=size(fy);
        for(jj=1:q);
            figure(3)
            nn=find(fy(30:end-10,jj)==0);
            % plot(fy(30:end-10,jj))
            loc=find(abs(fy(30:end-10,jj)) >5);
            ly(jj)=round(mean(loc))+30;
        end
         nlocs=find(isnan(ly));
         if ~isempty(nlocs)
             ly(nlocs)=500;
            % for jj=1:length(nlocs)
            %     ly(nlocs(jj))=round(mean(ly(nlocs-3):ly(nlocs+3)));
            % end
         end        
              plot(Yr(ly))
              
      % try to interpolate and plot             
         xx=[-PenHeader.Range(250):.0125:PenHeader.Range(250)];
         yy=[.2:.0025:2.2]';
         %  for logger files you need raw, for .8a1, need raw_gd...
         %imi=griddata(Xr,Yr,raw,xx,yy,'linear');
         imi=griddata(Xr,Yr,raw_gd,xx,yy,'linear');
         pcolor(xx,-yy, imi); shading flat
          hold on
            plot((prm*2/1000).*(sin(deg2rad(ha))),(-prm*2/1000).*(cos(deg2rad(ha))),'r.')
        xlabel('distance (m)')
        ylabel('depth (m)')
        title('Megansett 7/13 P1 using logger')
%this works for dock test data files
%   plot((prm*.2/1000).*(sin(deg2rad(ha))),(-prm*.2/1000).*(cos(deg2rad(ha))),'x')
%plot(hdst(6,:),elev(6,:),'k.')
%axis([-4 4 -1 -.6])
%plot(prm.*(sin(deg2rad(headangle(6,:)))),-prm.*(cos(deg2rad(headangle(6,:)))),'r.')
%but doesn't flatten out the ones from megansett- why?