
%
% This script is an abomination. Yes. I know. 
%
% The objective here is to brute force the optimal position of the zero we add
% to the inner loop to mkae the high-frequency slope accurate. Yes, this is a
% terrible idea and I would probably have been better served by setting the
% inner weighting to some kind of low pass filter.
%
% Hindsight is 20/20. Sue me. 
%

poles = 5:1:100;
inner_bw = 10;

results = struct(); 
for k = 1:length(poles)
    pole = poles(k);
    
    results(k).pole = pole;
    results(k).rmse = do_rmse_with_pole(inner_bw, pole);
    
    fprintf('Pole: s = %f, RMSE = %f\n', pole, results(k).rmse);
end

figure();
    semilogy([results(:).pole], [results(:).rmse]);
    grid on; 
    title('RMSE as a function of the position of the pole');
    ylabel('RMSE');
    xlabel('Pole position (s = x)');



function rmse = do_rmse_with_pole(inner_bw, pole)
    load 'quad_copter_models.mat';

    InnerReferenceModel = mk_2nd_order(inner_bw, .7) * tf([1 pole], pole);
    InnerReferenceModel_dt = c2d(InnerReferenceModel, Ts);
    
    [OptimalController_dt, ~] = VRFT1_ry_theta( ...
        vrft_data.dM, vrft_data.q_dot, InnerReferenceModel_dt, ...
        PIDControllerClass_dt, [], 9, [] ...
    );
    
    cloop = loopsens(PlantModel_dt, OptimalController_dt); 
    InnerLoop_VRFT_dt = cloop.Ti;
    
    vrft_y = step(InnerLoop_VRFT_dt, 10);
    ref_y  = step(InnerReferenceModel_dt, 10);
    
    rmse = rms(ref_y - vrft_y);
end

