# Her skriver du funksjoner som skal brukes i MathCalculations
# Etter å ha skrevet dem her kan du kalle på dem i Main.py filen (De blir automatisk importert)

def EulerForover(IntValue, FunctionValue, TimeStep):
    return IntValue + FunctionValue*TimeStep

def Trapes(IntValue, FunctionValue, TimeStep):
    # fungerer ikke å indeksere FunctionValue her inne!
    return IntValue + 0.5*(FunctionValue[0]+FunctionValue[1])*TimeStep

def BakoverDerivasjon(FunctionValues,TimeStep):
    return (FunctionValues[1]-FunctionValues[0])/TimeStep