T = [45 135];
dA = 2;
pC = 0.05;
cInt = [50 100];
nSteps = 1000;

noChange = false;

Ori=[T(1)]; dAA=[]; LastChange = 0; TC = T(1);
for s = 1:nSteps
    TC = TC + dA;
    
    if TC > 360; TC=TC-360; end
    if TC < 0; TC=TC+360; end
    
    Ori = [Ori TC];
    dAA = [dAA dA];

    if s-LastChange > cInt(1) && rand(1) < pC && ~noChange
        dA = -dA;
        LastChange = s;
    elseif s-LastChange == cInt(2)
        dA = -dA;
        LastChange = s;
    end
    
    dT = TC-T(2);
    if dT > 0 && dT <180 && ~noChange
        if dA < 0
            if abs((nSteps-s)*dA) <= dT
                noChange = true; 
            end
        elseif dA > 0
            if abs((nSteps-s)*dA) <= dT
                noChange = true;
                dA=-dA;
                LastChange = s;
            end
        end
    elseif dT >= 180 && ~noChange
        if dA < 0
            if abs((nSteps-s)*dA) <= 360-dT
                noChange = true; 
                dA=-dA;
                LastChange = s;
            end
        elseif dA > 0
            if abs((nSteps-s)*dA) <= 360-dT
                noChange = true;
            end
        end
    elseif dT < 0  && ~noChange
        if dA < 0
            if abs((nSteps-s)*dA) <= abs(dT)
                noChange = true; 
                dA=-dA;
                LastChange = s;
            end
        elseif dA > 0
            if abs((nSteps-s)*dA) <= abs(dT)
                noChange = true;
            end
        end
    end
end

subplot(2,1,1);
plot(Ori,'o-')
subplot(2,1,2);
plot(dAA,'o-')

fprintf(['Final value: ' num2str(TC) '\n']);