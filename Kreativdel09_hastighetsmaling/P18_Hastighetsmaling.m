%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt18_Hastighetsmaling
%
% Hensikten med programmet er å teste ut forskjeller i manuell kjøring
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
% - motor B
%
%--------------------------------------------------------------------------
% Anta online modus for datainnsamling og plotting

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all;

% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;

% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'FiltreringData.mat';

% Initialisering av variabler for datainnsamling
avstand = [];
motorPosisjon = [];
Lys = []; % Reflektert lysintensitet
tid = [];
k = 1; % Initialiserer telleren for datainnsamling
JoyMainSwitch = 0; % Initial tilstand for hovedbryter

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser sensorer.
if online
    % LEGO EV3 og styrestikke
    myev3 = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
    JoyMainSwitch = JoyButtons(1);
    
    % Sensorer
    myUltrasonicSensor = sonicSensor(myev3, 4);
    myColorSensor = colorSensor(myev3, 3);
    
    % Motorer
    MotorA = motor(myev3, 'A');
    MotorB = motor(myev3, 'B');
else
    % Her kan du legge til logikk for å laste inn og bruke lagrede data
    % for offline simulering
    disp('Offline-modus er ikke fullt implementert.');
end

disp('Equipment initialized.')    

%----------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1 = figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------



startSpeed = 30;
MotorA.Speed = startSpeed;
MotorB.Speed = startSpeed;
start(MotorA);
start(MotorB);

tic;

while ~JoyMainSwitch 
    % Datainnsamling og plotting
    avstand(k) = double(readDistance(myUltrasonicSensor));
    motorPosisjon(k) = readRotation(MotorA); %nok å lese av en motor
    Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));
    tid(k) = toc;
    
    % Oppdater plot i sanntid
    if k > 1
        % Ultralydsensor Data
        subplot(3,1,1)
        plot(tid(1:k), avstand(1:k), 'b');
        title('Ultralydsensor Data');
        xlabel('Tid (s)');
        ylabel('Avstand (cm)');
        
        % Motorposisjon Data
        subplot(3,1,2)
        plot(tid(1:k), motorPosisjon(1:k), 'r');
        title('Motorposisjon Data');
        xlabel('Tid (s)');
        ylabel('Posisjon (grader)');
        
        % Lyssensor Data
        subplot(3,1,3);
        plot(tid(1:k), Lys(1:k), 'g');
        title('Lyssensor Data');
        xlabel('Tid (s)');
        ylabel('Reflektert Lys Intensitet (%)');
        
        drawnow; % Oppdater figurene
    end
    
    k = k + 1; % Inkrementer indeksen for neste runde av datainnsamling
    pause(0.05); % Kort pause for å ikke overbelaste EV3 eller datamaskinen
end

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS OG LAGRE DATA

if online
    % Stopper motorene
    stop(MotorA);
    stop(MotorB);

    % Lagrer data til fil
    save(filename, 'avstand', 'motorPosisjon', 'Lys', 'tid');
    disp('Data lagret');
end
%------------------------------------------------------------------