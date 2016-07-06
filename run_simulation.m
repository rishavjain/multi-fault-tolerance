path = [0 0;
        10 0;
        10 10;
        -20 10;
        -20 0;]';

inflation_size = 5;

params = initialize();

close all;
figure;
plot(path(1,:), path(2,:));
    
inflate_path(params, path, inflation_size);

finish(params)