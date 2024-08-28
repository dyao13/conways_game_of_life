function next_gen_mat = GOL(in_mat)
% Construct the next evolution next_gen_mat 
% given an initial matrix in_mat
% for Conway's Game of Life.

    y_size = size(in_mat, 1);
    x_size = size(in_mat, 2);
    next_gen_mat = zeros(y_size, x_size);

    % evolve each cell
    for i = 1:(y_size)
        for j = 1:(x_size)
            % count number of live neighbors
            count = 0;
            for k = (i-1):(i+1)
                for l = (j-1):(j+1)
                    % check boundary conditions
                    if k ~= 0 && k ~= y_size+1 && l ~= 0 && l ~= x_size+1 && ~all([k, l] == [i, j])
                        count = count + in_mat(k, l);
                    end
                end
            end

            % perform rules and store evolution in matrix B
            if in_mat(i, j) == 1
                if count < 2 || count > 3
                    next_gen_mat(i, j) = 0;
                else
                    next_gen_mat(i, j) = 1;
                end
            elseif count == 3
                next_gen_mat(i, j) = 1;
            end
        end
    end
end