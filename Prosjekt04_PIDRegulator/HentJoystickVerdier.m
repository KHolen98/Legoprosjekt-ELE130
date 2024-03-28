function [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick)
    
    JoyAxes(1) = 100 * axis(joystick, 1); % side
    JoyAxes(2) = -100 * axis(joystick, 2); % forward
    
    % Endre paa fortegnet her
    % potensimeter og twist
    JoyAxes(3) = 100 * axis(joystick, 3); % 
    JoyAxes(4) = 100 * axis(joystick, 4); % 
    
    for i=1:12
        JoyButtons(i) = button(joystick, i);
    end
end

