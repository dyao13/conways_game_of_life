function A = RLE_decoder(file_name)
% Transform RLE file into matrix A.
% Note that RLE_decoder() remove the header,
% so no manual modifications to the input pattern are needed.
    
    % read RLE file
    raw_data = importdata(file_name);

    % convert struct array to cell array if needed
    if isstruct(raw_data)
        
        % locate dimensional data ({'x = ...'})
        for i = 1:size(raw_data.textdata, 1)
            if ~isempty(regexp(raw_data.textdata{i, 1}, '^x', 'match'))
                dim_line_index = i;
                dim_line = [raw_data.textdata{i, :}];
            end
        end

        raw_data = {raw_data.textdata{:, 1}}';
        raw_data{dim_line_index} = dim_line;
    end

    % remove comments
    data = {};

    for i = 1:size(raw_data)
        if isempty(regexp(raw_data{i}, '^#.*', 'once'))
            data = [data; raw_data{i}];
        end
    end

    % join array data into one cell
    for i = 3:size(data, 1)
        data{2} = [data{2}, data{i}];
    end
    data = {data{1:2}}';

    % remove spaces
    data{1} = replace(data{1}, ' ', '');
    
    % remove '!'
    if strcmp(data{2}(end), '!')
        data{2} = data{2}(1:end-1);
    end

    % determine dimensions of array
    dim_data = regexp(data{1}, '\D{1}=\d+', 'match');

    m = regexp(dim_data{2}, '\d+', 'match');
    n = regexp(dim_data{1}, '\d+', 'match');

    A = zeros(str2double(m{1}), str2double(n{1}));

    % construct array
    row_data = regexp(data{2}, '[^\$]+\${0,1}', 'match');

    % loop through the instructions for each row
    row = 1;
    for i = 1:size(row_data, 2)
        array_data = regexp(row_data{i}, '\d*\D\${0,1}', 'match');

        % populate array
        index = 1;
        for j = 1:size(array_data, 2)
            number = regexp(array_data{j}, '\d*', 'match');
            state = regexp(array_data{j}, '\D', 'match');
            end_row = regexp(array_data{j}, '\d*\$', 'match');

            if isempty(number)
                number = 1;
            else
                number = str2double(number{1});
            end
            state = state{1};
            
            if state == 'o'
                A(row, index:(index+number-1)) = ones(1, number);
            end

            index = index + number;
            
            if ~isempty(end_row)
                % end row
                end_row_number = regexp(end_row{1}, '\d*', 'match');

                if isempty(end_row_number)
                    end_row_number = 1;
                else
                    end_row_number = str2double(end_row_number{1});
                end

                row = row + end_row_number; 
            end
        end
    end
end