%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt10.1_ManuekkKjoring
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor

% Følgende motorer brukes:
% - motor A
% - motor B

%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P04_MeasManuellKjoring_Y.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.


if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    % fargesensor
    myColorSensor = colorSensor(mylego);
 
    
    % motorer


    %Kode for eventuelt annet utstyr
    motorA = motor(mylego,'A');
    motorA.resetRotation;
    motorB = motor(mylego,'B');
    motorB.resetRotation;
    

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
MAE(1) = 0

% PID-parametre
% PID-parametre
Kp = 1;  % Proporsjonal gain
Ki = 0.05;  % Integrativ gain
Kd = 0.05; % Derivativ gain

% Initialiser variabler for PID-regulering
integrertFeil = 0;
forrigeFeil = 0;

while online
     
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.

    if online
   
        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
         % Sjekker om lysintensiteten overstiger hvit-terskelen
            if Lys(k) > hvitTerskel
                disp('Hvit farge detektert, avslutter programmet.');
                break;  % Bryter ut av while-løkken
            end
    
        % PID-beregninger
        if k==1
            tic
            Tid(1) = 0;
            Ts(1) = 0.01;  % Initialverdi for tidskritt
        else
            Tid(k) = toc;
            Ts(k) = Tid(k) - Tid(k-1); % Beregn tidskritt
        end

        % Les lysintensiteten
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
    
        % Beregn avviket fra referanseverdien
        feil = (Lys(1) - Lys(k));
         % Avviket e(k)
        e(k) = Lys(1) - Lys(k);
        %Avvik filtrert
        if k == 1
            e_fil(k) = 0;
        else
            e_fil(k) = (0.3 * e(k)) + (0.7 * e_fil(k-1));
                %if e_fil(k) > 2
                %    e_fil(k) = 2
                %else
                %    if e_fil(k) < -2
                %        e_fil(k) = -2
                %    end
                %end
        end

         % PID-beregninger
        PID_padrag(k) = Kp * e_fil(k);
    
        if k == 1
            PowerA(1) = 5;
            PowerB(1) = 5;

        else
            % Oppdater pådrag for hver motor basert på PID-pådrag
            if 6 < abs(PowerA(k-1) + PID_padrag(k)) < 0
                PowerA(k) = PowerA(k-1)
            else
            PowerA(k) = PowerA(k-1) + PID_padrag(k);  % Juster etter behov
            end
            if 6 < abs(PowerB(k-1) - PID_padrag(k)) < 0
                PowerB(k) = PowerB(k-1)
            else
                PowerB(k) = PowerB(k-1) - PID_padrag(k);  % Juster etter behov
            end
            % Oppdater for PID neste iterasjon
            %integrertFeil = I;
            forrigeFeil = feil;
        end
        
      


        % Data fra styrestikke. 
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
       
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

    % Tilordne målinger til variabler

    % Spesifisering av initialverdier og beregninger
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
        Lys_sum(1) = 0;
    else
        % Beregninger av Ts og variable som avhenger av initialverdi
        Ts(k) = Tid(k) - Tid(k-1);
    end

    % Andre beregninger som ikke avhenger av initialverdi
   
    
    % Numerisk integrasjon av avviket |e(k)|
    if k > 1
        Lys_sum(k) = Lys_sum(k-1) + abs(e(k)) * Ts(k); % Eulers forovermetode
    end
    
    % MAE
    if k > 1
        MAE(k) = Lys_sum(k) / k ;
    end


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

    subplot(3,2,6)
    plot(Tid(1:k),MAE(1:k));
    title('MAE')
    xlabel('Tid [sek]')

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

    
    k=k+1;

end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%               STOP MOTORS OG LAGRE DATA

if online
    stop(motorA);
    stop(motorB);
   

    save(filename,"Lys","Tid","e","PowerA","PowerB");

end
%------------------------------------------------------------------

