function S = read_met
% function out_struct = read_metKJR(basename)
% read_met reads the AirMar PB100 files and writes into a structure
%
%  It was necessary to sequence through the data like this because parsing
%  by datatype and loading straight into Matlab showed that there were an
%  uneven number of timestamps versus data points.
%load multiple files
names = dir('*.DAT');
fnames = {names(:).name};
tic
seqno = 0;

% got up to file 08114402.DAT (file 845), will start over from there
% S = struct('lat',[],'lon',[],'jd',[],'bars',[],'temp',[],'RH',[],'Wdir',[],'Wspd',[]);
for i = 1:length(fnames)   %set this to the number of data files you have
    % for i = 1:10   %for testing
    fname = fnames{i};
    metdat = fopen(fname);
    disp(['Processing file ' fname ' started at ' datestr(now)])
    %     if isempty(S(i).lat),seqno=1;else,seqno = 0;end;
    while ~feof(metdat)
        str = fgetl(metdat);
        %for incomplete strings at either the beginning or end (-1 means it
        %reached end of file), need to grab next string, and go back one on the sequence so we
        %don't have extra timestamps
        %if ~strncmp(str,'$',20)||length(str)<65,str = fgetl(metdat);seqno = seqno-1;end;if str==-1,seqno = seqno-1;break,end;
        if ~strcmp(str(20),'$'),str = fgetl(metdat);seqno = seqno-1;end;if str==-1,seqno = seqno-1;break,end;
        % in the case of the WH logger the first 20 chars are a timestamp:
        % dd/mm/yyyy hh:mm:ss, so to identify the record type you have to
        % step into the string, and the timestamp is part of the first
        % variable returned
        type_str=str(20:24);
        % ours is not configured to do GPRM, our date comes from GPZD
        if strmatch(type_str,'$GPRM')
            seqno = seqno +1;%only increment the sequence when we get a new timestamp
            [pos,raw_time,stat,S.lat(seqno),latc,S.lon(seqno),lonc,sog,cog,raw_date,mvar1,mvar1dir,mode]...
                =strread(str,'%s%s%s%n%s%n%s%n%n%s%n%s%s','delimiter',',','emptyvalue',NaN);
            DATE = char(raw_date);TIME = char(raw_time);
            day = str2double(DATE(1:2)); mo = str2double(DATE(3:4));
            yr = str2double(DATE(5:6)) + 2000;hr = str2double(TIME(1:2));
            mi = str2double(TIME(3:4));sec = str2double(TIME(5:6));
            jd = julian([yr mo day hr mi sec]);
            S.jd(seqno) = jd;
        elseif strmatch(type_str,'$HCHD')
            seqno = seqno +1; %this is the first we see in our data cycle
            [hch,S.hdg(seqno),mdd,hd_dir,mvar,var_dir,fini]=strread(str,'%s%n%n%s%n%s%s','delimiter',',','emptyvalue',NaN);
        elseif strmatch(type_str,'$GPZD')
            [att,hms,da,mo,yr,gmtoff,fini]=strread(str,'%s%s%s%s%s%s%s','delimiter',',','emptyvalue',NaN);
            S.date(seqno)=cellstr([char(mo) '/' char(da) '/' char(yr)]);
            S.day(seqno)=str2double(char(da));
            S.month(seqno)=str2double(char(mo));
            S.year(seqno)=str2double(char(yr));
            chms=char(hms);
            S.time(seqno)=cellstr([chms(1:2) ':' chms(3:4) ':' chms(5:6)]);
            S.hr(seqno)=str2double(chms(1:2));
            S.min(seqno)=str2double(chms(3:4));
            S.sec(seqno)=str2double(chms(5:6));
            dtstr=char(att);
            S.acumendate(seqno)=cellstr(dtstr(1:19));
        elseif strmatch(type_str,'$PFEC')
            [att,GPatt,GPhd,S.ptch(seqno),S.roll(seqno)]=strread(str,'%s%s%s%f%f','delimiter',',','emptyvalue',NaN);
        elseif strmatch(type_str,'$WIMD')
            [wnm,n1,c1,S.bars(seqno),c2,S.temp(seqno),c3,n4,c4,S.RH(seqno),c5,n6,c6,S.Wdir(seqno),c7,n8,c8,n9,c9,S.Wspd(seqno),c10]...
                =strread(str,'%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s%n%s','delimiter',',','emptyvalue',NaN);
            [S.east(seqno),S.north(seqno)] = cmgspd2uv(S.Wspd(seqno),S.Wdir(seqno));
        else
        end
    end
    % now print out the data as csv for JB
    % columns are: month, day, year, hour, minute, second, hdg, barPr, Temp, RelH, Wdir, Wspd, east, north.
    C=struct2cell(S);
    csvwrite('airmarWH.csv',[C{11}' C{10}' C{12}' C{14}' C{15}' C{16}' C{1}' C{2}' C{3}' C{4}' C{5}' C{6}' C{7}' C{8}'])
    % the contents of columns 9, 13 and 17 are the date, time and Acument
    % time strings that don't play nice with simple printint like this.
    %
    % here's a fancier way to do it:
    nrows=length(C{1});
    spcs={' '};
    spcs2=repmat(spcs,nrows,1);
    dst=strcat(C{9}', spcs2, C{13}', spcs2) 
    fmto=strcat(dst,num2str(C{3}'), spcs2, num2str(C{2}'), spcs2, num2str(C{4}'), spcs2);
    fmtdo=strcat(fmto,num2str(C{1}'), spcs2, num2str(C{5}'), spcs2, num2str(C{6}'), spcs2);
    fmtdout=strcat(fmtdo,num2str(C{7}'), spcs2, num2str(C{8}'))
    % columns are date, time, hdg, barPr, Temp, RelH, Wdir, Wspd, east, north
    fid=fopen('AirMarWHout.txt','W')
    for rw=1:nrows
      fprintf(fid,'%s\n', fmtdout{rw,:});
    end
   %
    disp(['Closing File ' fname])
    fclose(metdat);
    %     if rem(i,24)==0
    %         matname = ['Rawdata' num2str(i/24)];
    %         save(matname,'S');
    %         disp(['Saving data to ' matname])
    %     end
end
disp(['Processing took ',num2str(toc/60),' minutes']);
