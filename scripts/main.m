

%%  constraints
% function main()

% load('mShiftConstraint.mat')
% 
mConstraints = int16([...
%1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31      �gyeleti napok	h�tf?-p�ntek (MIN)	h�tf?-p�ntek (MAX)	h�tv�gi napok (MIN)	h�tv�gi napok (MAX)
-1	-1	-1	0	2	0	-1	2	0	0	2	0	2	0	-1	-1	-1	-1	-1	-1	-1	0	0	0	-1	-1	-1	0	2	0	-1	6	1	3	1	3
0	0	0	0	0	0	0	-1	0	0	0	0	0	0	-1	0	0	0	0	0	0	-1	0	-1	-1	-1	0	0	-1	0	0	5	1	3	1	3
2	0	0	2	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	1	3	1	3
-1	-1	-1	-1	-1	0	0	-1	0	0	0	0	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	0	0	0	0	0	0	5	1	3	1	3
-1	0	0	-1	0	0	0	0	0	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	-1	0	0	0	0	2	5	1	3	0	3
-1	2	0	-1	-1	-1	-1	-1	0	-1	-1	-1	-1	0	0	0	0	0	0	0	0	0	0	-1	0	0	-1	-1	-1	0	-1	5	1	3	0	3
]); 
    
nMinFreeLongWeekend = 2;
firstMonday = 6; % date of the first monday in given month

% doctorNameArray={
%     '�get�'
%     'Gergely'
%     'Klimaj'
%     'Madar�sz'
%     'T�th'
%     }

doctorNameArray={
    'Szloboda'
    'J�svai'
    'Lip�th'
    'M�zer'
    'Trencs�ni'
    'M�zes'
    }


fid = fopen( 'shiftSolution_2.txt', 'wt' );
%% 
mShiftConstraint = mConstraints(:,1:end-5);
mShiftConstraint= int16(mShiftConstraint);
[nDoctor nDay] = size(mShiftConstraint);

switch firstMonday
    case 1
        saturdayArray = int16([firstMonday+5:7:nDay]);
        sundayArray = int16([firstMonday+6:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
    case 2
        saturdayArray = int16([firstMonday+5:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
    case 3
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday+4:7:nDay]);
    case 4
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
    case 5
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
    case 6
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
    case 7
        saturdayArray = int16([firstMonday-2:7:nDay]);
        sundayArray = int16([firstMonday-1:7:nDay]);
        mondayArray = int16([firstMonday:7:nDay]);
        fridayArray = int16([firstMonday-3:7:nDay]);
end

longWeekendCellArray = {[fridayArray(1):1:fridayArray(1)+2]};
for i = 1:floor(nDay/7)-1
    longWeekendCellArray = {longWeekendCellArray{:} [fridayArray(1)+i*7:1:fridayArray(1)+2+i*7]};
end
    
mBoundaryConstraint = mConstraints(:,end-4:end);
requiredShiftArrayCond = mBoundaryConstraint (:,1);
requiredMonFriCond = mBoundaryConstraint (:,2);
maxMonFri = mBoundaryConstraint (:,3);
requiredWeekendDayCond = mBoundaryConstraint (:,4);
maxWeekendDay = mBoundaryConstraint (:,5);

if any(sum(mShiftConstraint==2,1)>1)
    disp('legal�bb egy napn�l 2 darab kettes szerepel:');
    disp(find(sum(mShiftConstraint==2,1)>1));
    return
end

if any(sum(mShiftConstraint==-1,1)==numel(mShiftConstraint(:,1)))
    disp('legal�bb egy napn�l senki nem �r r�:');
    disp(find(sum(mShiftConstraint==-1,1)==numel(mShiftConstraint(:,1))));
    return
end

aBoundaryConstraint = sum(mBoundaryConstraint,1);
if aBoundaryConstraint(5) < numel(saturdayArray)+numel(sundayArray)
    disp('nincs el�g h�tv�gi nap');
    return
end

if aBoundaryConstraint(3) < numel(mondayArray)+numel(fridayArray)
    disp('nincs el�g h�tf�-p�ntek');
    return
end

if sum(requiredShiftArrayCond) ~= nDay
    disp('nem egyezik az �gyeleti napok sz�ma �s a h�nap napjainak a sz�ma');
    return
end
%% stack, txt file initialization


[mTmpShiftDay,mTmpShiftDoctor] = meshgrid(1:nDay,1:nDoctor);
mTmpShiftDay = int16(mTmpShiftDay);
mTmpShiftDoctor = int16(mTmpShiftDoctor);

dayPool = int16(1:nDay);

fprintf(fid,'�gyeleti beoszt�s opci�k: \n\n');

tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fridayArray]));
%%  slecting those days that are taken by a doctor (days assigned 2 to)
[fixedShiftDoctor, fixedShiftDay]=find(mShiftConstraint==2);
fixedShiftDoctor = int16(fixedShiftDoctor);
fixedShiftDay = int16(fixedShiftDay);

dayPool(find(int16(sum((mShiftConstraint==2),1)))) = [];

requiredShiftArray = requiredShiftArrayCond - int16(sum((mShiftConstraint==2),2));

requiredWeekendDay = requiredWeekendDayCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray]),2));
requiredWeekendDay = requiredWeekendDay.*int16(requiredWeekendDay>0);

requiredMonFri = requiredMonFriCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fridayArray]),2));
requiredMonFri = requiredMonFri.*int16(requiredMonFri>0);

fixedTueWenThuShiftArray = int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),tueWenThuArray),2));

if sum(min(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray tueWenThuArray]),2)),mBoundaryConstraint (:,3)))<numel(mondayArray)+numel(fridayArray)
    disp('nincs el�g h�tf�-p�ntek, lehets�ges probl�m�s ember:');
    disp(doctorNameArray(find(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray tueWenThuArray]),2))<mBoundaryConstraint (:,3))));
    return
end

if sum(min(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fridayArray tueWenThuArray]),2)),mBoundaryConstraint (:,5)))<numel(saturdayArray)+numel(sundayArray)
    disp('nincs el�g h�tv�ge, lehets�ges probl�m�s ember:');
    disp(doctorNameArray(find(requiredShiftArrayCond-int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fridayArray tueWenThuArray]),2))<mBoundaryConstraint (:,5))));
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
    passedEnoughRequiredMonFriShiftDay = true;
    passedEngagedWeekendDay = true;
    passedrequiredShiftArrayCond = true;
    
    tmpShiftIntMatrix = int16(shiftStructNode1.doctorMatrix==1);
    freeWeekendArray = zeros(nDoctor,1);
    for i=1:length(longWeekendCellArray)
        weekendShiftArray = sum(ismember((mTmpShiftDay.*tmpShiftIntMatrix),longWeekendCellArray{i}),2);
        freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
    end
    if  prod(freeWeekendArray >= nMinFreeLongWeekend)==1
        passednMinFreeLongWeekend = true;
    else
        passednMinFreeLongWeekend = false;
        continue
    end
    
    tueWenThuShiftArray = int16(sum(ismember(mTmpShiftDay.*tmpShiftIntMatrix,tueWenThuArray),2)) - fixedTueWenThuShiftArray;
    if  prod(requiredShiftArray < requiredMonFri + requiredWeekendDay + tueWenThuShiftArray)==1 % minimum 1 shifts on monday or frnDayPassed
        passedEnoughRequiredShiftDay = false;
        continue
    end
    
    monFriShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[mondayArray fridayArray]),2);
    if sum(monFriShiftArray > maxMonFri)>0 % checking maximum number of shifts on monday or friDayPassed checking
        passedEnoughRequiredMonFriShiftDay = false;
        continue
    end
    
    engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
    if sum(engagedWeekendDayArray > maxWeekendDay)>0; % checking maximum number of shifts on weekends
        passedEngagedWeekendDay = false;
        continue
    end
    
    if sum(requiredShiftArrayCond<sum(shiftStructNode1.doctorMatrix,2))
        passedrequiredShiftArrayCond = false;
        continue
    end
        
    %% pushing nodes into the stack if the previous conditions are fullfilled
    passed = all([passednMinFreeLongWeekend passedEnoughRequiredShiftDay passedEnoughRequiredMonFriShiftDay passedEngagedWeekendDay passedrequiredShiftArrayCond]);
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
        
        monFriShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[mondayArray fridayArray]),2);
        if prod(monFriShiftArray >= requiredMonFriCond)==1 % minimum shifts on monday or friDayPassed
            passed2 = true;
        else
            passed2 = false;
            continue
        end
        
        freeWeekendArray = zeros(nDoctor,1);
        for i=1:length(longWeekendCellArray)
            weekendShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,longWeekendCellArray{i}),2);
            freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        end
        if  prod(freeWeekendArray >= nMinFreeLongWeekend)==1
            passed2 = true;
        else
            passed2 = false;
            continue
        end
        
        engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
        if prod(engagedWeekendDayArray >= requiredWeekendDayCond)==1;
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
            fprintf(fid,'Megold�s sorsz�ma: %d\n',iSolution);
            for ii = 1:size(shiftStructNode1.doctorMatrix,1)
                fprintf(fid,'%u\t',shiftStructNode1.doctorMatrix(ii,:));
                fprintf(fid,'\n');
            end
            
            fprintf(fid,'�gyeleti beoszt�s : \n\n');
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
    if iSolution == 1000
        break
    end
end
if passednMinFreeLongWeekend == false && iSolution==0
    disp('nincs mindenkinek el�g szabad h�tv�g�je');
elseif passedEnoughRequiredMonFriShiftDay == false && iSolution==0
    disp('h�tf� p�ntek vagy h�tv�gi �gyeleti sz�mok probl�m�sok ');
elseif passedEnoughRequiredShiftDay == false && iSolution==0
    disp('nincs el�g �gyeleti nap');
elseif passedEngagedWeekendDay == false && iSolution==0
    disp('h�tv�gi �gyeleti napok probl�m�sok');
else
    if iSolution==0
        disp('lehets�ges probl�m�s nap:');
        disp(actualDay);
    else
        disp('megold�s keres�s v�ge');
    end
end
fclose(fid);
% end
