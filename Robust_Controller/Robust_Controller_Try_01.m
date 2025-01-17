clear all
close all
clc
addpath("functions\");



% Variables
Ip = diag([0.0088,0.0088,0.0044]);

w0= [0,0,0]';
q0 = [0,0,0]';

q_dot_0 = 1/2*skew3(w0)*q0;
w_dot_0 = inv(Ip)*(-skew3(w0)*Ip*w0);

A = [inv(Ip)*(skew3(Ip*w0)-skew3(w0)*Ip),    zeros(3,3);
                          1/2*(skew3(q0)+eye(3)),1/2*skew3(w0)];
B = [ -inv(Ip);
     zeros(3,3)];
C = eye(6,6);
D = zeros(6,3);

sys = ss(A,B,C,D);


%% Is the system controllable?
[U,d,V] = svd(ctrb(sys));
diag(d)

%Yes!

%% Try to control it

Q = diag([0.001,0.001,0.001,0.05,0.05,0.05]);
R = diag([1e8,1e8,1e8]);

K = lqr(sys,Q,R);



Nr = inv([A,B;[zeros(3),eye(3)],zeros(3)])*[zeros(6,3);eye(3)];
Nx = Nr(1:6,:);
Nu = Nr(7:9,:);
N = Nu+K*Nx;


sys_fl = ss(A-B*K,B*N,C,D);

step(sys_fl) % It appears to work!

%% Integral controller
% Lets seee booiii
A_int = [A,zeros(6,3);
        zeros(3),eye(3),zeros(3)];
B_int = [B;zeros(3,3)];


%Q = diag([0.05,0.05,0.05,0.001,0.001,0.001,1e-3,1e-3,1e-3]);
Q  = diag([[repmat(0.05,1,3)],[repmat(2000,1,3)],[repmat(50,1,3)]])
R = diag([1e11,1e11,1e11]);
K_i_all = lqr(ss(A_int,B_int,eye(9),zeros(9,3)),Q,R);

Ki= K_i_all(:,(end-2):end);
Kp =K_i_all(:,1:(end-3));
N = Nu+Kp*Nx

K_trying = Kp;
Ki_trying = Ki;


sys_int_tt = ss([A-B*Kp, -B*Ki;[zeros(3),eye(3),zeros(3)]],[B*N;-eye(3)],eye(9),zeros(9,3));

N_ki = (eye(3)-[zeros(3),eye(3),zeros(3)]*sys_int_tt);
%step(K_i_all*sys_int_tt*.5);

f2 = figure(2);
clf(f2);
bodemag([1,0,0]*N_ki*[1;0;0]);
hold on
bodemag(w_s)
ylim([-20,20]);
xlim([1e-3,1]);











