

%%  constraints
% function main()

% load('mShiftConstraint.mat')
mShiftConstraint = ...
[%1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	2	0	0	2	0	0	0
0	0	0	2	0	0	0	2	0	0	0	0	0	0	0	2	0	2	0	0	0	0	0	0	0	0	0	0	0	0	2
-1	-1	0	0	-1	0	-1	0	0	0	0	-1	0	-1	0	0	0	0	-1	0	-1	-1	-1	2	0	0	0	0	0	2	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	-1	-1	-1	-1	-1	-1	-1
0	-1	-1	0	0	0	0	0	-1	0	2	0	0	0	0	-1	0	0	-1	-1	0	2	-1	0	0	2	-1	-1	-1	-1	-1
0	-1	-1	-1	-1	-1	0	0	-1	-1	-1	-1	-1	-1	-1	-1	2	0	-1	-1	0	0	0	0	0	0	2	0	2	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	2	0	0	0	0	0	0	0	0
]

mBoundaryConstraint = int16([ ...
%     ügyeleti napok	hétf?-péntek (MIN)	hétf?-péntek (MAX)	hétvégi napok (MIN)	hétvégi napok (MAX)
5	1	2	1	2
5	1	1	1	3
5	1	2	1	2
5	1	2	1	2
5	1	2	1	2
5	0	0	1	2
1	0	1	0	1
])

nMinFreeLongWeekend = 2;

 doctorNameArray={
            'Égetö'
            'Gergely'
            'Klimaj'
            'Madarász'
            'Mózer'
            'Zabihi'
            'Jósvai'
            }
       
% doctorNameArray={
%             'Csókay'
%             'Jósvai'
%             'Lipóth'
%             'Mucsi'
%             'Mózes'
%             'Trencséni'
%             }

saturdayArray = int16([3:7:31]);
sundayArray = int16([4:7:31]);

% longWeekendCellArray = {[1:1:3]    [7:1:10]   [14:1:17]   [21:1:24]     [28:1:31]};
longWeekendCellArray = {[2:1:5]    [9:1:12]   [16:1:19]   [23:1:26]    [30:1:31]};

mondayArray = int16([5:7:31]);
fidayArray = int16([2:7:31]);

requiredShiftArrayCond = mBoundaryConstraint (:,1);
requiredMonFriCond = mBoundaryConstraint (:,2);
maxMonFri = mBoundaryConstraint (:,3);
requiredWeekendDayCond = mBoundaryConstraint (:,4);
maxWeekendDay = mBoundaryConstraint (:,5);

%% stack, txt file initialization
mShiftConstraint= int16(mShiftConstraint);

[nDoctor nDay] = size(mShiftConstraint);

[mTmpShiftDay,mTmpShiftDoctor] = meshgrid(1:nDay,1:nDoctor);
mTmpShiftDay = int16(mTmpShiftDay);
mTmpShiftDoctor = int16(mTmpShiftDoctor);

dayPool = int16(1:nDay);

fid = fopen( 'shiftSolution_1.txt', 'wt' );
fprintf(fid,'Ügyeleti beosztás opciók: \n\n');

tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fidayArray]));
%%  slecting those days that are taken by a doctor (days assigned 2 to)
[fixedShiftDoctor, fixedShiftDay]=find(mShiftConstraint==2);
fixedShiftDoctor = int16(fixedShiftDoctor);
fixedShiftDay = int16(fixedShiftDay);

dayPool(find(int16(sum((mShiftConstraint==2),1)))) = [];

requiredShiftArray = requiredShiftArrayCond - int16(sum((mShiftConstraint==2),2));
requiredWeekendDay = requiredWeekendDayCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[saturdayArray sundayArray]),2));
requiredMonFri = requiredMonFriCond - int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),[mondayArray fidayArray]),2));
fixedTueWenThuShiftArray = int16(sum(ismember(mTmpShiftDay.*int16(mShiftConstraint==2),tueWenThuArray),2));

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
    
    %% This section decreases the number of branches to be visited by regularly ckecking some of the constraints (every 2nd day)
    passed = true;
    if mod(iDayPassed,2)==1
        tmpShiftIntMatrix = int16(shiftStructNode1.doctorMatrix==1);
        freeWeekendArray = zeros(nDoctor,1);
        for i=1:length(longWeekendCellArray)
            weekendShiftArray = sum(ismember((mTmpShiftDay.*tmpShiftIntMatrix),longWeekendCellArray{i}),2);
            freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        end
        if  prod(freeWeekendArray >= nMinFreeLongWeekend)==1
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
        if sum(monFriShiftArray > maxMonFri)>0 % checking maximum number of shifts on monday or friDayPassed checking
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
        if prod(monFriShiftArray >= requiredMonFriCond)==1 % minimum shifts on monday or friDayPassed
            passed = true;
        else
            passed = false;
            continue
        end
        
        freeWeekendArray = zeros(nDoctor,1);
        for i=1:length(longWeekendCellArray)
            weekendShiftArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,longWeekendCellArray{i}),2);
            freeWeekendArray=(weekendShiftArray==0)+freeWeekendArray;
        end
        if  prod(freeWeekendArray >= nMinFreeLongWeekend)==1
            passed = true;
        else
            passed = false;
            continue
        end
        
        engagedWeekendDayArray = sum(ismember(mTmpShiftDay.*shiftStructNode1.doctorMatrix,[saturdayArray sundayArray]),2);
        if prod(engagedWeekendDayArray >= requiredWeekendDayCond)==1;
            passed=true;
        else
            passed=false;
            continue
        end
        
        
        
        if passed==true
            iSolution=iSolution+1
            fprintf(fid,'%d\n',iSolution);
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
    if iSolution == 1000000
        break
    end
end

% fprintf(fid,'\nNINCS TÖBB MEGOLDÁS');
fclose(fid)
% end

