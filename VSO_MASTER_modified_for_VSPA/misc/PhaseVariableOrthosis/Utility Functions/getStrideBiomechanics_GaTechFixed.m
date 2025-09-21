function dataOut = getStrideBiomechanics_GaTechFixed(dataset,activity,stride,task_input)


% subject_fields = fieldnames(dataset);
% subject_fields = subject_fields(~strcmp(subject_fields,"AB21"));

switch activity
    case "stair"
        leaveOut = ["none"];
        task_list = ["in7", "in6", "in5", "in4", "i4", "i5", "i6", "i7"];
    case "ramp"
        leaveOut = ["AB09","AB12","AB21","AB25","AB28"];
        task_list = ["in5x2", "in7x795", "in9x207", "in10x989", "in12x416", "in18",...
            "i18", "i12x416", "i10x989", "i9x207","i7x795", "i5x2"];
    case "treadmill"
        leaveOut = ["AB21","AB30"];
        task_list = ["i0"];
    otherwise
        error("Please input valid activity from this list: stair, ramp, treadmill.")
end

if ~exist('task_input','var')
    task_list = task_list;
else
    task_list = task_input;
end
subject_fields = fieldnames(dataset);
% subject_fields = subject_fields(~contains(subject_fields,leaveOut));

% task_list = ["in7", "in6", "in5", "in4", "i4", "i5", "i6", "i7"];

dataOut = struct;

for j = 1:length(task_list)
    task = task_list(j);
    
    % Full Stride
    thigh_angle_task = [];
    knee_angle_task = [];
    ankle_angle_task = [];
    
    thigh_velocity_task = [];
    knee_velocity_task = [];
    ankle_velocity_task = [];
    
    knee_torque_task= [];
    ankle_torque_task = [];
    
    knee_power_task= [];
    ankle_power_task = [];
    
    stride_time_task = [];
    
    knee_work_task = [];
    ankle_work_task = [];

    TO_task_temp = [];
    MHE_task_temp = [];
    MHF_task_temp = [];
    HS_task_temp = [];

    
    % Stance Stride
    thigh_angle_task_stance = [];
    knee_angle_task_stance = [];
    ankle_angle_task_stance = [];
    
    thigh_velocity_task_stance = [];
    knee_velocity_task_stance = [];
    ankle_velocity_task_stance = [];
    
    knee_torque_task_stance = [];
    ankle_torque_task_stance = [];
    
    knee_power_task_stance = [];
    ankle_power_task_stance = [];
    
    stride_time_task_stance = [];
    
    knee_work_task_stance = [];
    ankle_work_task_stance = [];

    TO_task_temp_stance = [];
    MHE_task_temp_stance = [];
    MHF_task_temp_stance = [];
    HS_task_temp_stance = [];
    
    % Swing Stride
    thigh_angle_task_swing = [];
    knee_angle_task_swing = [];
    ankle_angle_task_swing = [];
    
    thigh_velocity_task_swing = [];
    knee_velocity_task_swing = [];
    ankle_velocity_task_swing = [];
    
    knee_torque_task_swing = [];
    ankle_torque_task_swing = [];
    stride_time_task_swing = [];

    TO_task_temp_swing= [];
    MHE_task_temp_swing = [];
    MHF_task_temp_swing = [];
    HS_task_temp_swing= [];
    
    if strcmp(activity,"treadmill")
        stride_str = stride;
    elseif contains(task,"in") 
        stride_str = strcat(stride,"_descent");
    else
        stride_str = strcat(stride,"_ascent");
    end
       
    for i = 1:length(subject_fields)-2 %Ignore Average Subject and AB30 cause weird kinematics
        subject = subject_fields{i};
        % Initialize sub arrays
        
        % Fill in array
        if isfield(dataset.(subject).(activity).(stride_str),task) || strcmp(activity,"treadmill")
            
            if strcmp(activity,"treadmill")
                thigh_angle_sub = rad2deg(dataset.(subject).(activity).(stride_str).jointAngles.global_thigh_angle);
                knee_angle_sub =  rad2deg(dataset.(subject).(activity).(stride_str).jointAngles.knee_angle);
                ankle_angle_sub = rad2deg(dataset.(subject).(activity).(stride_str).jointAngles.ankle_angle);

                knee_torque_sub = dataset.(subject).(activity).(stride_str).jointMoments.knee_moment;
                ankle_torque_sub = dataset.(subject).(activity).(stride_str).jointMoments.ankle_moment;

                knee_power_sub = dataset.(subject).(activity).(stride_str).jointPowers.knee_power;
                ankle_power_sub = dataset.(subject).(activity).(stride_str).jointPowers.ankle_power;

                stride_time_sub = dataset.(subject).(activity).(stride_str).time;

                GRF_data = dataset.(subject).(activity).(stride_str).GRF.right.Treadmill_R_vy;
            else
                thigh_angle_sub = rad2deg(dataset.(subject).(activity).(stride_str).(task).jointAngles.global_thigh_angle);
                knee_angle_sub =  rad2deg(dataset.(subject).(activity).(stride_str).(task).jointAngles.knee_angle);
                ankle_angle_sub = rad2deg(dataset.(subject).(activity).(stride_str).(task).jointAngles.ankle_angle);

%                 knee_velocity_sub = rad2deg(dataset.(subject).(activity).(stride_str).(task).jointVelocities.knee_angle);
%                 ankle_velocity_sub = rad2deg(dataset.(subject).(activity).(stride_str).(task).jointVelocities.ankle_angle);

                knee_torque_sub = dataset.(subject).(activity).(stride_str).(task).jointMoments.knee_moment;
                ankle_torque_sub = dataset.(subject).(activity).(stride_str).(task).jointMoments.ankle_moment;

                knee_power_sub = dataset.(subject).(activity).(stride_str).(task).jointPowers.knee_power;
                ankle_power_sub = dataset.(subject).(activity).(stride_str).(task).jointPowers.ankle_power;

                stride_time_sub = dataset.(subject).(activity).(stride_str).(task).time;

                GRF_data = dataset.(subject).(activity).(stride_str).(task).GRF.right.FP_vy;
            end
        
        %Event Indexes
        [MHE_val, MHE_ind] = min(thigh_angle_sub');
        [MHF_val, MHF_ind] = max(thigh_angle_sub');
        HS_ind = ones(size(thigh_angle_sub,1),1);
        
        MHE_sub = MHE_ind';
        MHF_sub = MHF_ind';
        HS_sub = HS_ind;
        TO_sub = NaN(size(stride_time_sub,1),1);



        sample_vec = 1:size(stride_time_sub,2);
        
        thigh_velocity_sub = NaN(size(stride_time_sub));
        knee_velocity_sub = NaN(size(stride_time_sub));
        ankle_velocity_sub = NaN(size(stride_time_sub));

        
        knee_work_sub = NaN(size(stride_time_sub,1),1);
        ankle_work_sub = NaN(size(stride_time_sub,1),1);
        
        
        % initialize stance data
        thigh_angle_sub_stance = NaN(size(stride_time_sub));
        knee_angle_sub_stance = NaN(size(stride_time_sub));
        ankle_angle_sub_stance = NaN(size(stride_time_sub));
        
        thigh_velocity_sub_stance = NaN(size(stride_time_sub));
        knee_velocity_sub_stance = NaN(size(stride_time_sub));
        ankle_velocity_sub_stance = NaN(size(stride_time_sub));
        
        knee_torque_sub_stance = NaN(size(stride_time_sub));
        ankle_torque_sub_stance = NaN(size(stride_time_sub));
        
        stride_time_sub_stance = NaN(size(stride_time_sub));
        
        knee_power_sub_stance = NaN(size(stride_time_sub));
        ankle_power_sub_stance = NaN(size(stride_time_sub));
        
        knee_work_sub_stance = NaN(size(stride_time_sub,1),1);
        ankle_work_sub_stance = NaN(size(stride_time_sub,1),1);

        HS_sub_stance = NaN(size(stride_time_sub,1),1);
        MHE_sub_stance = NaN(size(stride_time_sub,1),1);
        TO_sub_stance = NaN(size(stride_time_sub,1),1);
        MHF_sub_stance = NaN(size(stride_time_sub,1),1);
        
        % initialize swing data
        thigh_angle_sub_swing = NaN(size(stride_time_sub));
        knee_angle_sub_swing = NaN(size(stride_time_sub));
        ankle_angle_sub_swing = NaN(size(stride_time_sub));
        
        thigh_velocity_sub_swing = NaN(size(stride_time_sub));
        knee_velocity_sub_swing = NaN(size(stride_time_sub));
        ankle_velocity_sub_swing = NaN(size(stride_time_sub));
        
        knee_torque_sub_swing = NaN(size(stride_time_sub));
        ankle_torque_sub_swing = NaN(size(stride_time_sub));
        
        stride_time_sub_swing = NaN(size(stride_time_sub));
        
        HS_sub_swing = NaN(size(stride_time_sub,1),1);
        MHE_sub_swing = NaN(size(stride_time_sub,1),1);
        TO_sub_swing = NaN(size(stride_time_sub,1),1);
        MHF_sub_swing = NaN(size(stride_time_sub,1),1);

        % Event Data full stride

        else
            thigh_angle_sub = [];
            knee_angle_sub =  [];
            ankle_angle_sub = [];

            knee_velocity_sub = [];
            ankle_velocity_sub = [];

            knee_torque_sub = [];
            ankle_torque_sub = [];

            knee_power_sub = [];
            ankle_power_sub = [];

            stride_time_sub = [];
            
            GRF_data =  [];
            
            thigh_velocity_sub = [];
        
            knee_work_sub = [];
            ankle_work_sub = [];
            
            MHE_sub = [];
            MHF_sub = [];
            HS_sub = [];
            TO_sub = [];
            
            
            % initialize stance data
            thigh_angle_sub_stance = [];
            knee_angle_sub_stance = [];
            ankle_angle_sub_stance = [];
            
            thigh_velocity_sub_stance = [];
            knee_velocity_sub_stance = [];
            ankle_velocity_sub_stance = [];
            
            knee_torque_sub_stance = [];
            ankle_torque_sub_stance = [];
            
            stride_time_sub_stance = [];
            
            knee_power_sub_stance = [];
            ankle_power_sub_stance = [];
            
            knee_work_sub_stance = [];
            ankle_work_sub_stance = [];

            HS_sub_stance = [];
            MHE_sub_stance = [];
            TO_sub_stance = [];
            MHF_sub_stance = [];
            
            % initialize swing data
            thigh_angle_sub_swing = [];
            knee_angle_sub_swing = [];
            ankle_angle_sub_swing = [];
            
            thigh_velocity_sub_swing = [];
            knee_velocity_sub_swing = [];
            ankle_velocity_sub_swing = [];
            
            knee_torque_sub_swing = [];
            ankle_torque_sub_swing = [];
            
            stride_time_sub_swing = [];

            HS_sub_swing = [];
            MHE_sub_swing = [];
            TO_sub_swing = [];
            MHF_sub_swing = [];
            
            continue;
        end  
        
        v_problem = [];
        for v = 1:size(stride_time_sub,1)
            dt_trial = mode(ddt(stride_time_sub(v,:)));
            thigh_angle_trial = thigh_angle_sub(v,:);
            knee_angle_trial = knee_angle_sub(v,:);
            ankle_angle_trial = ankle_angle_sub(v,:);
            
            thigh_velocity_sub(v,:) = ddt(thigh_angle_trial,dt_trial);
            knee_velocity_sub(v,:) = ddt(knee_angle_trial,dt_trial);
            ankle_velocity_sub(v,:) = ddt(ankle_angle_trial,dt_trial);
            %Event Indexes Full GC
            
            knee_work_sub(v,:) = trapz(knee_power_sub(v,:),stride_time_sub(v,:));
            ankle_work_sub(v,:) = trapz(ankle_power_sub(v,:),stride_time_sub(v,:));

            
            
            stance_indices = GRF_data(v,:) > 5e-3;
            stance_indices(find(~stance_indices(5:end),1,'first')+5:end) = 0;
            stance_indices(1:5) = 1;
            swing_indices = ~stance_indices;

%             figure(1)
%             yyaxis left
%             hold on
%             plot(GRF_data(v,:),"k-")
%             plot(stance_indices,"b-")
%             hold off
%             yyaxis right
%             plot(thigh_angle_sub(v,:),'g-')
%             hold on
%             plot(thigh_angle_sub(v,stance_indices),'r--')
%             hold off
%             pause(2)
%             close all

%           
%             if strcmp('AB23',subject) && strcmp('in5', task)
%                 keyboard
%             end

            if ~all(swing_indices == 0) 
                % get stance data
                thigh_angle_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(thigh_angle_sub(v,stance_indices))),thigh_angle_sub(v,stance_indices),sample_vec);
                knee_angle_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_angle_sub(v,stance_indices))),knee_angle_sub(v,stance_indices),sample_vec);
                ankle_angle_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_angle_sub(v,stance_indices))),ankle_angle_sub(v,stance_indices),sample_vec);
                
                thigh_velocity_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(thigh_velocity_sub(v,stance_indices))),thigh_velocity_sub(v,stance_indices),sample_vec);
                knee_velocity_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_velocity_sub(v,stance_indices))),knee_velocity_sub(v,stance_indices),sample_vec);
                ankle_velocity_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_velocity_sub(v,stance_indices))),ankle_velocity_sub(v,stance_indices),sample_vec);
                
                knee_torque_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_torque_sub(v,stance_indices))),knee_torque_sub(v,stance_indices),sample_vec);
                ankle_torque_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_torque_sub(v,stance_indices))),ankle_torque_sub(v,stance_indices),sample_vec);
                
                knee_power_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_power_sub(v,stance_indices))),knee_power_sub(v,stance_indices),sample_vec);
                ankle_power_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_power_sub(v,stance_indices))),ankle_power_sub(v,stance_indices),sample_vec);
                
                stride_time_sub_stance(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(stride_time_sub(v,stance_indices))),stride_time_sub(v,stance_indices),sample_vec);
                
                knee_work_sub_stance(v,:) = trapz(knee_power_sub_stance(v,:),stride_time_sub_stance(v,:));
                ankle_work_sub_stance(v,:) = trapz(ankle_power_sub_stance(v,:),stride_time_sub_stance(v,:));
                
                [MHE_val_stance, MHE_ind_stance] = min(thigh_angle_sub_stance(v,:));
                
                HS_sub_stance(v,:) = 1;
                MHE_sub_stance(v,:) = MHE_ind_stance;
                TO_sub_stance(v,:) = length(thigh_angle_sub_stance(v,:));

%                 MHF_sub_stance(v,:) = NaN(size(stride_time_sub,1),1);
                
                % get swing data
                thigh_angle_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(thigh_angle_sub(v,swing_indices))),thigh_angle_sub(v,swing_indices),sample_vec);
                knee_angle_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_angle_sub(v,swing_indices))),knee_angle_sub(v,swing_indices),sample_vec);
                ankle_angle_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_angle_sub(v,swing_indices))),ankle_angle_sub(v,swing_indices),sample_vec);
                
                thigh_velocity_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(thigh_velocity_sub(v,swing_indices))),thigh_velocity_sub(v,swing_indices),sample_vec);
                knee_velocity_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_velocity_sub(v,swing_indices))),knee_velocity_sub(v,swing_indices),sample_vec);
                ankle_velocity_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_velocity_sub(v,swing_indices))),ankle_velocity_sub(v,swing_indices),sample_vec);
                
                knee_torque_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(knee_torque_sub(v,swing_indices))),knee_torque_sub(v,swing_indices),sample_vec);
                ankle_torque_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(ankle_torque_sub(v,swing_indices))),ankle_torque_sub(v,swing_indices),sample_vec);
                
                stride_time_sub_swing(v,:) = interp1(linspace(min(sample_vec),max(sample_vec),length(stride_time_sub(v,swing_indices))),stride_time_sub(v,swing_indices),sample_vec);

                [MHF_val_swing, MHF_ind_swing] = max(thigh_angle_sub_swing(v,:));
                MHF_sub_swing(v,:) = MHF_ind_swing;
            else

                v_problem = [v_problem; v];
                
                continue;
            end

            
        end
    
    %Remove Problem Stride data
    if ~isempty(v_problem)
        thigh_angle_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));
        knee_angle_sub(v_problem,:) =  NaN(1,size(stride_time_sub, 2));
        ankle_angle_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        knee_velocity_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));
        ankle_velocity_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        knee_torque_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));
        ankle_torque_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        knee_power_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));
        ankle_power_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        stride_time_sub(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        GRF_data(v_problem,:) = NaN(1,size(stride_time_sub, 2));

        MHE_sub(v_problem,:) = NaN(size(stride_time_sub,1),1);
        MHF_sub(v_problem,:) = NaN(size(stride_time_sub,1),1);
        HS_sub(v_problem,:) = NaN(size(stride_time_sub,1),1);
        TO_sub(v_problem,:) = NaN(size(stride_time_sub,1),1);
    end

        
        % Full Stride
    thigh_angle_task = [thigh_angle_task; thigh_angle_sub];
    knee_angle_task = [knee_angle_task; knee_angle_sub];
    ankle_angle_task = [ankle_angle_task; ankle_angle_sub];
    
    thigh_velocity_task = [thigh_velocity_task; thigh_velocity_sub];
    knee_velocity_task = [knee_velocity_task; knee_velocity_sub];
    ankle_velocity_task = [ankle_velocity_task; ankle_velocity_sub];
    
    knee_torque_task = [knee_torque_task; knee_torque_sub];
    ankle_torque_task = [ankle_torque_task; ankle_torque_sub];
    stride_time_task = [stride_time_task; stride_time_sub];
    
    knee_power_task = [knee_power_task; knee_power_sub];
    ankle_power_task = [ankle_power_task; ankle_power_sub];
    
    knee_work_task = [knee_work_task; knee_work_sub];
    ankle_work_task = [ankle_work_task; ankle_work_sub];

    HS_task_temp = [HS_task_temp; HS_sub];
    MHE_task_temp = [MHE_task_temp; MHE_sub];
    TO_task_temp = [TO_task_temp; TO_sub];
    MHF_task_temp = [MHF_task_temp; MHF_sub];

    % Stance Stride
    thigh_angle_task_stance = [thigh_angle_task_stance; thigh_angle_sub_stance];
    knee_angle_task_stance = [knee_angle_task_stance; knee_angle_sub_stance];
    ankle_angle_task_stance = [ankle_angle_task_stance; ankle_angle_sub_stance];
    
    thigh_velocity_task_stance = [thigh_velocity_task_stance; thigh_velocity_sub_stance];
    knee_velocity_task_stance = [knee_velocity_task_stance; knee_velocity_sub_stance];
    ankle_velocity_task_stance = [ankle_velocity_task_stance; ankle_velocity_sub_stance];
    
    knee_torque_task_stance = [knee_torque_task_stance; knee_torque_sub_stance];
    ankle_torque_task_stance = [ankle_torque_task_stance; ankle_torque_sub_stance];
    
    knee_power_task_stance = [knee_power_task_stance; knee_power_sub_stance];
    ankle_power_task_stance = [ankle_power_task_stance; ankle_power_sub_stance];
    
    stride_time_task_stance = [stride_time_task_stance; stride_time_sub_stance];
    
    knee_work_task_stance = [knee_work_task_stance; knee_work_sub_stance];
    ankle_work_task_stance = [ankle_work_task_stance; ankle_work_sub_stance];

    HS_task_temp_stance = [HS_task_temp_stance; HS_sub_stance];
    MHE_task_temp_stance = [MHE_task_temp_stance; MHE_sub_stance];
    TO_task_temp_stance = [TO_task_temp_stance; TO_sub_stance];
    MHF_task_temp_stance = [MHF_task_temp_stance; MHF_sub_stance];
    
    % Swing Stride
    thigh_angle_task_swing = [thigh_angle_task_swing; thigh_angle_sub_swing];
    knee_angle_task_swing = [knee_angle_task_swing; knee_angle_sub_swing];
    ankle_angle_task_swing = [ankle_angle_task_swing; ankle_angle_sub_swing];
    
    thigh_velocity_task_swing = [thigh_velocity_task_swing; thigh_velocity_sub_swing];
    knee_velocity_task_swing = [knee_velocity_task_swing; knee_velocity_sub_swing];
    ankle_velocity_task_swing = [ankle_velocity_task_swing; ankle_velocity_sub_swing];
    
    knee_torque_task_swing = [knee_torque_task_swing; knee_torque_sub_swing];
    ankle_torque_task_swing = [ankle_torque_task_swing; ankle_torque_sub_swing];
    stride_time_task_swing = [stride_time_task_swing; stride_time_sub_swing];

    HS_task_temp_swing = [HS_task_temp_swing; HS_sub_swing];
    MHE_task_temp_swing = [MHE_task_temp_swing; MHE_sub_swing];
    TO_task_temp_swing = [TO_task_temp_swing; TO_sub_swing];
    MHF_task_temp_swing = [MHF_task_temp_swing; MHF_sub_swing];
        
    end
    vaf_task = [];
    for t = 1:size(thigh_angle_task,1)
        vaf_task(t,:) = VAF(thigh_angle_task(t,:),mean(thigh_angle_task,'omitnan'));
    end

    vaf_ind = vaf_task > 75;
    %Full GC data
        % mean of trials
    dataOut.(task).full.thigh_angle_mean = mean(thigh_angle_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.knee_angle_mean = mean(knee_angle_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_angle_mean = mean(ankle_angle_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.thigh_velocity_mean = mean(thigh_velocity_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.knee_velocity_mean = mean(knee_velocity_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_velocity_mean = mean(ankle_velocity_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_torque_mean = mean(knee_torque_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_torque_mean = mean(ankle_torque_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_power_mean = mean(knee_power_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_power_mean = mean(ankle_power_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_work_mean = mean(knee_work_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_work_mean = mean(ankle_work_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.stride_time_mean = mean(stride_time_task(vaf_ind,:),'omitnan');
        % std of trials
    dataOut.(task).full.thigh_angle_std = std(thigh_angle_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.knee_angle_std = std(knee_angle_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_angle_std = std(ankle_angle_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.thigh_velocity_std = std(thigh_velocity_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.knee_velocity_std = std(knee_velocity_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_velocity_std = std(ankle_velocity_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_torque_std = std(knee_torque_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_torque_std = std(ankle_torque_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_power_std = std(knee_power_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_power_std = std(ankle_power_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.knee_work_std = std(knee_work_task(vaf_ind,:),'omitnan');
    dataOut.(task).full.ankle_work_std = std(ankle_work_task(vaf_ind,:),'omitnan');
    
    dataOut.(task).full.stride_time_std = std(stride_time_task(vaf_ind,:),'omitnan');
        % all trials
    dataOut.(task).full.thigh_angle = (thigh_angle_task(vaf_ind,:));
    dataOut.(task).full.knee_angle = (knee_angle_task(vaf_ind,:));
    dataOut.(task).full.ankle_angle = (ankle_angle_task(vaf_ind,:));
    
    dataOut.(task).full.thigh_velocity = (thigh_velocity_task(vaf_ind,:));
    dataOut.(task).full.knee_velocity = (knee_velocity_task(vaf_ind,:));
    dataOut.(task).full.ankle_velocity = (ankle_velocity_task(vaf_ind,:));
    
    dataOut.(task).full.knee_torque = (knee_torque_task(vaf_ind,:));
    dataOut.(task).full.ankle_torque = (ankle_torque_task(vaf_ind,:));
    
    dataOut.(task).full.knee_power = (knee_power_task(vaf_ind,:));
    dataOut.(task).full.ankle_power = (ankle_power_task(vaf_ind,:));
    
    dataOut.(task).full.knee_work = (knee_work_task(vaf_ind,:));
    dataOut.(task).full.ankle_work = (ankle_work_task(vaf_ind,:));
    
    dataOut.(task).full.stride_time = (stride_time_task(vaf_ind,:));
%     dataOut.(task).full.events.HS = [(1:size(dataOut.(task).full.stride_time,1))', (HS_task_temp)];
%     dataOut.(task).full.events.MHE = [(1:size(dataOut.(task).full.stride_time,1))', (MHE_task_temp)];
%     dataOut.(task).full.events.TO = [(1:size(dataOut.(task).full.stride_time,1))', (TO_task_temp)];
%     dataOut.(task).full.events.MHF = [(1:size(dataOut.(task).full.stride_time,1))', (MHF_task_temp)];

    %Stance GC data
        % mean of trials
    dataOut.(task).stance.thigh_angle_mean = mean(thigh_angle_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.knee_angle_mean = mean(knee_angle_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_angle_mean = mean(ankle_angle_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.thigh_velocity_mean = mean(thigh_velocity_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.knee_velocity_mean = mean(knee_velocity_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_velocity_mean = mean(ankle_velocity_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_torque_mean = mean(knee_torque_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_torque_mean = mean(ankle_torque_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_power_mean = mean(knee_power_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_power_mean = mean(ankle_power_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_work_mean = mean(knee_work_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_work_mean = mean(ankle_work_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.stride_time_mean = mean(stride_time_task_stance(vaf_ind,:),'omitnan');
    
        % std of trials
    dataOut.(task).stance.thigh_angle_std = std(thigh_angle_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.knee_angle_std = std(knee_angle_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_angle_std = std(ankle_angle_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.thigh_velocity_std = std(thigh_velocity_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.knee_velocity_std = std(knee_velocity_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_velocity_std = std(ankle_velocity_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_torque_std = std(knee_torque_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_torque_std = std(ankle_torque_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_power_std = std(knee_power_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_power_std = std(ankle_power_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.knee_work_std = std(knee_work_task_stance(vaf_ind,:),'omitnan');
    dataOut.(task).stance.ankle_work_std = std(ankle_work_task_stance(vaf_ind,:),'omitnan');
    
    dataOut.(task).stance.stride_time_std = std(stride_time_task_stance(vaf_ind,:),'omitnan');
    
        % all trials
    dataOut.(task).stance.thigh_angle = (thigh_angle_task_stance(vaf_ind,:));
    dataOut.(task).stance.knee_angle = (knee_angle_task_stance(vaf_ind,:));
    dataOut.(task).stance.ankle_angle = (ankle_angle_task_stance(vaf_ind,:));
    
    dataOut.(task).stance.thigh_velocity = (thigh_velocity_task_stance(vaf_ind,:));
    dataOut.(task).stance.knee_velocity = (knee_velocity_task_stance(vaf_ind,:));
    dataOut.(task).stance.ankle_velocity = (ankle_velocity_task_stance(vaf_ind,:));
    
    dataOut.(task).stance.knee_torque = (knee_torque_task_stance(vaf_ind,:));
    dataOut.(task).stance.ankle_torque = (ankle_torque_task_stance(vaf_ind,:));
    
    dataOut.(task).stance.knee_power = (knee_power_task_stance(vaf_ind,:));
    dataOut.(task).stance.ankle_power = (ankle_power_task_stance(vaf_ind,:));
    
    dataOut.(task).stance.knee_work = (knee_work_task_stance(vaf_ind,:));
    dataOut.(task).stance.ankle_work = (ankle_work_task_stance(vaf_ind,:));
    
    dataOut.(task).stance.stride_time = (stride_time_task_stance(vaf_ind,:));
    
    %Swing GC data
        % mean of trials
    dataOut.(task).swing.thigh_angle_mean = mean(thigh_angle_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.knee_angle_mean = mean(knee_angle_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.ankle_angle_mean = mean(ankle_angle_task_swing(vaf_ind,:),'omitnan');
    
    dataOut.(task).swing.thigh_velocity_mean = mean(thigh_velocity_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.knee_velocity_mean = mean(knee_velocity_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.ankle_velocity_mean = mean(ankle_velocity_task_swing(vaf_ind,:),'omitnan');
    
%     dataOut.(task).swing.knee_torque_mean = mean(knee_torque_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_torque_mean = mean(ankle_torque_task_swing,'omitnan');
%     
%     dataOut.(task).swing.knee_power_mean = mean(knee_power_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_power_mean = mean(ankle_power_task_swing,'omitnan');
%     
%     dataOut.(task).swing.knee_work_mean = mean(knee_work_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_work_mean = mean(ankle_work_task_swing,'omitnan');
    
    dataOut.(task).swing.stride_time_mean = mean(stride_time_task_swing(vaf_ind,:),'omitnan');
    
        % std of trials
    dataOut.(task).swing.thigh_angle_std = std(thigh_angle_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.knee_angle_std = std(knee_angle_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.ankle_angle_std = std(ankle_angle_task_swing(vaf_ind,:),'omitnan');
    
    dataOut.(task).swing.thigh_velocity_std = std(thigh_velocity_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.knee_velocity_std = std(knee_velocity_task_swing(vaf_ind,:),'omitnan');
    dataOut.(task).swing.ankle_velocity_std = std(ankle_velocity_task_swing(vaf_ind,:),'omitnan');
    
%     dataOut.(task).swing.knee_torque_std = std(knee_torque_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_torque_std = std(ankle_torque_task_swing,'omitnan');
%     
%     dataOut.(task).swing.knee_power_std = std(knee_power_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_power_std = std(ankle_power_task_swing,'omitnan');
%     
%     dataOut.(task).swing.knee_work_std = std(knee_work_task_swing,'omitnan');
%     dataOut.(task).swing.ankle_work_std = std(ankle_work_task_swing,'omitnan');
    
    dataOut.(task).swing.stride_time_std = std(stride_time_task_swing(vaf_ind,:),'omitnan');
    
        % all trials
    dataOut.(task).swing.thigh_angle = (thigh_angle_task_swing(vaf_ind,:));
    dataOut.(task).swing.knee_angle = (knee_angle_task_swing(vaf_ind,:));
    dataOut.(task).swing.ankle_angle = (ankle_angle_task_swing(vaf_ind,:));
    
    dataOut.(task).swing.thigh_velocity = (thigh_velocity_task_swing(vaf_ind,:));
    dataOut.(task).swing.knee_velocity = (knee_velocity_task_swing(vaf_ind,:));
    dataOut.(task).swing.ankle_velocity = (ankle_velocity_task_swing(vaf_ind,:));
    
%     dataOut.(task).swing.knee_torque = knee_torque_task_swing;
%     dataOut.(task).swing.ankle_torque = ankle_torque_task_swing;
%     
%     dataOut.(task).swing.knee_power = knee_power_task_swing;
%     dataOut.(task).swing.ankle_power = ankle_power_task_swing;
%     
%     dataOut.(task).swing.knee_work = knee_work_task_swing;
%     dataOut.(task).swing.ankle_work = ankle_work_task_swing;
    
    dataOut.(task).swing.stride_time = (stride_time_task_swing(vaf_ind,:));
    
end
end