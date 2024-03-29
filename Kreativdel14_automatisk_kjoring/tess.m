%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt10.1_ManuekkKjoring
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor

% Følgende motorer brukes:
% - motor A
% - motor B

%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Rydder workspace opp først
clear; close all;
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P10_1_MeasManuellKjoring_Y.mat';

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
   
    % fargesensor
    myColorSensor = colorSensor(mylego);

   % motorer
    motorA = motor(mylego, 'A');
    motorB = motor(mylego, 'B');
else
    % Dersom online=false lastes datafil.
    load(filename);
end
disp('Equipment initialized.');

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       Initialverdier

% PID-parametre (Disse må muligens justeres basert på faktiske tester)
Kp = 1;  % Proporsjonal gain
Ki = 0.05;  % Integrativ gain
Kd = 0.05; % Derivativ gain

% Initialisering av variabler for PID-regulering
integrertFeil = 0;
forrigeFeil = 0;
maxPower = 50; % Maksimalt motorpådrag

% Definer en terskel for hvit farge
hvitTerskel = 70;


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       GET TIME AND MEASUREMENT
% Få tid og målinger fra sensorer, motorer og joystick
%
% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes.

% Hovedløkke
k = 1;
while online
    
    if k == 1
        tic;  % Start tidtaker
        Tid(1) = 0;
        Ts(1) = 0.01;  % Initialverdi for tidskritt
    else
        Tid(k) = toc;
        Ts(k) = Tid(k) - Tid(k-1);
    end

    Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));
    if Lys(k) > hvitTerskel
        break
    end
    feil = Lys(1) - Lys(k);
    integrertFeil = integrertFeil + feil * Ts(k);
    derivativFeil = (feil - forrigeFeil) / Ts(k);

    % PID-beregninger
    P = Kp * feil;
    I = Ki * integrertFeil;
    D = Kd * derivativFeil;
    PID_padrag = P + I + D;

    % Begrens motorpådraget
    PID_padrag = max(min(PID_padrag, maxPower), -maxPower);

    % Oppdater motorpådrag
    PowerA(k) = max(min(10 + PID_padrag, maxPower), -maxPower);
    PowerB(k) = max(min(10 - PID_padrag, maxPower), -maxPower);

    if online
        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);
        start(motorA);
        start(motorB);
    end

    % Oppdater for neste iterasjon
    forrigeFeil = feil;
    k = k + 1;
    pause(0.01);  % Liten pause for å ikke overbelaste EV3

    % (Plottekode kan legges her om nødvendig)
end

% Stopp motorer og lagre data ved avslutning
if online
    stop(motorA);
    stop(motorB);
    save(filename, "Lys", "Tid", "PowerA", "PowerB");
end