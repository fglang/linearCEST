function out = rmse(xdata, ydata)
    xdata = xdata(~isnan(xdata));
    ydata = ydata(~isnan(ydata));
    diff = xdata - ydata;
    range = 1;
    RMSE = sqrt(mean(abs(diff).^2,'all'));
    out = RMSE ./ range;
end