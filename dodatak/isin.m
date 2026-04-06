function [bool] = isin(A, DS)

bool = false;
if isa(DS, 'cell')
    for i = 1:numel(DS)
        if isequal(A, DS{i})
            bool = true;
            break
        end
    end
elseif isa(DS, 'table') || isa(DS, 'timetable')
    b = size(DS, 2);
    for i = 1:size(DS, 1)
        for j = 1:b
            if isequal(A, DS{i, j})
                bool = true;
                break
            end
        end
        if bool
            break
        end
    end
else
    for i = 1:numel(DS)
        if isequal(A, DS(i))
            bool = true;
            break
        end
    end
end

end