% Oppsett og initialisering
clear; close all;
mylego = legoev3('usb');
motorA = motor(mylego, 'A');
motorA.resetRotation; % Sørger for at rotasjonstelleren er nullstilt ved start

% Definerer trommelens diameter
drumDiameter = 0.055; % Diameter i meter
drumCircumference = pi * drumDiameter; % Beregner omkretsen

% Brukeren legger inn startposisjonen manuelt
actualStartPosition = input('Oppgi faktisk startposisjon i meter: ');

% Angi ønsket sluttposisjon (målt i meter fra startposisjonen)
desiredEndPosition = input('Oppgi ønsket sluttposisjon i meter: ');

% Initialiser figur for plotting
figure;
hold on;
xlabel('Tid (s)');
ylabel('Posisjon (m)');
title('Posisjon av last over tid');

disp('Systemet er klart. Starter løftet...');

% Initialiserer regulatorverdier og løkkekontrollvariabler
speedLimit = 30; % Justert hastighetsgrense
P_gain = 30; % Forsterkningsfaktor for P-regulator
D_gain = 15; % Justert forsterkningsfaktor for D-regulator
previousError = 0; % Lagrer forrige feil for D-regulatoren
startTime = tic; % Starter tidtaker for plotting

% Beregner målet posisjon i grader, gitt ønsket posisjon i meter
targetPositionInDegrees = ((desiredEndPosition - actualStartPosition) / drumCircumference) * 360;

while true
    % Les nåværende rotasjon
    currentRotation = motorA.readRotation;
    
    % Beregn nåværende posisjon basert på rotasjon
    currentPosition = (currentRotation / 360) * drumCircumference + actualStartPosition;
    
    % Tid for plotting
    currentTime = toc(startTime);
    
    % Beregn feilen mellom nåværende og målposisjon
    error = desiredEndPosition - currentPosition;
    
    % P og D regulator for hastighetsjustering
    speedAdjustment = P_gain * error - D_gain * (error - previousError);
    speedAdjustment = max(min(speedAdjustment, speedLimit), -speedLimit);
    
    % Setter motorhastigheten basert på justering
    motorA.Speed = speedAdjustment;
    start(motorA);
    
    % Plotter den nåværende posisjonen
    plot(currentTime, currentPosition, 'bo');
    drawnow;
    
    % Sjekker om vi er nær den ønskede posisjonen
    if abs(error) < 0.01 || abs(currentRotation - targetPositionInDegrees) < 5 % Legger til en sjekk på rotasjon
        disp('Nådd ønsket posisjon.');
        break;
    end
    
    % Oppdaterer tidligere feil
    previousError = error;
    
    % Sjekker for timeout
    if currentTime > 10
        disp('Timeout, stopper løft.');
        break;
    end
end

% Stopper motoren etter operasjonen
stop(motorA, 1); % '1' for bremsing
disp('Operasjon fullført.');
