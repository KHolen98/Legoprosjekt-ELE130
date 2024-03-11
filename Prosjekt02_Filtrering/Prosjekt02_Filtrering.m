%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt02_Filtrering
%
% Hensikten med programmet er å ....
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
filename = 'P02_MeasFiltrering';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% I Matlab trenger du generelt ikke spesifisere porten de er tilkoplet.
% Unntaket fra dette er dersom bruke 2 like sensorer, hvor du må
% initialisere 2 sensorer med portnummer som argument.
% Eksempel:
% mySonicSensor_1 = sonicSensor(mylego,3);
% mySonicSensor_2 = sonicSensor(mylego,4);

% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes. 

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

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


% setter skyteknapp til 0, og initialiser variabler
JoyMainSwitch=0;
k=1;
Tid = [];
Lys = [];
y_FIR = [];
y_IIR = [];

% Angi parametere for filtrering
M = 10; % Antall målinger i FIR-filter
alfa = 0.5; % Parameter i IIR-filter

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.

     if online
        if k == 1
            tic;
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        [~, JoyButtons] = read(joystick);
        JoyMainSwitch = JoyButtons(1);
    else
        if k == numel(Tid)
            JoyMainSwitch = 1;
        end
        pause(0.01); % Simuler EV3-Matlab kommunikasjon i online=false
    end

    % Implementer logikk for y_FIR og y_IIR basert på Lys(k)

    if k == 1
        % Initialiser første verdi basert på dine funksjoner
        y_FIR(k) = Lys(k); % Eksempel, erstatt med faktisk logikk
        y_IIR(k) = Lys(k); % Eksempel, erstatt med faktisk logikk
    else
        % Beregn filtrerte verdier
        y_FIR(k) = FIR_filter(Lys, M, k); % Anta at FIR_filter er implementert
        y_IIR(k) = IIR_filter(Lys, alfa, k); % Anta at IIR_filter er implementert
    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.
    % Kaller IKKE på en funksjon slik som i Python.

    % Implementer logikk for y_FIR og y_IIR basert på Lys(k)

    if k == 1
        % Initialiser første verdi basert på dine funksjoner
        y_FIR(k) = Lys(k); % Eksempel, erstatt med faktisk logikk
        y_IIR(k) = Lys(k); % Eksempel, erstatt med faktisk logikk
    else
        % Beregn filtrerte verdier
        y_FIR(k) = FIR_filter(Lys, M, k); % Anta at FIR_filter er implementert
        y_IIR(k) = IIR_filter(Lys, alfa, k); % Anta at IIR_filter er implementert
    end


    %--------------------------------------------------------------




    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne seksjonen plasseres enten i while-lokka eller rett etterpå.
    % Dette kan enkelt gjøres ved flytte de 5 nederste linjene
    % før "end"-kommandoen nedenfor opp før denne seksjonen.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % aktiver fig1
     figure(fig1);

    % Plot av lysintensitet og filtrerte signaler
    subplot(2,1,1);
    plot(Tid(1:k), Lys(1:k), 'b', Tid(1:k), y_FIR(1:k), 'r', Tid(1:k), y_IIR(1:k), 'g');
    title('Lysintensitet og filtrerte signaler');
    xlabel('Tid [s]');
    ylabel('Intensitet');
    legend('Original', 'FIR', 'IIR');


    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------

    % For å flytte PLOT DATA etter while-lokken, er det enklest å
    % flytte de neste 5 linjene (til og med "end") over PLOT DATA.
    % For å indentere etterpå, trykk Ctrl-A/Cmd-A og deretter Crtl-I/Cmd-I
    %
    % Oppdaterer tellevariabel
    k=k+1;
end

%------------------------------------------------------------------





