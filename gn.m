function [beta_hat, n_iter, y_hat, RSS] = gn(y, f, beta_hat, h, max_iter, stop)

n = size(y, 1);
r = @(b) y - f(b);
n_param = size(beta_hat, 1);
M = 1i * h * eye(n_param);

J = NaN(n, n_param);
for n_iter = 1:max_iter
    for j = 1:n_param
        J(:, j) = imag(r(beta_hat + M(:, j))) / h;
    end
    
    g = (J' * J) \ (J' * r(beta_hat));
    norm_g = norm(g);
    if norm_g < stop || isnan(norm_g)
        n_iter = n_iter - 1;
        break
    end
    
    beta_hat = beta_hat - g;
end

y_hat = f(beta_hat);
RSS = sum((y - y_hat) .^ 2);

end