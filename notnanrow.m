function [mask] = notnanrow(M)

n = size(M, 1);
k = size(M, 2);

mask = true(n, 1);
for i = 1:n
    for j = 1:k
        if isnan(M(i, j))
            mask(i) = false;
            break
        end
    end
end

end