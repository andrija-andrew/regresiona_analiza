atnum = xlsread('AirTraffic.xlsx');

n = 84;
atnum = atnum(1:n, :);
y = atnum(:, end);
k = size(atnum, 2) - 1;

deg_fr = n - 2;
SST = sum((atnum - repmat(mean(atnum), n, 1)) .^ 2);
q = tinv(0.975, deg_fr);

beta_hat = NaN(2, k);
RSS = NaN(1, k);
BP = NaN(1, k);
for j = 1:k
    X = [ones(n, 1) atnum(:, j)];
    [beta_hat(:, j), y_hat, RSS(j)] = lreg(X, y);
    
    BP(j) = bptest(X, y - y_hat);
    
    S2 = RSS(j) / deg_fr;
    t_reg = beta_hat(2, j) / sqrt(S2 / SST(j));
    if abs(t_reg) > q
        disp(['Prihvatamo hipotezu H1 da postoji linearna veza izmedju nezavisne promenljive x', num2str(j), ' i zavisne promenljive Y, na nivou poverenja 0.95.'])
    else
        disp(['Prihvatamo hipotezu H0 da ne postoji linearna veza izmedju nezavisne promenljive x', num2str(j), ' i zavisne promenljive Y, na nivou poverenja 0.95.'])
    end
end

MSE = RSS / n;
R2 = 1 - RSS / SST(end);