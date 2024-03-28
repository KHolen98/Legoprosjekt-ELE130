function Sekant = BakoverDerivasjon(FunctionValues, Timestep)

Sekant = (FunctionValues(2) - FunctionValues(1)) / Timestep;

end
