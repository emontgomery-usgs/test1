function [stat,rev_no]=get_svn_rev(fname)
%  GET_SVN_REV: return the subversion revision number of a file
%
%  this program can be used to get the revison number of a program- which
%  can then be put in a .history attribute or other metadata field
%
%  usage rev_no=get_svn_rev(fname)
%   where fname is the name of the m file called from and rev_no is the
%   subversion revision number associated with that file.
%
% emontgomery@usgs.gov

rev_info= $Revision$;
% all the version info is in a dir_root/.svn/all-wcprops file
% by parsing the full path name returned by which, you can create the name
% to get information from
fullname=which(fname);

% set the salahes to point the right direction (PC will do either, but not
% both!
if ispc
    slash='\';
else
    slash='/';
end

locs=findstr(slash,fullname);
infoname=[fullname(1:locs(end)) '.svn' slash 'all-wcprops'];

if isunix     % use grep
    % the retuned lines will be in v
    [s,v]=system(['grep ' fname ' ' infoname])

    if isempty(v)
        disp('the name does not match the repository record- returning 0')
        stat=0;
        rev_no=0;
    else
        stat=1;
        % something like this will be returned
        %   /cmgsoft/m_cmg/!svn/ver/846/trunk/sonarlib/mkrawcdf.m
        rnloc=findstr('/ver/',v)+5;  % +5 puts index at the end of/ver/
        rnlocend=findstr('/',v(rnloc:end));
        rev_no=v(rnloc:rnloc+rnlocend(1)-2);
    end
end

