%% Linear projection-based CEST reconstruction
% demo script for calculating CEST-LASSO solutions
% (L1-L2-regularization-based feature selection for Z-spectral offsets) from
% training data and applying to test dataset

% Felix Glang, 2021
% felix.glang@tuebingen.mpg.de

%% load demo datasets
load('linearCEST_demodata.mat');

% contains:
% Xtr:          training inputs (#training voxels x #input components)
% Ytr:          training targets (#training voxels x #target components)
% Z_uncorr:     test input dataset (Nx x Ny x Nz x #input components)
%               consists of: 1: B1-mimosa, 2: B1-CP,
%               3:56: low-B1 Z-spectrum, 57:110: high-B1 Z-spectrum
% popt:         ground truth fit result (Nx x Ny x Nz x #targets)

%% standardization and linear fit

% calculate mean and std of training inputs and targets
meanX = mean(Xtr,1);
meanY = mean(Ytr,1);
stdX = std(Xtr,0,1);
stdY = std(Ytr,0,1);

% standardize training data
Xtr_std = (Xtr - meanX) ./ stdX;
Ytr_std = (Ytr - meanY) ./ stdY;

% do pseudo-inverse
tic
    beta = pinv(Xtr_std) * Ytr_std; %% general linear model: Y = X*B -> B = inv(X'*X)*X'*Y = pinv(X)*Y
t=toc; fprintf('calculating pinv solution took %.4fs\n', t);


%% FISTA optimization of row lasso
% select here which target parameters are included simultaneously in the multivariate rowLASSO objective
useTargs = [5,8,11,14,17]; % amplitudes of APT, NOE, MT, amine and B0 shift (ppm)
% useTargs = 1:size(popt,4); % ALL target parameters (peak amplitudes, widths and positions)
% useTargs = 5; % a single target (5 = APT amplitude) -> standard LASSO regression with 1D target
VERBOSE = 1; % 0: nothing, 1: normal, 2: detailed

t1=tic; % usually takes some minutes
    [beta_lasso, keep_list, lambdas, nRetained] = CESTrowLasso(Xtr, Ytr, useTargs, VERBOSE);
t2=toc(t1); fprintf('calculating all LASSO solutions took %.4fs\n', t2);

%% apply weight vectors of all LASSO steps to test dataset

% bring test dataset in 2D shape by flattening all spatial dimensions
[nx,ny,nz,noffs] = size(Z_uncorr);
Xtest = reshape(Z_uncorr, [], noffs);

% standardize test input data
Xtest_std = (Xtest - meanX) ./ stdX;

Ytest_lasso_all = zeros(nx,ny,nz,size(Ytr,2),length(beta_lasso)); % store all LASSO predictions
for jj=1:length(beta_lasso) % all LASSO reduction steps
    % generate reduced linear projection result from test data by matrix product
    Ytest_lasso_std = Xtest_std * beta_lasso{jj};
    % bring back to original scale
    Ytest_lasso = Ytest_lasso_std .* stdY + meanY;
    % restore spatial dimensions
    Ytest_lasso_all(:,:,:,:,jj) = reshape(Ytest_lasso, nx, ny ,nz, []);
    fprintf('predicted LASSO step %d/%d\n', jj, length(beta_lasso));
end


%% show LASSO results

showLASSOsteps = [110, 55, 39, 3]; % these steps (=number of retained offsets) are plotted

SLICE = 11; % for plotting
OFFSETS = [5,8,11,14,17]; % [APT, NOE, MT, amine, dB0]
CLIMS = {[0.025 0.075], [0.06 0.16], [0.05 0.3], [0.01 0.07], [-.5 .5]}; % color scales for target params
NCol = 4;

f = figure('units','normalized','outerposition',[0 0 1 1]);
LINES=lines;
for jj=1:length(OFFSETS)
    OFFS=OFFSETS(jj);
    
    % collect all maps for plotting (ground truth + selected LASSO solutions)
    pmaps = {popt(:,:,SLICE,OFFSETS(jj))};
    pdiffs = {};
    pscatter_x = {};
    pscatter_y = {};
    pnames = {};
    for kk=1:length(showLASSOsteps) 
        pred_lasso = Ytest_lasso_all(:,:,:,:,length(beta_lasso)-showLASSOsteps(kk)+1);
        pmaps{kk+1} = pred_lasso(:,:,SLICE,OFFSETS(jj));
        pdiffs{kk} = popt(:,:,SLICE,OFFSETS(jj)) -  pred_lasso(:,:,SLICE,OFFSETS(jj));
        pscatter_x{kk} = popt(:,:,SLICE,OFFSETS(jj));
        pscatter_y{kk} = pred_lasso(:,:,SLICE,OFFSETS(jj));
        pnames{kk} = sprintf('#%d', showLASSOsteps(kk));
    end
    
    % ground truth & predicted maps
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+1); 
    im1 = tight_imagestack_h(pmaps);
    imagesc2t(im1);
    caxis(CLIMS{jj});
    ax = gca; ax.Colorbar.Location = 'southoutside';
    set_img_ylabel(paramnames7T(OFFSETS(jj)));
    CAX = caxis;
    
    % difference maps
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+2);
    im1 = tight_imagestack_h(pdiffs);
    imagesc2t(im1);
    ax = gca; ax.Colorbar.Location = 'southoutside';
    caxis(0.1.*[CAX(1)-CAX(2), CAX(2)-CAX(1)]);
    
    % scatter plots
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+3);
    if OFFS==17; NRMSEflag = 0; else; NRMSEflag = 1; end % for Delta B0 we calculated RMSE instead of NRMSE
    corrPlotmulti(pscatter_x,...
                  pscatter_y,...
                    1, 1, pnames, NRMSEflag);
    gridboxon;
    h = legend(); h.Location='northeastoutside';
    
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+4); hold on;  % regression coefficients
    yyaxis left; hold on; 
    for kk=1:length(showLASSOsteps) 
        plot(beta_lasso{length(beta_lasso)-showLASSOsteps(kk)+1}(:, OFFSETS(jj)),...
            '.-', 'Color', LINES(kk,:), 'DisplayName', sprintf('#%d', showLASSOsteps(kk))); 
    end
    if jj==1; LEG = legend; LEG.Location = 'northeast'; end
    yyaxis right;
    plot(squeeze(Z_uncorr(50,50,11,:)), '-', 'Color','k', 'DisplayName', 'ex. inp. vec.'); % example Z-spectrum
    ax = gca;
    ax.YAxis(1).Color = LINES(1,:);
    ax.YAxis(2).Color = 'k';
    grid on; grid minor; box on;
end

titlestr = '';
for kk=1:length(showLASSOsteps)
    titlestr = [titlestr, sprintf('   #%d', showLASSOsteps(kk))];
end

subplot(length(OFFSETS),NCol,1); title(['GT', titlestr]);
subplot(length(OFFSETS),NCol,2); title(['differences GT to', titlestr]);
subplot(length(OFFSETS),NCol,3); title('scatter');
subplot(length(OFFSETS),NCol,4); title('regression coefficients');
all_images_black_background(gcf);
