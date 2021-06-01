function [beta_lasso, keep_list, lambdas, nRetained] = CESTrowLasso(Xtr, Ytr, useTargs, verbose)
% solve CEST-LASSO to automatically obtain feature selection solutions for
% all possible numbers of retained inputs (gradually dropping from all to  1)

% inputs:
%   - Xtr: data matrix for regression (#samples x #features)
%   - Ytr: target matrix for regression (#samples x #targetparams)
%   - useTargs: target indices that are considered simultaneously for
%               rowLASSO (L2-L1) regularization
%   - verbose: flag (print some info to console?)

% return:
%   - beta_lasso:   cell array of LASSO solutions for each reduction step
%                   (zero filled such that all matrices have same size)
%   - keep_list:    cell array of indices of retained inputs for each LASSO step
%   - lambdas:      found regularization parameters 
%   - nRetained:    number of retained inputs in each LASSO step
%                   normally this should be identical to size(Xtr,2):-1:1

    if nargin < 4
        verbose = 1;
    end
    
    if nargin < 3
        useTargs = 1:size(Ytr,2);
    end

    nYtrOrig = size(Ytr,2);
    Ytr = Ytr(:,useTargs);
    
    % standardize inputs and targets
    meanX = mean(Xtr,1);
    meanY = mean(Ytr,1);
    stdX = std(Xtr,0,1);
    stdY = std(Ytr,0,1);
    
    Xtr_std = (Xtr - meanX) ./ stdX;
    Ytr_std = (Ytr - meanY) ./ stdY;
    
    
    %%%% FISTA optimization of row lasso

    % parameters for optimization
    opts.pos = false; % allow positive and negative regr coefficients (important!)
    opts.check_grad = 0; % very slow for large datasets
    opts.verbose = false; % much slower if true
    opts.max_iter = 5000;

    % find solutions for different regularizations so that all possible numbers of retained inputs occur
    [lambdas, nRetained, ~, keep_list] = incremental_row_LASSO(Xtr_std, Ytr_std, opts, flip(1:size(Xtr,2)), verbose);

    % plot number of non-zero inputs vs lambda
    if verbose
        figure;
        semilogx(lambdas, nRetained, '.-'); xlabel('\lambda'); ylabel('number of retained inputs');
        gridboxon; title('# nonzero rows vs \lambda');
    end
    
    % re-fitting: solve unregularized lsq problem only for retained inputs
    % according to LASSO solution -> LASSO is only used for feature selection
    for jj = 1:length(lambdas)
        if isnan(lambdas(jj))
            beta_lasso{jj} = zeros(size(Xtr,2), nYtrOrig);
            if verbose; fprintf('NaN for step %d/%d!\n', jj, length(lambdas)); end
        else
            Xtr_red = Xtr_std(:, keep_list{jj});
            tic
            beta_lsq_red = pinv(Xtr_red)*Ytr_std;
            beta_lasso{jj} = zeros(size(Xtr,2), nYtrOrig); % zero-filled regression coefficients
            beta_lasso{jj}(keep_list{jj},useTargs) = beta_lsq_red;
            t=toc;
            if verbose; fprintf('finished re-fitting %d/%d, time=%.4fs\n', jj, length(lambdas), t); end
        end
        
    end
end