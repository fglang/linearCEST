%% Linear projection-based CEST reconstruction
% demo script for generating linear regression coefficients from training
% data and applying to test dataset

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
t1=tic;
beta = pinv(Xtr_std) * Ytr_std; %% general linear model: Y = X*B -> B = inv(X'*X)*X'*Y = pinv(X)*Y
t=toc(t1); fprintf('calculating pinv solution took %.4fs\n', t);

%% apply weight vectors to test dataset

% bring test dataset in 2D shape by flattening all spatial dimensions
[nx,ny,nz,noffs] = size(Z_uncorr);
Xtest = reshape(Z_uncorr, [], noffs);

% standardize test input data
Xtest_std = (Xtest - meanX) ./ stdX;

% generate linear projection result from test data by matrix product
Ytest_proj_std = Xtest_std * beta;

% bring back to original scale
Ytest_proj = Ytest_proj_std .* stdY + meanY;

% restore spatial dimensions
Ytest_proj = reshape(Ytest_proj, nx, ny ,nz, []);

%% plot results
OFFSETS = [5,8,11,14,17]; % amplitudes of APT, NOE, MT, amine and B0 shift (ppm)
CLIMS = {[0.025 0.075], [0.06 0.16], [0.05 0.3], [0.01 0.07], [-.5 .5]}; % color scales for target params


SLICE = 11; % which one to disply
figure('units','normalized','outerposition',[0 0 1 1])
NCol = 4;
for jj=1:length(OFFSETS)
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+1); % ground truth maps & linear predictions
    imagesc2t(tight_imagestack_h({popt(:,:,SLICE,OFFSETS(jj)), Ytest_proj(:,:,SLICE,OFFSETS(jj))}));
    set_img_ylabel(paramnames7T(OFFSETS(jj)));
    caxis(CLIMS{jj}); cax = caxis;
    
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+2); % difference maps
    imagesc2t(popt(:,:,SLICE,OFFSETS(jj)) - Ytest_proj(:,:,SLICE,OFFSETS(jj)));
    caxis(0.1.*[cax(1)-cax(2), cax(2)-cax(1)]); 
    
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+3); % scatter plot
    if OFFSETS(jj)==17; NRMSEflag = 0; else; NRMSEflag = 1; end % for Delta B0 we calculated RMSE instead of NRMSE
    corrPlotmulti({popt(:,:,SLICE,OFFSETS(jj))},...
                  {Ytest_proj(:,:,SLICE,OFFSETS(jj))},...
                    1, 1, {''}, NRMSEflag);
    gridboxon;
    h = legend(); h.Location='northeastoutside';
    
    subplot(length(OFFSETS),NCol,(jj-1).*NCol+4); hold on;  % regression coefficients
    yyaxis left; plot(beta(:, OFFSETS(jj)), '.-');
    yyaxis right; plot(squeeze(Z_uncorr(50,50,11,:)), '-'); % example Z-spectrum
    grid on; grid minor; box on;
end
subplot(length(OFFSETS),NCol,1); title('ground truth,   linear projection');
subplot(length(OFFSETS),NCol,2); title('difference');
subplot(length(OFFSETS),NCol,3); title('scatter');
subplot(length(OFFSETS),NCol,4); title('coefficients');
legend('regr. coeffs. \beta', 'example input vector');
subplot(length(OFFSETS),NCol,length(OFFSETS)*NCol); xlabel('# input feature');
all_images_black_background(gcf);