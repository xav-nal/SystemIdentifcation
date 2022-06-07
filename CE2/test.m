clc 
clear 
close all



%% 

tau = seconds(.1);
sys = @(u, t)(u.*(1-exp(-t./tau)));

time = seconds(0:.01:1);

u1 = ones(size(time));
y1 = sys(u1, time);

u2 = 1.2 * u1;
y2 = sys(u2, time);

plot(time, u1, '--r', time, y1, '-r'), hold on
plot(time, u2, '--b', time, y2, '-b')
