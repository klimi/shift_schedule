

%%  constraints

load('mShiftConstraint.mat')

saturdayArray = int16([2:7:30]);
sundayArray = int16([3:7:30]);

longWeekendCellArray = {[1    2    3    4]    [8   9    10   11]   [15  16   17   18]   [22   23   24   25]};

mondayArray = int16([1:7:30]);
fidayArray = int16([4:7:30]);

requiredShiftArray = int16([...
4
4
4
5
4
4
2
3
    ])

requiredMonFri = int16([...
2
2
1
1
1
1
0
1
    ])

maxMonFri = int16([...
2
2
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
2
1
2
1
0
1
    ])

maxWeekendDay=int16([...
1
1
2
1
2
1
1
1
    ])
%% stack, txt file initialization
mShiftConstraint= int16(mShiftConstraint);

[nDoctor nDay] = size(mShiftConstraint);

[mTmpShiftDay,mTmpShiftDoctor] = meshgrid(1:nDay,1:nDoctor);
mTmpShiftDay = int16(mTmpShiftDay);
mTmpShiftDoctor = int16(mTmpShiftDoctor);

dayPool = int16(1:nDay);

fid = fopen( 'shiftSolution.txt', 'wt' );
fprintf(fid,'Ügyeleti beosztás opciók: \n\n');

tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fidayArray]));
%%  slecting those days that are taken by a doctor (days assigned 2 to)
[sureShiftDoctor, sureShiftDay]=find(mShiftConstraint==2);
sureShiftDoctor = int16(sureShiftDoctor);
sureShiftDay = int16(sureShiftDay);

dayPool(find(int16(sum((mShiftConstraint==2),1)))) = [];    

requiredShiftArray = requiredShiftArray - int16(sum((mShiftConstraint==2),2));
requiredWeekendDay = requiredWeekendDay - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray]),2));
requiredMonFri = requiredMonFri - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fidayArray]),2));
fixedTueWenThuShiftArray = int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),tueWenThuArray),2));

for i=1:length(sureShiftDoctor)
    mShiftConstraint(:,sureShiftDay(i)) = 0;
    mShiftConstraint(sureShiftDoctor(i),sureShiftDay(i)) = 1;
end

%%
[out,idx] = sort(sum(mShiftConstraint,1));
idxPool = idx(out<=0);
actualDay = idxPool(1);
        
iDayPassed=int16(1);
nDayUnfilled = int16(length(idxPool));
% shiftStruct.day = iDayPassed;
shiftStruct.dayIndex = 1;
shiftStruct.doctorMatrix = mShiftConstraint;
shiftStruct.requiredShiftArray = requiredShiftArray;



shiftStructStack = {shiftStruct};
leafCounter = 0;
iSolution=0;
%% loop
while (~isempty(shiftStructStack))
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    iDayPassed = nDay-nDayUnfilled+shiftStructNode1.dayIndex-1;
    
    %% This section decreases the number of branches to be visited by regularly ckecking some of the constraints (every 2nd day)
    passed = true;
    if mod(iDayPassed,2)==1
        tmpShiftIntMatrix = int16(shiftStructNode1.doctorMatrix==1);
        freeWeekendArray = zeros(nDoctor,1);
        for i=1:length(longWeekendCellArray)
            weekendShiftArray = sum(ismember((mTmpShiftDay.*tmpShiftIntMatrix),longWeekendCellArray{i}),2);
            freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        end
        if  prod(freeWeekendArray >= 2)==1
            passed = true;
        else
            passed = false;
            continue
        end
        
        tueWenThuShiftArray = int16(sum(ismember(mTmpShiftDay.*tmpShiftIntMatrix,tueWenThuArray),2)) - fixedTueWenThuShiftArray;
        if  prod(requiredShiftArray < requiredMonFri + requiredWeekendDay + tueWenThuShiftArray)==1 % minimum 1 shifts on monday or frnDayPassed
            passed = false;
            continue
        end
        
        monFriShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[mondayArray fidayArray]),2);
        if sum(monFriShiftArray > maxMonFri)>0 % checking maximum number of shifts on monday or frnDayPassed checking
            passed = false;
            continue
        end
        
        engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
        if sum(engagedWeekendDayArray > maxWeekendDay)>0; % checking maximum number of shifts on weekends
            passed = false;
            continue
        end
        
    end
    
    %% pushing nodes into the stack if the previous conditions are fullfilled
    
    if passed==true & nDay > iDayPassed
        
        actualDay = idxPool(shiftStructNode1.dayIndex);
        
        nonZeroArray = find(shiftStructNode1.requiredShiftArray);
        %     nonZeroArray = nonZeroArray(randperm(length(nonZeroArray))); % randomly sort elements of nonZeroArray in order to enhance random distribution of solutions over script runs
        
        for i=1:length(nonZeroArray)
            
            switch shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay)
                
                case -1
                    shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay) = 0;
                    continue
                    
                case 0    % aka the doctor is available on the given day
                    if actualDay > 1 & actualDay < nDay
                        
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay-1) ~= 1) & (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay+1) ~= 1)
                            
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,actualDay,nonZeroArray(i));
                        else
                            continue
                        end
                    end
                    if actualDay == 1
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay+1) ~= 1)
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,actualDay,nonZeroArray(i));
                        else
                            continue
                        end
                    end
                    
                    if actualDay == nDay
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay-1) ~= 1)
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,actualDay,nonZeroArray(i));
                        else
                            continue
                        end
                    end
            end
        end
    end 
    %% checking constraints at the end of the tree
    if iDayPassed == nDay
        leafCounter = leafCounter + 1;
        passed = false;
        
        monFriShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[mondayArray fidayArray]),2);
        if prod(monFriShiftArray >= requiredMonFri)==1 % minimum 1 shifts on monday or frnDayPassed
            passed = true;
        else
            passed = false;
            continue
        end
        
        %         freeWeekendArray = zeros(nDoctor,1);
        %         for i=1:length(longWeekendCellArray)
        %             weekendShiftArray = sum(ismember(mTmpShift.*shiftStructNode1.doctorMatrix,longWeekendCellArray{i}),2);
        %             freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        %         end
        %         if  prod(freeWeekendArray >= 2)==1
        %             passed = true;
        %         else
        %             passed = false;
        %             continue
        %         end
        
        engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
        if prod(engagedWeekendDayArray >= requiredWeekendDay)==1;
            passed=1;
        else
            passed=0;
            continue
        end
        
        if passed==true
            iSolution=iSolution+1
            fprintf(fid,'%d\n',iSolution);
            for ii = 1:size(shiftStructNode1.doctorMatrix,1)
                fprintf(fid,'%d\t',shiftStructNode1.doctorMatrix(ii,:));
                fprintf(fid,'\n');
            end
            fprintf(fid,'\n',iSolution);
            continue
        end
    end
end

fprintf(fid,'\nNINCS TÖBB MEGOLDÁS');
fclose(fid)

%% functions
function shiftStructStack = stepNode(shiftStructNodeStc,shiftStructNodeTmp,actualDay,iDoctor)
shiftStructNodeTmp.requiredShiftArray(iDoctor)= shiftStructNodeTmp.requiredShiftArray(iDoctor)-1;
shiftStructNodeTmp.doctorMatrix(:,actualDay) = 0;
shiftStructNodeTmp.doctorMatrix(iDoctor,actualDay) = 1;
% shiftStructNodeTmp.day = actualDay + 1;
shiftStructNodeTmp.dayIndex = shiftStructNodeTmp.dayIndex + 1;
shiftStructStack = {shiftStructNodeStc{:} shiftStructNodeTmp};
end