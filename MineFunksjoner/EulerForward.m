function IntValueNew = EulerForward(IntValueOld, Timestep, FunctionValue)

    IntValueNew = IntValueOld + Timestep * FunctionValue;

end
