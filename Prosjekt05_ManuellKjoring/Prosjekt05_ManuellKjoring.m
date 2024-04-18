%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt04_ManuekkKjoring
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
% - Gyroskop
% - Infrarødsensor
%
% Følgende motorer brukes:
% - motor A
% - motor B
% - ...
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
filename = 'P04_MeasManuellKjoring_MF.mat';
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
    % fargesensor
    myColorSensor = colorSensor(mylego);
    % gyrosensor
    myGyroSensor  = gyroSensor(mylego);
    resetRotationAngle(myGyroSensor)
    % ultralydsensor
    mySonicSensor = sonicSensor(mylego);
    
    % motorer


    %Kode for eventuelt annet utstyr
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
    %{
    myTouchSensor = touchSensor(mylego);
   ;
    ;

    % motorer
    
    motorC = motor(mylego,'C');
    motorC.resetRotation;
    motorD = motor(mylego,'D');
    motorD.resetRotation;
    %}

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
% Initialiser 'Avstand' som en tom vektor
Avstand = [];
% Definer en terskel for hvit farge
hvitTerskel = 70;

% Initialverdier for pådrag
TVA = 0;
TVB = 0;
MAE(1) = 0;


while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
   
        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
         % Sjekker om lysintensiteten overstiger hvit-terskelen
            if Lys(k) > hvitTerskel
                disp('Hvit farge detektert, avslutter programmet.');
                break;  % Bryter ut av while-løkken
            end
        GyroAngle(k) = double(readRotationAngle(myGyroSensor));
        GyroRate(k)  = double(readRotationRate(myGyroSensor));
        Avstand(k) = double(readDistance(mySonicSensor));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
        VinkelPosMotorB(k) = double(motorB.readRotation);

        %{
        LysDirekte(k) = double(readLightIntensity(myColorSensor));
        Bryter(k)  = double(readTouch(myTouchSensor));
        
        
        % motorer
        VinkelPosMotorC(k) = double(motorC.readRotation);
        VinkelPosMotorD(k) = double(motorC.readRotation);
        %}

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
        JoySving = JoyAxes(1); % Kodelinje fra ChatGPT Anta at X-aksen er den første aksen

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
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.
    % Kaller IKKE på en funksjon slik som i Python.

    % Parametre
    a=0.7;
    b = 0.5; % skalafaktor for sving

    % Tilordne målinger til variabler


    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
        Lys_sum(1) = 0
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
        Ts(k) = Tid(k) - Tid(k-1)
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
        MAE(k) = Lys_sum(k) / k 
    end

    % Beregn pådrag for fremover/tilbake-bevegelse og sving - kode kopiert
    % fra ChatGPT
    fremoverKraft = a * JoyForover(k);
    svingKraft = b * JoySving; % 'b' er en skalafaktor for sving, f.eks. 0.5

    
     % Oppdater pådrag for hver motor
    PowerA(k) = a * JoyForover(k) - b * JoySving;  % Eksempel på beregning
    PowerB(k) = a * JoyForover(k) + b * JoySving;

    % Beregn Total Variation for hver motor
    if k > 1
        TVA(k) = TVA(k-1) + abs(PowerA(k) - PowerA(k-1));
        TVB(k) = TVB(k-1) + abs(PowerB(k) - PowerB(k-1));
    end

    if online
        motorA.Speed = PowerA(k);
        motorB.Speed = PowerB(k);

        start(motorA);
        start(motorB);
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

    %subplot(2,4,3)
    %plot(Tid(1:k),VinkelPosMotorA(1:k));
    %title('Vinkelposisjon motor A')
    %xlabel('Tid [sek]')

    subplot(3,2,6)
    plot(Tid(1:k),MAE(1:k));
    title('MAE')
    xlabel('Tid [sek]')

    %subplot(2,4,7)
    %plot(Tid(1:k),VinkelPosMotorB(1:k));
    %title('Vinkelposisjon motor B')
    %xlabel('Tid [sek]')

    subplot(3,2,3)
    plot(Tid(1:k),PowerA(1:k), 'b');
    title('Power A')
    hold on
    plot(Tid(1:k),PowerB(1:k), 'r');
    title('Power B')
    xlabel('Tid [sek]')

    subplot(3,2,4)
    plot(Tid(1:k),Lys_sum(1:k));
    title('IAE - Sum lys for konkurranse')
    xlabel('Tid [sek]')

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
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
    stop(motorB);
    %stop(motorC);
    %stop(motorD);

    save(filename,"JoyForover","JoySving","GyroRate","Lys","Tid","e","PowerA","PowerB","GyroAngle","VinkelPosMotorA","VinkelPosMotorB");

end
%------------------------------------------------------------------





