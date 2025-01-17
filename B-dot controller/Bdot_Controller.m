%% setup
%magnetorquer_calculator;
%Stabilizing_Torque_calculator;
clc
%MagnetorquerPlant = Transferfunction;
dyear = decyear('20-may-2024','dd-mmm-yyyy');


%% testing space

%% orbital information
clc
n = 16470;
n2 = 0.0052;
n3 = 0.0023;
t = 0:1/n+1E4:1;
phi = 98*pi/180; %inclination
psi = sin(t); %longitude
theta = acos(sqrt(1- sin(psi).^2  *sin(phi)^2));  %lattitude
DataMagFieldBe = [psi;theta;zeros(size(t))];
Data = [psi;theta];
plot(t,Data)

%% Bdot data


DataBdotSatRot = out.DataBDotSatRot;
DataBdotMoment = out.DataBdotMoment;
minmaxBdotSatRot = out.MinMaxBdotSatRot;
minmaxBdotMoment = out.MinMaxBdotMoment;

%Rotation min/max lines
DataMaxRot = zeros(2.647E4,1);
DataMinRot = DataMaxRot;
DataMaxRot = DataMaxRot + 0.3*pi/180;
DataMinRot = DataMinRot - 0.3*pi/180;

%Moment min/max lines
DataMaxMom = zeros(2.647E4,1);
DataMinMom = DataMaxMom;
DataMaxMom = DataMaxMom + 105.9E-3;
DataMinMom = DataMinMom - 105.9E-3;

%% Data analysis
%Change the data from multi-axial to total value, just take norm

DataBdotSatTotalRotVeloc = mean(DataBdotSatRot.Data');
TotalAngData = [DataBdotSatRot.Time,DataBdotSatTotalRotVeloc'];

DataBdotMomentTotal = mean(DataBdotMoment.Data');
TotalMomData = [DataBdotMoment.Time,DataBdotMomentTotal'];

%% printing (axial values)
f1 = figure(1);
plot(DataBdotSatRot), hold on, grid on, fontsize(15,"points")
xline(n,'--','Color','black'), hold on
plot(DataMinRot,'--','Color','black'), hold on
plot(DataMaxRot,'--','Color','black'), title("Satellite rotations"), xlabel("time [s]","FontSize",16), ylabel("angular velocity [rad/s]"), legend("X","Y","Z","req:B2", 'fontsize', 15), hold off

f2 =figure(2);
plot(DataBdotMoment), hold on, grid on, fontsize(16,"points")
plot(DataMaxMom,'--','Color',[0,0,0]), hold on
plot(DataMinMom,'--','Color',[0,0,0]), title("Magnetic moment"), xlabel("time [s]"), ylabel("mag. moment [mA m^2]"), legend("X","Y","Z","Max","Min", 'fontsize', 15), hold off

f3 =figure(3);
plot(DataBdotSatRot), hold on, grid on, fontsize(15,"points") 
title("Satellite rotations")
yline([n3,-n3],'--'), xlabel("time [s]","FontSize",16), ylabel("angular velocity [rad/s]"), legend("X","Y","Z","Req:B1","Req:B1", 'fontsize', 15), hold off

%% printing (total values)
f4 = figure(4);
plot(TotalAngData(:,1),TotalAngData(:,2)), hold on, grid on, fontsize(15,"points")
xline(n,'--','Color','black'), hold on
plot(DataMinRot,'--','Color','black'), hold on
plot(DataMaxRot,'--','Color','black'), title("Satellite rotations"), xlabel("time [s]","FontSize",16), ylabel("angular velocity [rad/s]"), legend("X","Y","Z","req:B2", 'fontsize', 15), hold off

f5 =figure(5);
plot(TotalMomData(:,1),TotalMomData(:,2)), hold on, grid on, fontsize(16,"points")
plot(DataMaxMom,'--','Color',[0,0,0]), hold on
plot(DataMinMom,'--','Color',[0,0,0]), title("Magnetic moment"), xlabel("time [s]"), ylabel("mag. moment [mA m^2]"), legend("Control Moment","Max","Min", 'fontsize', 15), hold off

f6 =figure(6);
plot(TotalAngData(:,1),TotalAngData(:,2)), hold on, grid on, fontsize(15,"points")
title("Satellite rotations")
yline([n3,-n3],'--'), xlabel("time [s]","FontSize",16), ylabel("angular velocity [rad/s]"), legend("X","Y","Z","Req:B1","Req:B1", 'fontsize', 15), hold off

%% test
