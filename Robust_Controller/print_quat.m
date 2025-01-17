clc
clear T q
T = out.q_data.Time;
q = out.q_data.Data;
q_ref = q(3:4,:)';
q_bounded = q(7:8,:)';
q_real = q(11:12,:)';

figure
hold on
plot(repmat(T,1,2),q_ref,'--');
plot(repmat(T,1,2),q_bounded,'k');
plot(repmat(T,1,2),q_real);

legend("q_{ref,3}","q_{ref,4}","q_{bounded,3}","q_{bounded,4}","q_{real,3}","q_{real,4}")

%%
T = out.ang_err.Time;
ang = out.ang_err.Data;

plot(T,ang','b')
hold on
plot(T,1*ones(size(T)),'k--')
plot([145;145],[0,80],'k--')
plot(T,15*ones(size(T)),'r--')
hold off
grid on
xlabel("Time[s]")
ylabel("Angle error [º]")
legend("ang_{err}","ts = 145 s","err = 1º","Mp = 15º");