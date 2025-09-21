
load('DATA/JIM/testing/ChrisData/Feb27_2023/all_trials.mat')
angle = dorsiflexoboot.cam003_originalspring.angleJIM;
torque = dorsiflexoboot.cam003_originalspring.torque;
plot(angle,torque)