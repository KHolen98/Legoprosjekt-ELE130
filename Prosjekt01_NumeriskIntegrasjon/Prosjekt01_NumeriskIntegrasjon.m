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
filename = 'P01_MeasNumeriskIntegrasjon.mat';
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
else
    % Dersom online=false lastes datafil.
    load('P01_MeasNumeriskIntegrasjon_pumpe.mat')
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

% Anta at 'skyteknapp' er en variabel som kontrollerer while-løkken
while ~JoyMainSwitch
     
 
    % GET TIME AND MEASUREMENT
    % Registrerer måletidspunkt Tid(k)
    if k == 1
        tic
        Tid(1) = 0;
        nullflow = double(readLightIntensity(myColorSensor,'reflected'));
        Volum(1) = 0; % Initialverdi for Volum
        Ts_nominell = 0.2; % Nominell initialverdi for Ts
    else
        Tid(k) = toc;
    end

    % Registrerer lysmåling Lys(k)
    Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
    
    % Data fra styrestikke.
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
    JoyMainSwitch = JoyButtons(1);

    % CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Beregner Flow(k) og Volum(k)
    Flow(k) = Lys(k) - nullflow;
    if k > 1
        Ts(k) = Tid(k) - Tid(k-1);
    else
        Ts(k) = Ts_nominell;
    end
    if k > 1
        Volum(k) = Volum(k-1) + Flow(k) * Ts(k); % Eulers forovermetode
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
end

% Etter at løkken er avsluttet, lagre de akkumulerte dataene til en fil
save(filename, 'Tid', 'Lys', 'Flow', 'Volum');

disp('Data saved to file.');
