%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt01_Numerisk_Integrasjon
%
% Hensikten med programmet er å simulere påfylling og tapping i en
% vannbeholder
% Følgende sensorer brukes:
% - Lyssensor
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P01_MeasNumeriskIntegrasjon_med_motor_fart_okende';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke og sensorer.
if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;

else
    % Dersom online=false lastes datafil.
    load(filename)
end

disp('Equipment initialized.')
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------


% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;

%Andre parametre og variabler
if online
else
% Anta at nullflow og Ts_nominell er kjente eller beregnede verdier fra tidligere kjøringer
%For data fra fart 1, sett nullflow til 28 og k til 61
%For data fra fart 2, sett nullflow til 28.5 og k til 
nullflow = 28.5; % Eksempelverdi, juster dette basert på dine behov eller kalibreringsresultater
Ts_nominell = 0.2; % Nominell verdi for samplingstiden
k = 1;
end


% Anta at 'skyteknapp' er en variabel som kontrollerer while-løkken
while ~JoyMainSwitch
    if online
        % Tid og lysmåling for online modus
        if k == 1
            tic;
            Tid(1) = 0;
            nullflow = double(readLightIntensity(myColorSensor, 'reflected'));
            Volum(1) = 0; % Initialverdi for volum
            Ts_nominell = 0.2; % Nominell initialverdi for samplingstid
        else
            Tid(k) = toc;
        end
        Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));

        % Leser data fra styrestikke
        [~, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    end

    % Beregner flow og volum
    if k == 1
        Flow(k) = 0; % Ingen flow ved start
    else
        Flow(k) = Lys(k) - nullflow; % Anta nullflow er definert
        Ts(k) = Tid(k) - Tid(k-1);
        Volum(k) = Volum(k-1) + Flow(k) * Ts(k);
    end

    if online
    % Justerer motorhastigheten basert på tid
    if Tid(k) > 4
        motorA.Speed = .5+(0.3*(k-4)); % Setter en lav hastighet som øker etter 4 sekunder
    else
        motorA.Speed = 0; % Normal hastighet før 4 sekunder
    end
    start(motorA);
end

    % PLOT DATA
    % Aktiver fig1
    figure(fig1)

    % Plotter Flow
    subplot(2,1,1)
    plot(Tid(1:k), Flow(1:k));
    title('Flow')
    xlabel('Tid [sek]')

    % Plotter Volum
    subplot(2,1,2)
    plot(Tid(1:k), Volum(1:k));
    title('Volum')
    xlabel('Tid [sek]')

    % Tegn nå
    drawnow

    % Oppdaterer tellevariabel
    k = k + 1;

     % Avslutt løkken dersom vi er offline og har nådd slutten av datasettet
    if ~online && k > length(Tid)
        JoyMainSwitch = 1;
    end
    
end

% Stopp motor A (og eventuelle andre motorer) når programmet avsluttes
if online
    % Stopper motor A når programmet avsluttes
    stop(motorA);
end

% Etter at løkken er avsluttet, lagre de akkumulerte dataene til en fil
save(filename, 'Tid', 'Lys', 'Flow', 'Volum');

disp('Data saved to file.');
