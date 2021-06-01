function all_images_black_background(figh, cmap)
    if nargin < 1
        figh = gcf;
    end
    if nargin < 2
        cmap = parula;
    end
    allAxesInFigure = findall(figh,'type','axes');

%     cbar_mod = [[0,0,0]; cmap];

    for jj=1:length(allAxesInFigure)
%         colormap(allAxesInFigure(jj),cbar_mod);
        % only do it for images
        if any(arrayfun(@(x)isa(x,'matlab.graphics.primitive.Image'),allAxesInFigure(jj).Children))
            set(allAxesInFigure(jj), 'color', 'black'); % better: alpha channel and black background
        end

    end
    
    set(gcf, 'color', 'w');
end