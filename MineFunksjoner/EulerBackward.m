function IntValueNew = EulerBackward(IntValueOld, Timestep, FunctionValue)

    IntValueNew = IntValueOld + Timestep * FunctionValue;

end