function T = read_mot(filename)
% Robust reader for .mot with 7 header lines and names on line 8.

% First, read the first 8 lines to confirm
    fid = fopen(filename,'r');
    if fid < 0, error('Cannot open file: %s', filename); end
    C = textscan(fid, '%s', 8, 'Delimiter','\n', 'Whitespace','');  % read first 8 lines raw
    fclose(fid);
    if numel(C{1}) < 8
        error('File appears to have fewer than 8 lines; not a valid .mot with headers.');
    end
    
    % Try using detectImportOptions with VariableNamesLine = 8.
    try
        opts = detectImportOptions(filename, 'FileType','text');
        % In many cases, the first data row is 9 (since 8 is variable names)
        opts.VariableNamesLine = 7;
        opts.DataLines = [8 Inf];
        % Use whitespace delimiters (tabs/spaces)
        opts.Delimiter = {'\t',' ','\b'};
        % Protect against non-numeric strings in data section
        T = readtable(filename, opts);
    catch
        % Fallback manual read: parse header line 8 to get names, then read numerics
        fid = fopen(filename,'r');
        hdr = cell(7,1);
        for i=1:7, hdr{i} = fgetl(fid); end
        headerLine = fgetl(fid);
        if ~ischar(headerLine)
            fclose(fid);
            error('Could not read header names line.');
        end
        varNames = regexp(strtrim(headerLine), '\s+', 'split');
        raw = textscan(fid, repmat('%f',1,numel(varNames)), 'Delimiter', {'\t',' '}, 'CollectOutput', true);
        fclose(fid);
        M = raw{1};
        if size(M,2) ~= numel(varNames)
            % Attempt to clean names and retry minimal fix
            varNames = matlab.lang.makeValidName(varNames, 'ReplacementStyle','delete');
            varNames = matlab.lang.makeUniqueStrings(varNames);
            M = M(:, 1:min(end, numel(varNames))); % clip if too many numeric cols
        end
        T = array2table(M, 'VariableNames', varNames(1:size(M,2)));
    end
    
    % Ensure numeric
    for k = 1:width(T)
        if ~isnumeric(T.(k))
            T.(k) = str2double(T.(k));
        end
    end
end