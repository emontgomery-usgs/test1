%script do_EPIC_cvt.m
% DO_EPIC_CVT: convert all the .cdf files in a directory to EPIC
%
% makes repeated calls to fix_buoy_ts.m to convert to EPIC

% find the .cdf files in cwd
fil=dir;
    for ik=1:length(fil)-2
        iscdf=~isempty(strfind(fil(ik+2).name, '.cdf'));
        if  iscdf
            files{ik}=fil(ik+2).name;
        end
    end
    % run fix_buoy_ts on them
    for jj=1:length(files)
        nd=fix_buoy_ts(files{jj});
        if nd==0; return; end
    end

