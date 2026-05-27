% example_read_storage_file
clear; clc;

startup_pipeline();

file_path = fullfile('..', '..', 'data_templates', 'mot', 'example_grf_mot');

data = opensimio.read_mot(file_path);

disp(data);