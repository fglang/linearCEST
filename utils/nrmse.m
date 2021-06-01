function out = nrmse(xdata, ydata)
    xdata = xdata(~isnan(xdata));
    ydata = ydata(~isnan(ydata));
    diff = xdata - ydata;
    range = mean(xdata,'all','omitnan');
    RMSE = sqrt(mean(abs(diff).^2,'all'));
    out = RMSE ./ range;
end