function [feat, beta_hat, y_hat, RSS] = ffsb(x, y, base, alpha)

n = size(y, 1);
k = size(x, 2);

feat = base;
[~, ~, RSS] = lreg(x(:, feat), y);
for i = 2:k
    RSS_arr = NaN(k, 1);
    for j = 1:k
        if ~isin(j, feat)
            [~, ~, RSS_arr(j)] = lreg(x(:, [feat; j]), y);
        end
    end
    
    [RSS_c, feat_c] = min(RSS_arr);
    if (RSS - RSS_c) / (RSS_c / (n - i)) <= finv(1 - alpha, 1, n - i)
        break
    end
    
    feat = [feat; feat_c];
    RSS = RSS_c;
end

[beta_hat, y_hat] = lreg(x(:, feat), y);

end