clear all
clc
%% Physical aspects 
%Satellite sizes [1, 1.5, 2]
n           = 2;    

%original AAUSAT1 Width.Height =80.5, 97.5 
maxWidth    = 75E-3                     ;   %m       TBD, check satellite specs     Assumed to be 8x8 but bound to be changed
maxHeight   = n*75E-3                   ;   %m       TBD, check satellite specs
maxcrossW   = 2E-3                      ;   %m       TBD, check satellite specs
maxcrossH   = 5E-3                      ;   %m       TBD, check satellite specs
AreaCoil    = maxWidth*maxHeight        ;   %m^2     TBD, check satellite specs
CrossArea   = maxcrossH*maxcrossW       ;   %m^2     TBD, check satellite specs
circumf     = (maxWidth+maxHeight)*2    ;   %m       Circumference
Kelvin      =   0                       ;   %Kelvin     Translate from C->K
TempMin     = -100+Kelvin               ;   %Kelvin     Minimum temp
TempNorm    = 20+Kelvin                 ;   %Kelvin     Normal temp
TempMax     = 100+Kelvin                ;   %Kelvin     Max temp
mu0         = pi*4E-6                   ;   %H/m      Permeability in vacuum
Windings    = 275                       ;   %         windings

%Mcoil       = n*20E-3 - n*(n-1)/4*20E-3 ;   %Kgram    Mass of coil (insulated) -1/4 is for 2U, because structural difference

%Wire aspects-[copper , alum] 
diamWireCop         = 0.1E-3                ;   %mm     Wire thickness with insulation
diamWireAlu         = 0.1E-3               ;   %mm     Wire thickness with insulation
AwireCrossActualCop = pi*(diamWireCop/2)^2  ;   %mm^2   Cross-Area of wire: copper non insulated
AwireCrossActualAlu = pi*(diamWireAlu/2)^2  ;   %mm^2   Cross-Area of wire: copper non insulated
AwireCrossMin = [AwireCrossActualCop, AwireCrossActualAlu];

diamInsulCop    = 0.027E-3               ;   %mm     insulation
diamInsulAlu    = 0.018E-3               ;   %mm     insulation
ACrossInsulCop  = (pi*((diamWireCop+diamInsulCop)/2)^2)-AwireCrossMin(1);
ACrossInsulAlu  = (pi*((diamWireAlu+diamInsulAlu)/2)^2)-AwireCrossMin(2);
rhoInsul        = 1.35E3                    ;   %Kg/m^3     Material density insulation https://myelectrical.com/notes/entryid/178/cable-insulation-properties
rho             = [8.93E3 , 2.70E3 ]        ;   %Kg/m^3     Material density wire
resistivityRef  = [1.68E-8, 2.65E-8]        ;   %Ohm*m      Resistivity
tempCoeff       = [4.04E-3, 3.90E-3]        ;   %Percentile Temperature coefficient
CopAWG36Res     = 1426E-3                     ;   %Ohm/m      Reference Resistances       https://www.kbe-elektrotechnik.com/en/service/awg-table/

%% Electric design parameters
MinPowerLossCurrGenerator   = 3.20E-3       ;   %W
NormPowerLossCurrGenerator  = 2.19E-3       ;   %W   
MaxPowerLossCurrGenerator   = 1.93E-3       ;   %W
MinPowerUsedByCoil          = 214.7E-3      ;   %W
NormPowerUsedByCoil         = 122.98E-3     ;   %W
MaxPowerUsedByCoil          = 93.08E-3      ;   %W
MinPowerSupplyVolt          = 4.9           ;   %V
VoltDropInCurrGenerator     = 0.11E-3       ;   %V
VoltSupplyCoil              = 4.8           ;   %V +-    
MinVoltOverMeasResistor     = 2.1771E-3     ;   %V +-
NormVoltOverMeasResistor    = 2.8053E-3     ;   %V +-
MaxVoltOverMeasResistor     = 4.963E-3      ;   %V +-
MeasResistor                = 0.09          ;   %Ohm

%% Earth parameters
MagneticFieldEarth          = 54*1E3 *1E-9  ;   %uT     Magnetic field strength

%% Physical equations

%Material resistivity
%minSigma  = [resistivityRef(1)*(1 + tempCoeff(1)*TempMin) , resistivityRef(2)*(1 + tempCoeff(2)*TempMin)];
%normSigma = [resistivityRef(1)*(1 + tempCoeff(1)*TempNorm), resistivityRef(2)*(1 + tempCoeff(2)*TempNorm)];
%maxSigma  = [resistivityRef(1)*(1 + tempCoeff(1)*TempMax) , resistivityRef(2)*(1 + tempCoeff(2)*TempMax)];


%Coil Windings
ActualWindingsCop = Windings; %Mcoil/(circumf*AwireCrossMin(1)*rho(1));
ActualWindingsAlu = Windings; %Mcoil/(circumf*AwireCrossMin(2)*rho(2));

ActualMassCop = n*(Windings*circumf*(AwireCrossMin(1)*rho(1)+ACrossInsulCop*rhoInsul))*1E-3 - n*(n-1)/4*(Windings*circumf*(AwireCrossMin(1)*rho(1)+ACrossInsulAlu*rhoInsul))*1E-3;
ActualMassAlu = n*(Windings*circumf*AwireCrossMin(2)*rho(2))*1E-3 - n*(n-1)/4*(Windings*circumf*AwireCrossMin(2)*rho(2))*1E-3;

TotalWireLengthCop = circumf*ActualWindingsCop; %m
TotalWireLengthAlu = circumf*ActualWindingsAlu; %m

%% Coil self-inductance

RrefCop = CopAWG36Res*TotalWireLengthCop;
RrefAlu = 0;
%Resistances
minResCop = RrefCop*(1 + tempCoeff(1)*TempMin)      ;
normResCop = RrefCop*(1 + tempCoeff(1)*TempNorm)    ;
maxResCop = RrefCop*(1 + tempCoeff(1)*TempMax)      ;
minResAlu = RrefAlu*(1 + tempCoeff(2)*TempMin)      ;
normResAlu = RrefAlu*(1 + tempCoeff(2)*TempNorm)    ;
maxResAlu = RrefAlu*(1 + tempCoeff(2)*TempMax)      ;
% minResCop   = (ActualWindingsCop*circumf*minSigma(1))/AwireCrossMin(1);
% normResCop  = (ActualWindingsCop*circumf*normSigma(1))/AwireCrossMin(1);
% maxResCop   = (ActualWindingsCop*circumf*maxSigma(1))/AwireCrossMin(1);
% minResAlu   = (ActualWindingsAlu*circumf*minSigma(2))/AwireCrossMin(2);
% normResAlu  = (ActualWindingsAlu*circumf*normSigma(2))/AwireCrossMin(2);
% maxResAlu   = (ActualWindingsAlu*circumf*maxSigma(2))/AwireCrossMin(2);
ResCop      = [minResCop, normResCop, maxResCop];
ResAlu      = [minResAlu, normResAlu, maxResAlu];


%Current based on power and voltage
minCurrentCoilCop   = VoltSupplyCoil/ResCop(3);
normCurrentCoilCop  = VoltSupplyCoil/ResCop(2);
maxCurrentCoilCop   = VoltSupplyCoil/ResCop(1);
minCurrentCoilAlu   = VoltSupplyCoil/ResAlu(3);
normCurrentCoilAlu  = VoltSupplyCoil/ResAlu(2);
maxCurrentCoilAlu   = VoltSupplyCoil/ResAlu(1);
CurrentCop = [minCurrentCoilCop, normCurrentCoilCop, maxCurrentCoilCop];
CurrentAlu = [minCurrentCoilAlu, normCurrentCoilAlu, maxCurrentCoilAlu];

%Calculated power used
minPowerUsedCop     = VoltSupplyCoil*CurrentCop(1);
normPowerUsedCop    = VoltSupplyCoil*CurrentCop(2);
maxPowerUsedCop     = VoltSupplyCoil*CurrentCop(3);
minPowerUsedAlu     = VoltSupplyCoil*CurrentAlu(1);
normPowerUsedAlu    = VoltSupplyCoil*CurrentAlu(2);
maxPowerUsedAlu     = VoltSupplyCoil*CurrentAlu(3);
PowerUsedCop        = [minPowerUsedCop, normPowerUsedCop, maxPowerUsedCop];
PowerUsedAlu        = [minPowerUsedAlu, normPowerUsedAlu, maxPowerUsedAlu];

%Sidelengt of coil, approximation
d = sqrt(maxWidth*maxHeight);

%Magnetic flux
MagneticFieldStrengthCop = mu0*(2*sqrt(2)*ActualWindingsCop*CurrentCop(2))/(pi*d);
mMagneticFieldStrengthCop = (mu0/(4*pi))*(CurrentCop(2)/maxWidth)*(sqrt(maxHeight^2 +maxWidth^2)/maxHeight*maxWidth);

MagneticFieldStrengthAlu = mu0*(2*sqrt(2)*ActualWindingsAlu*CurrentAlu(2))/(pi*d);

%Magnetic flux over surface of magnetorquer
PhiCop = MagneticFieldStrengthCop*AreaCoil;
PhiAlu = MagneticFieldStrengthAlu*AreaCoil;

%Self inductance
SelfInductanceCop   = ActualWindingsCop*PhiCop/CurrentCop(2);
SelfInductanceAlu   = ActualWindingsAlu*PhiAlu/CurrentAlu(2);
%SelfInductanceCop  = (2*sqrt(2))/(pi)*mu0*(ActualWindingsCop^2)*d 
%SelfInductanceAlu  = (2*sqrt(2))/(pi)*mu0*(ActualWindingsAlu^2)*d

%% Moment & Torque
minMomentCop    = ActualWindingsCop*CurrentCop(1)*AreaCoil;
normMomentCop   = ActualWindingsCop*CurrentCop(2)*AreaCoil; 
maxMomentCop    = ActualWindingsCop*CurrentCop(3)*AreaCoil;
minmomentAlu    = ActualWindingsAlu*CurrentAlu(1)*AreaCoil;
normMomentAlu   = ActualWindingsAlu*CurrentAlu(2)*AreaCoil;
maxMomentAlu    = ActualWindingsAlu*CurrentAlu(3)*AreaCoil;
CopMoment       = [minMomentCop, normMomentCop, maxMomentCop];
AluMoment       = [minmomentAlu, normMomentAlu, maxMomentAlu];

TorqueCop = MagneticFieldEarth * (CopMoment);
TorqueAlu = MagneticFieldEarth * (AluMoment);

%% Temperature characteristic
syms t
simulationTemp = linspace(TempMin, TempMax,100);%TempMin:1:TempMax; %Simulation span

SigmaCopHandle = resistivityRef(1)*(1 + tempCoeff(1)*t);
SigmaAluHandle = resistivityRef(2)*(1 + tempCoeff(2)*t);

ResCopHandle = (ActualWindingsCop*circumf*SigmaCopHandle)/AwireCrossMin(1);
ResAluHandle = (ActualWindingsAlu*circumf*SigmaAluHandle)/AwireCrossMin(2);

CurrentCopHandle = VoltSupplyCoil*ResCopHandle;
CurrentAluHandle = VoltSupplyCoil*ResAluHandle;

CopMagnetorquerMomentByTempHolder = ActualWindingsCop*CurrentCopHandle*AreaCoil;
AluMagnetorquerMomentByTempHolder = ActualWindingsAlu*CurrentAluHandle*AreaCoil;

CopMagnetorquerMomentByTemp = matlabFunction(CopMagnetorquerMomentByTempHolder);
AluMagnetorquerMomentByTemp = matlabFunction(AluMagnetorquerMomentByTempHolder);


%% Printing Output
fprintf("Physical design:\n");
fprintf("Size: %.0fx%.0f mm\n", maxHeight*1E3,maxWidth*1E3);
fprintf("Area: %.2f mm^2\n", AreaCoil*1E6);
fprintf("circumference: %.0f mm\n", circumf*1E3);
fprintf("wire diameter (with insulation): %.1f + %.3f mm\n", diamWireCop*1E3, diamInsulCop*1E3);
fprintf("Windings: %.2f turns\n", ActualWindingsCop);
fprintf("total wire length: %.2f meters\n", TotalWireLengthCop);
fprintf("Total mass: %.2f grams\n", ActualMassCop*1E6);
fprintf("-\n");
fprintf("Operable temperatures:\n");
fprintf("Min: %.0f\n", TempMin);
fprintf("Norm:  %.0f\n", TempNorm);
fprintf("Max:  %.0f\n", TempMax);
fprintf("-\n")
fprintf("Supply voltage: %.2f volt \n", VoltSupplyCoil)
fprintf("Operating currents:\n");
fprintf("Min:  %.2f milli amp\n", minCurrentCoilCop*1E3);
fprintf("Norm: %.2f milli amp\n", normCurrentCoilCop*1E3);
fprintf("Max:  %.2f milli amp\n", maxCurrentCoilCop*1E3);
fprintf("-\n");
fprintf("Power consumption:\n");
fprintf("Min:  %.2f milliWatt\n", PowerUsedCop(1)*1E3);
fprintf("Norm: %.2f milliWatt\n", PowerUsedCop(2)*1E3);
fprintf("Max:  %.2f milliWatt\n", PowerUsedCop(3)*1E3);
fprintf("-\n");
fprintf('Producible Moments:\n');
fprintf("Min:  %.2f mA*m^2\n", CopMoment(1)*1E3);
fprintf("Norm: %.2f mA*m^2\n", CopMoment(2)*1E3);
fprintf("Max:  %.2f mA*m^2\n", CopMoment(3)*1E3);
fprintf("-\n");
fprintf("Producible torques:\n");
fprintf("Min torque:  %.2f nN*m\n", TorqueCop(1)*1E9);
fprintf("Norm torque: %.2f nN*m\n", TorqueCop(2)*1E9);
fprintf("Max torque:  %.2f nN*m\n", TorqueCop(3)*1E9);
