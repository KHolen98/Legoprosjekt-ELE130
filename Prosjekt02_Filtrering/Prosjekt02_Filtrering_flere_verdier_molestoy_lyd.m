% Prosjekt02_FiltreringLyd.m
% playTone finput: playTone(myEV3, frequency, volume, duration);

clear; close all;

% Konfigurasjonsparametere
online = false; % Skift til 'false' for å kjøre i offlinemodus basert på lagrede data
alfa = 0.5; % Eksempelverdi for alpha i IIR-filteret
filename = 'FiltreringData.mat'; % Navnet på filen hvor data lagres

% Initialiser LEGO EV3 hvis online
if online
    mylego = legoev3('USB');
    myColorSensor = colorSensor(mylego);
    myTouchSensor = touchSensor(mylego);
else
    if exist(filename, 'file')
        load(filename, 'Tid', 'x', 'y_IIR'); % Last inn lagrede data
        % Plot lagrede data og avslutt
        figure;
        plot(Tid, x, 'b-', Tid, y_IIR, 'r-');
        xlabel('Tid [s]'); ylabel('Signalstyrke');
        title('Lagrede Signaldata'); legend('Ufiltrert signal', 'Filtrert signal');
        return; % Avslutter koden etter plotting av lagrede data
    else
        disp('Datafilen finnes ikke. Kjør i online modus for å generere data.');
        return;
    end
end

disp('Utstyret er initialisert.');

% Forbered til plotting
fig1 = figure;
set(fig1, 'Position', [100, 100, 600, 400]);
title('Signalbehandling med og uten filtrering');
xlabel('Tid [s]'); ylabel('Signalstyrke');
hold on;

% Initialiser variabler
k = 1; maxIter = 100; % Begrens antall iterasjoner
Tid = zeros(1, maxIter); x = zeros(1, maxIter); y_IIR = zeros(1, maxIter);

while k <= maxIter
    if k == 1
        tic; % Start tidtakning
    end
    Tid(k) = toc; % Oppdater tid
    
    % Les lysintensitet, legg til støy og konstant verdi
    rawLys = readLightIntensity(myColorSensor, 'reflected');
    x(k) = rawLys + randn + 100; % Juster for frekvensområde
    
    % Sjekk om bryteren er trykket
    if read(myTouchSensor) == 1
        y_IIR(k) = IIR_filter(y_IIR(max(k-1, 1)), x(k), alfa);
        playTone(mylego, y_IIR(k)*10, 10, 50); % Spill filtrert tone
    else
        y_IIR(k) = x(k); % Kopier ufiltrert verdi
        playTone(mylego, x(k)*10, 10, 50); % Spill ufiltrert tone
    end
    
    k = k + 1; % Inkrementer indeks
    pause(0.1); % Kort pause mellom iterasjoner
end

% Avslutt lydsignal
playTone(mylego, 0, 0, 0); % Spiller en "stille" tone for å stoppe lyden

% Lagrer eksperimentdata til en fil
save(filename, 'Tid', 'x', 'y_IIR');

% Plotting
plot(Tid, x, 'b-', 'DisplayName', 'Ufiltrert signal');
plot(Tid, y_IIR, 'r-', 'DisplayName', 'Filtrert signal');
legend show;
hold off;

% Definer IIR_filter-funksjonen
function y = IIR_filter(oldY, newX, alpha)
    y = alpha * newX + (1 - alpha) * oldY;
end

