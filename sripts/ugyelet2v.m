
iSolution=0;

load('mShiftConstraint.mat')
% mShiftConstraint = int16(load('nShiftConstraint.mat'));
mShiftConstraint= int16(mShiftConstraint);

[nDoctor nDay] = size(mShiftConstraint);
[mTmpShift,] = int16(meshgrid(1:nDay,1:nDoctor))

fid = fopen('shiftSolution.txt','wt');
fprintf(fid,'Ügyeleti beosztás opciók: \n\n');

saturdayArray = int16([2:7:30]);
sundayArray = int16([3:7:30]);

longWeekendCellArray = {[2    3    4]    [9   10   11]   [16   17   18]   [23   24   25]};

mondayArray = int16([1:7:30]);
fridayArray = int16([4:7:30]);

requiredShiftArray = int16([...
    5
    4
    3
    5
    5
    4
    2
    2
    ])
requiredMonFri = int16([...
    1
    1
    1
    1
    1
    1
    1
    1
    ])
requiredWeekendDay=int16([...
    1
    1
    1
    1
    1
    1
    1
    1
    ])

%% stack initialization
tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fridayArray]));

iDay=int16(1);
shiftStruct.day = iDay;
shiftStruct.doctorMatrix = mShiftConstraint;
shiftStruct.requiredShiftArray = requiredShiftArray;

shiftStructStack = {shiftStruct};
leafCounter = 0;
iSolution=0;

while (~isempty(shiftStructStack))
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    iDay = shiftStructNode1.day;
    
    nonZeroArray = find(shiftStructNode1.requiredShiftArray);
%     if leafCounter == 0;
%         nonZeroArray = requiredShiftArray(randperm(length(requiredShiftArray))); % randomly sort elements of nonZeroArray in order to enhance random distribution of solutions over script runs
%     end
    
    if shiftStructNode1.day > nDay
        leafCounter = leafCounter + 1;
        passed = false;
        
        monFriShiftArray = sum(ismember(mTmpShift.*shiftStructNode1.doctorMatrix,[mondayArray fridayArray]),2);
        if prod(monFriShiftArray >= requiredMonFri)==1 % minimum 1 shifts on monday or friday
            passed = true;
        else
            passed = false;
            continue
        end
        
        freeWeekendArray = zeros(nDoctor,1);
        for i=1:length(longWeekendCellArray)
            weekendShiftArray = sum(ismember(mTmpShift.*shiftStructNode1.doctorMatrix,longWeekendCellArray{i}),2);
            freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        end
        if  prod(freeWeekendArray >= 2)==1
            passed = true;
        else
            passed = false;
            continue
        end
        
        engagedWeekendDayArray = sum(ismember(mTmpShift.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
        if prod(engagedWeekendDayArray >= requiredWeekendDay)==1;
            passed = true;
        else
            passed = false;
            continue
        end
        
        
        if passed==true
            iSolution=iSolution+1
            for ii = 1:size(shiftStructNode1.doctorMatrix,1)
                fprintf(fid,'%d\t',shiftStructNode1.doctorMatrix(ii,:));
                fprintf(fid,'\n');
            end
            fprintf(fid,'%d\n',iSolution);
            continue
        end
    end
    
    for i=1:numel(nonZeroArray)
        
        switch shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay)
            
            case -1
                shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay) = 0;
                continue
                
            case 2 % the one who wants to have the shift takes it
                shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                break
                
            case 0    % aka the doctor is available on the given day
                if iDay > 1 & iDay < nDay
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1) & (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                        shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                    else
                        continue
                    end
                end
                if iDay == 1
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                        shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                    else
                        continue
                    end
                end
                
                if iDay == nDay
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1)
                        shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                    else
                        continue
                    end
                end
        end
    end
end


fclose(fid)

%% functions
function shiftStructStack = stepNode(shiftStructNodeStc,shiftStructNodeTmp,nonZeroArray,iDay,iDoctor)
shiftStructNodeTmp.requiredShiftArray(nonZeroArray(iDoctor))= shiftStructNodeTmp.requiredShiftArray(nonZeroArray(iDoctor))-1;
shiftStructNodeTmp.doctorMatrix(:,iDay) = 0;
shiftStructNodeTmp.doctorMatrix(nonZeroArray(iDoctor),iDay) = 1;
shiftStructNodeTmp.day = iDay + 1;
shiftStructStack = {shiftStructNodeStc{:} shiftStructNodeTmp};
end