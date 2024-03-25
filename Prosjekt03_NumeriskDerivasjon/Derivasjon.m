function Sekant = Derivasjon(FunctionValues, Timestep, options)
arguments
    FunctionValues (1,3) double
    Timestep (1,1) double
    options.metode (1,:) char = 'Bakover'
end

if strcmp(options.metode,'Bakover')
    % Bakoverderivert: (f(x) - f(x-h)) / h
    Sekant = (FunctionValues(3) - FunctionValues(2)) / Timestep;

elseif strcmp(options.metode,'Forover')
    % Foroverderivert: (f(x+h) - f(x)) / h
    Sekant = (FunctionValues(2) - FunctionValues(1)) / Timestep;

elseif strcmp(options.metode,'Senter')
    % Senterderivert: (f(x+h) - f(x-h)) / (2*h)
    Sekant = (FunctionValues(3) - FunctionValues(1)) / (2 * Timestep);

else
    errordlg('Feil metode spesifisert');
    return
end

end
