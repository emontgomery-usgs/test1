function [theMaskFile,velR,corT,echI,Pgd]=fillmsk(theDataFile,theMaskFile,velR,corT,echI,Pgd);

%function [theMaskFile,velR,corT,echI,Pgd]=...
%...fillmsk(theDataFile,theMaskFile,velR,corT,echI,Pgd);
%Scans a raw ADCP Workhorse data file and marks the mask file to 
%meet the good data criteria standards set by RDI 
%correlation threshold, echo intensity threshold, minimum percent good.
%Where:
%		theDataFile= the raw ADCP data file in netcdf
%		theMaskFile= Mask file created with ncmakemsk.m
%			If no mask is given you will be asked to create one.
%	
%	The min and max range for the following variables are optional inputs.
%	If not given the function will look in the netcdf file and find 
%	the pre-recorded values set prior to deployment.
%		velR=[min max] velocity
%		corT= [min max] corrleation threshold
%		echI= [min max] echo intensity
%		Pgd= [min max] percent good
%


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. Côté, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andrée L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

 

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov
%
%Sub-programs
%	ncmkmask.m
%	premask.m-5/21/99 need the version of premask.m edited by JMC

% version 1.0
% updated 14-mar-2008 MM - allow masking in earth case, don't get hung up on
% percent good
% updated 13-Oct-1999 16:43:41
% modified 17-Feb-2004 by ALR - if waves software has turned the Echo
% Intensiy off, fillmask will set the echo intensity to [50 255] to process
% the data.

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1051 $';
disp(sprintf('%s %s running',mfilename,rev_info))

if nargin<1, theDataFile = ''; end
if nargin<2, theMaskFile = ''; end

if isempty(theDataFile), theDataFile = '*'; end
if isempty(theMaskFile), theMaskFile = '*'; end

if any(theDataFile == '*')
   help(mfilename)
   thePrompt = theDataFile;
   [theFile, thePath] = uigetfile(thePrompt, 'Select ADCP Data File');
   if ~any(theFile), return, end
   if thePath(end) ~= filesep, thePath(end+1) = filesep; end
   theDataFile = [thePath theFile];
   cd(thePath)
end

if any(theMaskFile == '*')
   thePrompt = theMaskFile;
   [theFile, thePath] = uigetfile(thePrompt, 'Select ADCP Mask File');
   
   %Check to see if there is a mask file, if not ask to create
   if ~any(theFile) 
      prompt={'Do you want to create a mask file now?'};
   title='Mask File Not Found';
   lineNo=1;
   DefAns={'Yes'};
   dlgresult=inputdlg(prompt,title,lineNo,DefAns);
   if char(dlgresult{:})=='Yes';
      [p, outFile, ext, v] = fileparts(theDataFile);
		theMaskFile = [outFile '.msk'];
      %ncmkmask(theDataFile,theMaskFile);
      mkadcpmask(theDataFile,theMaskFile);
      disp(['The Mask file ' theMaskFile ' was created'])
      else 
         disp(['You must create a mask file to run fillmsk function'])
         return, end
   end
   if thePath(end) ~= filesep, thePath(end+1) = filesep; end
   theMaskFile = [thePath theFile];
end

f = netcdf(theDataFile, 'write'); % Open the file.
if isempty(f), return, end 


if nargin < 3
        
	%Just autonan the velocities
	for ii=1:4;
  		v=autonan(f{['vel' int2str(ii)]},1);
  		eval(['vd' num2str(ii) '=v(:);'])
	end

	%check to make sure that the autonan worked
	check=length(isnan(vd1));
	if isempty(check)
   	disp(['error executing autonan function'])
	end


	%Get the max and min of the velocities of the four beams 
	%to set some criteria for masking
	disp(['Pulling out the needed Global attributes from the Data file'])
	disp(['This information sets the criteria for masking'])
	vlim=ones(4,2);
	[ii,jj]=size(vlim);
	for i=1:ii;
	   eval(['vlim(i,1)=min(min(vd' int2str(i) '));'])
	   eval(['vlim(i,jj)=max(max(vd' int2str(i) '));'])
	end
	vmin=min(min(vlim))/10; %in cm/sec for premask
	vmax=max(max(vlim))/10;
	velR=[vmin vmax];

	%Undo autonan the velocities
	for ii=1:4;
	  v=autonan(f{['vel' int2str(ii)]},0);
	  eval(['vd' num2str(ii) '=v(:);'])
	end

	%To get global attribute data for use in premask
        % from TRDI March 05 command and output format manual
        % The percent-good data field is a data-quality indicator that reports the percentage
        % (0 to 100) of good data collected for each depth cell of the velocity
        % profile. The setting of the EX-command (Coordinate Transformation) determines
        % how the Workhorse references percent-good data as shown below.
        % EX-Command Coord. Sys  Velocity 1 Velocity 2 Velocity 3 Velocity 4
        %                               Percentage Of Good Pings For:
        %                               Beam 1 BEAM 2 BEAM 3 BEAM 4
        % xxx00xxx Beam                     Percentage Of: 
        % xxx01xxx Inst             3-Beam  Transformations    More Than One  4-Beam Transformations
        % xxx10xxx Ship     Transformations Rejected (note 2) Beam Bad In Bin
        % xxx11xxx Earth        (note 1)
        % 1. Because profile data did not exceed correlation threshold (WC).
        % 2. Because the error velocity threshold (WE) was exceeded.
        % At the start of the velocity profile, the backscatter echo strength is typically
        % high on all four beams. Under this condition, the Workhorse uses all four
        % beams to calculate the orthogonal and error velocities. As the echo returns
        % from far away depth cells, echo intensity decreases. At some point, the
        % echo will be weak enough on any given beam to cause the Workhorse to
        % reject some of its depth cell data. This causes the Workhorse to calculate
        % velocities with three beams instead of four beams. When the Workhorse
        % does 3-beam solutions, it stops calculating the error velocity because it
        % needs four beams to do this. At some further depth cell, the Workhorse rejects
        % all cell data because of the weak echo. As an example, let us assume
        % depth cell 60 has returned the following percent-good data.
        % FIELD #1 = 50, FIELD #2 = 5, FIELD #3 = 0, FIELD #4 = 45
        % If the EX-command was set to collect velocities in BEAM coordinates, the
        % example values show the percentage of pings having good solutions in cell
        % 60 for each beam based on the Low Correlation Threshold (WC-command).
        % Here, beam 1=50%, beam 2=5%, beam 3=0%, and beam 4=45%. These are
        % not typical nor desired percentages. Typically, you would want all four
        % beams to be about equal and greater than 25%.
        % On the other hand, if velocities were collected in INSTRUMENT, SHIP, or
        %     EARTH coordinates, the example values show:
        %     FIELD 1 – Percentage of good 3-beam solutions – Shows percentage of
        %     successful velocity calculations (50%) using 3-beam solutions because the
        %     correlation threshold (WC) was not exceeded.
        %     FIELD 2 – Percentage of transformations rejected – Shows percent of error
        %     velocity (5%) that was less than the WE-command setting. WE has a default
        %     of 5000 mm/s. This large WE setting effectively prevents the Workhorse
        %     from rejecting data based on error velocity.
        %     WorkHorse Commands and Output Data Format
        %     P/N 957-6156-00 (March 2005) page 143
        %     FIELD 3 – Percentage of more than one beam bad in bin – 0% of the velocity
        %     data were rejected because not enough beams had good data.
        %     FIELD 4 – Percentage of good 4-beam solutions – 45% of the velocity data
        %     collected during the ensemble for depth cell 60 were calculated using four
        %     beams.
    Pgd=f.minmax_percent_good(:);
    if strcmpi(f.transform(:),'BEAM'),
        if isequal(Pgd(1),0)
            Pgd = [25 Pgd(2)];
        end
    else % SHIP, INST, EARTH right now don't do anything different
        if isequal(Pgd(1),0)
            Pgd = [25 Pgd(2)];
        end
    end
    
	echI=f.false_target_reject_values(:);
    if isequal(echI(1),255)
        echI = [50 255]
        disp('Echo Intensity was turned off by Waves software.')
        disp('Values of 50 to 255 were set by the ADCP Toolbox to process file.')
      %Add in history comment
        %thecomment = sprintf('%s\n','Echo Intensity was turned off by Waves software. Values of 50 to 255 were set by the ADCP Toolbox.');
       % history(theMaskFile,thecomment);
    end
	errV=f.minmax_error_velocity(:);
	corT=f.valid_correlation_range(:);
   
end %if nargin<3;  
 
close(f)

%Let's run premask based on these criteria
%premask(theDataFile, theMaskFile, vel, cor, agc, good)
premask(theDataFile,theMaskFile,velR,corT,echI,Pgd);

%ncclose

disp(['The mask is filled '])