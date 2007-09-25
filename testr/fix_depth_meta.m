function retn = fix_depth_meta(tripod_no, new_water_depth, cmnt)
%
%  function to adjust all global metadata to be consistent for one tripod
%  using a scientist supplied water_depth.  The default value should be
%  that from the mooring log.  Adds
%
%   usage : retn_status = fix_depth_meta(726, 9.3, 'computed from adv pressure')
%         where the retn_status is 1 if no problems
%         arg1= mooring number, arg2= new water depth, arg3 = comment
%         describing how the new water depth was computed
%  emontgomery@usgs.gov 6/7/06


%%% START USGS BOILERPLATE -------------%%
% This program was written to modify a netCDF file in some way.
% It is self documenting- there is currently no other publication 
% describing the use of this software.
%
% Program written in Matlab v7.4,0.287 (R2007a)
% Program ran on PC with Windows XP Professional OS.
% The software requires the netcdf toolbox and mexnc, both available
% from SourceForge (http://www.sourceforge.net)
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
if nargin ~= 3; help (mfilename); retn=0; return; end

  retn = 1;
  tripno=num2str(tripod_no);
%
%  NOTE : this only works on files in the cwd- it doesn't traverse dirs to
%  find files to modify !!
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
   
   % NOW fix the water depth & add comments
   water_depth_ori = nc.WATER_DEPTH(:);        % save the original value
   nc.WATER_DEPTH=ncfloat(new_water_depth);
    if(isempty(nc.WATER_DEPTH_NOTE))
       nc.WATER_DEPTH_NOTE = ncchar([cmnt ': (m) ']);
    else   
       nc.WATER_DEPTH_NOTE = ncchar([cmnt ': (m) ' nc.WATER_DEPTH_NOTE]);
    end
    
    if (~isempty(nc.ADVProbeHeight))
        nc.inst_height=ncfloat(nc.ADVProbeHeight);
        nc{'depth'}(:)=new_water_depth - nc.inst_height;
    elseif (~isempty(nc.PCADPProbeHeight))
        nc.inst_height=ncfloat(nc.PCADPProbeHeight);
    elseif (~isempty(nc.sensor_height))
        nc.inst_height=ncfloat(nc.sensor_height);
        nc.sensor_height=[];
    elseif flg==2
        nc{'depth'}(:)=new_water_depth - nc.inst_height;
    end
      % this is  *NOT* tested 12/28/06
      % for data types where depth is a vector, not a point, you need do do something like
      % if (length(nc{'depth'}(:) > 1))
      %   nc{'depth'}(:)= nc{'depth'}(:) + (water_depth_ori-new_water_depth);
      % end

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
     end
     
     nc.inst_height_note=ncchar('height in meters above bottom: accurate for tripod mounted intstruments');
     nc.inst_depth=ncfloat(nc.WATER_DEPTH - nc.inst_height);
     nc.inst_depth_note=ncchar('inst_depth = (water_depth - inst_height); nominal depth below the surface'); 

     
   % need to deal with the variable attributes next....
   % variable attributes
   % nc{'T_28'}.sensor_depth=ncfloat(inst_depth);
   
   vn=var(nc);
   for ik=6:length(vn)
     if (~isempty(vn{ik}.sensor_depth(:)))
         % this part is for hydra's that may have sensors attached to it
         % at many heights- the likely sensor names are P_402?, SDP_850
         % sed_??, and NEP*, so are using the names to separate... 
         if (strncmpi(name(vn{ik}),'NEP',3) | strncmpi(name(vn{ik}),'SED',3) | strfind(name(vn{ik}),'P_'))
            [name(vn{ik}) ' ' num2str(nc{name(vn{ik})}.sensor_depth(:))]            
            s_ih=water_depth_ori-  vn{ik}.sensor_depth(:)
             nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - s_ih);
              [name(vn{ik}) ' ' num2str(nc{name(vn{ik})}.sensor_depth(:))]            
          else  % for everything else use nc.inst_height  
         nc{name(vn{ik})}.sensor_depth=ncfloat(nc.WATER_DEPTH - nc.inst_height);
          end
     end
   end
  
close(nc)
  end

% at the very end, verify that all the variables seem reasonable and match
  for ik=1:length(fn)
    ncfilename=fn{ik};
    disp_ncdepth(ncfilename)
  end

