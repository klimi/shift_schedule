

%%  constraints
% function main()

% load('mShiftConstraint.mat')
% 
mConstraints = int16([...
%1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31      ügyeleti napok	hétf?-péntek (MIN)	hétf?-péntek (MAX)	hétvégi napok (MIN)	hétvégi napok (MAX)
-1	0	0	0	0	0	0	0	0	0	0	-1	-1	-1	-1	0	0	0	0	0	0	2	0	0	0	0	0	-1	-1	0			4	2	2	2	2
0	0	0	0	0	0	0	-1	0	2	0	0	0	0	0	0	0	2	0	0	0	0	0	0	0	0	0	0	0	0			4	3	3	1	1
-1	0	-1	0	-1	0	0	-1	-1	-1	-1	-1	-1	-1	-1	0	-1	0	-1	0	0	-1	0	-1	0	-1	-1	-1	-1	-1			4	0	0	0	2
-1	0	-1	0	-1	0	0	-1	0	-1	0	-1	0	-1	-1	0	-1	0	-1	0	0	-1	-1	-1	0	-1	-1	-1	-1	0			4	0	0	1	2
-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	0	0	2	0	0	0	0	0	0	-1	-1	-1	0	0	0	0	0	0	0	0			4	2	2	2	2
-1	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	0	0	0	0	0	0	0	0	0			4	2	2	1	2
0	2	0	0	-1	-1	-1	-1	-1	0	0	-1	-1	-1	-1	0	0	0	0	0	0	0	0	2	0	0	-1	-1	-1	0			4	2	2	1	2
0	0	0	-1	0	0	-1	-1	-1	0	0	0	0	-1	0	0	0	-1	0	0	0	0	-1	-1	-1	-1	-1	-1	-1	-1			2	2	2	0	2
]); 

nMinFreeLongWeekend = 2;
firstMonday = 2; % date of the first monday in given month

doctorNameArray={
    'Bagó M'
    'Benkö'
    'Gácsi'
    'Klimaj'
    'Kopa'
    'Nagy Z'
    'Pánczél'
    'Mezei'
    }

difficultDay=int16([2,4,7]);
nMaxSolution = 100000;
fid = fopen( 'shiftSolution_2.txt', 'wt' );
%% 
mShiftConstraint = mConstraints(:,1:end-5);
mShiftConstraint= int16(mShiftConstraint);
[nDoctor nDay] = size(mShiftConstraint);
nDoctor = int16(nDoctor);
nDay = int16(nDay);

switch firstMonday
    case 1
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday+2:7:nDay]);
        thursdayArray = int16([firstMonday+3:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
        saturdayArray = int16([firstMonday+5:7:nDay]);
        sundayArray = int16([firstMonday+6:7:nDay]);
    case 2
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday+2:7:nDay]);
        thursdayArray = int16([firstMonday+3:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
        saturdayArray = int16([firstMonday+5:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
    case 3
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday+2:7:nDay]);
        thursdayArray = int16([firstMonday+3:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
       
    case 4
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday+2:7:nDay]);
        thursdayArray = int16([firstMonday+3:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
    case 5
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday+2:7:nDay]);
        thursdayArray = int16([firstMonday-4:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
    case 6
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday+1:7:nDay]);
        wednesdayArray = int16([firstMonday-5:7:nDay]);
        thursdayArray = int16([firstMonday-4:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
    case 7
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        tuesdayArray = int16([firstMonday-6:7:nDay]);
        wednesdayArray = int16([firstMonday-5:7:nDay]);
        thursdayArray = int16([firstMonday-4:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
end

aWeekDay = [mondayArray tuesdayArray wednesdayArray thursdayArray fridayArray];
aWeekendDay = [saturdayArray sundayArray];

longWeekendCellArray = {[fridayArray(1):1:fridayArray(1)+2]};
for i = 1:floor(nDay/7)-1
    longWeekendCellArray = {longWeekendCellArray{:} [fridayArray(1)+i*7:1:fridayArray(1)+2+i*7]};
end
    
mBoundaryConstraint = mConstraints(:,end-4:end);
requiredShiftArrayCond = mBoundaryConstraint (:,1);
requiredDifficultDayCond = mBoundaryConstraint (:,2);
maxDifficultDayCond = mBoundaryConstraint (:,3);
requiredWeekendDayCond = mBoundaryConstraint (:,4);
maxWeekendDayCond = mBoundaryConstraint (:,5);

if any(sum(mShiftConstraint==2,1)>1)
    disp('legalább egy napnál 2 darab kettes szerepel:');
    disp(find(sum(mShiftConstraint==2,1)>1));
    return
end

if any(sum(mShiftConstraint==-1,1)==numel(mShiftConstraint(:,1)))
    disp('legalább egy napnál senki nem ér rá:');
    disp(find(sum(mShiftConstraint==-1,1)==numel(mShiftConstraint(:,1))));
    return
end

aBoundaryConstraint = sum(mBoundaryConstraint,1);
if aBoundaryConstraint(5) < numel(saturdayArray)+numel(sundayArray)
    disp('nincs elég hétvégi nap');
    return
end

aDifficultWeekDay = [];
aDifficultWeekendDay = [];
for i=1:numel(difficultDay)
    switch difficultDay(i)
        case 1
            aDifficultWeekDay = [aDifficultWeekDay mondayArray];
        case 2
            aDifficultWeekDay = [aDifficultWeekDay tuesdayArray];
        case 3
            aDifficultWeekDay = [aDifficultWeekDay wednesdayArray];
        case 4
            aDifficultWeekDay = [aDifficultWeekDay thursdayArray];
        case 5
            aDifficultWeekDay = [aDifficultWeekDay fridayArray];
        case 6
            aDifficultWeekendDay = [aDifficultWeekendDay saturdayArray];
        case 7
            aDifficultWeekendDay = [aDifficultWeekendDay sundayArray];
    end
end
aNormalWeekDay = aWeekDay(~ismember(aWeekDay,aDifficultWeekDay));
aNormalWeekendDay = aWeekendDay(~ismember(aWeekendDay,aDifficultWeekendDay));

aRequiredDifficultDay =  [aDifficultWeekDay aDifficultWeekendDay];
nRequiredDifficultDay = numel(aRequiredDifficultDay);


if aBoundaryConstraint(3) < nRequiredDifficultDay
    disp('nincs elég ember a nehéz napokra');
    return
end

if sum(requiredShiftArrayCond) ~= nDay
    disp('nem egyezik az ügyeleti napok száma és a hónap napjainak a száma');
    return
end

%% stack, txt file initialization


[mTmpShiftDay,mTmpShiftDoctor] = meshgrid(1:nDay,1:nDoctor);
mTmpShiftDay = int16(mTmpShiftDay);
mTmpShiftDoctor = int16(mTmpShiftDoctor);

dayPool = int16(1:nDay);

fprintf(fid,'Ügyeleti beosztás opciók: \n\n');

%%  slecting those days that are taken by a doctor (days assigned 2 to)
[fixedShiftDoctor, fixedShiftDay]=find(mShiftConstraint==2);
fixedShiftDoctor = int16(fixedShiftDoctor);
fixedShiftDay = int16(fixedShiftDay);

dayPool(find(int16(sum((mShiftConstraint==2),1)))) = [];

requiredShiftArray = requiredShiftArrayCond - int16(sum((mShiftConstraint==2),2));

% requiredWeekendDay = requiredWeekendDayCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray]),2));
% requiredWeekendDay = requiredWeekendDay.*int16(requiredWeekendDay>0);
% requiredDifficultDay = requiredDifficultDayCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),aRequiredDifficultDay),2));
% requiredDifficultDay = requiredDifficultDay.*int16(requiredDifficultDay>0);
% aFixedNormalWeekday = int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),aNormalWeekDay),2));

if sum(min(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray aNormalWeekDay]),2)),mBoundaryConstraint (:,3)))<nRequiredDifficultDay
    disp('nincs elég nehéz nap, lehetséges problémás ember:');
    disp(doctorNameArray(find(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray aNormalWeekDay]),2))<mBoundaryConstraint (:,3))));
    return
end

if sum(min(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fridayArray aNormalWeekDay]),2)),mBoundaryConstraint (:,5)))<numel(saturdayArray)+numel(sundayArray)
    disp('nincs elég hétvége, lehetséges problémás ember:');
    disp(doctorNameArray(find(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fridayArray aNormalWeekDay]),2))<mBoundaryConstraint (:,5))));
    return
end

for i=1:length(fixedShiftDoctor)
    mShiftConstraint(:,fixedShiftDay(i)) = 0;
    mShiftConstraint(fixedShiftDoctor(i),fixedShiftDay(i)) = 1;
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
iSolution=int64(0);
%% loop
while (~isempty(shiftStructStack))
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    iDayPassed = nDay-nDayUnfilled+shiftStructNode1.dayIndex-1;
    
    %% This section decreases the number of branches to be visited by regularly ckecking some of the constraints
    passednMinFreeLongWeekend = true;
    passedEnoughRequiredShiftDay = true;
    passedEnoughRequiredDifficultDay = true;
    passedEngagedWeekendDay = true;
    passedrequiredShiftArrayCond = true;
    
    tmpShiftMatrix = int16(shiftStructNode1.doctorMatrix==1);
    freeWeekendArray = zeros(nDoctor,1);
    for i=1:length(longWeekendCellArray)
        weekendShiftArray = sum(ismember((mTmpShiftDay.*tmpShiftMatrix),longWeekendCellArray{i}),2);
        freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
    end
    if  all(freeWeekendArray >= nMinFreeLongWeekend)
        passednMinFreeLongWeekend = true;
    else
        passednMinFreeLongWeekend = false;
        continue
    end
    
    aNormalWeekDayShift = int16(sum(ismember(mTmpShiftDay.*tmpShiftMatrix,aNormalWeekDay),2));
    aDifficultWeekDayShift = int16(sum(ismember(mTmpShiftDay.*tmpShiftMatrix,aDifficultWeekDay),2));
    aNormalWeekendDayShift = int16(sum(ismember(mTmpShiftDay.*tmpShiftMatrix,aNormalWeekendDay),2));
    aDifficultWeekendDayShift = int16(sum(ismember(mTmpShiftDay.*tmpShiftMatrix,aDifficultWeekendDay),2));
    
    if  all(requiredShiftArrayCond < requiredDifficultDayCond + aNormalWeekDayShift + aNormalWeekendDayShift)
        passedEnoughRequiredShiftDay = false;
        continue 
    end
    if  all(requiredShiftArrayCond < requiredWeekendDayCond + aNormalWeekDayShift + aDifficultWeekDayShift)
        passedEnoughRequiredShiftDay = false;
        continue
    end
    
    aDifficultDayShift = sum(ismember(mTmpShiftDay.*tmpShiftMatrix,aRequiredDifficultDay),2);
    if any(aDifficultDayShift > maxDifficultDayCond) % checking maximum number of shifts on difficult day
        passedEnoughRequiredDifficultDay = false;
        continue
    end
    
    engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*tmpShiftMatrix,[saturdayArray sundayArray]),2);
    if any(engagedWeekendDayArray > maxWeekendDayCond); % checking maximum number of shifts on weekends
        passedEngagedWeekendDay = false;
        continue
    end
    
    if any(requiredShiftArrayCond<sum(tmpShiftMatrix,2))
        passedrequiredShiftArrayCond = false;
        continue
    end
        
    %% pushing nodes into the stack if the previous conditions are fullfilled
    passed = all([passednMinFreeLongWeekend passedEnoughRequiredShiftDay passedEnoughRequiredDifficultDay passedEngagedWeekendDay passedrequiredShiftArrayCond]);
    if passed==true && nDay > iDayPassed
        
        actualDay = idxPool(shiftStructNode1.dayIndex);
        
        [out,idx] = sort(shiftStructNode1.requiredShiftArray,'descend');
        nonZeroArray = idx(out>0);
        
        %         nonZeroArray = find(shiftStructNode1.requiredShiftArray);
        %     nonZeroArray = nonZeroArray(randperm(length(nonZeroArray))); % randomly sort elements of nonZeroArray in order to enhance random distribution of solutions over script runs
        
        for i=1:length(nonZeroArray)
            
            switch shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay)
                
                case -1
                    shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay) = 0;
                    continue
                    
                case 0    % aka the doctor is available on the given day
                    if actualDay > 1 && actualDay < nDay                        
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay-1) ~= 1) && (shiftStructNode1.doctorMatrix(nonZeroArray(i),actualDay+1) ~= 1)
                            
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
        passed2 = false;
        
        if all(aDifficultDayShift >= requiredDifficultDayCond) % minimum shifts on monday or friDayPassed
            passed2 = true;
        else
            passed2 = false;
            continue
        end
        
        if all(engagedWeekendDayArray >= requiredWeekendDayCond);
            passed2=true;
        else
            passed2=false;
            continue
        end
        
%         if iSolution==1
%             break
%         end
        
        if passed2==true
            iSolution=iSolution+1
            fprintf(fid,'Megoldás sorszáma: %d\n',iSolution);
            for ii = 1:size(shiftStructNode1.doctorMatrix,1)
                fprintf(fid,'%u\t',shiftStructNode1.doctorMatrix(ii,:));
                fprintf(fid,'\n');
            end
            
            fprintf(fid,'Ügyeleti beosztás : \n\n');
            for iNap=1:nDay
                for iDoctor = 1:nDoctor
                    if shiftStructNode1.doctorMatrix(iDoctor,iNap) ==1
                        fprintf(fid,'%i\t',iNap);
                        fprintf(fid,'%s\n',doctorNameArray{iDoctor});
                        %                 fprintf(fid,'\n');
                    end
                end
            end
            fprintf(fid,'\n');
            continue
        end
    end
    if iSolution == nMaxSolution
        break
    end
end
%%
if passednMinFreeLongWeekend == false && iSolution==0
    disp('nincs mindenkinek elég szabad hétvégéje');
elseif passedEnoughRequiredDifficultDay == false && iSolution==0
    disp('hétfö péntek vagy hétvégi ügyeleti számok problémások ');
elseif passedEnoughRequiredShiftDay == false && iSolution==0
    disp('nincs elég ügyeleti nap');
elseif passedEngagedWeekendDay == false && iSolution==0
    disp('hétvégi ügyeleti napok problémások');
else
    if iSolution==0
        disp('lehetséges problémás nap:');
        disp(actualDay);
    else
        disp('megoldás keresés vége');
    end
end
fclose(fid);
% end
