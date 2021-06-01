function out = paramnames7T(kk)
    % 5-pool model: constant, water, APT, NOE, MT, amine
    paramnames = {'c'}; poolnames = {'water', 'APT', 'NOE', 'MT', 'amine'};
    for jj=1:length(poolnames)
        paramnames{end+1} = sprintf('A_{%s}', poolnames{jj});
        paramnames{end+1} = sprintf('\\Gamma_{%s}', poolnames{jj});
        paramnames{end+1} = sprintf('\\Delta\\omega_{%s}', poolnames{jj});
    end
    paramnames{end+1} = '\DeltaB_0';
    paramnames{end+1} = 'rB1_{mimosa}';
    paramnames{end+1} = 'rB1_{cp}';
    out = paramnames{kk};
end