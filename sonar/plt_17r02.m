 function plt_17r02(PencilData, PencilHeader, PencilSwitches)
% creates a matrix o images thaw were saved by the azimuth drive
% usage  must have read the data first:
%  [PenData, PenHa, PSwa, PAza] = readrangeallETM;
%  
%  em 7/23  works on the "newer" readrangeall format

[p,q,r]=size(PencilData.imagedata);
for ik=1:p
  figure (1); clf
  img=rot90(fliplr(squeeze(PencilData.imagedata(ik,:,:))));
  prm=PencilHeader.ProfileRange(ik,:);
    pcolor(img); shading flat
      hold on
      plot(prm/PencilSwitches.Range,'w.')
      title('raw image in slant range P17r10')
      xlabel ('ping in sweep')
      ylabel ('points in ping')

figure(2); clf
    SampPerMeter=PencilHeader.NPoints/(PencilSwitches.Range);  %range settings should all be same
     hang=(PencilHeader.HeadAngle(ik,:)/180)*pi;  % has to be radians for trig functions                                   
      r  = 1:PencilHeader.NPoints;    %because the last point is already removed from imagedata
      rr = r./SampPerMeter;
	    Yr = rr'*cos(hang);
	    Xr = rr'*sin(hang);
        
         xx=[-PencilSwitches.Range:.0125:PencilSwitches.Range];
         yy=[.2:.0025:2.2]';
         if length(hang) < q
             img=img(:,1:length(hang));
         end
         imgi=griddata(Xr,Yr,img,xx,yy,'linear');
           imgi_mat(ik,:,:)=imgi;
         pcolor(xx,-yy, imgi); shading flat
          hold on
            plot((prm*2/1000).*sin(hang),(-prm*2/1000).*cos(hang),'w.')
            axis ([-3 3 -1.2 -0.4])
        xlabel('distance (m)')
        ylabel('depth (m)')
        title('Pencil Beam sonar in Azimuth drive and  USGS logger')
        text(-2.8,-.5,['sweep # ' num2str(ik)])
  %pause (3)
end
save s17r02_img imgi_mat