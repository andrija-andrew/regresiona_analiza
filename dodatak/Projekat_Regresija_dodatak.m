atnum = xlsread('AirTraffic.xlsx');

n = 84;
X = atnum(1:n, 1:6);
y = atnum(1:n, 7);

alpha = 0.05;
gamma = 1 - alpha;

% ---- Jednostruki linearni model ----

X4 = atnum(1:n, 4);

X_jm = [ones(n, 1) X4];
[beta_jm_hat, y_jm_hat, RSS_jm] = lreg(X_jm, y);

res_jm = y - y_jm_hat;
p_jm = bptest(X_jm, res_jm);
if p_jm < alpha
    disp(['Reziduali jednostrukog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali jednostrukog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

deg_fr = n - size(beta_jm_hat, 1);
S2_jm = RSS_jm / deg_fr;
SX4X4 = sum((X4 - mean(X4)) .^ 2);
q_jm = tinv(1 - alpha / 2, deg_fr);
pm_ci_beta_jm_0 = q_jm * sqrt(S2_jm * sum(X4 .^ 2) / (SX4X4 * n));
ci_beta_jm_0 = [beta_jm_hat(1) - pm_ci_beta_jm_0, beta_jm_hat(1) + pm_ci_beta_jm_0];
disp(['Interval poverenja za koeficijent beta_0 jednostrukog linearnog modela, na nivou poverenja ', num2str(gamma), ', je: [', num2str(ci_beta_jm_0(1)), ', ', num2str(ci_beta_jm_0(2)), '].']);

pm_ci_beta_jm_1 = q_jm * sqrt(S2_jm / SX4X4);
ci_beta_jm_1 = [beta_jm_hat(2) - pm_ci_beta_jm_1, beta_jm_hat(2) + pm_ci_beta_jm_1];
disp(['Interval poverenja za koeficijent beta_1 jednostrukog linearnog modela, na nivou poverenja ', num2str(gamma), ', je: [', num2str(ci_beta_jm_1(1)), ', ', num2str(ci_beta_jm_1(2)), '].']);

MSE_jm = RSS_jm / n;

Syy = sum((y - mean(y)) .^ 2);
R2_jm = 1 - RSS_jm / Syy;

% ---- Pun linearni model ----

X = [ones(n, 1) X];
rank_X = rank(X);

[beta_hat, y_hat, RSS] = lreg(X, y);

res = y - y_hat;
p = bptest(X, res);
if p < alpha
    disp(['Reziduali punog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali punog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

MSE = RSS / n;
R2 = 1 - RSS / Syy;

% ---- Redukovani linearni model ----

[feat, beta_red_hat, y_red_hat, RSS_red] = ffsb(X, y, 1, alpha);
X_red = X(:, feat);

res_red = y - y_red_hat;
p_red = bptest(X_red, res_red);
if p_red < alpha
    disp(['Reziduali redukovanog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali redukovanog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

MSE_red = RSS_red / n;
R2_red = 1 - RSS_red / Syy;

deg_fr1 = size(X, 2) - size(X_red, 2);
deg_fr2 = n - size(X, 2);
F_reg = ((RSS_red - RSS) / deg_fr1) / (RSS / deg_fr2);
q = finv(1 - alpha, deg_fr1, deg_fr2);
if F_reg > q
    disp(['Prihvatamo hipotezu H1(beta_izb nije nula vektor), na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Prihvatamo hipotezu H0(beta_izb je nula vektor), na nivou poverenja ', num2str(gamma), '.'])
end

% ---- Nelinearni modeli ----

f_jm = @(b) 100 ./ (1 + exp(-(X_jm * b)));

beta_jmnl_hat = zeros(size(X_jm, 2), 1);
h = 1e-11;
max_iter = 100;
stop = 1e-11;
[beta_jmnl_hat, n_iter_jm, y_jmnl_hat, RSS_jmnl] = gn(y, f_jm, beta_jmnl_hat, h, max_iter, stop);

MSE_jmnl = RSS_jmnl / n;

f = @(b) 100 ./ (1 + exp(-(X * b)));
f_red = @(b) 100 ./ (1 + exp(-(X_red * b)));

beta_nl_hat = zeros(size(X, 2), 1);
[beta_nl_hat, n_iter, y_nl_hat, RSS_nl] = gn(y, f, beta_nl_hat, h, max_iter, stop);
beta_rednl_hat = zeros(size(X_red, 2), 1);
[beta_rednl_hat, n_iter_red, y_rednl_hat, RSS_rednl] = gn(y, f_red, beta_rednl_hat, h, max_iter, stop);

MSE_nl = RSS_nl / n;
MSE_rednl = RSS_rednl / n;

% ---- Trening i testiranje ----

trening_size = 0.7;
tt_iter = 1000;

n_trening = round(trening_size * n);
n_test = n - n_trening;
nv = 1:n;

MSE_test = NaN(tt_iter, 6);
for i = 1:tt_iter
    tren_rows = randsample(n, n_trening);
    test_rows = setdiff(nv, tren_rows);
    
    X_jm_tren = X_jm(tren_rows, :);
    X_tren = X(tren_rows, :);
    X_red_tren = X_red(tren_rows, :);
    f_jm_tren = @(b) 100 ./ (1 + exp(-(X_jm_tren * b)));
    f_tren = @(b) 100 ./ (1 + exp(-(X_tren * b)));
    f_red_tren = @(b) 100 ./ (1 + exp(-(X_red_tren * b)));
    y_tren = y(tren_rows, :);
    
    beta_jm_tren = lreg(X_jm_tren, y_tren);
    beta_tren = lreg(X_tren, y_tren);
    beta_red_tren = lreg(X_red_tren, y_tren);
    beta_jmnl_tren = zeros(size(X_jm_tren, 2), 1);
    beta_jmnl_tren = gn(y_tren, f_jm_tren, beta_jmnl_tren, h, max_iter, stop);
    beta_nl_tren = zeros(size(X_tren, 2), 1);
    beta_nl_tren = gn(y_tren, f_tren, beta_nl_tren, h, max_iter, stop);
    beta_rednl_tren = zeros(size(X_red_tren, 2), 1);
    beta_rednl_tren = gn(y_tren, f_red_tren, beta_rednl_tren, h, max_iter, stop);
    
    X_jm_test = X_jm(test_rows, :);
    X_test = X(test_rows, :);
    X_red_test = X_red(test_rows, :);
    f_jm_test = @(b) 100 ./ (1 + exp(-(X_jm_test * b)));
    f_test = @(b) 100 ./ (1 + exp(-(X_test * b)));
    f_red_test = @(b) 100 ./ (1 + exp(-(X_red_test * b)));
    y_test = y(test_rows, :);
    
    MSE_test(i, 1) = sum((y_test - X_jm_test * beta_jm_tren) .^ 2) / n_test;
    MSE_test(i, 2) = sum((y_test - X_test * beta_tren) .^ 2) / n_test;
    MSE_test(i, 3) = sum((y_test - X_red_test * beta_red_tren) .^ 2) / n_test;
    MSE_test(i, 4) = sum((y_test - f_jm_test(beta_jmnl_tren)) .^ 2) / n_test;
    MSE_test(i, 5) = sum((y_test - f_test(beta_nl_tren)) .^ 2) / n_test;
    MSE_test(i, 6) = sum((y_test - f_red_test(beta_rednl_tren)) .^ 2) / n_test;
end

mean_MSE_test = mean(MSE_test);