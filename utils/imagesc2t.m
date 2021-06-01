function h = imagesc2t(im, showstats, tightzoomFlag, ROIs, showROILabels, ROIlabels)
% set_caxis: flag whether to show colorbar
% auto_caxis = 1: automatic colorscale from MEAN+-t*STD
% auto_caxis = 2 (default): automatic colorscale from t-percentile
    if nargin < 6
        ROIlabels = {};
    end

    if nargin < 5
        showROILabels = 0;
    end

    if nargin < 4
        ROIs = {};
    end

    if nargin < 3
        tightzoomFlag = 1;
    end
    
    if nargin < 2
        showstats=0;
    end

    if tightzoomFlag == 1
        tightZoomInd = tightzoom(im, 1);
        im = tightzoom(im);
    end
    
    h = imagesc(rot90(im,1), 'AlphaData', ~isnan(rot90(im,1)));
    
    if numel(ROIs) > 0
        hold on;
        
        for ii=1:numel(ROIs) % must be done first, to make sure that labels are not overlapped by contour
            if tightzoomFlag ~= 1
                ROI{ii} = rot90(ROIs{ii}.ROI_def,1);
            else
                ROI{ii} = rot90(ROIs{ii}.ROI_def(tightZoomInd(1,1):tightZoomInd(1,2), tightZoomInd(2,1):tightZoomInd(2,2)),1);
            end
            contour(ROI{ii},1,'m-','LineWidth',2);
        end
        
        for ii=1:numel(ROIs)
            [yy xx]=find(ROI{ii});
            if showROILabels == 1
                t_h=text(fix(max(xx)),fix(min(yy)),'# ');
                if isempty(ROIlabels)
                    set(t_h,'String',sprintf('#: %d ',ii),'BackgroundColor',[1 1 1]);
                else
                    set(t_h,'String',sprintf('%s',ROIlabels{ii}),'BackgroundColor',[1 1 1]);
                end
                leg{ii}=sprintf('ROI # %d:%s',ii, 'string');
            end
        end
        set(gca,'xtick',[],'ytick',[]);
        clear yy xx
    end
    
    colorbar;
    caxis(set_caxis(im,.01));
    
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    
    set(gca,'ydir','reverse');
    
    axis image;
    
    if showstats == 1
        values = im(:);
        values(isnan(values))=[];
        values(isinf(values))=[];
%         values(values==0) = [];
        MEAN = mean(values);
        STD = std(values);
        MAX = max(values);
        MIN = min(values);
        MEDIAN = median(values);
        hh=xlabel(sprintf('\\mu\\pm\\sigma=%.2g\\pm%.2g',MEAN,STD));
        hh.Interpreter='tex';
    end
end