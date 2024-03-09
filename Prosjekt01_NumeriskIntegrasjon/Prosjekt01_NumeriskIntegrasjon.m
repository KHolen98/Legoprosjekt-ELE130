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
filename = 'P01_MeasNumeriskIntegrasjon_numint';
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
    load('P01_MeasNumeriskIntegrasjon_numint')
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

% Anta at nullflow og Ts_nominell er kjente eller beregnede verdier fra tidligere kjøringer
nullflow = Lys(1); % Eksempelverdi, juster dette basert på dine behov eller kalibreringsresultater
Ts_nominell = 0.2; % Nominell verdi for samplingstiden
% Initialisering av variabler
k = 1;
Volum = zeros(1, length(Tid));
Flow = zeros(1, length(Tid));
Ts = zeros(1, length(Tid)) + Ts_nominell; % Anta konstant Ts hvis ikke annet er spesifisert

while k <= length(Tid)
    if k > 1
        Ts(k) = Tid(k) - Tid(k-1); % Beregn tidssteg hvis mulig
    end
    
    Flow(k) = Lys(k) - nullflow; % Beregn flow basert på lysmåling minus nullflow
    
    if k > 1
        Volum(k) = Volum(k-1) + Flow(k) * Ts(k); % Euler-integrasjon for volum
    end
    
    % Plotting
    figure(fig1);
    subplot(2, 1, 1);
    plot(Tid(1:k), Flow(1:k), 'LineWidth', 2);
    title('Flow');
    xlabel('Tid [sek]');
    
    subplot(2, 1, 2);
    plot(Tid(1:k), Volum(1:k), 'LineWidth', 2);
    title('Volum');
    xlabel('Tid [sek]');
    
    drawnow;
    
    k = k + 1;
end

% Lagre de oppdaterte dataene til en fil
save(filename, 'Tid', 'Lys', 'Flow', 'Volum');
disp('Data saved to file.');