function [dttim, tr_height, std_tr_height]=find_center_ht;

fname=dir('az*cdf');
knt=1;
for kk=1:length(fname)
    ncr=netcdf(fname(kk).name);
    if ncr.Range(:)==3
        fctr=6;
    else
        fctr=1;
    end
    szs = ncsize(ncr{'raw_image'});
    for ki=1:szs(1)
        for jj=1:szs(2)
            minidx=szs(4)/2-5; maxidx=szs(4)/2+5;
            locs=find(ncr{'profile_range'}(ki,jj,minidx:maxidx) > 0);
            while (size(locs) < 5)
                minidx=minidx-5; maxidx=maxidx+5;
                locs=find(ncr{'profile_range'}(ki,jj,minidx:maxidx) > 0);
            end
            mid_sect=[minidx:1:maxidx];
            tmp_pr=ncr{'profile_range'}(ki,jj,:);
            tr_ht(jj)=mean(tmp_pr(mid_sect(locs)))/fctr;
               clear locs midsect tmp_pr minidx maxidx
        end
        tr_height(knt)=gmean(tr_ht);
        if isnan(tr_height(knt)); keyboard; end
        std_tr_height(knt)=gmean(tr_ht);
        dttim(knt)=ncr{'time'}(ki)+(ncr{'time2'}(ki)./86400000);
        knt=knt+1;
    end
    close (ncr)
end