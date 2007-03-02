function [newvarin,newchosen] = em_dollyvar(nc, allflag)
% called by em_dolly- not for standalone use.
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


	if running(batch)
	   str = get(batch);
      eval(['nvarin = ' str ';']); 
      for i = 1:nvarin;
	      str = get(batch);
	      eval(['chosen{i} = ' str ';']);
	   end
	else
	   
		invars = ncnames(var(nc));
      if(allflag)
	    nvarin = length(invars);
		chosen=invars;          
      else    
		for i = 1:length(invars)
		   eval (['varlist.',invars{i},'={''checkbox'' 0};'])
		end
		vlist = varlist;
		varlist = guido(vlist,'Which variables should be kept?');
		nvarin = 0;
		for i = 1:length(invars)
		   eval (['tf = varlist.',invars{i},'{2};'])
		   if tf
		      nvarin = nvarin+1;
		      chosen{nvarin}=invars{i};
		   end   
        end
      end
   end
% Check for dimension variables.
dimvars = strvcat('time','time2','depth','lon','lat');
newvarin = 0;
for i = 1:nvarin;
    dimmatch = strmatch(chosen{i},dimvars,'exact');
    if isempty(dimmatch)
	    newvarin = newvarin+1;
        newchosen{newvarin}=chosen{i};
	end   
end
if newvarin == 0;
    newvarin = nvarin;
    newchosen = chosen;
end

