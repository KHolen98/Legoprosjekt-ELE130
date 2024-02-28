%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt00_TestOppkopling
%
% Hensikten med programmet er å teste at opplegget fungerer på PC/Mac
% Følgende sensorer brukes:
% - Lyssensor
%
% Følgende motorer brukes:
% - motor A
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
filename = 'P00_MeasTest_1.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                 INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%

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
%----------------------------------------------------------------------

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;

while ~JoyMainSwitch
    % oppdater tellevariabel
    k=k+1;

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % sensorer
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);

        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
    else
        % online=false
        % Naar k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter paa styrestikke trykkes inn.
        if k==length(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------






    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjoer matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet

    % Parametre
    b = 1;

    % Tilordne maalinger til variable

    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        r(1) = Lys(1);
        Ts(1) = 0.1;  % nominell verdi
    else
        r(k) = r(1);
        Ts(k) = Tid(k)-Tid(k-1);  % nominell verdi

        % Beregninger av Ts og variable som avhenger av initialverdi
    end

    % beregning av pådrag fra styrestikken
    u_A(k) = JoyForover(k);

    if online
        % Setter pådragsdata mot EV3
        % (slett de motorene du ikke bruker)
        motorA.Speed = u_A(k);
        start(motorA)
    end
    %--------------------------------------------------------------



    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne plasseres enten i while-lokka eller rett etterpaa.
    % Dette kan enkelt gjoeres ved flytte de 5 nederste linjene
    % foer 'end'-kommandoen nedenfor opp foer denne seksjonen.
    % Alternativt saa kan du lage en egen .m-fil for plottingen som du
    % kaller paa.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    figure(fig1)
    subplot(2,2,1)
    plot(Tid(1:k),VinkelPosMotorA(1:k));
    title('M{\aa}ling av vinkelposisjon motor A, $y_1(t)$')
    ylabel('$[^{\circ}]$')

    subplot(2,2,2)
    plot(Tid(1:k),u_A(1:k));
    title('P{\aa}drag motor A, $u_A(t)$')
    ylabel('$[-]$')

    subplot(2,2,3)
    plot(Tid(1:k),r(1:k),'r');
    hold on
    plot(Tid(1:k),Lys(1:k),'b');
    hold off
    xlabel('Tid [sek]')
    ylabel('$[-]$')
    title('Referanse $r(t)$ og m{\aa}ling av lys, $y_2$(t)')

    subplot(2,2,4)
    plot(Tid(1:k),Ts(1:k));
    xlabel('Tid [sek]')
    ylabel('[s]')
    title('Tidsskritt $T_s$')

    % tegn naa (viktig kommando)
    drawnow
    %--------------------------------------------------------------
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                STOP MOTORS

if online
    % For ryddig og oversiktlig kode, er det lurt aa slette
    % de sensorene og motoren som ikke brukes.
    stop(motorA);
end
%------------------------------------------------------------------





