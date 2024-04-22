%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt14_Automatisk_Kjoring_PID
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
% - motor B
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all;
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P14_MeasKjoring_PID.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%

if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    % sensorer
    % fargesensor
    myColorSensor = colorSensor(mylego);
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
else
    % Dersom online=false lastes datafil.
    load(filename);
end
disp('Equipment initialized.');
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

fig1 = figure;
screen = get(0, 'Screensize');
set(fig1, 'Position', [1, 1, 0.5*screen(3), 0.5*screen(4)]);
set(0, 'defaultTextInterpreter', 'latex');
set(0, 'defaultAxesFontSize', 14);
set(0, 'defaultTextFontSize', 16);

% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k = 1;
% Definer en terskel for hvit farge
hvitTerskel = 50; 

% Initialverdier for pådrag
TVA = 0;
TVB = 0;
MAE(1) = 0;

% Initialisering av PID-regulering variabler og tilhørende variabler
u0 = 0;
Kp = .2; 
Ki = .0; 
Kd = .0; 
I_sum = 0;
e(1) = 0; 
P(1) = 0;
I(1) = 0;
D(1) = 0;
maxPower = 10; % Maksimalt motorpådrag
I_max = 100; 
I_min = -100;
Lys_sum = 0; % Tillegg for MAE beregning
PowerA = 0; % Initialiser PowerA for TV beregning
PowerB = 0; % Initialiser PowerB for TV beregning
PID_padrag = 0; % Initialiserer PID_padrag
u_A = 0; % Startverdi

% Legger til disse initialiseringene før while-løkken
desiredSpeed = 0; % Ønsket hastighet basert på JoyPot
lastErrorA = 0; % Forrige feil for motor A
lastErrorB = 0; % Forrige feil for motor B
integralErrorA = 0; % Integrert feil for motor A
integralErrorB = 0; % Integrert feil for motor B
PID_A = 0;
PID_B = 0;


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       GET TIME AND MEASUREMENT
% Få tid og målinger fra sensorer, motorer og joystick

while ~JoyMainSwitch
    if online
        if k == 1
            tic;  
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        VinkelPosMotorA(k) = readRotation(motorA); 
        VinkelPosMotorB(k) = readRotation(motorB);
        
        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
         % Sjekker om lysintensiteten overstiger hvit-terskelen
            if Lys(k) > hvitTerskel
                disp('Hvit farge detektert, avslutter programmet.');
                break;  % Bryter ut av while-løkken
            end
        
        
        % Data fra styrestikke. 
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyPot(k) = 0.2 * JoyAxes(4); % Dette er signaler fra spaken bak på joysticken 

        if k > 1
            y = Lys(k);          
            r = Lys(1);   
            e(k) = r - y;      
            P(k) = Kp * e(k); 
            I(k) = 0; %min(max(I(k-1) + Ki * e(k) * Ts, I_min), I_max); % Integrator med begrensning
            D(k) = 0; %Kd * (e(k) - e(k-1)) / Ts; % Enkel derivasjon
            u_A = u0 + P(k) + I(k) + D(k);
           
           deltaTime = Tid(k) - Tid(k-1); % Beregn tidsdifferanse
            % Anta at JoyPot endrer ønsket hastighet lineært
            desiredSpeed = JoyPot(k) * maxPower; % Juster dette etter behov
                % Beregn faktisk hastighet som endring i vinkelposisjon delt på tid
            actualSpeedA = (VinkelPosMotorA(k) - VinkelPosMotorA(k-1)) / deltaTime;
            actualSpeedB = (VinkelPosMotorB(k) - VinkelPosMotorB(k-1)) / deltaTime;

                % Beregn feilen mellom ønsket og faktisk hastighet
            errorA = desiredSpeed - actualSpeedA;
            errorB = desiredSpeed - actualSpeedB;


             % Akkumuler feilen for integraldelen
            integralErrorA = integralErrorA + errorA * deltaTime;
            integralErrorB = integralErrorB + errorB * deltaTime;

            % Beregn endring i feil for derivatdelen
            derivativeErrorA = (errorA - lastErrorA) / deltaTime;
            derivativeErrorB = (errorB - lastErrorB) / deltaTime;

            % Beregn PID-pådrag for hver motor
            PID_A = Kp * errorA + Ki * integralErrorA + Kd * derivativeErrorA;
            PID_B = Kp * errorB + Ki * integralErrorB + Kd * derivativeErrorB;
        end
          
        
    else
        % online=false
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)
  
    end


   
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.


    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
        Lys_sum(1) = 0;
        fartA(k) = 0;
        fartB(k) = 0;
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
      
        Ts(k) = Tid(k) - Tid(k-1);
        fartA(k) = (VinkelPosMotorA(k) - VinkelPosMotorA(k-1)) / Ts(k);
        fartB(k) = (VinkelPosMotorB(k) - VinkelPosMotorB(k-1)) / Ts(k);
    end

    % Andre beregninger som ikke avhenger av initialverdi
    % Avviket e(k)
    e(k) = Lys(1) - Lys(k);
    
    % Numerisk integrasjon av avviket |e(k)|
    if k > 1
        Lys_sum(k) = Lys_sum(k-1) + abs(e(k)) * Ts(k); % Eulers forovermetode
    end
    
    % MAE
    if k > 1
        MAE(k) = Lys_sum(k) / k ;
    end

    
     % Oppdater pådrag for hver motor
    %PID_padrag = max(min(u_A, maxPower), -maxPower); % Definerer PID_padrag her
            PowerA(k) = JoyPot(k) + PID_A; %max(min(10 + PID_padrag, maxPower), -maxPower);
            PowerB(k) = JoyPot(k) + PID_B; %max(min(10 - PID_padrag, maxPower), -maxPower);
            motorA.Speed = PowerA(k);
            motorB.Speed = PowerB(k);
            start(motorA);
            start(motorB);

    % Beregn Total Variation for hver motor
    if k > 1
        TVA(k) = TVA(k-1) + abs(PowerA(k) - PowerA(k-1));
        TVB(k) = TVB(k-1) + abs(PowerB(k) - PowerB(k-1));
    end




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
    figure(fig1)

    subplot(3,2,1)
    
    plot(Tid(1:k),Lys(1:k));
    hold on
    
    plot(Tid(1:k),Lys(1)*ones(1,k),'k--')
    title('Lys reflektert')
    xlabel('Tid [sek]')

    subplot(3,2,2)
    plot(Tid(1:k),e(1:k));
    title('Avvik e(k)')
    xlabel('Tid [sek]')

    subplot(3,2,4)
    plot(Tid(1:k),fartA(1:k));
    title('Vinkelposisjon motor A')
    xlabel('Tid [sek]')
%{
    subplot(3,2,6)
    plot(Tid(1:k),MAE(1:k));
    title('MAE')
    xlabel('Tid [sek]')
%}
    subplot(3,2,6)
    plot(Tid(1:k),fartB(1:k));
    title('Vinkelposisjon motor B')
    xlabel('Tid [sek]')

    subplot(3,2,3)
    plot(Tid(1:k),PowerA(1:k), 'b');
    title('Power A')
    hold on
    plot(Tid(1:k),PowerB(1:k), 'r');
    title('Power B')
    xlabel('Tid [sek]')
%{
    subplot(3,2,4)
    plot(Tid(1:k),Lys_sum(1:k));
    title('IAE - Sum lys for konkurranse')
    xlabel('Tid [sek]')
%}
    subplot(3,2,5)
    plot(Tid(1:k), TVA(1:k), 'b'); % Plott TVA i blått
    hold on;
    plot(Tid(1:k), TVB(1:k), 'r'); % Plott TVB i rødt
    title('Total Variation for Motor A og B');
    xlabel('Tid [sek]');
    ylabel('Total Variation');
    legend('TVA', 'TVB');

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

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS OG LAGRE DATA

if online
    stop(motorA);
    stop(motorB);
    
    save(filename,"Lys","Tid","e","PowerA","PowerB","VinkelPosMotorA","VinkelPosMotorB");
    disp('Data lagret');
end
%------------------------------------------------------------------
