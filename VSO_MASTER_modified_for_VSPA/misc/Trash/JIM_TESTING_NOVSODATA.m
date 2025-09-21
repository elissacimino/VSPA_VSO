clear
%close all

%Dual cam hysteresis testing
% load('DATA/JIM/3_26_23/BreakBearings.mat')
% cam = BreakBearings;
% cam_folder = 'DATA/JIM/3_26_23';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'X1'};


%Dual cam hysteresis testing
load('DATA/JIM/12_21_22/dualdebugC2.mat')
cam = dualdebugC2;
cam_folder = 'DATA/JIM/12_21_22';
plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
slider = {'xswitch' 'xswitch2' 'xsinglecamc2'};

for i=1:length(slider)
    %JIM
    timeJIM = cam.(slider{i}).timeJIM;
    angleJIM = rad2deg(cam.(slider{i}).angleJIM);
    torqueJIM = cam.(slider{i}).torque;
    figure(2)
    hold on
    plot(angleJIM,torqueJIM)
end

% slider = {'xswitch2' 'xsinglecamc2' 'xsinglecam2c2' 'xsinglecam3c2'};
% for i=1:length(slider)
%     %JIM
%     timeJIM = cam.(slider{i}).timeJIM;
%     angleJIM = rad2deg(cam.(slider{i}).angleJIM);
%     torqueJIM = cam.(slider{i}).torque;
%     figure(2)
%     hold on
%     plot(angleJIM,torqueJIM)
% end

