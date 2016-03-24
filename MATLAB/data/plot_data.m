
% Make a plot of the input output data store in 'dati_qr.mat'

qr_data = load('dati_qr.mat');

figure()
    subplot 311
        time_vec = 1:length(y1);
        plot(time_vec, qr_data.u1, 'b', time_vec, qr_data.y1, 'r');
        title('Quadrotor I/O Measurements');
    subplot 312
        time_vec= 1:length(y2); 
        plot(time_vec, qr_data.u2, 'b', time_vec, qr_data.y2, 'r');        
    subplot 313
        time_vec = 1:length(y3);
        plot(time_vec, qr_data.u3, 'b', time_vec, qr_data.y3, 'r');
        legend('Input', 'Output');
        
clear qr_data;