% Prosjekt03_Numerisk_derivasjon
%
% Hensikten med programmet er å demonstrere numerisk derivasjon med LEGO EV3
%
% Følgende sensorer brukes:
% - Lyssensor
% - TouchSensor
%
% Følgende  motorer brukes: 
%  - motor A
%
%--------------------------------------------------------------------------

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME 
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomfoeres online mot EV3 eller mot lagrede data?
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P03_Numerisk_derivasjon_motor2.mat';
%--------------------------------------------------------------------------



% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                 INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.

if online
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);

    
    myColorSensor = colorSensor(mylego);
    myTouchSensor = touchSensor(mylego);
    
    % motorer
    motorA = motor(mylego,'A');
    motorA.resetRotation;
   

else
    % Hente lagrede data for offline modus
    load(filename);
end

disp('Equipment initialized.');


%--------------------------------------------------------------------------



%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1 = figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1, 1, 0.5*screen(3), 0.5*screen(4)]);
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14);
set(0,'defaultTextFontSize',16);


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       GET TIME AND MEASUREMENT
% Faa tid og maalinger fra sensorer, motorer og joystick
alfa = 0.5; % IIR-filter parameter
JoyMainSwitch = 0;
k = 1;

while ~JoyMainSwitch && (online || k <= length(Tid))
    if online
        
        % Logikk for innsamling av data i online modus
        if k == 1
            tic;
            Tid(1) = 0;
            Ts(1) = 0.01;
        else
            Tid(k) = toc;
            Ts(k) = Tid(k) - Tid(k-1);
        end

        rawLys = double(readLightIntensity(myColorSensor, 'reflected'));
        Avstand(k) = rawLys * 1; 
        Bryter(k) = readTouch(myTouchSensor);
    end


    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    
if k == 1
    u_f(k) = Avstand(k);
else
    u_f(k) = IIR_filter(u_f(k-1), Avstand(k), alfa);
end

if Bryter(k) == 0
    v(k) = 0;
    v_f(k) = 0;
else
    v(k) = BakoverDerivasjon([Avstand(k-1), Avstand(k)], Ts(k));
    v_f(k) = BakoverDerivasjon([u_f(k-1), u_f(k)], Ts(k));
end

if online
    [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
    JoyMainSwitch = JoyButtons(1);
    motorA.Speed = 20; %setter hastighet 10 på første forsøk og 20 på andre
    %motorA.Speed = 10 + (Tid(k) * 3); %hastgihet øker med 2 per sekund
    start(motorA); % Starter motoren med hastighet 
end


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                  PLOT DATA
% Denne plasseres enten i while-lokka eller rett etterpaa. 
% Dette kan enkelt gjoeres ved aa skrive 'end' rett over her, 
% og samtidig kommentere bort 'end' nedenfor. 
%
% Husk at syntaksen plot(Tid(1:k),data(1:k))
% for gir samme opplevelse i online=0 og online=1 siden
% hele datasettet (1:end) eksisterer i den lagrede .mat fila
    
figure(fig1);
subplot(4, 1, 1);
plot(Tid, Avstand, 'b-', Tid, u_f, 'r-');
title('Avstand og Filtrert Avstand');
xlabel('Tid [s]'); ylabel('Avstand');
xlim([0, 10]); % Setter y-aksens grenser

subplot(4, 1, 2);
plot(Tid, Bryter);
title('Bryter Status');
xlabel('Tid [s]'); ylabel('Av/ på');
xlim([0, 10]); % Setter y-aksens grenser

subplot(4, 1, 3);
plot(Tid, v, 'g-');
title('Fart');
xlabel('Tid [s]'); ylabel('v [m/s]');
xlim([0, 10]); % Setter y-aksens grenser

subplot(4, 1, 4);
plot(Tid, v_f, 'm-');
title('Filtrert Fart');
xlabel('Tid [s]'); ylabel('v_f [m/s]');
xlim([0, 10]); % Setter y-aksens grenser

drawnow;


k = k + 1;
pause(0.01);
end


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%           STOP MOTORS

if online
    stop(motorA);           
end

% Lagring av data i online-modus
if online

save(filename, 'Tid', 'Avstand', 'Bryter', 'u_f', 'v', 'v_f', 'Ts');
disp('Data saved to file.');

end