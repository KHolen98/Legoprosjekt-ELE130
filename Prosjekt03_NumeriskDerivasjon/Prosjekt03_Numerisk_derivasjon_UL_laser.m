% Prosjekt03_Numerisk_derivasjon
%
% Hensikten med programmet er å demonstrere numerisk derivasjon med LEGO EV3
%
% Følgende sensorer brukes:
% - Lyssensor
% - TouchSensor

clear; close all;

% Konfigurasjon for online eller offline kjøring
online = true; % Endre til true for å kjøre med tilkoblet hardware
filename = 'P03_Numerisk_derivasjonUL.mat';

if online
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    mySonicSensor = sonicSensor(mylego);
    myTouchSensor = touchSensor(mylego);
    % Initialisering av variabler for online modus
    Tid = [];
    Avstand = [];
    Bryter = [];
    u_f = [];
    v = [];
    v_f = [];
    Ts = [];
else
    % Hente lagrede data for offline modus
    load(filename);
end

disp('Equipment initialized.');

% Grafikkinnstillinger
fig1 = figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1, 1, 0.5*screen(3), 0.5*screen(4)]);
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14);
set(0,'defaultTextFontSize',16);

alfa = 0.1; % IIR-filter parameter
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
        raalyd = double(readDistance(mySonicSensor));
        Avstand(k) = raalyd * 10; 
        Bryter(k) = readTouch(myTouchSensor);
    end
    
    % Fellestrekk for online og offline modus
    if k == 1
        u_f(k) = Avstand(k);
    else
        u_f(k) = IIR_filter(u_f(k-1), Avstand(k), alfa);
    end
    
    if Bryter(k) == 0
        v(k) = 0;
        v_f(k) = 0;
    elseif k > 1
        v(k) = BakoverDerivasjon([Avstand(k-1), Avstand(k)], Ts(k));
        v_f(k) = BakoverDerivasjon([u_f(k-1), u_f(k)], Ts(k));
    end

    if online
        [JoyAxes, JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
    end

    % Plotting
    figure(fig1);
    subplot(4, 1, 1);
    plot(Tid, Avstand, 'b-', Tid, u_f, 'r-');
    title('Avstand og Filtrert Avstand');
    xlabel('Tid [s]'); ylabel('Avstand');

    subplot(4, 1, 2);
    plot(Tid, Bryter);
    title('Bryter Status');
    xlabel('Tid [s]'); ylabel('Trykket / Ikke Trykket');

    subplot(4, 1, 3);
    plot(Tid, v, 'g-');
    title('Fart');
    xlabel('Tid [s]'); ylabel('v [m/s]');

    subplot(4, 1, 4);
    plot(Tid, v_f, 'm-');
    title('Filtrert Fart');
    xlabel('Tid [s]'); ylabel('v_f [m/s]');

    drawnow;

    
    k = k + 1;
    pause(0.01);
end

% Lagring av data i online-modus
if online
    save(filename, 'Tid', 'Avstand', 'Bryter', 'u_f', 'v', 'v_f', 'Ts');
    disp('Data saved to file.');
end