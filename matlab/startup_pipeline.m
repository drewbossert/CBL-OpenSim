function startup_pipeline()
% STARTUP_PIPELINE Add the modeling pipeline MATLAB folders to the path.
%
% Run this file from anywhere to add the  repository MATLAB tools to the
% current MATLAB path.

    this_file = mfilename('fullpath');
    matlab_dir = fileparts(this_file);
    repo_root = fileparts(matlab_dir);

    addpath(matlab_dir);
    addpath(fullfile(matlab_dir, 'examples'));

    fprintf('Infant neck modeling pipeline added to MATLAB path.\n');
    fprintf('Repository root: %s\n', repo_root);
end
