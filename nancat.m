function [M] = nancat(C, dim)

n = numel(C);

if dim == 2
    cdim = 1;
else
    cdim = 2;
end

maxcdim = 0;
accsumdim = zeros(1, n + 1);
for i = 1:n
    if size(C{i}, cdim) > maxcdim
        maxcdim = size(C{i}, cdim);
    end
    
    accsumdim(i + 1) = accsumdim(i) + size(C{i}, dim);
end

if dim == 2
    M = NaN(maxcdim, accsumdim(n + 1));
    for i = 1:n
        M(1:size(C{i}, cdim), accsumdim(i) + 1:accsumdim(i + 1)) = C{i};
    end
else
    M = NaN(accsumdim(n + 1), maxcdim);
    for i = 1:n
        M(accsumdim(i) + 1:accsumdim(i + 1), 1:size(C{i}, cdim)) = C{i};
    end
end

end