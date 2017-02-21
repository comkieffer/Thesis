
load 'quad_copter_models.mat';


dampings = .1:.1:1;
bandwidths = 1:1:40;

all_rows = struct();
all_rows_idx = 1;

good_rows = cell(0);
good_rows_idx = 1;

for d = dampings
    for bw = bandwidths 
       [Kp, Ki, Kd, Tf] = run_inner_vrft_bf(bw, d);
       
       all_rows(all_rows_idx).bandwidth = bw;
       all_rows(all_rows_idx).damping = d;
       all_rows(all_rows_idx).Kp = Kp;
       all_rows(all_rows_idx).Ki = Ki;
       all_rows(all_rows_idx).Kd = Kd;
       all_rows(all_rows_idx).Tf = Tf;
       
       all_rows_idx = all_rows_idx + 1;
    end 
end

%%
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║                       All PID Controllers                    ║\n');
fprintf('╠═══════╦══════╦═══════════╦═══════════╦═══════════╦═══════════╣\n');
fprintf('║ Band  ║ Damp ║    Kp     ║    Ki     ║    Kd     ║    Tf     ║\n');
fprintf('╠═══════╬══════╬═══════════╬═══════════╬═══════════╬═══════════╣\n');

for k = 1:length(all_rows)
    row = all_rows(k);
    fprintf('║ %5.2f ║ %4.2f ║  %7.3f  ║  %7.3f  ║  %7.3f  ║  %7.3f  ║\n', ...
        row.bandwidth, row.damping, row.Kp, row.Ki, row.Kd, row.Tf);
end

fprintf('╚═══════╩══════╩═══════════╩═══════════╩═══════════╩═══════════╝\n');

for k = 1:length(all_rows)
    row = all_rows(k);
    
    if (row.Kp >= 0 && row.Ki >= 0 && row.Kd >= 0)
        good_rows(good_rows_idx).bandwidth = row.bandwidth;
        good_rows(good_rows_idx).damping = row.damping;
        good_rows(good_rows_idx).Kp = row.Kp;
        good_rows(good_rows_idx).Ki = row.Ki;
        good_rows(good_rows_idx).Kd = row.Kd;
        good_rows(good_rows_idx).Tf = row.Tf;
        
        cloop = loopsens(PitchRateModel * Mixer, pid(row.Kp, row.Ki, row.Kd));
        info = stepinfo(cloop.Ti);
        
        good_rows(good_rows_idx).SettlingTime = info.SettlingTime; 
        good_rows(good_rows_idx).Overshoot = info.Overshoot;
        
        good_rows_idx = good_rows_idx + 1;
    end
end


fprintf('╔══════════════════════════════════════════════════════════════════════════════════════╗\n');
fprintf('║                               All Good PID Controllers                               ║\n');
fprintf('╠═══════╦══════╦═══════════╦═══════════╦═══════════╦═══════════╦═══════════╦═══════════╣\n');
fprintf('║ Band  ║ Damp ║    Kp     ║    Ki     ║    Kd     ║    Tf     ║ Settl. T. ║ Overshoot ║\n');
fprintf('╠═══════╬══════╬═══════════╬═══════════╬═══════════╦═══════════╬═══════════╬═══════════╣\n');

for k = 1:length(good_rows)
    row = good_rows(k);
    fprintf('║ %5.2f ║ %4.2f ║  %7.3f  ║  %7.3f  ║  %7.3f  ║  %7.3f  ║  %7.3f  ║  %7.3f  ║\n', ...
        row.bandwidth, row.damping, row.Kp, row.Ki, row.Kd, row.Tf, row.SettlingTime, row.Overshoot);    
end

fprintf('╚═══════╩══════╩═══════════╩═══════════╩═══════════╩═══════════╩═══════════╩═══════════╝\n');

function [Kp, Ki, Kd, Tf] = run_inner_vrft_bf(ref_bw, ref_damping)

    load 'quad_copter_models.mat';

    InnerReferenceModel = mk_2nd_order(ref_bw, ref_damping);
    InnerReferenceModel_dt = c2d(InnerReferenceModel, Ts);

    vrft_data = struct();
    ol_data = load('dati_id_ol_scalati.mat');

    vrft_data.time      = ol_data.t;
    vrft_data.dOmega    = ol_data.u;
    vrft_data.q_dot     = ol_data.yi;
    vrft_data.dM = lsim(Mixer^-1, vrft_data.dOmega, vrft_data.time);

    OptimalNoiseOrder = 9;

    Controller = VRFT1_ry_theta( ...
        vrft_data.dM, vrft_data.q_dot, InnerReferenceModel_dt, ...
        PIDControllerClass_dt, [], OptimalNoiseOrder, [] ...
    );
    
    % Get the gains of the continuous time PID controller
    [Kp, Ki, Kd, Tf] = piddata( d2c(Controller) );
    
end