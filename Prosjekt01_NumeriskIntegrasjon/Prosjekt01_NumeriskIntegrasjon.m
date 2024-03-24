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
y = zeros(1, length(Tid));
u = zeros(1, length(Tid));
Ts = zeros(1, length(Tid)) + Ts_nominell; % Anta konstant Ts hvis ikke annet er spesifisert

while k <= length(Tid)
    if k > 1
        Ts(k) = Tid(k) - Tid(k-1); % Beregn tidssteg hvis mulig
    end
    
    u(k) = Lys(k) - nullflow; % Beregn flow basert på lysmåling minus nullflow
    
    if k > 1
        y(k) = EulerBackward(y(k-1), Ts(k), u(k)); % Euler-integrasjon for volum
    end
    
    % Plotting
    figure(fig1);
    subplot(2, 1, 1);
    plot(Tid(1:k), u(1:k), 'LineWidth', 2);
    title('Strømningshastighet, u(k)');
    xlabel('Tid [sek]');
    
    subplot(2, 1, 2);
    plot(Tid(1:k), y(1:k), 'LineWidth', 2);
    title('Volum, y(k)');
    xlabel('Tid [sek]');
    
    drawnow;
    
    k = k + 1;
end

% Lagre de oppdaterte dataene til en fil
save('P01_LysTidVolum_01', 'Tid', 'Lys', 'u', 'y');
disp('Data saved to file.');