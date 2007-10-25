function outfile = em_dolly(infile,outfile,task, keepallvars)
% function outfile = em_dolly(infile,outfile,task, keepallvars)
% A user interface for EPIC netCDF datafile manipulation.
%
%  usage : outfile = dolly('7443pt-a.nc','7553pt-alp.nc','low_pass','yes')
% infile is the name of an existing EPIC netCDF file.
% outfile is the name of an EPIC netCDF file that will
%		be created.
% task is a keyword specifying which task 
%		is to be performed. Current possibilities include:
%		'timesample','daily_avg','beam_attenuation',
%		'var_sample','low_pass','fix_time','depth_sample'
%     'apply_mag_var','rotate','hour_avg','polar_currents'
%     'OBS_concentration','decimal_time','convert_time_vector'
%		'Chlorophyll','salinity','sigma_theta'
% keepallvars is a string- 'yes' for maintain all variables and attributes
% Started by Fran Hotchkiss 20 Apr 2000.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use of this program is self described.
% Program written in Matlab v7.1.0 SP3
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% 5/25/06 add a workaround for non-EPIC variables... they will be copied,
% but they will not be edited.  MM

% 5/30/06 added keepall functionality, which gets around having to select
% which variables and attributes to keep

% let it use EP_Time or ep_time
warning('off','MATLAB:dispatcher:InexactMatch')

Main.task = {{'timesample','daily_avg','beam_attenuation',...
         'var_sample','low_pass','fix_time','depth_sample',...
         'apply_mag_var','rotate','hour_avg','polar_currents'...
         'OBS_concentration','decimal_time','convert_time_vector',...
      	'Chlorophyll','salinity','sigma_theta'}, 1};
nvarin = 1;
if running(batch)
   str = get(batch);
   eval(['Main.infile = ' str ';']);      
   str = get(batch);
   eval(['Main.outfile = ' str ';']);      
   str = get(batch);
   eval(['task = ' str ';']);      
   Main.task{2} = strmatch(task,Main.task{1});
else
	if nargin < 2;
   	  Main.infile = '9999Atct-a.cdf';
    end
	 if nargin < 3
    	Main.outfile = '9999Atct-a1h.nc';
        Main_Menu = Main;
        Main = guido(Main_Menu,'Select files and processing task');   
     end
    
   if nargin >= 3;
        Main.infile = infile;
     	Main.outfile = outfile;
     	Main.task{2} = strmatch(task,Main.task{1});
	   if isempty(Main.task{2})
   	   Main.task{2} = 1;
       end
       do_allvars=0;
   end
   if nargin ==4    % set the do_all flag
       if(strcmp(upper(keepallvars(1)),'Y'))
         do_allvars=1;
      else 
        do_allvars=0;
       end
   else
       keepallvars = 'N';
   end
    

	if isempty(Main)
   	disp ('Main Menu must be completed. Execution ends.')
	   return
   end
end

nvarout = 0;
vardesc = '';
epname{1} = '';
calatts = '';
varcomment = '';
calcomment = '';
infile = Main.infile;
outfile = Main.outfile;

 if exist(infile,'file')
    nc = netcdf(infile);
 else
   [infile,inpath] = uigetfile('*.cdf','Choose input file');
   nc = netcdf(infile);
   if isempty(nc)
      disp (['Cannot open input file ' infile]);
      disp (['Execution ends.']);
      return;
   end
 end

switch Main.task{2}
case 1
   histcomment = 'Interpolated to a new time base by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Choose start and stop times and interval.
	if running(batch)
	   str = get(batch);
	   eval(['Interval.start = ' str ';']);      
	   str = get(batch);
	   eval(['Interval.stop = ' str ';']);      
	   str = get(batch);
	   eval(['Interval.time_step_seconds = ' str ';']);      
   else
      Interval.start = nc.start_time(:);
      Interval.stop = nc.stop_time(:);
      Interval.time_step_seconds = nc.DELTA_T(:);
      Ival = Interval;
      Interval = guido(Ival,'New file time base');
   end
   
   %Make new time base.
   firstime = datenum(Interval.start);
   lastime = datenum(Interval.stop);
   eval(['day_per_step = ' Interval.time_step_seconds '/24/60/60;']);
   ntimes = round((lastime - firstime)/day_per_step)+1;
   recnum = 0:ntimes-1;
   timenum = (day_per_step*recnum)+firstime;
   alltime = EP_Time(timenum');
   time = alltime(:,1);
   time2 = alltime(:,2);
   
   att_delta_t = Interval.time_step_seconds;
	att_start_time = datestr(timenum(1),0);
   att_stop_time = datestr(timenum(ntimes),0);
   scratch = netcdf('scratch.nc','clobber');
	copy(nc{'time'},scratch,0,1);
	copy(nc{'time2'},scratch,0,1);
   scratch{'time'}(1:ntimes) = time;
   scratch{'time2'}(1:ntimes) = time2;
   tvar = scratch{'time'};
   
   nvarout = nvarin;
   for i = 1: nvarin;
      ivar = nc{chosen{i}};
      ivar = autonan(ivar,1);
      epname{i} = name(ivar);
      inname{i} = name(ivar);
      indims = size(ivar);
      newsize{i} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{i} = [newsize{i} ',1:' num2str(indims(idims))];
      end
      vardesc = [ vardesc ':' ivar.name(:)];
      eval(['newvar' num2str(i) ' = timterp(ivar,tvar);']);
   end
   close(scratch)  
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
case 2
   histcomment = 'Averaged to daily time base by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   indays = nc{'time'}(:);
   newdays = find(diff(indays));
   ntimes = length(newdays)+1;
   time = indays(newdays);
   time(ntimes) = indays(length(indays));
   
   recend = newdays;
   recend(ntimes) = length(indays);
   recstart(1) = 1;
   recstart(2:ntimes) = newdays + 1;
   time2 = zeros(size(time));
   indata = nc{'time2'}(:);
   for iday = 1:ntimes;
      time2(iday) = mean(indata(recstart(iday):recend(iday)));
   end
   
   att_delta_t = 86400.;
	att_start_time = datestr(ep_datenum([time(1) time2(1)]),0);
   att_stop_time = datestr(ep_datenum([time(ntimes) time2(ntimes)]),0);

   nvarout = nvarin;
   for i = 1: nvarin;
      ivar = nc{chosen{i}};
      ivar = autonan(ivar,1);
      epname{i} = name(ivar);
      inname{i} = name(ivar);
      indims = size(ivar);
      newsize{i} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{i} = [newsize{i} ',1:' num2str(indims(idims))]%;
      end
      vardesc = [ vardesc ':' ivar.name(:)];
      eval(['newvar' num2str(i) ' = zeros(' newsize{i} ');']);
	   indata = ivar(:);
   	for iday = 1:ntimes;
         for idepth = 1:indims(2);
	      	eval(['newvar' num2str(i) '(iday,idepth,1,1) = mean(indata(recstart(iday):recend(iday),idepth,1,1));']);
         end
      end
   end
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
case 3
   histcomment = 'Beam attenuation calculated by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);

      
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   tranvarname = 'time';
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
      if strncmp('tran',chosen{ivar},4)
         tranvarname = chosen{ivar};
      elseif strncmp('TRN',chosen{ivar},3)
         tranvarname = chosen{ivar};
      end
   end
   
   %Get necessary constants.
	if running(batch)
	   str = get(batch);
	   eval(['tranvarname = ' str ';']);  
       invar = nc{tranvarname};
      invar = autonan(invar,1); %added 20-Mar-2003
	   trvolts = invar(:);
	   str = get(batch);
	   eval(['len = ' str ';']);      
	   str = get(batch);
      eval(['Vair = ' str ';']); 
      str = get(batch);
      eval(['trans_id = ' str ';']);
   else
      Att.tranvarname = tranvarname;
      Att.length = 0.25;
      Att.volts_air = 4.5;
      Att.inst_id = nc{tranvarname}.serial_number(:); 
      Aval = Att;
      Att = guido(Aval,'Beam attenuation parameters');
       invar = nc{tranvarname};
      invar = autonan(invar,1); %added 20-Mar-2003
	   trvolts = invar(:);
      tranvarname = Att.tranvarname;
   	len = Att.length;
      Vair = Att.volts_air;
      trans_id = Att.inst_id;
   end
   
   %Calculate beam attenuation.
   trmax = max(trvolts);
   V95 = .95*Vair;
   if trmax > V95
      Vair = trmax/.95;
   end
   attn = -(1/len) .* log(trvolts./(.95*Vair));
   nvarout = nvarout+1;
   attvarname = 'ATTN_55';
   epname{nvarout} = attvarname;
   inname{nvarout} = tranvarname;
   vardesc = [ vardesc ':ATTN'];
   eval(['newvar' num2str(nvarout) '= attn;']);
   indims = size(nc{tranvarname});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
   
case 4
   histcomment = 'Extra variables deleted by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   
case 5
   histcomment = 'Low-pass filtered with pl33 filter, by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);

   
   %Make new time base.
   msecperhr = 60*60*1000;
   datenum_start = ep_datenum([nc{'time'}(1) nc{'time2'}(1)]);
   ntimes = length(nc{'time'})%;
   datenum_stop = ep_datenum([nc{'time'}(ntimes) nc{'time2'}(ntimes)]);
  
  
   %Choose start and stop times and interval.
	if running(batch)
	   str = get(batch);
	   eval(['Interval.start = ' str ';']);      
	   str = get(batch);
	   eval(['Interval.stop = ' str ';']);      
	   str = get(batch);
	   eval(['Interval.time_step_hours = ' str ';']);      
   else
      Interval.start = nc.start_time(:);
      Interval.stop = nc.stop_time(:);
      Interval.time_step_hours = 6.;
      Ival = Interval;
      Interval = guido(Ival,'New file time base');
   end
   
   outstep = Interval.time_step_hours;
   
   base_num = max((datenum(Interval.start) - 33/24),datenum_start);
	base_eptime = ep_time(base_num);
	day_start = base_eptime(1,1);
	hour_start = ceil(base_eptime(1,2)/msecperhr);
   
   end_num = min((datenum(Interval.stop) + 33/24),datenum_stop);
	end_eptime = ep_time(end_num);
	day_end = end_eptime(1,1);
	hour_end = ceil(end_eptime(1,2)/msecperhr);
   
   nhours = 24*(day_end - day_start) + hour_end - hour_start;
   hours = [0:nhours];
	n = floor(nhours/outstep +1)
	jtime = day_start + (hour_start + hours)/24;
	time = floor(jtime);
	time2 = (jtime - time)*24*msecperhr;

	regc = netcdf('scratch.nc','clobber');
	regc('time') = 0;
	regc{'time'} = nclong('time');
	regc{'time'}.units = ncchar('True Julian Day');
	regc{'time'}.type = ncchar('EVEN');
	regc{'time'}.epic_code = nclong(624);
	regc{'time2'} = nclong('time') ;
	regc{'time2'}.units = ncchar('msec since 0:00 GMT');
	regc{'time2'}.type = ncchar('EVEN');
	regc{'time2'}.epic_code = nclong(624);
	regc{'count'} = nclong('time') ;
	endef(regc)
	nreg = length(time);
	regc{'time'}(1:nreg) = time (:);
	regc{'time2'}(1:nreg) = time2 (:);
	regc{'count'}(1:nreg) = [1:nreg];

   
   %Filter input variables.
   nvarout = nvarin;
   ovar = 0;
   havespdvar = 0;
   havedirvar = 0;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
      vardim = dim(invar);
      d1name = name(vardim{1});
      if ~(strncmp('time',d1name,4))
         disp (['Cannot filter variable ' invar.name(:)]);
         nvarout = nvarout - 1;
      elseif ~(isempty(findstr('SPEED',invar.long_name(:))))
         havespdvar = 1;
         spdvar = invar;
         nvarout = nvarout - 1;
      elseif ~(isempty(findstr('DIRECTION',invar.long_name(:))))
         havedirvar = 1;
         dirvar = invar;
         nvarout = nvarout - 1;
      else
         ovar = ovar + 1;
     		vardesc = [vardesc ':' invar.name(:)];
      	inname{ovar} = name(invar);
      	epname{ovar} = inname{ovar};
      	% Use timterp to make in_name variables have regular 
         %     hourly time base.
         dat = timterp(invar,regc{'count'});
     	   %Call filter function.
     	   [outvar,jdfilt]=plfilt(dat,jtime,outstep);
			eval (['newvar' num2str(ovar) ' = outvar;' ]);
         indims = size(outvar);
         ntimes = length(jdfilt);
      	newsize{ovar} = ['1:' num2str(ntimes) ];
     		for idims = 2:length(indims)
      	   newsize{ovar} = [newsize{ovar} ',1:' num2str(indims(idims))];
         end
      end
   end
   
   if havedirvar*havespdvar
      spd = timterp(spdvar,regc{'count'});
      dir = timterp(dirvar,regc{'count'});
		[u,v] = polar2uv(dir,spd);
  		dat = [u v];
  		%Call filter function.
      [outvar,jdfilt]=plfilt(dat,jtime,outstep);
      [dir,spd] = uv2polar(outvar(:,1),outvar(:,2));
      ovar = ovar + 1;
    	vardesc = [vardesc ':' dirvar.name(:)];
      inname{ovar} = name(dirvar);
      epname{ovar} = inname{ovar};
		eval (['newvar' num2str(ovar) ' = dir;' ]);
      indims = size(dir);
      ntimes = length(jdfilt);
      newsize{ovar} = ['1:' num2str(ntimes) ];
     	for idims = 2:length(indims)
      	newsize{ovar} = [newsize{ovar} ',1:' num2str(indims(idims))];
      end
      ovar = ovar + 1;
      vardesc = [vardesc ':' spdvar.name(:)];
      inname{ovar} = name(spdvar);
      epname{ovar} = inname{ovar};
		eval (['newvar' num2str(ovar) ' = spd;' ]);
      indims = size(spd);
      ntimes = length(jdfilt);
      newsize{ovar} = ['1:' num2str(ntimes) ];
     	for idims = 2:length(indims)
      	newsize{ovar} = [newsize{ovar} ',1:' num2str(indims(idims))];
      end
      nvarout = nvarout + 2;
   end
      
	%Time variables
	time = floor(jdfilt); 
	time2 = (jdfilt - time)*24*msecperhr;
	att_delta_t = Interval.time_step_hours * 3600;
	att_start_time = datestr(ep_datenum([time(1) time2(1)]),0);
   att_stop_time = datestr(ep_datenum([time(ntimes) time2(ntimes)]),0);
   
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
case 6
   histcomment = 'Time fixed in dolly.m';
   
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   ntimes = length(time)%;

   %Choose time interval to be shifted and shift amount.
	if running(batch)
	   str = get(batch);
	   eval(['Record.start_shift = ' str ';']);      
	   str = get(batch);
	   eval(['Record.stop_shift = ' str ';']);      
	   str = get(batch);
	   eval(['Record.time_increase_days = ' str ';']);      
	   str = get(batch);
	   eval(['Record.time_increase_hours = ' str ';']);      
	   str = get(batch);
	   eval(['Record.time_increase_minutes = ' str ';']);      
	   str = get(batch);
	   eval(['Record.time_increase_seconds = ' str ';']);      
   else
      Record.start_shift = 1;
      Record.stop_shift = ntimes;
      Record.time_increase_days = 0;
      Record.time_increase_hours = 1;
      Record.time_increase_minutes = 0;
      Record.time_increase_seconds = 0;
      Ival = Record;
      Record = guido(Ival,'Interval and time increment');
   end
   
   increment = Record.time_increase_days;
   increment = increment + (Record.time_increase_hours / 24);
   increment = increment + (Record.time_increase_minutes / 1440);
   increment = increment + (Record.time_increase_seconds / 86400);
   timenum = ep_datenum([time time2]);
   timenew = timenum(Record.start_shift:Record.stop_shift) + increment;
   timenum(Record.start_shift:Record.stop_shift) = timenew;
   alltime = EP_Time(timenum);
   time = alltime(:,1);
   time2 = alltime(:,2);

   att_delta_t = nc.DELTA_T(:);
	att_start_time = datestr(timenum(1),0);
   att_stop_time = datestr(timenum(ntimes),0);
   histcomment = 'Time fixed in dolly.m by increasing time ';
   histcomment = [histcomment num2str(increment*24)];
   histcomment = [histcomment ' hours from record '];
   histcomment = [histcomment num2str(Record.start_shift) ' thru '];
   histcomment = [histcomment num2str(Record.stop_shift) '.']
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
      vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      disp (['keeping input variable ' inname{ivar}]);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   
case 7
   histcomment = 'Depth subsampled by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Choose depths to keep.
   if running(batch)
	   str = get(batch);
      eval(['keep_depths = ' str ';']);     
      ndepths = length(keep_depths);
   else
		indepths = nc{'depth'}(:)
		for i = 1:length(indepths)
		   eval (['depthlist.bin',num2str(i),'={''checkbox'' 0};'])
		end
		dlist = depthlist;
		depthlist = guido(dlist,'Which depths should be kept?');
      ndepths = 0;
      for i = 1:length(indepths)
		   eval (['tf = depthlist.bin',num2str(i),'{2};'])
		   if tf
		      ndepths = ndepths+1;
		      keep_depths(ndepths)=i;
		   end   
	   end
   end
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(keep_depths);
   
   %Pass through input variables.
   nvarout = nvarin;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      indims = size(invar);
      numdims = length(indims);
      switch numdims
      case 3
         newsize{ivar} = ['1:' num2str(ntimes) ',1:' num2str(indims(2)) ',1:' num2str(indims(3))];
         eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      case 4
         newsize{ivar} = ['1:' num2str(ntimes) ',1:' num2str(ndepths) ',1:' num2str(indims(3)) ',1:' num2str(indims(4))];
         for idepth = 1:ndepths
            eval (['newvar' num2str(ivar) '(:,idepth,:,:) = invar(:,keep_depths(idepth),:,:);' ]);
         end
      otherwise
         newsize{ivar} = ['1:' num2str(ntimes) ];
         eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      end
   end

case 8
   histcomment = 'Magnetic variation applied by dolly.m.';
   
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
   
   %Get variables to operate on.
	if running(batch)
	   str = get(batch);
	   eval(['mvar = ' str ';']);      
	   str = get(batch);
      eval(['use_polar = ' str ';']);  
      str = get(batch);
      eval(['dirvarname = ' str ';']);
      str = get(batch);
      eval(['spdvarname = ' str ';']);
      str = get(batch);
      eval(['eastvarname = ' str ';']);
      str = get(batch);
      eval(['northvarname = ' str ';']);
   else
      magnetic.variation = -17.;
      magnetic.use_polar = 1;
      magnetic.current_direction = 'CD_310';
      magnetic.current_speed = 'CS_300';
      magnetic.current_east = 'u_1205';
      magnetic.current_north = 'v_1206';
      mval = magnetic;
      magnetic = guido(mval,'Magnetic variation parameters');
	   mvar = magnetic.variation;      
      use_polar = magnetic.use_polar;  
      dirvarname = magnetic.current_direction;
      spdvarname = magnetic.current_speed;
      eastvarname = magnetic.current_east;
      northvarname = magnetic.current_north;
   end

   %Pass through input variables that aren't current.
   nvarout = nvarin+4;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   if use_polar
      spdvar = nc{spdvarname};
      spdvar = autonan(spdvar,1);
      dirvar = nc{dirvarname};
      dirvar = autonan(dirvar,1);
      invar = nc{spdvarname};
      dirdat = dirvar(:) + mvar;
      beyond = find(dirdat<0);
      dirdat(beyond) = dirdat(beyond) + 360;
      beyond = find(dirdat>360);
      dirdat(beyond) = dirdat(beyond) - 360;
      spddat = spdvar(:);
      [eastdat,northdat] = polar2uv(dirdat,spddat);
   else
      eastvar = nc{eastvarname};
      eastvar = autonan(eastvar,1);
      northvar = nc{northvarname};
      northvar = autonan(northvar,1);
      invar = nc{eastvarname};
      eastdat = eastvar(:);
      northdat = northvar(:);
      [dirdat,spddat] = uv2polar(eastdat,northdat)
      dirdat = nc{dirvarname}(:) + mvar;
      beyond = find(dirdat<0);
      dirdat(beyond) = dirdat(beyond) + 360;
      beyond = find(dirdat>360);
      dirdat(beyond) = dirdat(beyond) - 360;
      [eastdat,northdat] = polar2uv(dirdat,spddat);
   end
   
   inname{nvarin+1} = name(invar); 
   inname{nvarin+2} = name(invar); 
   inname{nvarin+3} = name(invar); 
   inname{nvarin+4} = name(invar); 
   epname{nvarin+1} = spdvarname; 
   epname{nvarin+2} = dirvarname; 
   epname{nvarin+3} = eastvarname; 
   epname{nvarin+4} = northvarname;
   eval (['newvar' num2str(nvarin+1) ' = spddat;' ]);
   eval (['newvar' num2str(nvarin+2) ' = dirdat;' ]);
   eval (['newvar' num2str(nvarin+3) ' = eastdat;' ]);
   eval (['newvar' num2str(nvarin+4) ' = northdat;' ]);
   indims = size(invar);
   newsize{nvarin+1} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarin+1} = [newsize{nvarin+1} ',1:' num2str(indims(idims))];
   end
   newsize{nvarin+2} = newsize{nvarin+1};
   newsize{nvarin+3} = newsize{nvarin+1};
   newsize{nvarin+4} = newsize{nvarin+1};
	eps = netcdf('ep_standard.nc');
	if isempty(eps)
	   [epsfile,epspath] = uigetfile('*.nc','Choose epic standard file');
	   eps = netcdf(epsfile);
	   if isempty(eps)
	      disp (['Cannot open epic standard file ' epsfile]);
	      disp (['Execution ends.']);
	      ncclose;
	      return;
	   end
   end
   for i=1:4
      vardesc = [vardesc ':' eps{epname{nvarin+i}}.name(:)];
   end
   
	close (eps)
   
case 9
   histcomment = 'Current rotated by dolly.m, ';
   
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
  
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
   
   %Get variables to operate on.
	if running(batch)
	   str = get(batch);
	   eval(['theta = ' str ';']);      
	   str = get(batch);
      eval(['use_polar = ' str ';']);  
      str = get(batch);
      eval(['dirvarname = ' str ';']);
      str = get(batch);
      eval(['spdvarname = ' str ';']);
      str = get(batch);
      eval(['eastvarname = ' str ';']);
      str = get(batch);
      eval(['northvarname = ' str ';']);
   else
      rotate.angle = 180.;
      rotate.use_polar = 1;
      rotate.current_direction = 'CD_310';
      rotate.current_speed = 'CS_300';
      rotate.current_east = 'u_1205';
      rotate.current_north = 'v_1206';
      rval = rotate;
      rotate = guido(rval,'Magnetic variation parameters');
	   theta = rotate.angle;      
      use_polar = rotate.use_polar;  
      dirvarname = rotate.current_direction;
      spdvarname = rotate.current_speed;
      eastvarname = rotate.current_east;
      northvarname = rotate.current_north;
   end
   histcomment = [histcomment 'heading increased by ' num2str(theta) ]   
   nvarout = nvarin+4;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   if use_polar
      spdvar = nc{spdvarname};
      spdvar = autonan(spdvar,1);
      dirvar = nc{dirvarname};
      dirvar = autonan(dirvar,1);
      invar = nc{spdvarname};
      dirdat = dirvar(:) + theta;
      beyond = find(dirdat<0);
      dirdat(beyond) = dirdat(beyond) + 360;
      beyond = find(dirdat>360);
      dirdat(beyond) = dirdat(beyond) - 360;
      spddat = spdvar(:);
      [eastdat,northdat] = polar2uv(dirdat,spddat);
   else
      eastvar = nc{eastvarname};
      eastvar = autonan(eastvar,1);
      northvar = nc{northvarname};
      northvar = autonan(northvar,1);
      invar = nc{eastvarname};
      eastdat = eastvar(:);
      northdat = northvar(:);
      [dirdat,spddat] = uv2polar(eastdat,northdat);
      dirdat = dirdat + theta;
      beyond = find(dirdat<0);
      dirdat(beyond) = dirdat(beyond) + 360;
      beyond = find(dirdat>360);
      dirdat(beyond) = dirdat(beyond) - 360;
      [eastdat,northdat] = polar2uv(dirdat,spddat);
   end
   
   inname{nvarin+1} = name(invar); 
   inname{nvarin+2} = name(invar); 
   inname{nvarin+3} = name(invar); 
   inname{nvarin+4} = name(invar); 
   epname{nvarin+1} = spdvarname; 
   epname{nvarin+2} = dirvarname; 
   epname{nvarin+3} = eastvarname; 
   epname{nvarin+4} = northvarname;
   eval (['newvar' num2str(nvarin+1) ' = spddat;' ]);
   eval (['newvar' num2str(nvarin+2) ' = dirdat;' ]);
   eval (['newvar' num2str(nvarin+3) ' = eastdat;' ]);
   eval (['newvar' num2str(nvarin+4) ' = northdat;' ]);
   indims = size(invar);
   newsize{nvarin+1} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarin+1} = [newsize{nvarin+1} ',1:' num2str(indims(idims))];
   end
   newsize{nvarin+2} = newsize{nvarin+1};
   newsize{nvarin+3} = newsize{nvarin+1};
   newsize{nvarin+4} = newsize{nvarin+1};
	eps = netcdf('ep_standard.nc');
	if isempty(eps)
	   [epsfile,epspath] = uigetfile('*.nc','Choose epic standard file');
	   eps = netcdf(epsfile);
	   if isempty(eps)
	      disp (['Cannot open epic standard file ' epsfile]);
	      disp (['Execution ends.']);
	      ncclose;
	      return;
	   end
   end
   for i=1:4
      vardesc = [vardesc ':' eps{epname{nvarin+i}}.name(:)];
   end
   
	close (eps)
   
case 10
   histcomment = 'Scalar averaged to new time base by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   %Choose start and stop times and interval.
	if running(batch)
	   str = get(batch);
	   eval(['Interval.start = ' str ';']);      
	   str = get(batch);
	   eval(['Interval.time_step_seconds = ' str ';']);      
   else
      Interval.start = nc.start_time(:);
      Interval.time_step_seconds = 3600;
      Ival = Interval;
      Interval = guido(Ival,'New file time base');
   end
   
	%Investigate input time base.
	time = nc{'time'}(:);
	time2 = nc{'time2'}(:);
	tsecs = time*86400 + time2/1000;
	tdifs = diff(tsecs);
	[theMode, theCount]=modecount(tdifs)%;
	incount = length(time);
	
	outstep = Interval.time_step_seconds;
	%Create a netcdf variable with a regular time base which 
	%  is close to the input data interval but a simple fraction of 
	%  the output data time interval.
	avcount = round(outstep/mean(theMode))%;
	regstep = outstep/avcount/86400%;
	regfirst = datenum(Interval.start)%;
	secsfirst = regfirst*86400;
	secsmax = 86400*ep_datenum([time(incount) time2(incount)]);
	regcount = avcount * fix((secsmax-secsfirst)/outstep);
	reglast = regfirst + regcount*regstep - regstep;
	regtime = [regfirst:regstep:reglast].';
	regeptime = EP_Time(regtime);

	regc = netcdf('scratch.nc','clobber');
	regc('time') = 0;
	regc{'time'} = nclong('time');
	regc{'time'}.units = ncchar('True Julian Day');
	regc{'time'}.type = ncchar('EVEN');
	regc{'time'}.epic_code = nclong(624);
	regc{'time2'} = nclong('time') ;
	regc{'time2'}.units = ncchar('msec since 0:00 GMT');
	regc{'time2'}.type = ncchar('EVEN');
	regc{'time2'}.epic_code = nclong(624);
	regc{'count'} = nclong('time') ;
	endef(regc)
	nreg = length(regtime);
	regc{'time'}(1:nreg) = regeptime (:,1);
	regc{'time2'}(1:nreg) = regeptime (:,2);
	regc{'count'}(1:nreg) = [1:nreg];
	n = nreg/avcount;

	%Create new time base
	time = regc{'time'}(:);
	time2 = regc{'time2'}(:);
	invar = ep_datenum([time time2]);
	varray = reshape(invar,avcount,n);
	outvar = mean((varray)).';
	eptime = EP_Time(outvar);
	time = eptime (:,1);
   time2 = eptime (:,2);
	att_start_time = datestr(outvar(1));
	att_stop_time = datestr(outvar(length(outvar)));
	ntimes = length(time);
	att_delta_t = outstep;

   nvarout = nvarin;
   for i = 1: nvarin;
      ivar = nc{chosen{i}};
      ivar = autonan(ivar,1);
      epname{i} = name(ivar);
      inname{i} = name(ivar);
      indims = size(ivar);
      newsize{i} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{i} = [newsize{i} ',1:' num2str(indims(idims))]%;
      end
      vardesc = [ vardesc ':' ivar.name(:)];
   	% Use timterp to make input variables have regular time base.
      invar = timterp(ivar,regc{'count'});
      for idepth = 1:indims(2);
      	%Reshape and average.
      	data = invar(:,idepth,1,1);
      	varray = reshape(data,avcount,n);
      	outvar = mean((varray)).';
   		eval (['newvar' num2str(i) '(:,idepth) = outvar;' ]);
      end
   end
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
case 11
   histcomment = 'Speed and direction calculated by dolly.m ';
   
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
   ndepths = length(depth)
   
   
   %Get variables to operate on.
	if running(batch)
      str = get(batch);
      eval(['eastvarname = ' str ';']);
      str = get(batch);
      eval(['northvarname = ' str ';']);
      str = get(batch);
      eval(['dirvarname = ' str ';']);
      str = get(batch);
      eval(['spdvarname = ' str ';']);
   else
      addpolar.current_east = 'u_1205';
      addpolar.current_north = 'v_1206';
      addpolar.current_direction = 'CD_310';
      addpolar.current_speed = 'CS_300';
      rval = addpolar;
      addpolar = guido(rval,'Input/output variable names');
      dirvarname = addpolar.current_direction;
      spdvarname = addpolar.current_speed;
      eastvarname = addpolar.current_east;
      northvarname = addpolar.current_north;
   end
   histcomment = [dirvarname ' and ' spdvarname ' calculated from ']   
   histcomment = [histcomment eastvarname ' and ' northvarname ' by Dolly.m ']   
   nvarout = nvarin+4;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   eastvar = nc{eastvarname};
   eastvar = autonan(eastvar,1);
   northvar = nc{northvarname};
   northvar = autonan(northvar,1);
   invar = nc{eastvarname};
   eastdat = eastvar(:);
   northdat = northvar(:);
   [dirdat,spddat] = uv2polar(eastdat,northdat);
   
   inname{nvarin+1} = name(invar); 
   inname{nvarin+2} = name(invar); 
   inname{nvarin+3} = name(invar); 
   inname{nvarin+4} = name(invar); 
   epname{nvarin+1} = spdvarname; 
   epname{nvarin+2} = dirvarname; 
   epname{nvarin+3} = eastvarname; 
   epname{nvarin+4} = northvarname;
   eval (['newvar' num2str(nvarin+1) ' = spddat;' ]);
   eval (['newvar' num2str(nvarin+2) ' = dirdat;' ]);
   eval (['newvar' num2str(nvarin+3) ' = eastdat;' ]);
   eval (['newvar' num2str(nvarin+4) ' = northdat;' ]);
   indims = size(invar);
   newsize{nvarin+1} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarin+1} = [newsize{nvarin+1} ',1:' num2str(indims(idims))];
   end
   newsize{nvarin+2} = newsize{nvarin+1};
   newsize{nvarin+3} = newsize{nvarin+1};
   newsize{nvarin+4} = newsize{nvarin+1};
	eps = netcdf('ep_standard.nc');
	if isempty(eps)
	   [epsfile,epspath] = uigetfile('*.nc','Choose epic standard file');
	   eps = netcdf(epsfile);
	   if isempty(eps)
	      disp (['Cannot open epic standard file ' epsfile]);
	      disp (['Execution ends.']);
	      ncclose;
	      return;
	   end
   end
   for i=1:4
      vardesc = [vardesc ':' eps{epname{nvarin+i}}.name(:)];
   end
   
   close (eps)
   
case 12
   histcomment = 'OBS concentration calculated by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   OBSvarname = 'time';
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
      if strncmp('Trb',chosen{ivar},3)
         OBSvarname = chosen{ivar};
      end
   end
   
   %Get necessary constants.
	if running(batch)
	   str = get(batch);
	   eval(['OBSvarname = ' str ';']);      
	   FNU = nc{OBSvarname}(:);
	   str = get(batch);
	   eval(['slope = ' str ';']);      
	   str = get(batch);
      eval(['intercept = ' str ';']); 
      str = get(batch);
      eval(['OBS_id = ' str ';']);
   else
      Conc.OBSvarname = OBSvarname;
      Conc.slope = 1.5;
      Conc.intercept = 0;
      Conc.OBS_id = nc{OBSvarname}.serial_number(:); 
      Cval = Conc;
      Conc = guido(Cval,'OBS concentration parameters');
      FNU = nc{Conc.OBSvarname}(:);
      OBSvarname = Conc.OBSvarname;
   	slope = Conc.slope;
      intercept = Conc.intercept;
      OBS_id = Conc.OBS_id;
   end
   
   %Calculate OBS concentration.
   mGpL = (slope * FNU) + intercept;
   GpL = mGpL/1000.;
   nvarout = nvarout+1;
   sedvarname = 'Sed_981';
   epname{nvarout} = sedvarname;
   inname{nvarout} = OBSvarname;
   vardesc = [ vardesc ':Sed'];
   eval(['newvar' num2str(nvarout) '= GpL;']);
   indims = size(nc{OBSvarname});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
   
case 13
   histcomment = 'Decimal Year Day variable added by dolly.m.';
   
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   
   %Calculate Decimal Year Days.
   day1 = ep_datenum([time(1) time2(1)]);
   [Y,M,D,H,MI,S] = datevec(day1);
   time0 = ep_time([Y-1 12 31]);
   yrday = time - time0(1);
   msecperday = 1000*60*60*24%;
   DYD = yrday + time2/msecperday;
   nvarout = nvarout+1;
   newvarname = 'TIM_601';
   epname{nvarout} = newvarname;
   inname{nvarout} = inname{1};
   vardesc = [ vardesc ':TIM'];
   eval(['newvar' num2str(nvarout) '= DYD;']);
   indims = size(nc{'time'});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
  
case 14
   histcomment = 'New time base by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
   
   %Make new time base.
   Yr = nc{'Yr'}(:);
  	if max(Yr) < 1000.
        Yr = Yr + 1900;
    end
    Mo = nc{'Mo'}(:);
	Da = nc{'Da'}(:);
	Hr = nc{'Hr'}(:);
    Mi = nc{'Mi'}(:);
    Se = nc{'Se'}(:);
	if length(Mi) < length(Yr)
        Mi = 0.;
    end
	if length(Se) < length(Yr)
        Se = 0.;
    end
	timenum = datenum(Yr,Mo,Da,Hr,Mi,Se);
   alltime = EP_Time(timenum);
	time = alltime(:,1);
   time2 = alltime(:,2);
   ntimes = length(time);
   
   att_delta_t = 'irregular';
	att_start_time = datestr(timenum(1),0);
   att_stop_time = datestr(timenum(ntimes),0);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin%;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
   end
   
case 15
    histcomment = 'Chlorophyll concentration calculated by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   voltsname = 'time';
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
      if strncmp('rCv',chosen{ivar},3)
         voltsname = chosen{ivar};
      elseif strncmp('vws',chosen{ivar},3)
         voltsname = chosen{ivar};
      elseif strncmp('Fvt',chosen{ivar},3)
         voltsname = chosen{ivar};
    end
   end
   
   %Get necessary constants.
	if running(batch)
	   str = get(batch);
	   eval(['voltsname = ' str ';']);      
	   Cvolts = nc{voltsname}(:);
      str = get(batch);
      eval(['Chlor_id = ' str ';']);
      str = get(batch);
      eval(['SF = ' str ';']);
      str = get(batch);
      eval(['CWO = ' str ';']);
      str = get(batch);
      eval(['Cvarname = ' str ';']);
   else
      Chl.voltsname = voltsname;
      Chl.inst_id = nc{voltsname}.serial_number(:); 
      Chl.SF = 17.6616;
      Chl.Cvarname = 'CA3_937';
      Chl.CWO = 0.07;
      Cval = Chl;
      Chl = guido(Cval,'Chlorophyll parameters');
      Cvolts = nc{Chl.voltsname}(:);
      voltsname = Chl.voltsname;
      Chlor_id = Chl.inst_id;
      SF = Chl.SF;
      CWO = Chl.CWO;
      Cvarname = Chl.Cvarname;
   end
   
   %Calculate chlorophyll concentration.
   conc = (Cvolts - CWO)*SF;
   nvarout = nvarout+1;
      epname{nvarout} = Cvarname;
   inname{nvarout} = voltsname;
   str = Cvarname(1:3);
   vardesc = [ vardesc ':' str];
   eval(['newvar' num2str(nvarout) '= conc;']);
   indims = size(nc{voltsname});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
 
case 16
   histcomment = 'Salinity calculated by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   havetemp = 0;
   havecond = 0;
   havepres = 0;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
      if strncmp('T_',chosen{ivar},2)
         tempname = chosen{ivar};
         tcel = nc{tempname}(:);
         havetemp = 1;
      end
      if strncmp('C_',chosen{ivar},2)
         condname = chosen{ivar};
         if nc{condname}.epic_code(1) == 50;
             cmmho = nc{condname}(:);
             havecond = 1;
         elseif nc{condname}.epic_code(1) == 51;
             cmmho = 10 .* nc{condname}(:);
             havecond = 1;
         end
      end
      if strncmp('P_',chosen{ivar},2)
         presname = chosen{ivar};
         if nc{presname}.epic_code(1) == 1;
             prdbar = nc{presname}(:);
             havepres = 1;
         elseif nc{presname}.epic_code(1) == 4023;
             prdbar = nc{presname}(:) ./ 100. - 10.1325;
             havepres = 1;
         end
      end
   end
   
   %Get necessary constants.
	 if ~havetemp
			if running(batch)
			   str = get(batch);
   			eval(['tcel = ' str ';']);      
			else
	         UserValueT.temperature = 10;
   	      c = UserValueT;
      	   UserValueT = guido(c,'Input temperature, degrees Celsius');
            tcel = UserValueT.temperature;
         end
         calcomment = [calcomment 'Constant temperature of '...
               num2str(tcel) ' Celsius used for salinity. '];
     end
      if ~havepres
			if running(batch)
			   str = get(batch);
   			eval(['prdbar = ' str ';']);      
			else
	         UserValueP.pressure = 1000;
   	      c = UserValueP;
      	   UserValueP = guido(c,'Input pressure depth in dbar.');
            prdbar = UserValueP.pressure;
         end
         calcomment = [calcomment 'Constant pressure of '...
               num2str(prdbar) ' dbar used for salinity. '];
      end
  
   %Calculate salinity.
    % the pss1978 and sw_salt rountines produce indistinguishable results
    % so am continuing to use Fran's routine for continuity.
	 sal = pss1978(cmmho,tcel,prdbar);
    % sal = sw_salt(cmmho/sw_c3515,tcel,prdbar);
    nvarout = nvarout+1;
    epname{nvarout} = 'S_41';
    inname{nvarout} = condname;
    vardesc = [ vardesc ':S'];
   eval(['newvar' num2str(nvarout) '= sal;']);
   indims = size(nc{condname});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
   
   
case 17
   histcomment = 'Sigma theta calculated by dolly.m.';
	% Which variables should be kept?
   [nvarin,chosen] = em_dollyvar(nc,do_allvars);
      
   %Make new time base.
   time = nc{'time'}(:);
   time2 = nc{'time2'}(:);
   att_delta_t = nc.DELTA_T(:);
	att_start_time = nc.start_time(:);
   att_stop_time = nc.stop_time(:);
   ntimes = length(time);
   
   depth = nc{'depth'}(:);
	ndepths = length(depth)
   
   %Pass through input variables.
   nvarout = nvarin;
   havetemp = 0;
   havecond = 0;
   havepres = 0;
   for ivar = 1:nvarin;
      invar = nc{chosen{ivar}};
      invar = autonan(invar,1);
		vardesc = [vardesc ':' invar.name(:)];
      inname{ivar} = name(invar);
      epname{ivar} = inname{ivar};
      eval (['newvar' num2str(ivar) ' = invar(:);' ]);
      indims = size(invar);
      newsize{ivar} = ['1:' num2str(ntimes) ];
      for idims = 2:length(indims)
         newsize{ivar} = [newsize{ivar} ',1:' num2str(indims(idims))];
      end
      if strncmp('T_',chosen{ivar},2)
         tempname = chosen{ivar};
         tcel = nc{tempname}(:);
         havetemp = 1;
      end
      if strncmp('S_',chosen{ivar},2)
         salname = chosen{ivar};
         sal = nc{salname}(:);
         havesal = 1;
      end
      if strncmp('P_',chosen{ivar},2)
         presname = chosen{ivar};
         if nc{presname}.epic_code(1) == 1;
             prdbar = nc{presname}(:);
             havepres = 1;
         elseif nc{presname}.epic_code(1) == 4023;
             prdbar = nc{presname}(:) ./ 100. - 10.1325;
             havepres = 1;
         end
      end
   end
   
   %Get necessary constants.
	 if ~havetemp
			if running(batch)
			   str = get(batch);
   			eval(['tcel = ' str ';']);      
			else
	         UserValueT.temperature = 10;
   	      c = UserValueT;
      	   UserValueT = guido(c,'Input temperature, degrees Celsius');
            tcel = UserValueT.temperature;
         end
         calcomment = [calcomment 'Constant temperature of '...
               num2str(tcel) ' Celsius used for sigma theta. '];
     end
      if ~havepres
			if running(batch)
			   str = get(batch);
   			eval(['prdbar = ' str ';']);      
			else
	         UserValueP.pressure = 1000;
   	      c = UserValueP;
      	   UserValueP = guido(c,'Input pressure depth in dbar.');
            prdbar = UserValueP.pressure;
         end
         calcomment = [calcomment 'Constant pressure of '...
               num2str(prdbar) ' dbar used for sigma theta. '];
      end
      if ~havesal
			if running(batch)
			   str = get(batch);
   			eval(['sal = ' str ';']);      
			else
	         UserValueP.salinity = 34.;
   	      c = UserValueP;
      	   UserValueP = guido(c,'Input salinity in ppt.');
            sal = UserValueP.salinity;
         end
         calcomment = [calcomment 'Constant salinity of '...
               num2str(sal) ' ppt used for sigma theta. '];
      end
  
   %Calculate sigma theta.
	pden0 = sw_pden(sal,tcel,prdbar,0) - 1000.;
    nvarout = nvarout+1;
    epname{nvarout} = 'STH_71';
    inname{nvarout} = salname;
    vardesc = [ vardesc ':STH'];
   eval(['newvar' num2str(nvarout) '= pden0;']);
   indims = size(nc{salname});
   newsize{nvarout} = ['1:' num2str(ntimes) ];
   for idims = 2:length(indims)
      newsize{nvarout} = [newsize{nvarout} ',1:' num2str(indims(idims))];
   end
   
   
otherwise
   disp ('No task chosen.  Execution ends.')
   return
end
% Open output cdf
outc = netcdf(outfile,'noclobber');
if isempty(outc)
   [outfile,outpath] = uiputfile('*.nc','Choose output file');
   outc = netcdf(fullfile(outpath,outfile),'noclobber'); % MM 11/18/04 add path 
   if isempty(outc)
      disp (['Cannot open output file ' outfile]);
      disp (['Data will be parked in temporary.nc']);
      outc = netcdf('temporary.nc','clobber');
   end
end

% Which global attributes should be kept?
if running(batch)
   str = get(batch);
   eval(['ngatts = ' str ';']);      
   for i = 1:ngatts;
      str = get(batch);
      eval(['gatt{i} = ' str ';']);
      eval(['keepatts{i} = nc.' gatt{i} ';']);
   end
elseif (strcmp(upper(keepallvars(1)),'Y'))  % skip attribute selection, if keepallvars set
   keepatts = att(nc);
   ngatts=length(keepatts);
else	   
   ingatts = att(nc);
   halflist = floor(length(ingatts)/2);
   for i = 1:halflist
      eval (['attlist.',name(ingatts{i}),'={''checkbox'' 1};'])
   end
   alist = attlist;
   attlist = guido(alist,'Which global atts should be kept?');
   ngatts = 0;
   for i = 1:halflist
      eval (['tf = attlist.',name(ingatts{i}),'{2};'])
	   if tf
         ngatts = ngatts+1;
         keepatts{ngatts}=ingatts{i};
		end   
   end
   clear attlist;
   for i = halflist+1:length(ingatts)
      eval (['attlist.',name(ingatts{i}),'={''checkbox'' 1};'])
   end
   alist = attlist;
   attlist = guido(alist,'Which global atts should be kept?');
   for i = halflist+1:length(ingatts)
      eval (['tf = attlist.',name(ingatts{i}),'{2};'])
	   if tf
         ngatts = ngatts+1;
         keepatts{ngatts}=ingatts{i};
		end   
	end
end

% Copy global attributes from input file to output file.
for i = 1 : ngatts;
   copy(keepatts{i},outc);
end

%Update global attributes and variables in output file.
history =[histcomment ':' nc.history(:)];  
outc.history = history;
vardesc(1) = '';
outc.VAR_DESC = ncchar(vardesc);
outc.CREATION_DATE = ncchar(datestr(now,0));
outc.DELTA_T = att_delta_t;
outc.start_time = att_start_time;
outc.stop_time = att_stop_time;
if isequal(Main.task{2},8)
   outc.magnetic_variation = ncfloat(mvar);
end


%% Dimensions:
outc('time') = 0;
outc('depth') = ndepths;
outc('lon') = 1;
outc('lat') = 1;
 
 %% Variables and attributes:
copy(nc{'time'},outc,0,1);
copy(nc{'time2'},outc,0,1);
copy(nc{'depth'},outc,0,1);
copy(nc{'lon'},outc,0,1);
copy(nc{'lat'},outc,0,1);


eps = netcdf('ep_standard.nc');
% check in the dolly root directory for ep_standard MM 11/15/04
if isempty(eps),
    [dpath, dname, dext, dver] = fileparts(mfilename('fullpath'));
    disp(sprintf('Found epic standard in %s',dpath))
    eps = netcdf(fullfile(dpath,'ep_standard.nc'));
end
if isempty(eps)
   [epsfile,epspath] = uigetfile('*.nc','Choose epic standard file');
   eps = netcdf([epspath,epsfile]);
   if isempty(eps)
      disp (['Cannot open epic standard file ' epsfile]);
      disp (['Execution ends.']);
      ncclose;
      return;
   end
end

for i = 1: nvarout;
   disp (['creating output variable ' epname{i}]);
   ivar = nc{epname{i}};
   epvar = eps{epname{i}};
   if ~isempty(ivar)
      copy(ivar,outc,0,1);
   elseif ~isempty(epvar)
      copy(epvar,outc,0,1);
   else
      display (['Variable ' epname{i} ' not found in ep_standard.nc. Execution ends.'])
      ncclose 
      return
   end
end
close (eps)

for i = 1:nvarout
   disp (['updating attributes of variable ' epname{i}]);
	ovar = outc{epname{i}};
   ivar = nc{inname{i}};
   try
      ovar.sensor_depth = ivar.sensor_depth(:);
   end
   try
      ovar.serial_number = ivar.serial_number(:);
   end
	eval (['ovar.minimum = ncfloat(min(newvar' num2str(i) '));']);
   eval (['ovar.maximum = ncfloat(max(newvar' num2str(i) '));']);
end
switch Main.task{2}
case 3
   outc{tranvarname}.serial_number = ncchar(trans_id);
   outc{attvarname}.serial_number = ncchar(trans_id);
   outc{attvarname}.Vair = ncdouble(Vair);
   outc{attvarname}.focal_length = ncdouble(len);
   str = ['ATTN = -(1/focal_length).* log(' tranvarname './(.95*Vair))'];
   outc{attvarname}.comment = ncchar(str);
case 12
   outc{OBSvarname}.serial_number = ncchar(OBS_id);
   outc{sedvarname}.serial_number = ncchar(OBS_id);
   outc{sedvarname}.m = ncdouble(slope);
   outc{sedvarname}.b = ncdouble(intercept);
   str = ['Sed= (m * ' OBSvarname ' + b)/1000'];
   outc{sedvarname}.comment = ncchar(str);
case 15
   outc{voltsname}.serial_number = ncchar(Chlor_id);
   outc{Cvarname}.serial_number = ncchar(Chlor_id);
   str = ['CA3 = ( ' voltsname ' - 0.07 ) * 17.6616'];
   outc{Cvarname}.comment = ncchar(str);
case 16
    outc{'S_40'}.comment = ncchar(calcomment);
case 17
    outc{'STH_71'}.comment = ncchar(calcomment);
end

endef(outc)

outc{'lat'}(1) = nc{'lat'}(1);
outc{'lon'}(1) = nc{'lon'}(1);
outc{'depth'}(1:ndepths) = depth;
outc{'time'}(1:ntimes) = time;
outc{'time2'}(1:ntimes) = time2;

for i = 1:nvarout
    if length(size(outc{epname{i}})) == 4,
        ovar = outc{epname{i}};
        ovar = autonan(ovar,1);
        eval (['ovar(' newsize{i} ') = newvar' num2str(i) ';' ]);
    else
        % added by MM 5/25/06
        copy(nc{epname{i}}, outc, 1, 1);
    end
end
close (nc);
close (outc);
