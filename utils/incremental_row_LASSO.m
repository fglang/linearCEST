function [lambdas, DF_target, betas, keep_list] = incremental_row_LASSO(Xtr, Ytr, opts, DF_target, verbose, trafoFuncs)
% row-LASSO regression with automatic selection of lambda
%   - start with lambda=0 -> all inputs are there (standard lsq regression)
%   -> increase lambda such that the number of non-zero components drops
%      one by one (for each desired number of retained inputs, a lambda
%      search range is defined and iteratively contracted to find desired value)
%   - uses external FISTA solver for rowLASSO (L1L2-regularization)

% inputs:
%   - Xtr: data matrix for regression (#samples x #features)
%   - Ytr: target matrix for regression (#samples x #targetparams)
%   - ops: struct with options for FISTA solver
%   - DF_target: desired numbers of non-zero input components
%                default: all possible numbers: N, N-1,...,0
%   - verbose: flag (show some info in console?)
%   - trafoFuncs: optional, non-uniformly spaced search ranges
%                 cell with two function handles that need to be inverse of
%                 each other
%                 (had the impression that searching uniformly spaced
%                 log(lambda) might be a bit faster -> use {@log,@exp}
%                 default {@(x)x, @(x)x} as log created trouble for some datasets                

% return:
%   - lambdas: list of found regularization params
%   - DF_target: number of non-zero components for each lambda
%   - betas: cell of regression matrices for each lambda
%   - keep_list: cell of lists of retained input numbers for each lambda
    
    if nargin < 4
        DF_target = flip(1:size(Xtr,2));
    end

    if nargin < 6
        trafoFuncs = {@(x)x, @(x)x};
    end
    
    if nargin < 5
        verbose = 0;
    end

    % keep track of all checked lambda values for maybe using them later
    all_lambdas = []; 
    all_DFs = [];

    lambdas = zeros(size(DF_target));
    
    % first is unregularized
    lambda = 0;
    [betas{1}, DF_current, keep_list{1}] = eval_row_Lasso(lambda, Xtr, Ytr, opts);
    
    % find initial upper bound for lambda that sets ALL coeffs to 0
    lambda = 1;
    while DF_current ~= 0
        % evaluate current lambda
        [~, DF_current, ~] = eval_row_Lasso(lambda, Xtr, Ytr, opts);
        all_lambdas(end+1) = lambda;
        all_DFs(end+1) = DF_current;
        lambda = lambda * 10; % just increase somehow exponentially
    end

    % set initial search range: 0 to very large
    lambda_min = trafoFuncs{1}(0+eps); % eps to avoid divergence in log
    lambda_max = trafoFuncs{1}(lambda);
   
    Nline = 5; % number of intermediate values in the search range for each iteration, needs maybe some manual finetuning for speeding up(?)
    NWMAX = 100; % stop while loop after a certain number of search attempts
    
    for jj=2:length(DF_target) % try to hit each target DF
        % reset search range
        lambda1 = lambda_min; % lower
        lambda2 = lambda_max; % upper
        
        % check if we had that already
        found_index = find(all_DFs == DF_target(jj), 1, 'last');
        if ~isempty(found_index)
            lambdas(jj) = all_lambdas(found_index);
            [betas{jj}, DF_current, keep_list{jj}] = eval_row_Lasso(lambdas(jj), Xtr, Ytr, opts);
            if verbose; fprintf('found nRetained=%d (lambda=%.4g) in memory list\n', DF_target(jj), lambdas(jj)); end
            continue;
        end

        done = false;
        wcounter = 1;
        while ~done
            lbd_check = trafoFuncs{2}(linspace(lambda1, lambda2, Nline)); % search points
%             if verbose
%                 fprintf('lambda1=%d lambda2=%d\n', lambda1, lambda2);
%             end
            for kk=1:length(lbd_check)
                lambda = lbd_check(kk);
                
                % evaluate current lambda
                [beta, DF_current, keep_list_current] = eval_row_Lasso(lambda, Xtr, Ytr, opts);
                
                if verbose == 2
                    fprintf('DFtarg=%d, DFcurrent=%d, lambda=%.4g, loopcount=%d\n', DF_target(jj),DF_current, lambda, wcounter);
                end
                    
                % keep track of all evaluated lambdas
                all_lambdas(end+1) = lambda;
                all_DFs(end+1) = DF_current;
                
                
                % found the right lambda for current target DF
                if DF_current == DF_target(jj)
                    % save it
                    lambdas(jj) = lambda;
                    betas{jj} = beta;
                    keep_list{jj} = keep_list_current;

                    if verbose; fprintf('found nRetained=%d (lambda=%.4g)\n', DF_target(jj), lambdas(jj)); end

                    % end current iteration
                    done = true;
                    break;

                elseif DF_current > DF_target(jj) % lambda was too small -> increase lower bound of search range
                    lambda1 = trafoFuncs{1}(lambda);
                elseif DF_current < DF_target(jj) % lambda was too high -> decrease upper bound of search range
                    lambda2 = trafoFuncs{1}(lambda);
                    break; % no need to search for higher upper bound, take lowest possible to shrink search range as much as possible
                end
                % like that, the search range should iteratively contract
                % in a way to find the right lambda for given target DF
            end
            
            wcounter = wcounter + 1;
            if verbose == 2; fprintf('loopcount=%d\n',wcounter); end
            if wcounter > NWMAX
                fprintf('loop counter exceeded, nRetained=%d not possible!', DF_target(jj));
                lambdas(jj) = lambda.*NaN;
                betas{jj} = beta.*NaN;
                keep_list{jj} = keep_list_current.*NaN;
                done = true;
            end
        end
    end
   
end

function [beta, DF, keep_list] = eval_row_Lasso(lambda, Xtr, Ytr, opts)
    opts.lambda = lambda;
%     tic
    beta = fista_row_sparsity(Ytr, Xtr, [], opts);
%     toc
    keep_list = find(sum(abs(beta),2) > 0);
    DF = length(keep_list);
end