%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt14_Kjøring_med 
%
% Hensikten med programmet er å gjøre automatisk kjøring med en PID-
% regulator
% Følgende sensorer brukes:
% - Lyssensor

% Følgende motorer brukes:
% - motor A
% - motor B

%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Rydder workspace opp først
clear; close all;
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P13_MeasKjoring_PID.mat';

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
   
    % fargesensor
    myColorSensor = colorSensor(mylego);

   % motorer
    motorA = motor(mylego, 'A');
    motorB = motor(mylego, 'B');
else
    % Dersom online=false lastes datafil.
    load(filename);
end
disp('Equipment initialized.');

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------




%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       GET TIME AND MEASUREMENT
% Få tid og målinger fra sensorer, motorer og joystick
%
% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes.

% Hovedløkke
k = 1;
hvitTerskel = 70; % Definer en terskel for hvit farge
while online
    
    if k == 1
        tic;  % Start tidtaker
        Tid(1) = 0;
        Ts(1) = 0.01;  % Initialverdi for tidskritt
    else
        Tid(k) = toc;
        Ts(k) = Tid(k) - Tid(k-1);
    end
        
    % motorer
    VinkelPosMotorA(k) = double(motorA.readRotation); %Leser rotasjoene fra motoren
    VinkelPosMotorB(k) = double(motorB.readRotation);   

    Lys(k) = double(readLightIntensity(myColorSensor, 'reflected'));
    y(k) = Lys(k);
    if Lys(k) > hvitTerskel
        break
    end


   

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

% PID-parametre (Disse justeres basert på faktiske tester)
u0 = 0;
Kp = 1;  % Kan justeres for proporsjonalforsterkningen. for forsøket med stor Kp er KP satt til 2. For å vise at motoren gir 0 ved null avvik, 0.1
Ki = 0.05;  % Kan justeres for integral del. 
Kd = 0.05; % Kan justeres for derivat del
I_sum = 0; % Integralsum
e(1) = 0; % Forrige feil

% Verdier til filter
alfa = 1; %settes til en i forsøkene for P og I. Er også satt til 1 i forsøk D a og b. I forsøk 1 i c) er alfa 0.6 og i forsøk 2 0.3. For prøve og feile settes alfa til 0.6
OldFilteredValue = 0;

%andre verdier
maxPower = 50; % Maksimalt motorpådrag
Ts = 0.1; % Samplingstid


if k==1
     % Initialverdier
    Ts(1) = 0.01;      % nominell verdi
    e(1) = 0; % Avvik


    % Initialverdi PID-regulatorens deler
    P(1) = 0;       % P-del
    I(1) = 0;       % I-del
    D(1) = 0;       % D-del
    
else 
    % Beregninger av tidsskritt
    Ts(k) = Tid(k)-Tid(k-1);
    


    % Beregning av reguleringsavvik
    y(k) = Lys(k);          % lysmåling settes til y(k)
    r(k) = Lys(1);   % referanse
    e(k) = r(k) - y(k);      % reguleringssavvik 
    

    % Lag kode for bidragene P(k), I(k) og D(k)
    P(k) = Kp * e(k); %direkte proporsjonal med feilen e(k)
    I(k) = I(k-1) + Ki * e(k) * Ts(k); % Akkumulerer feilen over tid
    e_f(k) = e(k);
    %e_f(k) = IIR_filter(OldFilteredValue, e(k), alfa); % Filtrering kan legges til her for D-delen
    D(k) = Kd * BakoverDerivasjon([e(k-1), e(k)], Ts(k));
    % Integratorbegrensing


    I_max(k) = 100;
    I_min(k) = -100;
    
    if I(k) > I_max(k)
        I(k) = I_max(k);
    end
    
    if I(k) < I_min(k)
       I(k) = I_min(k);
    end
    
    u_A(k) = u0 + P(k) + I(k) + D(k);
    pause(0.01);  % Liten pause for å ikke overbelaste EV3


    % Begrens motorpådraget
    PID_padrag = max(min(u_A(k), maxPower), -maxPower);
    
    % Oppdater motorpådrag
    PowerA(k) = max(min(10 + PID_padrag, maxPower), -maxPower);
    PowerB(k) = max(min(10 - PID_padrag, maxPower), -maxPower);
    
    motorA.Speed = PowerA(k);
    motorB.Speed = PowerB(k);
    start(motorA);
    start(motorB);

end
    




% Initialisering av variabler for PID-regulering

maxPower = 50; % Maksimalt motorpådrag




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

%{
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



% Stopp motorer og lagre data ved avslutning

stop(motorA);
stop(motorB);
save(filename, "Lys", "Tid", "PowerA", "PowerB");
