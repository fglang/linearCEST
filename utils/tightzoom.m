function out2d = tightzoom(inp2d, indicesOut)
% crop 2d matrix such that tightest rectangle containing non-NaNs is shown
% indicesOut = 1 -> return respective crop indices
% otherwise: return cropped matrix

    if nargin < 2
        indicesOut = 0;
    end
    
    xmask = any(~isnan(inp2d),1);
    x1 = find(xmask, 1, 'first');
    x2 = find(xmask, 1, 'last');
    
    ymask = any(~isnan(inp2d),2);
    y1 = find(ymask, 1, 'first');
    y2 = find(ymask, 1, 'last');
    
    if indicesOut == 1
        out2d = [[y1, y2]; [x1, x2]];
    else
        out2d = inp2d(y1:y2, x1:x2);
    end
end