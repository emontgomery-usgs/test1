function plt_prga(pr,ha,ga,PenHeader)
%
%  this program is intended for use with .81a files created in real time
%  they may have gain changing with time, and WILL have multiple sweeps.
%
%  run view_pen, first, the plt_prga
%   pr is ProfileRange
%   ha is Headangle
%   ga is the gain at the start of the sweep
%   PenHeader is the header info for this file
%
 mnx=-PenHeader.Range(1);
 mxx=PenHeader.Range(1);
 mny=-1.5;
 mxy=-.5;
   %[mnx mxx mny mxy]
[a,b]=size(pr);
 % see about amimating for CRS
 % mov=avifile('pengain103.avi');
 % mov.Fps=1;
 % mov.Quality=100;
 
  if (PenHeader.Range < 5)
    fctr=500;
  else
    fctr=100;
  end
  % for some .81a'a the headangle needs *3....
  ha=ha.*3;
  
cols=['b','g','r','c','m','k'];
  if a>length(cols)
      stp=length(cols);
  else
      stp=a;
  end
  k=1;
for ik=1:stp
    plot((pr(ik,:)/fctr).*(sin(deg2rad(ha(ik,:)))),-(pr(ik,:)/fctr).*(cos(deg2rad(ha(ik,:)))),[cols(k) '.'])
    axis([mnx mxx mny mxy])
    xlabel('distance (m)')
    ylabel('depth(m)')
    title([PenHeader.FileName ' scan ' num2str(ik)])
    %text(1, -1.3,['gain ' num2str(ga(ik)) '; range = ', num2str(PenHeader.Range(ik))])
    hold on
    k=k+1;
  % I tried to make this into a movie but had the usual trouble with axes
  % uncomment this if packaging it is important.
  % now add frames
  % gca or gcf??
   % fr(ik) = getframe(gca);
   % [xfr,x]=frame2im(fr);
end
  % movie(fr);
  % save  pgmov fr
  %  movie2avi(movie(fr),'pengain.avi')
    ylabel('depth(m)')
