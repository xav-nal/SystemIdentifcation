%% paternoster 
close all
clear
clc
addpath("data")

global sect_counter subsect_counter
sect_counter = 0;
subsect_counter = 0;

%% 0. load data 

load("data\gyro400.mat")
N       = length(u);            % [samples]
Ts      = 20e-3;                % [s]
fs      = 1/Ts;                 % [Hz]
time    = seconds([0:N-1]/fs)'; % [s]