function out = tight_imagestack_h(imstack)
    out = [];
    for jj=1:length(imstack)
        im_zoomed = tightzoom(imstack{jj});
        out = cat(1, out, im_zoomed);
    end
    
    if any(iscomplex(out(:)))
        out = abs(out);
    end
end