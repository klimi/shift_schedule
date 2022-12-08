function shiftStructStack = stepNode(shiftStructNodeStc,shiftStructNodeTmp,actualDay,iDoctor)
shiftStructNodeTmp.requiredShiftArray(iDoctor)= shiftStructNodeTmp.requiredShiftArray(iDoctor)-1;
shiftStructNodeTmp.doctorMatrix(:,actualDay) = 0;
shiftStructNodeTmp.doctorMatrix(iDoctor,actualDay) = 1;
% shiftStructNodeTmp.day = actualDay + 1;
shiftStructNodeTmp.dayIndex = shiftStructNodeTmp.dayIndex + 1;
shiftStructStack = {shiftStructNodeStc{:} shiftStructNodeTmp};
end