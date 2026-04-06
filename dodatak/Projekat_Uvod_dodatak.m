atnum = xlsread('AirTraffic.xlsx');
atnum = atnum(1:84, :);

k = size(atnum, 2);

Rho = corr(atnum);

HP = NaN(2, k);
for j = 1:k
    [HP(1, j), HP(2, j)] = chi2gof(atnum(:, j));
end