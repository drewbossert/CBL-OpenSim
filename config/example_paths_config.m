function paths = example_paths_config()
%EXAMPLE_PATHS_CONFIG Example local path configuration.
%
% Copy this file to paths_config.m and edit the paths for your machine.
% paths_config.m is ignored by Git.

    paths = struct();

    paths.repo_root = 'C:\path\to\infant-neck-modeling-pipeline';
    paths.opensim_install = 'C:\OpenSim 4.5';
    paths.project_data = 'C:\path\to\local\data';
    paths.model_dir = 'C:\path\to\models';
    paths.results_dir = 'C:\path\to\results';

end
