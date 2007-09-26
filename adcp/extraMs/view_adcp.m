function view_adcp(DateFile, varargin)

%function view_adcp(DateFile, DateFile2, DateFile3, ...)
% this functions is used to display and save ADCP data in 
% the following forms: a vector plot in the form of a jpeg, 
% an image plot in the form of a jpeg, and an ascii file 
% providing N-S and E-W current information as a function of depth.
%
% The files will be generated for the dates given in the argument list.
% Assumes the dates will be given in the form nyymmdd.* (ex. n991020.rdi)
%   at least so that the month and day are characters 4-7.


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

%sub-function
%	uv2polar
%	arrowsafe

if nargin < 1, help mfilename, end
days = nargin;

FileNames = cell(length(nargin));
FileNames{1} = DateFile;
for j = 1:length(varargin);
   FileNames{j+1} = varargin{j};
end

xtlab = [ ];

for j = 1:length(FileNames)
   NextDateFile = FileNames{j}
	if isa(NextDateFile, 'netcdf')
   	G = NextDateFile;
	elseif ischar(NextDateFile)
   	G = netcdf(NextDateFile, 'nowrite');
	else
   	error(' ## ')
	end

	DEPTH = G{'depth'}(:);
	n = length(DEPTH);
	TIME = G{'time'}(:);
	TIME2 = G{'time2'}(:);
	mt = length(TIME);

	u = G{'u_1205'}(:);
	v = G{'v_1206'}(:);
	w = G{'w_1204'}(:);
   werr = G{'Werr_1201'}(:);
   
   %calculate magnitude and direction to be put in table
   mag2d = sqrt(u.^2 + v.^2);
   [direc,spd] = uv2polar(u,v);
   %this is the direction for plotting purposes since 0 is East
	dre = atan2(u,v)*(180/pi);

   for ii = 1:length(TIME);
   	datnum(ii) = ep_datenum([TIME(ii) TIME2(ii)]);
   	datvec(ii,:) = ep_datevec([TIME(ii) TIME2(ii)]);
	end

	tvec = datvec(:,4).*100 + datvec(:,5);
   hh = datvec(:,4);
   
   date1 = datestr(datenum(datvec(1,1),datvec(1,2),datvec(1,3)));
	date2 = datestr(datenum(datvec(mt,1),datvec(mt,2),datvec(mt,3)));

%Assuming that the files are given as single days
%days = datenum(date2) - datenum(date1)+1;
%if all ensembles were good would have T points
%T = (tvec(end)-tvec(1))/100 + (days-1)*24;

%create ascii outputfile for hourly tables
[PPATH, fname, ext] = fileparts(NextDateFile);
for mm = 1:mt;
      tout(:,1) = flipud(DEPTH);
      tout(:,2) = flipud(u(mm,:)');   
      tout(:,3) = flipud(v(mm,:)');
      tout(:,4) = flipud(spd(mm,:)');
      tout(:,5) = flipud(direc(mm,:)');
      tname = [fname(:,4:7) '_' num2str(mm)];
      eval(['save ' tname ' tout -ascii'])
   end
   
%Fill in the missing hours for the first day of data
count = 24; %as in hours
k = count * (j-1); % j is the file number
xxplot = [k:1:23+k];
yyplot = zeros(1,24);


%surface plots
while 0
Dsurf = DEPTH(n)
if Dsurf > 0
	usurf = u(:,n);
	vsurf = v(:,n);
	msurf = spd(:,n);
   dsurf = dre(:,n)
   disp(['top bin contains surface current'])
else
end
end

%using the 3rd bin from the top as proxy for the surface
usurf = u(:,n-2);
vsurf = v(:,n-2);
msurf = spd(:,n-2);
dsurf = dre(:,n-2);
disp(['bin# ' num2str(n-2) ' contains surface current at ' num2str(DEPTH(n-2)) ' m'])   
%end

%bottom currents
Dbot = DEPTH(1);
ubot = u(:,1);
vbot = v(:,1);
mbot = spd(:,1);
drbot = dre(:,1);

x = xxplot(hh+1);
y = yyplot(hh+1);

%dy needs to be an even number
%work on this, breaks down at days = 5.
if days > 4
  dy = 24;
else   
  dy = days*2;
end

if isequal(j,1)
   xtlab{1} = date2(1:6);
elseif  j > 1
   xtlab{(k/dy)+1} = date2(1:6);
end

xxticks =[dy:dy:count];

for pp = (k/dy)+2:((k+count)/dy)+1
    xtlab{pp} = xxticks(pp-(k/dy)-1);
end

if days > 4 & isequal(j,length(FileNames))
   enddate = datestr((datenum(date2)+1));
   xtlab{end} = enddate(1:6);
end

subplot(211)
arrowsafe(x,y,msurf,dsurf,msurf/8)
h1 = gca;
axis tight
arrowsafe
set(h1,'xlimmode','auto','ylimmode','auto')
arrowsafe

set(h1,'XTick',[0:dy:24+k])
arrowsafe
set(h1,'XTickLabel',xtlab)
arrowsafe

arrowsafe
set(h1,'xlim',[-1*dy xxplot(end)+1+dy],'ylim',[-15 15])
arrowsafe
set(h1,'YGrid','on')
ytlk = get(h1,'YTickLabel');
ytlk = abs(str2num(ytlk));
set(h1,'YTickLabel',ytlk)

ylabel('cm/s')
title('surface current')

subplot(212)
arrowsafe(x,y,mbot,drbot,mbot/8)
h2 = gca;
axis tight
arrowsafe
%axis([0 xxplot(end) -10 10])
set(h2,'xlimmode','auto','ylimmode','auto')
arrowsafe

%axis([0 xxplot(end) -1*round(Dbot)-2 -1*round(Dbot)+2])
set(h2,'XTick',[0:dy:24+k])
arrowsafe
set(h2,'XTickLabel',xtlab)
arrowsafe
set(h2,'YGrid','on')

set(gca,'xlim',[-dy xxplot(end)+1+dy],'ylim',[-15 15])
arrowsafe
ytlk = get(h2,'YTickLabel');
ytlk = abs(str2num(ytlk));
set(h2,'YTickLabel',ytlk)
arrowsafe

da = axis;
%axis vis3d
legtxt = ['current at ' num2str(round(Dbot)) ' m'];
title(legtxt)
ylabel('cm/s')
xlabel('GMT (hour)')
arrowsafe

close(G)

clear u v w werr TIME TIME2 DEPTH date1 usurf ubot vsurf vbot x y hh n mt tvec datvec
end  %the loop through NewDateFile

%lr = stext(7,-8.5,'\18\times\horiz')
%dr = stext(7.07,-8.75,'\18\times\vert')


ur = stext(xxplot(end)-2*j,da(4)-5,'\18\times\uparrow');
text(xxplot(end)-j,da(4)-5,'N','FontSize',[12])

%jpeg did not look so great
%[PPATH, fname, ext] = fileparts(DateFile);
%figname = fullfile(PPATH, [fname '.eps']);
%eval(['printsto -deps ' figname])

