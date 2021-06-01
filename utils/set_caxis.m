function cax = set_caxis(im, t)
% get color scale from upper and lower t quantile
    if nargin < 2
        t = 1;
    end

    values = im(:);
    values(isnan(values))=[];
    values(isinf(values))=[];
   
    lower = quantile(values, t);
    upper = quantile(values, 1-t);
    
    cax = [lower upper];
end