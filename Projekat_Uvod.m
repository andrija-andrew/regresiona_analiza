at = readtable('AirTraffic.csv');

at{:, 1} = strrep(at{:, 1}, 'MAY', 'MAJ');
at{:, 1} = strrep(at{:, 1}, 'JUNE', 'JUN');
at{:, 1} = strrep(at{:, 1}, 'JULY', 'JUL');
at{:, 1} = strrep(at{:, 1}, 'AUG', 'AVG');
at{:, 1} = strrep(at{:, 1}, 'OCT', 'OKT');
at{:, 9} = strrep(at{:, 9}, 'Y', 'G');

oznake = {'letova', 'sati letenja', 'predjenih kilometara u hiljadama', 'putnika', 'putnickih kilometara u hiljadama', 'kilometara dostupnih sedista u hiljadama', 'Procenat zauzetih sedista'};

atnum = at{:, 2:8};
mask = notnanrow(atnum);
atnum = atnum(mask, :);

n = size(atnum, 1);
k = size(atnum, 2);

mo_fiscalyr = strcat(at{:, 1}, {' '}, at{:, 9});
x_axis = mo_fiscalyr(mask);
colors = {'b', 'g', 'r', 'c', 'm', 'y'};
fs = 22;
for j = 1:k - 1
    figure
    bar(atnum(:, j), 'BarWidth', 0.77, 'FaceColor', char(colors(j)))
    set(gca, 'XTick', 1:n, 'XTickLabel', x_axis, 'XTickLabelRotation', 90, 'TickLength', [0 0], 'FontSize', 10.5)
    txt = strcat({'Broj '}, oznake(j));
    ylabel(char(txt), 'FontSize', fs)
    title(char(strcat(txt, {' tokom meseca'})), 'FontSize', fs)
end
figure
bar(atnum(:, k), 'BarWidth', 0.77)
set(gca, 'XTick', 1:n, 'XTickLabel', x_axis, 'XTickLabelRotation', 90, 'TickLength', [0 0], 'FontSize', 10.5)
ylabel(char(oznake(k)), 'FontSize', fs)
title(char(strcat(oznake(k), {' tokom meseca'})), 'FontSize', fs)

mean_arr = mean(atnum);
min_arr = min(atnum);
quart1_arr = quantile(atnum, 0.25);
med_arr = median(atnum);
quart3_arr = quantile(atnum, 0.75);
max_arr = max(atnum);
mode_arr = [];
[~, freq_mode_arr, mode_cell] = mode(atnum);
for j = 1:k
    if freq_mode_arr(j) > 1
        mode_arr = nancat({mode_arr, mode_cell{j}}, 2);
    else
        mode_arr = nancat({mode_arr, NaN}, 2);
    end
end
cvar_arr = var(atnum);
cstdev_arr = sqrt(cvar_arr);
iqr_arr = quart3_arr - quart1_arr;

Rho = corr(atnum);

HP = NaN(2, k);
for j = 1:k
    [HP(1, j), HP(2, j)] = chi2gof(atnum(:, j));
end