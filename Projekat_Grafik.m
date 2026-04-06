x = -5:0.1:5;
y = 100 ./ (1 + exp(-x));
plot(x, y, 'b')
xlabel('x')
ylabel('y')
title('y = 100 / (1 + exp(-x))')