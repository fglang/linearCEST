function corrPlotmulti(xdatas, ydatas, showIdentity, lockAxes, names, metricflag)
% multi datasets scattered in same plot
% scatter plot of ydata vs xdata, can be nd-arrays of same size, as they
% get vectorized. NaNs are ignored.
% inputs:
%           xdatas: cell array of x datasets
%           ydatas: cell array of y datasets (each of same size as x datasets)
%           showIdentity: flag: show y=x line?
%           lockAxes: flag: enforce xlim = ylim ?
%           names: cell array of strings, dataset names for legend
%           metricflag: which metric to show in legend (1: NRMSE, 2: Pearson correlation, other: NRMSE)
%           
% return: array of metric for all datasets

    if nargin < 6
        metricflag = 1; % NRMSE
    end

    if nargin < 5
        for jj=1:length(xdatas)
            names{jj} = '';
        end
    end

    if nargin < 4
        lockAxes = 1;
    end

    if nargin < 3
        showIdentity = 0;
    end
    hold on;
    metrics = zeros(length(xdatas),1); % record metric for each dataset
    for jj=1:length(xdatas)
        xdata = xdatas{jj};
        ydata = ydatas{jj};
        
%         xdata = xdata(~isnan(xdata));
%         ydata = ydata(~isnan(ydata));
        
        nanmask = isnan(xdata(:)) | isnan(ydata(:));
        xdata = xdata(~nanmask);
        ydata = ydata(~nanmask);
        
        if metricflag == 1
            metric = nrmse(xdata, ydata)*100; %percent
            metricname = 'NRMSE';
            legstr = sprintf('%s = %.2g%%', metricname, metric);
        elseif metricflag == 2
            CORRCOEFF = corrcoef(xdata, ydata);
            metric = CORRCOEFF(1,2);
            metricname = 'r';
            legstr = sprintf('%s = %.2f', metricname, metric);
        else
            metric = rmse(xdata, ydata); %percent
            metricname = 'RMSE';
            legstr = sprintf('%s = %.2g', metricname, metric);
        end
        

        MIN = min(min(xdata), min(ydata));
        MAX = max(max(xdata), max(ydata));

        poptlin = polyfit(xdata,ydata,1);

        if lockAxes == 1
            xcont = linspace(MIN,MAX);
        else
            XLIM = xlim;
            xcont = linspace(XLIM(1),XLIM(2));
        end
        
        if ~strcmp(names{jj},'')
            legstr = sprintf('%s, %s', names{jj}, legstr);
        end
        
        S=scatter(xdata, ydata, '.', 'DisplayName',legstr, 'MarkerFaceAlpha', 0.8);
        
        P=plot(xcont, poptlin(1).*xcont+poptlin(2), '--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
        P.Color = S.CData;
            
        if lockAxes == 1
            xlim([MIN, MAX]); ylim([MIN, MAX]); 
        end

        metrics(jj) = metric;
    
    end
    
    if showIdentity
%         plot(xcont, xcont, '-.', 'LineWidth', 1.5, 'DisplayName', 'y=x');
        plot(xcont, xcont, '-.', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
    
    L=legend();
    L.Location = 'northwest';
end