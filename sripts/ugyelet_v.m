
iSolution=0;

load('mShiftConstraint.mat')
% mShiftConstraint = int16(load('nShiftConstraint.mat'));
mShiftConstraint= int16(mShiftConstraint);

[nDoctor nDay] = size(mShiftConstraint);

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

iDay=int16(1);
shiftStruct.day = iDay;
shiftStruct.doctorMatrix = mShiftConstraint;
shiftStruct.requiredShiftArray = requiredShiftArray;

shiftStructStack = {shiftStruct};

% Stack = new Stack();
% Stack.put(param);
% result = 0;

while (~isempty(shiftStructStack))
    %     param = Stack.remove();
    
    shiftStructNode1 = shiftStructStack{end};
    shiftStructStack(end)= [];
    
    nonZeroArray = find(shiftStructNode1.requiredShiftArray);
    iDay = shiftStructNode1.day;
    
   
    
    if shiftStructNode1.day > nDay
        
        passed = 0;
        for i=1:numel(requiredShiftArray)   % minimum 1 shifts at weekend
            w=find(shiftStructNode1.doctorMatrix(i,:));
            if nnz(ismember(w,[saturdayArray sundayArray]))>=1
                passed=1;
            else
                passed=0;
                break
            end
            
            if nnz(ismember(w,[mondayArray fridayArray]))>=1 % minimum 1 shifts on monday or friday
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
            
        end
        
        if passed
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
            case 2 % the one who wants to have the shift takes it
                shiftStructNode2 = shiftStructNode1;
                shiftStructNode2.requiredShiftArray(nonZeroArray(i))= shiftStructNode1.requiredShiftArray(nonZeroArray(i))-1;
                shiftStructNode2.doctorMatrix(:,iDay) = 0;
                shiftStructNode2.doctorMatrix(nonZeroArray(i),iDay) = 1;
                shiftStructNode2.day = iDay + 1;
                shiftStructStack = {shiftStructStack{:} shiftStructNode2};
                break
                
                %%  shiftStructNode.doctorMatrix(nonZeroArray(i),iDay) = nonZeroArray(i)-1;
                
            case 0    % aka the doctor is available on the given day
                if iDay>1 & iDay<nDay
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1) & (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                        shiftStructNode2 = shiftStructNode1;
                        shiftStructNode2.requiredShiftArray(nonZeroArray(i))= shiftStructNode1.requiredShiftArray(nonZeroArray(i))-1;
                        shiftStructNode2.doctorMatrix(:,iDay) = 0;
                        shiftStructNode2.doctorMatrix(nonZeroArray(i),iDay) = 1;
                        shiftStructNode2.day = iDay + 1;
                        shiftStructStack = {shiftStructStack{:} shiftStructNode2};
                    else
                        continue
                    end
                end
                if iDay==1
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay+1) ~= 2)
                        shiftStructNode2 = shiftStructNode1;
                        shiftStructNode2.requiredShiftArray(nonZeroArray(i))= shiftStructNode1.requiredShiftArray(nonZeroArray(i))-1;
                        shiftStructNode2.doctorMatrix(:,iDay) = 0;
                        shiftStructNode2.doctorMatrix(nonZeroArray(i),iDay) = 1;
                        shiftStructNode2.day = iDay + 1;
                        shiftStructStack = {shiftStructStack{:} shiftStructNode2};
                    else 
                        continue
                    end
                end
                
                if iDay==nDay
                    if (shiftStructNode1.doctorMatrix(nonZeroArray(i),iDay-1) ~= 1)
                        shiftStructNode2 = shiftStructNode1;
                        shiftStructNode2.requiredShiftArray(nonZeroArray(i))= shiftStructNode1.requiredShiftArray(nonZeroArray(i))-1;
                        shiftStructNode2.doctorMatrix(:,iDay) = 0;
                        shiftStructNode2.doctorMatrix(nonZeroArray(i),iDay) = 1;
                        shiftStructNode2.day = iDay + 1;
                        shiftStructStack = {shiftStructStack{:} shiftStructNode2};
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

fclose(fid)


function shiftStructStack = nodeStep(shiftStructNodeStc,shiftStructNodeTmp,nonZeroArray,iDay)
    shiftStructNodeTmp.requiredShiftArray(nonZeroArray(i))= shiftStructNodeTmp.requiredShiftArray(nonZeroArray(i))-1;
    shiftStructNodeTmp.doctorMatrix(:,iDay) = 0;
    shiftStructNodeTmp.doctorMatrix(nonZeroArray(i),iDay) = 1;
    shiftStructNodeTmp.day = iDay + 1;
    shiftStructStack = {shiftStructNodeStc{:} shiftStructNodeTmp};
end