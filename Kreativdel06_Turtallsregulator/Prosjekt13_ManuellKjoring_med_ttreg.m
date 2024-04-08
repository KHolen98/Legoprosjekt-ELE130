% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt13_ManuellKjoring_turtallregulering
%
% Hensikten med programmet er å teste ut forskjeller i manuell kjøring
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
% - motor B
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all;
online = true; 
filename = 'P13_MeasManuellKjoring_trrg.mat';


%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes.

if online
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    myColorSensor = colorSensor(mylego);
    myGyroSensor  = gyroSensor(mylego);
    mySonicSensor = sonicSensor(mylego);

    motorA = motor(mylego, 'A');
    motorB = motor(mylego, 'B');
    motorA.resetRotation;
    motorB.resetRotation;












else
    load(filename)
end

disp('Equipment initialized.');






fig1 = figure;
screen = get(0, 'Screensize');
set(fig1, 'Position', [1, 1, 0.5*screen(3), 0.5*screen(4)]);
set(0, 'defaultTextInterpreter', 'latex');
set(0, 'defaultAxesFontSize', 14);
set(0, 'defaultTextFontSize', 16);

JoyMainSwitch = 0;
k = 1;

Avstand = [];
hvitTerskel = 200;
TVA = 0;
TVB = 0;
MAE(1) = 0;

Kp = 0.0;
Ki = 0.0;
Kd = 0.0;

integralErrorA = 0;
integralErrorB = 0;
previousErrorA = 0;
previousErrorB = 0;
previousPositionA = 0;
previousPositionB = 0;
onsketFart = zeros(1,1); % For plotting
maaltFartA = zeros(1,1); % For plotting
maaltFartB = zeros(1,1); % For plotting
Ts = zeros(1,1); % For plotting

while ~JoyMainSwitch
    if online
        tic;
        Tid(k) = toc;

        Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));
        if Lys(k) > hvitTerskel
            disp('Hvit farge detektert, avslutter programmet.');
            break;
        end
        GyroAngle(k) = double(readRotationAngle(myGyroSensor));
        GyroRate(k) = double(readRotationRate(myGyroSensor));
        Avstand(k) = double(readDistance(mySonicSensor));

        VinkelPosMotorA = double(motorA.readRotation);
        VinkelPosMotorB = double(motorB.readRotation);
        if k > 1
            actualSpeedA = (VinkelPosMotorA - previousPositionA) / Ts(k-1);
            actualSpeedB = (VinkelPosMotorB - previousPositionB) / Ts(k-1);
        else
            actualSpeedA = 0;
            actualSpeedB = 0;
            Ts(1) = 0.1; % Starter med en antatt Ts
        end
        
        [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyPot(k) = JoyAxes(4); 
        onsketFart(k) = JoyPot(k) * 1; % Skalert
        
        if k > 1
            Ts(k) = Tid(k) - Tid(k-1);
        end
        
        errorA(k) = onsketFart(k) - actualSpeedA;
        errorB(k) = onsketFart(k) - actualSpeedB;
        integralErrorA = integralErrorA + errorA * Ts(k);
        integralErrorB = integralErrorB + errorB * Ts(k);
        derivativeErrorA = (errorA - previousErrorA) / Ts(k);
        derivativeErrorB = (errorB - previousErrorB) / Ts(k);
        PID_A = Kp * errorA(k) + Ki * integralErrorA + Kd * derivativeErrorA;
        PID_B = Kp * errorB(k) + Ki * integralErrorB + Kd * derivativeErrorB;
        
        previousErrorA = errorA; 
        previousErrorB = errorB;
        previousPositionA = VinkelPosMotorA; previousPositionB = VinkelPosMotorB;
        
        motorA.Speed = PID_A;
        motorB.Speed = PID_B;
        start(motorA);
        start(motorB);

        maaltFartA(k) = actualSpeedA; % Oppdaterer for plotting
        maaltFartB(k) = actualSpeedB; % Oppdaterer for plotting
        
        % Plotting
        figure(fig1);
        subplot(3,1,1);
        plot(Tid(1:k), onsketFart(1:k), 'b');
        title('Onsket Fart');
        xlabel('Tid [s]');
        ylabel('Fart [%]');
        grid on;
        
        subplot(3,1,2);
        plot(Tid(1:k), maaltFartA(1:k), 'r');
        hold on;
        plot(Tid(1:k), maaltFartB(1:k), 'g');
        hold off;
        title('Maalt Fart for Motor A og B');
        xlabel('Tid [s]');
        ylabel('Fart [%]');
        legend('Motor A', 'Motor B');
        grid on;

        subplot(3,1,3);
        plot(Tid(1:k), errorA(1:k), 'r');
        hold on;
        plot(Tid(1:k), errorB(1:k), 'g');
        hold off;
        title('Feil i PID-regulering');
        xlabel('Tid [s]');
        ylabel('Feil [%]');
        legend('Feil A', 'Feil B');
        grid on;
        
        drawnow; % Oppdaterer plotter i sanntid

        k = k + 1; % Oppdaterer tellevariabel
    else
        pause(0.01); % Simulerer ventetid for offline modus
    end
end

if online
    stop(motorA);
    stop(motorB);
    save(filename, "JoyPot", "JoySving", "GyroRate", "Lys", "Tid", "PID_A", "PID_B");
    disp('Data lagret.');
end
