clear; clc;

startup_pipeline();

force = [
    0 0 10
    0 0 20
    0 0 30
];

moment = [
    1 2 0
    2 4 0
    3 6 0
];

origin = [0 0 0];

cop = grf.compute_cop(force, moment, origin);

disp(cop);