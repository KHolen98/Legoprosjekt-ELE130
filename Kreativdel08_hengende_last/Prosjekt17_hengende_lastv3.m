%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt_Hengende_last
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Ultralydsensor
%
% Følgende motorer brukes:
% - motor A
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all;
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;

% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P14_MeasKjoring_PID.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
if online
    mylego = legoev3('usb');
    motorA = motor(mylego, 'A');
    motorA.resetRotation; % Sørger for at rotasjonstelleren er nullstilt ved start
    
    % sensorer
    % ultralydsensor
    ultrasonicSensor = sonicSensor(mylego);
    
    % Definerer trommelens diameter
    trommelDiameter = 0.055; % Diameter i meter
    trommelOmkrets = pi * trommelDiameter; % Beregner omkretsen
    
    % Legger inn startposisjonen manuelt
    faktiskStartPosisjon = input('Oppgi faktisk startposisjon i meter: ');
    
    % Legger inn ønsket sluttposisjon (målt i meter fra startposisjonen)
    onsketSluttPosisjon = input('Oppgi ønsket sluttposisjon i meter: ');

% Figur for plotting
figure;
hold on;
xlabel('Tid (s)');
ylabel('Posisjon (m)');
title('Posisjon av last over tid');
legend('Beregnet posisjon', 'Målt posisjon', 'Location', 'best');
grid on;

disp('Systemet er klart. Starter løftet...');

% Initialiserer diverse variabler og parametre
maksFart = 30; % Justert hastighetsgrense
P_gain = 30; % Forsterkningsfaktor for P-regulator
I_gain = 0.5; % Konstant for I-regulering
D_gain = 15; % Justert forsterkningsfaktor for D-regulator
integrator = 0; % Integrator state initialization
integratorLimit = 50; % for å forhindre windup
forrigeFeil = 0; % Lagrer forrige feil for D-regulatoren
startTid = tic; % Starter tidtaker for plotting

% Beregner målet posisjon i grader, gitt ønsket posisjon i meter
sluttPosisjonGrader = ((onsketSluttPosisjon - faktiskStartPosisjon) / trommelOmkrets) * 360;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       GET TIME AND MEASUREMENT
% Få tid og målinger fra sensorer og motorer

while true
    % Les nåværende rotasjon
    Rotasjon = motorA.readRotation;
    
    % Beregn nåværende posisjon basert på rotasjon
    Posisjon = (Rotasjon / 360) * trommelOmkrets + faktiskStartPosisjon;
    
    % Les målt avstand fra ultralydsensoren
    maaltAvstand = readDistance(ultrasonicSensor); % Fjerner 'meters'
    
    % Tid for plotting
    Tid = toc(startTid);
    
    % Beregn feilen mellom nåværende og målposisjon
    feil = onsketSluttPosisjon - Posisjon;
    
    
    % Akkumulerer feil for I-komponenten
    integrator = integrator + feil;
    % Begrenser integratoren for å forhindre windup
    integrator = max(min(integrator, integratorLimit), -integratorLimit);

    % Setter motorhastigheten basert på justering
    motorA.Speed = justeringFart;
    start(motorA);

     % PID-regulering for hastighetsjustering
    justeringFart = P_gain * feil + I_gain * integrator - D_gain * (feil - forrigeFeil);
    justeringFart = max(min(justeringFart, maksFart), -maksFart);
    
    
    % Sjekker om vi er i den ønsket posisjon
    if abs(feil) < 0.01 || abs(Rotasjon - sluttPosisjonGrader) < 5 % Legger til en sjekk på rotasjon
        disp('Nådd ønsket posisjon.');
        break;
    end
    
    % Oppdaterer tidligere feil
    forrigeFeil = feil;
    
    % Legger inn en tidsbegrensning. Grei å ha siden ikke vi har joystickknapp til å
    % avslutte koden
    if Tid > 10
        disp('Timeout, stopper løft.');
        break;
    end

        % Plotter den nåværende beregnede posisjonen og den målte posisjonen
    plot(Tid, Posisjon, 'b-', Tid, maaltAvstand, 'r-');
    drawnow;
end

% Stopper motoren etter operasjonen
stop(motorA, 1); % '1' for bremsing
disp('Operasjon fullført.');
