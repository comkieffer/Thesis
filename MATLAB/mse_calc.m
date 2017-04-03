%% MSE Analysis of the measured data
% First things first. What data do we want to read ?


source_datasets = {
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt/parsed_logs/test_i8_di09_o4_do09_full_batt.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_1/parsed_logs/test_i8_di09_o4_do09_full_batt_1.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_2/parsed_logs/test_i8_di09_o4_do09_full_batt_2.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_3/parsed_logs/test_i8_di09_o4_do09_full_batt_3.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_4/parsed_logs/test_i8_di09_o4_do09_full_batt_4.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_5/parsed_logs/test_i8_di09_o4_do09_full_batt_5.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_7/parsed_logs/test_i8_di09_o4_do09_full_batt_7.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_8/parsed_logs/test_i8_di09_o4_do09_full_batt_8.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_9/parsed_logs/test_i8_di09_o4_do09_full_batt_9.mat',
  'Hardware Testing/test_results/test_i8_di09_o4_do09_full_batt_10/parsed_logs/test_i8_di09_o4_do09_full_batt_10.mat',
};
%% 
% Since for some reason |MATLAB| wants to hide all the usefule error metrics 
% from us we need our own |mse| function.

mse = @(ref, actual) mean((ref - actual).^2);
%% Analyse the data

full_test_mse = [];

for k = 1:length(source_datasets)
    data = load(source_datasets{k}); 
    full_test_mse(k) = mse(data.attitude_ctr_test_p, data.o_attitude_p);
end

full_test_mse_mean = mean(full_test_mse);

disp('Full Test MSEs');
disp(full_test_mse);
disp('Mean:');
disp(full_test_mse_mean);

%% Same thing for the disturbed scenario

source_datasets = {
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_1/parsed_logs/test_i8_di09_o4_do09_disturb_1.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_2/parsed_logs/test_i8_di09_o4_do09_disturb_2.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_3/parsed_logs/test_i8_di09_o4_do09_disturb_3.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_4/parsed_logs/test_i8_di09_o4_do09_disturb_4.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_5/parsed_logs/test_i8_di09_o4_do09_disturb_5.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_6/parsed_logs/test_i8_di09_o4_do09_disturb_6.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_8/parsed_logs/test_i8_di09_o4_do09_disturb_8.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_9/parsed_logs/test_i8_di09_o4_do09_disturb_9.mat',
    'Hardware Testing/test_results/test_i8_di09_o4_do09_disturb_10/parsed_logs/test_i8_di09_o4_do09_disturb_10.mat',
};

disturb_test_mse = [];

for k = 1:length(source_datasets)
    data = load(source_datasets{k}); 
    disturb_test_mse(k) = mse(data.attitude_ctr_test_p, data.o_attitude_p);
end

disturb_test_mse_mean = mean(disturb_test_mse);


disp('Disturbed Test MSEs');
disp(disturb_test_mse);
disp('Mean:');
disp(disturb_test_mse_mean);