function [header_lines, T] = read_opensim_storage_with_header(file_path, varargin)
% ----------------------------------------------------------------------- %
% read_opensim_storage_with_header.m
% Read an OpenSim .sto or .mot file, preserving header lines and returning
% the numeric data as a table.
%
% Usage:
%   [header_lines, T] = read_opensim_storage_with_header(file_path)
%
% Inputs:
%   file_path - path to an OpenSim storage-style text file (.sto or .mot)
%
% Outputs:
%   header_lines - cell array of header lines up to and including
%   'endheader'
%   T            - data table with column names from the first line after
%   'endheader'
%
% Notes:
%   - This reader assumes the file contains an 'endheader' line.
%   - The line immediately following 'endheader' is treated as the column
%     name row.
%   - All data columns are read as numeric where possible.
%   - The time column name is normalized to 'time' if present with other
%     capitalization.
%
% Example:
%   [hdr, T] = read_opensim_storage_with_header('trial_01.mot');

    %% ---- Input validation ----
    if nargin < 1
        error('read_opensim_storage_with_header requires file_path as input.');
    end

    if ~(ischar(file_path) || isstring(file_path))
        error('file_path must be a character vector or a string scalar.');
    end

    file_path = char(file_path);

    if ~isfile(file_path)
        error('File not found: %s', file_path);
    end

    %% ---- Read header lines up to endheader ----
    fid = fopen(file_path, 'r');
    if fid < 0
        error('Could not open file: %s', file_path)
    end

    cleanup_obj = onCleanup(@() fclose(fid));

    header_lines = {};
    found_endheader = false;

    while true
        line = fgetl(fid);

        if ~ischar(line)
            break;
        end

        % Strip leading non-printing characters if present
        line = regexprep(char(line), '^[^\x20-\x7E]+', '');
        header_lines{end+1} = line; %#ok<AGROW>

        if strcmpi(strtrim(line), 'endheader')
            found_endheader = true;
            break;
        end
    end

    if ~found_endheader
        error('Did not find "endheader" in file: %s', file_path);
    end

    %% ---- Read column name line ----
    header_line = fgetl(fid);
    if ~ischar(header_line)
        error('Could not read column header line after endheader in file: %s', file_path);
    end

    header_line = strtrim(header_line);
    if isempty(header_line)
        error('Column header line after endheader is empty in file: %s', file_path);
    end

    var_names = regexp(header_line, '\s+', 'split');
    var_names = matlab.lang.makeValidName(var_names, 'ReplacementStyle', 'delete');
    var_names = matlab.lang.makeUniqueStrings(var_names);

    if isempty(var_names)
        error('No variable names were parsed from the column header line in file: %s', file_path);
    end

    %% ---- Read numeric data block ----
    format_spec = repmat('%f', 1, numel(var_names));
    raw = textscan(fid, format_spec, ...
        'Delimiter', {'\t', ' '}, ...
        'MultipleDelimsAsOne', true, ...
        'CollectOutput', true, ...
        'ReturnOnError', false);

    data = raw{1};

    if isempty(data)
        warning('No numeric data rows were read from file: %s', file_path);
        T = array2table(zeros(0, numel(var_names)), 'VariableNames', var_names);
        return;
    end

    %% ---- Handle column count mismatch conservatively ----
    n_cols_data = size(data, 2);
    n_cols_names = numel(var_names);

    if n_cols_data ~= n_cols_names
        warning(['Column count mismatch in file "%s": parsed %d variable names ' ...
                 'but read %d numeric columns. Truncating to the smaller count.'], ...
                 file_path, n_cols_names, n_cols_data);

        n_keep = min(n_cols_data, n_cols_names);
        data = data(:, 1:n_keep);
        var_names = var_names(1:n_keep);
    end

    %% ---- Build output table ----
    T = array2table(data, 'VariableNames', var_names);

    %% ---- Normalize time column name ----
    vars = T.Properties.VariableNames;
    for i = 1:numel(vars)
        if strcmpi(vars{i}, 'time')
            T.Properties.VariableNames{i} = 'time';
            break
        end
    end
end
