
nDoctor=6;
nDay = 30;
mTmpShift = zeros(nDoctor,nDay);

load('mShiftConstraint.mat')
% mShiftConstraint = int16(load('nShiftConstraint.mat'));
mShiftConstraint= int16(mShiftConstraint);

fid = fopen('shiftSolution.txt','wt');

fid = fopen( 'shiftSolution.txt', 'wt' );
fprintf(fid,'Ügyeleti beosztás opciók: \n\n');
%%  constraints

saturdayArray = int16([1 8 15 22 29]);
sundayArray = int16([2 9 16 23 30]);

longWeekendCellArray = {[1 2] [7 8 9] [14 15 16] [21 21 23] [28 29 30]};

mondayArray = int16([3 10 17 24]);
fridayArray = int16([7 14 21 28]);

requiredShiftArray = int16([5;5;5;5;5;5])
requiredMonFri = int16([1;0;1;1;0;0])
requiredWeekend=int16([1;1;1;1;1;1])
%%
tueWenThuArray = find(~ismember(1:nDay,[saturdayArray sundayArray mondayArray fridayArray]));

% requiredSaturday = int16([1;1;0;0;1;1]);

iDay=int16(1);
shiftStruct.day = iDay;
shiftStruct.doctorMatrix = mShiftConstraint;
shiftStruct.requiredShiftArray = requiredShiftArray;

shiftStructStack = {shiftStruct};

% Stack = new Stack();
% Stack.put(param);
% result = 0;
iSolution=0;
while (~isempty(shiftStructStack))
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    nonZeroArray = find(shiftStructNode1.requiredShiftArray);
    iDay = shiftStructNode1.day;
    passed = 1;
    if shiftStructNode1.day > nDay
        
        passed = 0;
        for i=1:numel(requiredShiftArray)   % minimum 1 shifts at weekend
            w=find(shiftStructNode1.doctorMatrix(i,:));
            
            if nnz(ismember(w,[mondayArray fridayArray]))>=requiredMonFri(i) % minimum 1 shifts on monday or friday
                passed=1;
            else
                passed=0;
                break
            end
            
            nFreeWeekend = 0;
            for i=1:numel(longWeekendCellArray)
                if nnz(ismember(w,longWeekendCellArray{i}))==0
                    nFreeWeekend=nFreeWeekend+1;
                end
            end
            
            if nFreeWeekend>1
                passed=1;
            else
                passed=0;
                break
            end
            
            nEngagedWeekend = nnz(ismember(w,[saturdayArray sundayArray]));
            if nEngagedWeekend>=requiredWeekend(i);
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
            
                passed=1;
                if shiftStructNode1.day > numel(requiredShiftArray)*2
        
                    for i=1:numel(requiredShiftArray)
                        if min(shiftStructNode1.requiredShiftArray)<=requiredMonFri(i)+requiredWeekend(i)
                            w=find(shiftStructNode1.doctorMatrix(i,:)==1);
        
                            nFreeWeekend = 0;
                            for j=1:numel(longWeekendCellArray)
                                if nnz(ismember(w,longWeekendCellArray{j}))==0
                                    nFreeWeekend=nFreeWeekend+1;
                                end
                            end
                            if nFreeWeekend<1
                                passed=0;
                                break
                            end
        
                            if requiredShiftArray(i)-nnz(ismember(w,tueWenThuArray))<requiredMonFri(i)+requiredWeekend(i) % minimum 1 shifts on monday or friday and weekends
                                passed=0;
                                break
                            end
                        end
                    end
                end
    
        
        
            if passed==1
        for i=1:numel(nonZeroArray)
            
            switch shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay)
                case 2 % the one who wants to have the shift takes it
                    shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                    break
                    
                case 0    % aka the doctor is available on the given day
                    if iDay>1 & iDay<nDay
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1) & (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                        else
                            continue
                        end
                    end
                    if iDay==1
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                        else
                            continue
                        end
                    end
                    
                    if iDay==nDay
                        if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1)
                            shiftStructStack = stepNode(shiftStructStack,shiftStructNode1,nonZeroArray,iDay,i);
                        else
                            continue
                        end
                    end
                    
                case -1
                    shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay) = 0;
                    continue
            end
        end
    end
end
if iSolution==0
    fprintf(fid,'NINCS MEGOLDÁS');
end
fclose(fid)


function shiftStructStack = stepNode(shiftStructNodeStc,shiftStructNodeTmp,nonZeroArray,iDay,iDoctor)
shiftStructNodeTmp.requiredShiftArray(nonZeroArray(iDoctor))= shiftStructNodeTmp.requiredShiftArray(nonZeroArray(iDoctor))-1;
shiftStructNodeTmp.doctorMatrix(:,iDay) = 0;
shiftStructNodeTmp.doctorMatrix(nonZeroArray(iDoctor),iDay) = 1;
shiftStructNodeTmp.day = iDay + 1;
shiftStructStack = {shiftStructNodeStc{:} shiftStructNodeTmp};
end