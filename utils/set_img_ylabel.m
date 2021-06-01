function yl=set_img_ylabel(text, fontsize)
    if nargin < 2
        fontsize = 14;
    end
    axis on, yl=ylabel(text, 'FontSize',fontsize);
    set(gca, 'xtick', []), set(gca, 'ytick', []); 
end