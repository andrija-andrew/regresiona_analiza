atnum = xlsread('AirTraffic.xlsx');
X = atnum(:, 1:6);
y = atnum(:, 7);

n = size(y, 1);

alpha = 0.05;
gamma = 1 - alpha;

% ---- Jednostruki linearni model ----

X5 = atnum(:, 5);

X_jm = [ones(n, 1) X5];
[beta_jm_hat, y_jm_hat, RSS_jm] = lreg(X_jm, y);
disp(['Jednacina jednostruke linearne regresije za procenat zauzetih sedista preko broja putnickih kilometara * 1000, tokom meseca, je Y = ', num2str(beta_jm_hat(1)), ' + ', num2str(beta_jm_hat(2)), ' * x5.'])

figure
plot(X5, y, 'b*')
hold on
plot(X5, y_jm_hat, 'r')
xlabel('Broj putnickih kilometara u hiljadama')
ylabel('Procenat zauzetih sedista')
title(['Dijagram rasipanja i regresiona prava y = ', num2str(beta_jm_hat(1)), ' + ', num2str(beta_jm_hat(2)), ' * x'])
hold off

res_jm = y - y_jm_hat;
p_jm = bptest(X_jm, res_jm);
if p_jm < alpha
    disp(['Reziduali jednostrukog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali jednostrukog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

figure
plot(y_jm_hat, res_jm, 'b*')
xlabel('Ocena procenta zauzetih sedista jednostrukog linearnog modela')
ylabel('Reziduali jednostrukog linearnog modela')
title('Dijagram rasipanja reziduala u odnosu na ocenu procenta zauzetih sedista')

deg_fr = n - size(beta_jm_hat, 1);
S2_jm = RSS_jm / deg_fr;
SX5X5 = sum((X5 - mean(X5)) .^ 2);
q_jm = tinv(1 - alpha / 2, deg_fr);
pm_ci_beta_jm_0 = q_jm * sqrt(S2_jm * sum(X5 .^ 2) / (SX5X5 * n));
ci_beta_jm_0 = [beta_jm_hat(1) - pm_ci_beta_jm_0, beta_jm_hat(1) + pm_ci_beta_jm_0];
disp(['Interval poverenja za koeficijent beta_0 jednostrukog linearnog modela, na nivou poverenja ', num2str(gamma), ', je: [', num2str(ci_beta_jm_0(1)), ', ', num2str(ci_beta_jm_0(2)), '].']);

pm_ci_beta_jm_1 = q_jm * sqrt(S2_jm / SX5X5);
ci_beta_jm_1 = [beta_jm_hat(2) - pm_ci_beta_jm_1, beta_jm_hat(2) + pm_ci_beta_jm_1];
disp(['Interval poverenja za koeficijent beta_1 jednostrukog linearnog modela, na nivou poverenja ', num2str(gamma), ', je: [', num2str(ci_beta_jm_1(1)), ', ', num2str(ci_beta_jm_1(2)), '].']);

MSE_jm = RSS_jm / n;

Syy = sum((y - mean(y)) .^ 2);
R2_jm = 1 - RSS_jm / Syy;

% ---- Pun linearni model ----

X = [ones(n, 1) X];
rank_X = rank(X);

[beta_hat, y_hat, RSS] = lreg(X, y);
disp(['Jednacina visestruke linearne regresije za procenat zauzetih sedista preko ostalih promenljivih, tokom meseca, je Y = ', num2str(beta_hat(1)), ' + ', num2str(beta_hat(2)), ' * x1 - ', num2str(abs(beta_hat(3))), ' * x2 + ', num2str(beta_hat(4)), ' * x3 - ', num2str(abs(beta_hat(5))), ' * x4 + ', num2str(beta_hat(6)), ' * x5 - ', num2str(abs(beta_hat(7))), ' * x6.']);

res = y - y_hat;
p = bptest(X, res);
if p < alpha
    disp(['Reziduali punog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali punog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

figure
plot(y_hat, res, 'b*')
xlabel('Ocena procenta zauzetih sedista punog linearnog modela')
ylabel('Reziduali punog linearnog modela')
title('Dijagram rasipanja reziduala u odnosu na ocenu procenta zauzetih sedista')

MSE = RSS / n;
R2 = 1 - RSS / Syy;

% ---- Redukovani linearni model ----

[feat, beta_red_hat, y_red_hat, RSS_red] = ffsb(X, y, 1, alpha);
disp(['Jednacina visestruke linearne regresije za procenat zauzetih sedista preko broja putnickih kilometara * 1000, broja sati letenja i broja putnika, tokom meseca, je Y = ', num2str(beta_red_hat(1)), ' + ', num2str(beta_red_hat(2)), ' * x5 - ', num2str(abs(beta_red_hat(3))), ' * x2 - ', num2str(abs(beta_red_hat(4))), ' * x4.'])
X_red = X(:, feat);

res_red = y - y_red_hat;
p_red = bptest(X_red, res_red);
if p_red < alpha
    disp(['Reziduali redukovanog linearnog modela nisu homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
else
    disp(['Reziduali redukovanog linearnog modela su homoskedasticni prema studentizovanom Brus-Peiganovom testu na nivou poverenja ', num2str(gamma), '.'])
end

figure
plot(y_red_hat, res_red, 'b*')
xlabel('Ocena procenta zauzetih sedista redukovanog linearnog modela')
ylabel('Reziduali redukovanog linearnog modela')
title('Dijagram rasipanja reziduala u odnosu na ocenu procenta zauzetih sedista')

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
disp(['Jednacina jednostruke nelinearne regresije za procenat zauzetih sedista preko broja putnickih kilometara * 1000, tokom meseca, je Y  = 100 / (1 + exp(-(', num2str(beta_jmnl_hat(1)), ' + ', num2str(beta_jmnl_hat(2)), ' * x5))).']);

figure
plot(X5, y, 'b*')
hold on
xv = (min(X5):7000:max(X5))';
plot(xv, 100 ./ (1 + exp(-([ones(size(xv, 1), 1) xv] * beta_jmnl_hat))), 'r')
xlabel('Broj putnickih kilometara u hiljadama')
ylabel('Procenat zauzetih sedista')
title(['Dijagram rasipanja i regresiona kriva y = 100 / (1 + exp(-(', num2str(beta_jmnl_hat(1)), ' + ', num2str(beta_jmnl_hat(2)), ' * x)))'])
hold off

MSE_jmnl = RSS_jmnl / n;

f = @(b) 100 ./ (1 + exp(-(X * b)));
f_red = @(b) 100 ./ (1 + exp(-(X_red * b)));

beta_nl_hat = zeros(size(X, 2), 1);
[beta_nl_hat, n_iter, y_nl_hat, RSS_nl] = gn(y, f, beta_nl_hat, h, max_iter, stop);
disp(['Jednacina visestruke nelinearne regresije za procenat zauzetih sedista preko ostalih promenljivih, tokom meseca, je Y = 100 / (1 + exp(-(', num2str(beta_nl_hat(1)), ' + ', num2str(beta_nl_hat(2)), ' * x1 - ', num2str(abs(beta_nl_hat(3))), ' * x2 + ', num2str(beta_nl_hat(4)), ' * x3 - ', num2str(abs(beta_nl_hat(5))), ' * x4 + ', num2str(beta_nl_hat(6)), ' * x5 - ', num2str(abs(beta_nl_hat(7))), ' * x6))).']);
beta_rednl_hat = zeros(size(X_red, 2), 1);
[beta_rednl_hat, n_iter_red, y_rednl_hat, RSS_rednl] = gn(y, f_red, beta_rednl_hat, h, max_iter, stop);
disp(['Jednacina visestruke nelinearne regresije za procenat zauzetih sedista preko broja putnickih kilometara * 1000, broja sati letenja i broja putnika, tokom meseca, je Y  = 100 / (1 + exp(-(', num2str(beta_rednl_hat(1)), ' + ', num2str(beta_rednl_hat(2)), ' * x5 - ', num2str(abs(beta_rednl_hat(3))), ' * x2 - ', num2str(abs(beta_rednl_hat(4))), ' * x4))).']);

MSE_nl = RSS_nl / n;
MSE_rednl = RSS_rednl / n;

X_red2 = X_red(:, 2:end);
f_red2 = @(b) 100 ./ (1 + exp(-(X_red2 * b)));

beta_red2nl_hat = zeros(size(X_red2, 2), 1);
[beta_red2nl_hat, n_iter_red2, y_red2nl_hat, RSS_red2nl] = gn(y, f_red2, beta_red2nl_hat, h, max_iter, stop);
disp(['Jednacina visestruke nelinearne regresije bez slobodnog clana za procenat zauzetih sedista preko broja putnickih kilometara * 1000, broja sati letenja i broja putnika, tokom meseca, je Y  = 100 / (1 + exp(-(', num2str(beta_red2nl_hat(1)), ' * x5 - ', num2str(abs(beta_red2nl_hat(2))), ' * x2 - ', num2str(abs(beta_red2nl_hat(3))), ' * x4))).']);

MSE_red2nl = RSS_red2nl / n;

% ---- Trening i testiranje ----

trening_size = 0.7;
tt_iter = 1000;

n_trening = round(trening_size * n);
n_test = n - n_trening;
nv = 1:n;

MSE_test = NaN(tt_iter, 7);
for i = 1:tt_iter
    tren_rows = randsample(n, n_trening);
    test_rows = setdiff(nv, tren_rows);
    
    X_jm_tren = X_jm(tren_rows, :);
    X_tren = X(tren_rows, :);
    X_red_tren = X_red(tren_rows, :);
    X_red2_tren = X_red2(tren_rows, :);
    f_jm_tren = @(b) 100 ./ (1 + exp(-(X_jm_tren * b)));
    f_tren = @(b) 100 ./ (1 + exp(-(X_tren * b)));
    f_red_tren = @(b) 100 ./ (1 + exp(-(X_red_tren * b)));
    f_red2_tren = @(b) 100 ./ (1 + exp(-(X_red2_tren * b)));
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
    beta_red2nl_tren = zeros(size(X_red2_tren, 2), 1);
    beta_red2nl_tren = gn(y_tren, f_red2_tren, beta_red2nl_tren, h, max_iter, stop);
    
    X_jm_test = X_jm(test_rows, :);
    X_test = X(test_rows, :);
    X_red_test = X_red(test_rows, :);
    X_red2_test = X_red2(test_rows, :);
    f_jm_test = @(b) 100 ./ (1 + exp(-(X_jm_test * b)));
    f_test = @(b) 100 ./ (1 + exp(-(X_test * b)));
    f_red_test = @(b) 100 ./ (1 + exp(-(X_red_test * b)));
    f_red2_test = @(b) 100 ./ (1 + exp(-(X_red2_test * b)));
    y_test = y(test_rows, :);
    
    MSE_test(i, 1) = sum((y_test - X_jm_test * beta_jm_tren) .^ 2) / n_test;
    MSE_test(i, 2) = sum((y_test - X_test * beta_tren) .^ 2) / n_test;
    MSE_test(i, 3) = sum((y_test - X_red_test * beta_red_tren) .^ 2) / n_test;
    MSE_test(i, 4) = sum((y_test - f_jm_test(beta_jmnl_tren)) .^ 2) / n_test;
    MSE_test(i, 5) = sum((y_test - f_test(beta_nl_tren)) .^ 2) / n_test;
    MSE_test(i, 6) = sum((y_test - f_red_test(beta_rednl_tren)) .^ 2) / n_test;
    MSE_test(i, 7) = sum((y_test - f_red2_test(beta_red2nl_tren)) .^ 2) / n_test;
end

mean_MSE_test = mean(MSE_test);