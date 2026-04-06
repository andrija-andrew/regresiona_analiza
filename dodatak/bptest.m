function [p] = bptest(z, res, studentize)

if nargin == 2
    studentize = true;
end

n = size(res, 1);

res2 = res .^ 2;
ML_S2 = sum(res2) / n;
g = res2 / ML_S2;
[~, g_hat] = lreg(z, g);

deg_fr = size(z, 2) - 1;
ESS = sum((g_hat - mean(g)) .^ 2);
if studentize
    TSS = sum((g - mean(g)) .^ 2);
    R2 = ESS / TSS;
    test_stat = n * R2;
else
    test_stat = ESS / 2;
end
p = 1 - chi2cdf(test_stat, deg_fr);

end