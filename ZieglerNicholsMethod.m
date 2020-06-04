close all
clear all
clc

%% Transfer Function Definition
%This is just an example
D = 0.5;
E = 48;
R = 10;
C = 100e-6;
L = 100e-6;

Vc = E/(1-D);
IL = E/(R*(1-D)^2);

A = [0 , -(1-D)/L ; (1-D)/C , -1/(R*C)];
B = [Vc/L ; -IL/C];
C = [0 , 1];
D = 0;

s = tf('s');
TF = tf(ss(A,B,C,D));

%% Ku Ultimate Gain (WORK IN PROGRESS)
%Still need to make sure that the Ku used is the correct one (as just
%finding Ku this way might not be the only option)
syms K
CE = cell2mat(TF.Denominator) + K*cell2mat(TF.Numerator);%Characteristic Equation

nonzero = find(cell2mat(TF.Numerator)~=0);
Kvalues = zeros(1,length(CE));

for i = nonzero
        Kvalues(i) = solve(CE(i),K);
end

Ku = Kvalues(Kvalues> 0 & min(Kvalues));%The selection of this Ku value still needs to be checked

%% Frecuency and Period
System = feedback(Ku*TF,1);
Poles = abs(pole(System));
Frecuency = Poles(1);
Pu = 2*pi/Frecuency;

%% For a P Controller
Kp = 0.5*Ku;
P = Kp;
System = feedback(P*TF,1);

%% For a P Controller
Kp = 0.5*Ku;
P = Kp;
System = feedback(P*TF,1);

step(48*System,'g')
hold on

%% For a PI Controller
Kp = 0.45*Ku;
Ti = Pu/1.2;
Ki = Kp/Ti;
PI = (Kp + Ki/s);
System = feedback(PI*TF,1);

step(48*System,'r')

%% For a PID Controller
Kp = 0.6*Ku;
Ti = Pu/2;
Ki = Kp/Ti;
Td = Pu/8;
Kd = Kp*Td;
PID = (Kp + s*Kd + Ki/s);
System = feedback(PID*TF,1);

step(48*System,'b')
