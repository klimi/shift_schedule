
load('mShiftConstraint.mat')
% mShiftConstraint = int16(load('nShiftConstraint.mat'));
mShiftConstraint= int16(mShiftConstraint);

[nDoctor nDay] = size(mShiftConstraint);

fid = fopen( 'shiftSolution.txt', 'wt' );
fprintf(fid,'�gyeleti beoszt�s opci�k: \n\n');
%%  constraints

saturdayArray = int16([2 9 16 23 30 37]);
sundayArray = int16([3 10 17 24 31 38]);

longWeekendCellArray = {[1 2 3] [8 9 10] [15 16 17] [22 23 24] [29 30 31] [36 37 38]};

mondayArray = int16([4 11 18 25 32 39]);
fridayArray = int16([1 8 15 22 29 36]);

requiredShiftArray = int16([5;4;3;5;5;4;2;2;9])
requiredMonFri = int16([1;1;1;0;0;1;1;1;0])
requiredWeekendDay=int16([1;1;0;0;0;1;1;1;0])

%% stack initialization
tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fridayArray]));

iDay=int16(1);
shiftStruct.day = iDay;
shiftStruct.doctorMatrix = mShiftConstraint;
shiftStruct.requiredShiftArray = requiredShiftArray;

shiftStructStack = {shiftStruct};
leafCounter = 0;
iSolution=0;
%%
while (~isempty(shiftStructStack))
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    nonZeroArray = find(shiftStructNode1.requiredShiftArray());
    nonZeroArray = nonZeroArray(randperm(length(nonZeroArray))); % randomly sort elements of nonZeroArray in order to enhance random distribution of solutions over script runs
    
    iDay = shiftStructNode1.day;
    passed = 1;
    if shiftStructNode1.day > nDay
        leafCounter = leafCounter + 1;
        passed = 0;
        for i=1:length(requiredShiftArray)-1   % minimum 1 shifts at weekend
            shiftArray=find(shiftStructNode1.doctorMatrix(i,:));
            
            nMonFriShift = nnz(ismember(shiftArray,[mondayArray fridayArray]));
            if nMonFriShift >= requiredMonFri(i) % minimum 1 shifts on monday or friday
                passed=1;
            else
                passed=0;
                break
            end
            
            nFreeWeekend = 0;
            for i=1:length(longWeekendCellArray)
                weekendShift = nnz(ismember(shiftArray,longWeekendCellArray{i}));
                if weekendShift == 0
                    nFreeWeekend=nFreeWeekend+1;
                end
            end
            
            if nFreeWeekend >= 2
                passed=1;
            else
                passed=0;
                break
            end
            
            nEngagedWeekendDay = nnz(ismember(shiftArray,[saturdayArray sundayArray]));
            if nEngagedWeekendDay >= requiredWeekendDay(i);
                passed=1;
            else
                passed=0;
                break
            end
        end
        
        if passed==1
            iSolution=iSolution+1
            for ii = 1:size(shiftStructNode1.doctorMatrix,1)
                fprintf(fid,'%d\t',shiftStructNode1.doctorMatrix(ii,:));
                fprintf(fid,'\n');
            end
            fprintf(fid,'%d\n',iSolution);
            continue
        end
    end
    
    %% This section decreases the number of branches to be visited by regularly ckecking some of the constraints (regularly - after a given number of days passed (nDay mod X))
    passed=1;
%     if iDay>nDay/2
        
%         for i=1:length(requiredShiftArray)-1
%             shiftArray=find(shiftStructNode1.doctorMatrix(i,:)==1);
%             
%             nFreeWeekend = 0;
%             for j=1:length(longWeekendCellArray)
%                 if nnz(ismember(shiftArray,longWeekendCellArray{j}))==0
%                     nFreeWeekend=nFreeWeekend+1;
%                 end
%             end
%             if nFreeWeekend<1
%                 passed=0;
%                 break
%             end
%             
%             if requiredShiftArray(i)-nnz(ismember(shiftArray,tueWenThuArray))<requiredMonFri(i)+requiredWeekendDay(i) % minimum 1 shifts on monday or friday and weekends
%                 passed=0;
%                 break
%             end
%         end
%     end

    %%
    
    if passed==1
        for i=1:length(nonZeroArray)
            
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
end
if iSolution==0
    fprintf(fid,'NINCS MEGOLD�S');
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