function [beta_hat, y_hat, RSS] = lreg(x, y)

beta_hat = (x' * x) \ (x' * y);
y_hat = x * beta_hat;
RSS = sum((y - y_hat) .^ 2);

end