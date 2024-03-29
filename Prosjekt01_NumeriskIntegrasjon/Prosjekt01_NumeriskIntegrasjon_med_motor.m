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
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P01_MeasNumeriskIntegrasjon_med_motor_fart_2';
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
startK = 1;
else
% Anta at nullflow og Ts_nominell er kjente eller beregnede verdier fra tidligere kjøringer
%For data fra fart 1, sett nullflow til 28 og k til 61
%For data fra fart 2, sett nullflow til 28.55 og k til 72
%For data for økende, sett nullflow til 29.7 og k til 64
nullflow = 28.55; % Eksempelverdi, juster dette basert på dine behov eller kalibreringsresultater
Ts_nominell = 0.2; % Nominell verdi for samplingstiden
startK = 72; % Endre dette tallet til ønsket startverdi for k
startvolum = 0;
k = startK;
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
           
            Tid(startK) = toc;
        end
        Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));

        % Leser data fra styrestikke
        [~, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    end

    % Beregner flow og volum
    if k == startK
        Flow(k) = 0; % Ingen flow ved start
        Volum(k) = startvolum;
    else
        Flow(k) = Lys(k-1) - nullflow; % Anta nullflow er definert
        Ts(k) = Tid(k) - Tid(k-1);
        Volum(k) = Volum(k-1) + Flow(k) * Ts(k);
    end

    if online
    % Justerer motorhastigheten basert på tid
    if Tid(k) > 4
        motorA.Speed = 2; % Setter en lav hastighet etter 4 sekunder
        %Kode for økende fart
        % motorA.Speed = .5+(0.3*(k-4)); % Setter en lav hastighet som øker etter 4 sekunder
       
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
    plot(Tid(startK:k)-Tid(startK), Flow(startK:k));
    title('Flow')
     %xlim 0 til 20 på fart 1 og 2, 0 til 10 på økende
    xlim([0 20]);
    xlabel('Tid [sek]')
    ylabel('Flow [liter per sek]')

    % Plotter Volum
    subplot(2,1,2)
    plot(Tid(startK:k)-Tid(startK), Volum(startK:k));
    title('Volum')
    %xlim 0 til 20 på fart 1 og 2, 0 til 10 på økende
    xlim([0 20]);
    xlabel('Tid [sek]')
    ylabel('Volum [liter]')
    

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
