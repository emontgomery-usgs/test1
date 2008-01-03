
function retn = fix_depth_meta(tripod_no, new_water_depth, cmnt)
%
%  function to adjust all global metadata to be consistent for one tripod
%  using a scientist supplied water_depth.  The default value should be
%  that from the mooring log.  Adds comments
%
%   usage : retn_status = fix_depth_meta(726, 9.3, 'computed from adv pressure')
%         where the retn_status is 1 if no problems
%         arg1= mooring number, 
%         arg2= new water depth, 
%         arg3 = comment describing source of new water depth 
%  emontgomery@usgs.gov 6/7/06
%
% 10/15/07 added modification of nc{'depth'} variable along with the attributes
%
% most recent mods allow the program to detect orientation sensors that are
% probably at a different height than the sensors they're with

% check for arguments and exit if the right number aren't present
if nargin ~= 3; help (mfilename); retn=0; return; end

  retn = 1;
  tripno=num2str(tripod_no);

%  NOTE : this only works on files in the cwd- 
% it doesn't traverse dirs to find files to modify !!
if ispc
    eval(['d=dir(''*' tripno '*.nc'');'])
    for jj=1:length(d)
        fn{jj}=d(jj).name;
    end
else              % for unix
   eval(['[stat,fnames]=unix(''ls ' tripno '*.nc'');'])
   xx=findstr(tripno,fnames);
   xx=[xx length(fnames)+1];
     knt=1;
  for ik=1:length(xx)-1
      vv=char(deblank(fnames(xx(ik):xx(ik+1)-1)));
      if findstr(vv,'old')
         disp(['not processing ' vv]);
      else
         fn{knt}=deblank(fnames(xx(ik):xx(ik+1)-1));
         knt=knt+1;
      end
  end
end

% loop through to manipulate each file on the tripod
  for ik=1:length(fn)
     ncfilename=fn{ik};
     perloc=findstr('.',ncfilename);
     new_nm=[ncfilename(1:perloc-1) '_old.nc'];

    result=fcopy(ncfilename,new_nm);
    nc = netcdf(ncfilename, 'write');
    if isempty(nc), disp('read of ncfile failed, try another name'), return, end

   %% modify history & modification date:
   lfeed = char(10);
   nc.CREATION_DATE = ncchar(datestr(now,0));
   history = ['WATER_DEPTH related attributes corrected.: ' nc.history(:)];
   ifeed = findstr(history,lfeed);
   history(ifeed) = ':';
   nc.history = ncchar(history);
   flg=0;
  
   % fix global attributes related to WATER_DEPTH
    ga=att(nc);
    for j=1:length(ga)
      attname=name(ga{j});
      % capitalize the attribute names in sc, mc, and pt
      if (strcmp(attname,'inst_depth'))
        flg=flg+1;
      elseif (strcmp(attname,'water_depth'))
        nc.WATER_DEPTH=nc.water_depth(:);
        nc.water_depth=[];
        flg=flg+1;
      end
     end
     % this is data that doesn't have the inst_height attribute
      if (flg ==2)  
         nc.inst_height=nc.inst_depth(:); %use a dummy to create attribute
         %so compute it from what's there
         nc.inst_height=ncfloat(nc.WATER_DEPTH-nc.inst_depth);
      end
   
   % save the original value, insert new WATER_DEPTH & add comments
    water_depth_ori = nc.WATER_DEPTH(:);       
    nc.WATER_DEPTH=ncfloat(new_water_depth);
    if(isempty(nc.WATER_DEPTH_NOTE))
       nc.WATER_DEPTH_NOTE = ncchar([cmnt ': (m) ']);
    else   
       nc.WATER_DEPTH_NOTE = ncchar([cmnt ': (m) ' nc.WATER_DEPTH_NOTE]);
    end
     nc.inst_height_note=ncchar('height in meters above bottom: accurate for tripod mounted intstruments');
     nc.inst_depth_note=ncchar('inst_depth = (water_depth - inst_height); nominal depth below the surface'); 

    % some instruments have metadata with the height info -use it!
      if (~isempty(nc.ADVProbeHeight))
        nc.inst_height=ncfloat(nc.ADVProbeHeight);
        %nc{'depth'}(:)=new_water_depth - nc.inst_height;
      elseif (~isempty(nc.PCADPProbeHeight))
         nc.inst_height=ncfloat(nc.PCADPProbeHeight);
      elseif (~isempty(nc.sensor_height))
        nc.inst_height=ncfloat(nc.sensor_height);
        nc.sensor_height=[];
      end
      
   % now try to sort out the sensor_depths using inst_height (or similar)
     if (isempty(nc.inst_height))
         disp(['NO instrument height available in the metadata for ' ncfilename]);
         disp('please select a value to use from these options from the mooring log')
         rd_mlog_mno_hgt(tripno)
         hgt=input('  enter the value as decimal meters (such as: 2.05): \n');
         if isempty(hgt)
             disp ('can not use that answer, exiting')
            close(nc)
           return
         else
            nc.inst_height = ncfloat(hgt);
         end
     else
         hgt=nc.inst_height;
     end    
     nc.inst_depth=ncfloat(nc.WATER_DEPTH - nc.inst_height);

   % now deal with adjusting the variable attributes ...
    vn=var(nc);
    for ik=6:length(vn)
     if (~isempty(vn{ik}.sensor_depth(:)))
        s_ih=water_depth_ori - vn{ik}.sensor_depth(:);
         % this part is for hydra's that may have sensors attached to it
         % at many heights- the likely sensor names are P_402?, SDP_850
         % sed_??, and NEP*, ATTN*, tran* so are using the names to separate... 
         isNEP=strncmpi(name(vn{ik}),'NEP',3);  % transmissometers are
         isSED=strncmpi(name(vn{ik}),'SED',3);  % always different
         isATTN=strncmpi(name(vn{ik}),'ATTN',4);
         istran=strncmpi(name(vn{ik}),'tran',4);
         isCTD=strncmpi(name(vn{ik}),'CTD',3);
         isPr=strncmpi(name(vn{ik}),'P_',2);
         iscmp=strncmpi(name(vn{ik}),'comp',4);    % orientation data is usually
         istlt=strncmpi(name(vn{ik}),'tilt',4);    % in the logger, but may
         isptc=strncmpi(name(vn{ik}),'pitch',4);   % not be given a separate
         isrol=strncmpi(name(vn{ik}),'roll',4);    % height
           % strncmpi used here because it returns a true or false.
           % strfind is [] if it fails, and the {if a|b} doesn't work as
           % expected with []
         if (isNEP | isSED | isATTN | istran | isCTD | isPr)
          % use initial_sensor_height, if available
          sh=vn{ik}.initial_sensor_height(:);
           if (~isempty(sh))
             nc{name(vn{ik})}.sensor_depth=ncfloat(new_water_depth - sh);
           else
             nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - hgt);
             nc{name(vn{ik})}.sensor_hab=ncfloat(hgt);
              % [name(vn{ik}) ' ' num2str(nc{name(vn{ik})}.sensor_depth(:))] 
           end
        % or if orientation, ask what height to put in the attribute
        elseif (iscmp | istlt | isptc | isrol)
             use_hgt=input(['is ' num2str(hgt) 'm the correct height_above bottom for ' name(vn{ik}) '? '],'s');
             if strfind(lower(use_hgt),'n')
                 ori_hgt=input('enter a new height for the orientation sensor: ');
             else
                 ori_hgt=hgt;
             end
             nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - ori_hgt);
             nc{name(vn{ik})}.sensor_hab=ncfloat(ori_hgt);  
        %otherwise use the unrounded instrument height
        elseif (~isempty('s_ih'))
             % even though there is a sensor height, it is often rounded
             % by using the hght input, it can regain the precision lost
           nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - hgt);
           nc{name(vn{ik})}.sensor_hab=ncfloat(hgt);
       else  % for everything else use nc.inst_height  
           nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - nc.inst_height);
      end    % if
     end     % for each variable
    end      % for each file
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % this section changes the contents of the depth() variable
   % {'depth'} is for the depth of the measurements
    dif_wd = new_water_depth-water_depth_ori;
    % are the new and old WATER_DEPTHs are the same?
    if abs(dif_wd) > .01 
      % we're going to change the contents of the variable depth here!
      %  sokeep the original depth info in attributes
       nc{'depth'}.ori_water_depth=water_depth_ori;
        dp=nc{'depth'}(:);
        dnp=num2str(dp(1));
        for ik=2:length(dp)
         dnp=[dnp ', ' num2str(dp(ik))];
        end
       nc{'depth'}.oridepth=dnp;
       % Finally insert adjusted measurement depths  
        if (length(nc{'depth'}(:)) > 1) %for vectors (adv, pca)
            nc{'depth'}(:)= nc{'depth'}(:) + (dif_wd);
        else    % for single depth sensors
            nc{'depth'}(:)=new_water_depth - nc.inst_height;
        end
        nc{'depth'}.CMNT=ncchar('adjusted using new water_depth- original depth data in depth.oridepth attribute');
     else       % if the depths are the same don't change stuff
        nc{'depth'}.CMNT=ncchar('no change needed');
     end
    % recompute min and max of depth 
    nc{'depth'}.minimum=ncfloat(min(nc{'depth'}(:)));
    nc{'depth'}.maximum=ncfloat(max(nc{'depth'}(:)));
    
  close(nc)
  end

% finally, verify that all the variables seem reasonable and match
  for ik=1:length(fn)
    ncfilename=fn{ik};
    disp_ncdepth(ncfilename)
  end
