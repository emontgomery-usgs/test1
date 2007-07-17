function [pr,ha,ga]=view_pen(PenHeader, PenData, PenSw)
%
% for looking at pencil data
% usage: 
%   [profileRange, headAngle, gain]= view_pen((PenHeader, PenData, PenSw)
%  where the inputs come from readpencil (as below)
%      [PenData, PenHeader, PenSwitches] = readpencil(fileName);
%  outputs are vectors or matrices of profile range, head angle and gain,
%  depending on what logged the files.  The only ones returning a vector
%  for gain will be the .81a files.  They will also tend to have more than
%  one sweep per file (thus will generate matrices, not vectors)
%
%  this code currently works with files written by the Imagenex viewer(.8a1
%  suffix), and files written by the logger in the tank, and the ones
%  written by the old logger.  New configurations will probably need the
%  factors used to overlay ProfileRange on the image.
%  assumes you ran 
% [PenData, PenHeader, PenSwitches] = readpencil(fileName); first
%
%  returns matrices of profile_range(pr), headAngle(ha), and gain(ga),
%  where the first dimension is the sweep number, and the second is pings
%  in the sweep.
%
%  emontgomery 6/07

if (nargin ~= 3)
    help (mfilename); return
end

% for .81a's logged by viewer, headangle often comes out wrong
if(mean(abs(diff(PenHeader.HeadAngle))) ~= PenHeader.StepSize)
   hpangle1=(PenHeader.HeadPosition-600)*PenHeader.StepSize/3;
else
   hpangle1=PenHeader.HeadAngle;
end
  % put the bottom data in a easy to use name
  prange=PenHeader.ProfileRange;
%
% since there are usually more than one sweep pre file, organize into
% sweeps by when headangle changes
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
     
   % pre-declare variables
   pr=zeros(length(sweep_strt)-1,len_swp);
   ha=zeros(length(sweep_strt)-1,len_swp);
   ga=zeros(length(sweep_strt)-1,len_swp);

for ik=1:floor(length(sweep_strt)-1)
% these are ones where the profile_range is mostly found
 % for ik=1:5
   figure(1);  clf
   if rem(ik,2)
       img=PenData.imagedata(:,sweep_strt(ik):sweep_strt(ik+1)-1);
        if ((sweep_strt(ik+1))-sweep_strt(ik) ~= length(pr))
           sw_end= sweep_strt(ik)+(sweep_strt(2)-sweep_strt(1))-1;
       else
           sw_end=sweep_strt(ik+1)-1;
       end
          %[sweep_strt(ik) sw_end sw_end-sweep_strt(ik)] 
       pr(ik,:)=prange(sweep_strt(ik):sw_end);
         pr_plt=prange(sweep_strt(ik):sw_end);
       ha(ik,:)=hpangle1(sweep_strt(ik):sw_end);
   else
       img=fliplr(PenData.imagedata(:,sweep_strt(ik):sweep_strt(ik+1)-1));
       if ((sweep_strt(ik+1))-sweep_strt(ik) ~= length(pr))
           sw_end= sweep_strt(ik)+(sweep_strt(2)-sweep_strt(1))-1;
           if sw_end > sweep_strt(end)
               sw_end=sweep_strt(end);
           end
       else
           sw_end=sweep_strt(ik+1)-1;
       end
         % [sweep_strt(ik) sw_end sw_end-sweep_strt(ik)]
         % we don't need to flip prange to store but do to plot!
         pr_plt=fliplr(prange(sweep_strt(ik):sw_end));
         tmp_pr=prange(sweep_strt(ik):sw_end);
         tmp_ha=hpangle1(sweep_strt(ik):sw_end);

         if length(tmp_pr) < len_swp
             tmp_pr=[tmp_pr(1) tmp_pr];
             tmp_ha=[tmp_ha(1) tmp_ha];
         else
             tmp_pr=tmp_pr(1:len_swp);
             tmp_ha=tmp_ha(1:len_swp);
         end
       pr(ik,:)=tmp_pr;
       ha(ik,:)=tmp_ha;
   end  
       if isfield(PenHeader,'StartGain')
         ga(ik,:)=PenHeader.StartGain(sweep_strt(ik));
       end

    pcolor(img)
      shading flat
      caxis([0 100])
    hold on
    %for megansett tests pulse length was 20, abs=.6
    % for 2.0m HAB (range=5) need prof_range/2
    % for p50 (1.0m) need prof_range/6 to overlay raw image
    % for p17 (1.25m) need prof_range/8
    % for p08 (0.75m) need prof_range/6
    % for 3/14 pulse length is 10, abs = .06
    % for 3/14, range==3, fctr=1   (6/6) is good
    % for 3/14 range==4, fctr=1.333 (8/6) is good
    % for dock test 3/14 files, *.2/1000 works best (for x-y view)

   % the factor required here to have the profile range overlay the image
   % is undoubtedly a function of the switch settings, I'm just not sure
   % how to get there computationally- for now, just believe the hard-wired
   % values...
    if PenHeader.Range == 5
        fctr = 2;
    elseif PenHeader.Range == 4
        fctr=8;
    elseif PenHeader.Range == 3
        fctr=6;
    else
        fctr=1;
    end
    
    % if the data is from the logger: pulselength=10, abs.06 divide by 6
      if (PenSw.PulseLength==10 & PenSw.Absorption == 0.06)
        fctr=fctr/6;
      end
    plot(pr_plt/fctr,'y.')
    xlabel('scan number')
    ylabel('points in scan')
    title([PenHeader.FileName ' scan ' num2str(ik)])
    text(140,-20,'2.0 MAB')
       if isfield(PenHeader,'StartGain')
          text(0,-20,['gain ' num2str(ga(ik)) '; range = ', num2str(PenHeader.Range(ik))])
          pause(.5)
     else
         text(0,-20,[' range = ', num2str(PenHeader.Range(ik))])
           ga = NaN;
           pause(.5)
        %break
    end

end

  
  
