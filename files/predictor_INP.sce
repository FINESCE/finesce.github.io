//Copyright [2015] [FINESCE Consortium]
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

//Developped by: José Sanchez Torres
//Last version : 02/03/2015


function MAPEval = MAPE(xreal, xpred)
    xrn = length (xreal);
    xpn = length (xpred);
    rnmin=min(abs(xreal));
    if xrn == xpn & rnmin>0 then
        MAPEval=100*sum(abs((xreal-xpred)./xreal))/xrn;
    elseif rnmin == 0
        for i = 1:xrn do
            if xreal(i)==0 then
                xreal(i)=0.001;
            end
        end
        MAPEval=100*sum(abs((xreal-xpred)./xreal))/xrn;
    else
        MAPEval=-1;
    end
endfunction

function RMSEval = RMSE(xreal, xpred)
    xrn = length (xreal);
    xpn = length (xpred);
    if xrn == xpn then
        RMSEval = sqrt(sum((xpred-xreal).^2)./xrn);
    else
        RMSEval=-1;
    end
endfunction

function MAEval = MAE(xreal, xpred)
    xrn = length (xreal);
    xpn = length (xpred);
    rnmin=min(abs(xreal));
    if xrn == xpn & rnmin>0 then
        MAEval=100*sum(abs((xreal-xpred)./xreal));
    elseif rnmin == 0
        for i = 1:xrn do
            if xreal(i)==0 then
                xreal(i)=0.001;
            end
        end
        MAEval=100*sum(abs((xreal-xpred)./xreal));
    else
        MAEval=-1;
    end
endfunction

function [oldEnergy, oldTraining] = getOldEnergy(periodTime,endDate,oldEnergy1h)
    //periodTime    1 : 1 week
    //              2 : 2 week
    //              3 : 1 day
    //              4 ; 2 days
    //..............5 : 1 month
    //..............6 : 6 months
    //..............7 : 1 year
    
    //endDate : Current Date (string timestamp)
    //oldEnergy1h : Matrix with all Energies 1h timestamped
    
    //This function should create a Matrix with the Old Energy values for the client in a period of time 'periodTime'
    
    //In the oldEnergy1h it is included the old Temperature, week and other values, it is for simplicity I should give a maximum of data just in case user or predictor needs
    if periodTime == 1 then
        steps = 24 * 7; //one week - every day 24h
    elseif periodTime == 2 then
        steps = 24 * 7 * 2; //two weeks - every day 24h
    elseif periodTime == 3 then
        steps = 24; //one day 24h
    elseif periodTime == 4 then
        steps = 24 * 2; //two days - every day 24h
    elseif periodTime == 5 then
        steps = 24 * 7 * 4;//four weeks
    elseif periodTime == 6 then
        steps = 24 * 7 * 4 * 6;//24 weeks
    elseif periodTime == 7 then
        steps = 24 * 7 * 4 * 53;
    else
        steps = 24 * 2; //Default value 2 days - every day 24h
    end
    
    currentTime = evstr(endDate);
    timeVector = getdate(currentTime);
    currentWeek = timeVector(3);
    currentDayofWeek = timeVector(5);
    currentHour = timeVector(7);
    position = (currentWeek-1)*168+(currentDayofWeek-1)*24+currentHour+1;
    
    //Once we know the position on the matrix, we have to check the steps backwards. That means, if position is 10, one week means 378 positions back, so we need to take this information from the end of the matrix
    
    poscheck = position - steps;
    if poscheck < 1 then
        if position == 1 then
            posto2 = (53*24*7)+poscheck;
            posfrom2 = 53*24*7; //53 weeks, 24 hours, 7 days
            oldEnergy = oldEnergy1h(posfrom2:posto2,9:$);
            oldTraining = oldEnergy1h(posfrom2:posto2,1:8)
        else
            posfrom1 = 1;
            posto1 = position -1;
            posfrom2 = (53*24*7);
            posto2 = 53*24*7+poscheck; //53 weeks, 24 hours, 7 days
            oldEnergy = [oldEnergy1h(posfrom2:posto2,9:$);oldEnergy1h(posfrom1:posto1,9:$)];
            oldTraining = [oldEnergy1h(posfrom2:posto2,1:8);oldEnergy1h(posfrom1:posto1,1:8)];
        end
    else
        posto1 = position -1;
        posfrom1 = poscheck;
        oldEnergy = oldEnergy1h(posfrom1:posto1,9:$);
        oldTraining = oldEnergy1h(posfrom1:posto1,1:8);
    end
endfunction

function [prediction]=SVM_predictor(trainingEnergy, trainingWeather, currentEnergy, currentTemperature,testTime,parameters)
    //The output should be the Power, even if it is predicting the Energy
    
    testlabel = zeros(24,1);

    trainingWeather = [trainingWeather; currentTemperature];
    trainingEnergy =  [trainingEnergy; currentEnergy];

    prediction = zeros(1,20);
    trainingValues = trainingWeather; //The same training values for all meters
     
     s = parameters(1);
     t = parameters(2); 
    
    //Predict AP
     powerType = 0;
     c = parameters((powerType*3)+3);
     g = parameters((powerType*3)+4);
     p = parameters((powerType*3)+5);
     trainParam = '-s '+string(s)+' -t '+string(t)+ '-c '+string(c)+' -g '+string(g)+' -p '+string(p);
    
    
    trainingObjective = trainingEnergy(:,1); //Ap
    
    [maxScale,minScale,trainingScaledEnergy]= scale(trainingObjective);
    
    powerModel = libsvm_svmtrain(trainingScaledEnergy,trainingValues,trainParam);
    
    [predictions,Accuracy,Probability]= libsvm_svmpredict(testlabel,testTime,powerModel);
    
    Ap = predictions([1, 3, 6, 12, 24]);
    Ap = unScale(Ap,maxScale,minScale);
        
    //Predict Al
     powerType = 3;
     c = parameters((powerType*3)+3);
     g = parameters((powerType*3)+4);
     p = parameters((powerType*3)+5);
     trainParam = '-s '+string(s)+' -t '+string(t)+ '-c '+string(c)+' -g '+string(g)+' -p '+string(p);
     
    trainingObjective = trainingEnergy(:,4); //Al
    [maxScale,minScale,trainingScaledEnergy]= scale(trainingObjective);
    powerModel = libsvm_svmtrain(trainingScaledEnergy,trainingValues,trainParam);
    [predictions,Accuracy,Probability]= libsvm_svmpredict(testlabel,testTime,powerModel);
    Al = predictions([1, 3, 6, 12, 24]);
    Al = unScale(Al,maxScale,minScale);  

    //Predict Q1
     powerType = 1;
     c = parameters((powerType*3)+3);
     g = parameters((powerType*3)+4);
     p = parameters((powerType*3)+5);
     trainParam = '-s '+string(s)+' -t '+string(t)+ '-c '+string(c)+' -g '+string(g)+' -p '+string(p);
     
    trainingObjective = trainingEnergy(:,2); //Q1
    [maxScale,minScale,trainingScaledEnergy]= scale(trainingObjective);
    powerModel = libsvm_svmtrain(trainingScaledEnergy,trainingValues,trainParam);
    [predictions,Accuracy,Probability]= libsvm_svmpredict(testlabel,testTime,powerModel);
    Q1 = predictions([1, 3, 6, 12, 24]);
    Q1 = unScale(Q1,maxScale,minScale);  

    //Predict Q4
     powerType = 2;
     c = parameters((powerType*3)+3);
     g = parameters((powerType*3)+4);
     p = parameters((powerType*3)+5);
     trainParam = '-s '+string(s)+' -t '+string(t)+ '-c '+string(c)+' -g '+string(g)+' -p '+string(p);
     
    trainingObjective = trainingEnergy(:,3); //Q4
    [maxScale,minScale,trainingScaledEnergy]= scale(trainingObjective);
    powerModel = libsvm_svmtrain(trainingScaledEnergy,trainingValues,trainParam);
    [predictions,Accuracy,Probability]= libsvm_svmpredict(testlabel,testTime,powerModel);
    Q4 = predictions([1, 3, 6, 12, 24]);
    Q4 = unScale(Q4,maxScale,minScale);  
    
    prediction = [Al(1) Q4(1) Ap(1) Q1(1) Al(2) Q4(2) Ap(2) Q1(2) Al(3) Q4(2) Ap(3) Q1(3) Al(4) Q4(4) Ap(4) Q1(4) Al(5) Q4(5) Ap(5) Q1(5)];
endfunction

//*************************************************************************
//*************************************************************************
//*****************P R E D I C T O R - M A I N F I L E*********************
//*************************************************************************
//*************************************************************************

function [predP]=predictor_INP(loadNow, weatherNow,recentHistory, codes,e2p_conversion)
    //loadNow : Readings from meters
    //weatherNow : Readings from file
    //oldPower : Not necessary
    //oldWeather : Not necessary
    //Codes : meter codes
    //e2p_conversion
    
    predP  = zeros(loadNow.n,20);

    //AP -> Index
    //Q1 -> Index + 1
    //Q4 -> Index + 2
    //Al -> index + 3
    meters_old = [9, 17,41,25,73,69,29,57,33,21,37,49,45,61,65, 1,13, 5,53]; //Vector to undestand the history file input
                //01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19
    
    //*************************************************************************
    // PREDICTION PARAMETERS
    //*************************************************************************
    //                s     t       c_Ap    g_Ap    p_Ap    c_Q1    g_Q1    p_Q1    c_Q4    g_Q4    p_Q1    c_Al    g_Al    p_Al
    parameters_svm = [3     2       1       1e-6    1e-5    1       1e-6    1e-5    1       1e-2    1e-1    1       0.01    0.01; // 01
                      3     2       1       1e-5    1e-5    1       1e-3    1e-6    1       1e-4    1e-6    1       1e-5    1e-6; // 02
                      3     2       1       1e-6    1e-6    1       1e-5    1e-5    1       1e-3    1e-5    1       0.005   0.01; // 03
                      3     2       1       1e-5    1e-3    1       1e-3    1e-5    1       1e-4    1e-1    1       0.005   0.01; // 04
                      3     2       1       1e-6    1e-6    1       1e-1    1e-5    0.1     1e-3    1e-6    1       0.005   0.01; // 05
                      3     2       1       1e-2    1e-5    1       1e-4    1e-5    1       1e-1    1e-4    1       0.005   0.01; // 06
                      3     2       1       1e-6    1e-5    1       1e-3    1e-5    1       1e-4    1e-5    1       0.005   0.01; // 07
                      3     2       1       1e-5    1e-6    1       1e-5    1e-6    1       1e-3    1e-1    1       0.005   0.01; // 08
                      3     2       1       1e-6    1e-6    1       1e-6    1e-6    1       1e-4    1e-1    1       0.005   0.01; // 09
                      3     2       1       1e-5    1e-5    1       1e-4    1e-4    1       1e-1    1e-6    1       0.005   0.01; // 10
                      3     2       1       1e-6    1e-5    1       1e-4    1e-5    0.01    1e-1    1e-5    1       0.005   0.01; // 11
                      3     2       1       1e-4    1e-6    1       1e-5    1e-6    1       1e-3    1e-5    1       0.005   0.01; // 12
                      3     2       1       1e-5    1e-5    1       1e-3    1e-6    0.1     1e-5    1e-5    1       0.005   0.01; // 13
                      3     2       1       1e-6    1e-6    1       1e-4    1e-4    1       1e-6    1e-4    1       0.005   0.01; // 14
                      3     2       1       1e-4    1e-5    1       1e-5    1e-5    1       1e-5    1e-6    1       0.005   0.01; // 15
                      3     2       1       1e-2    1e-6    1       1e-4    1e-4    1       1e-4    1e-1    1       1e-6    1e-6; // 16
                      3     2       1       1e-2    1e-5    1       1e-1    1e-4    1       1e-1    1e-5    1       0.005   0.01; // 17
                      3     2       0.1     1e-6    1e-5    0.1     1e-4    1e-4    1       1e-4    1e-1    1       0.005   0.01; // 18
                      3     2       1       1e-2    1e-4    1       1e-6    1e-6    1       1e-4    1e-1    1       0.005   0.01];// 19
    
    
    
    //****************************************************************
    // PREPARING DATA FOR TRAINING
    oldEnergy1h = read_csv('history_INP.csv',',','decimal','double');
    [oldEnergyPeriod, oldTrainingData] = getOldEnergy(7,loadNow.time,oldEnergy1h);

    //write_csv(string(oldEnergyPeriod),'trainingEnergy.csv')

    //oldEnergyPeriod is a matrix with the number of data needed to predict (1 week, 1 day, 2 days and 2 weeks)
    //oldTrainingPeriod is a matrix with the training information in the chosen period
    
    //Now the training data must be scaled
    //I added some MAX and mins
    
    hour = oldTrainingData(:,1);
    hour = [hour;23;0]; //MAX 23 - min 0
    hour = libsvm_scale(hour,[0,1]);
    hour($)=[]; hour($)=[];
    oldTrainingData(:,1)=hour;
    clear hour
    
    week = oldTrainingData(:,3);
    week = [week; 1; 53];//MAX 53 - min 1
    week = libsvm_scale(week,[0,1]);
    week($)=[]; week($)=[];
    oldTrainingData(:,3)=week;
    clear week
    
    dayofweek = oldTrainingData(:,4);
    dayofweek = [dayofweek;1;7]; //MAX 7 - min 1
    dayofweek = libsvm_scale(dayofweek,[0,1]);
    dayofweek($)=[]; dayofweek($)=[];
    oldTrainingData(:,4)=dayofweek;
    clear dayofweek
    
    temperature = oldTrainingData(:,8);
    temperature = [temperature;-10;40]; //MAX 40, min -10
    temperature = libsvm_scale(temperature,[-1,1]);
    temperature($)=[]; temperature($)=[];
    oldTrainingData(:,8) = temperature;
    clear temperature
    
    oldTrainingData(:,2)=[];
    
    //Prepare recent data
    if ~isempty(recentHistory) then
        hour = recentHistory(:,1);
        hour = [hour;23;0]; //MAX 23 - min 0
        hour = libsvm_scale(hour,[0,1]);
        hour($)=[]; hour($)=[];
        recentHistory(:,1)=hour;
        clear hour
        
        week = recentHistory(:,3);
        week = [week; 1; 53];//MAX 53 - min 1
        week = libsvm_scale(week,[0,1]);
        week($)=[]; week($)=[];
        recentHistory(:,3)=week;
        clear week
    
        dayofweek = recentHistory(:,4);
        dayofweek = [dayofweek;1;7]; //MAX 7 - min 1
        dayofweek = libsvm_scale(dayofweek,[0,1]);
        dayofweek($)=[]; dayofweek($)=[];
        recentHistory(:,4)=dayofweek;
        clear dayofweek
    
        temperature = recentHistory(:,8);
        temperature = [temperature;-10;40]; //MAX 40, min -10
        temperature = libsvm_scale(temperature,[-1,1]);
        temperature($)=[]; temperature($)=[];
        recentHistory(:,8) = temperature;
        clear temperature
        recentEnergy = recentHistory(:,8:$);
        recentTraining = recentHistory(:,1:7);
    else
        recentEnergy = [];
        recentTraining = [];
    end
    
    //****************************************************************    
    // PREPARING DATA FOR PREDICTING
    [timeN] = getNowFuture(loadNow.time);
    
    hour = timeN(:,1);
    hour = [hour;23;0]; //MAX 23 - min 0
    hour = libsvm_scale(hour,[0,1]);

    hour($)=[]; hour($)=[];
    timeN(:,1)=hour;
    clear hour
    
    week = timeN(:,2);
    week = [week; 1; 53];//MAX 53 - min 1
    week = libsvm_scale(week,[0,1]);
    week($)=[]; week($)=[];
    timeN(:,2)=week;
    clear week
    
    dayofweek = timeN(:,3);
    dayofweek = [dayofweek;1;7]; //MAX 7 - min 1
    dayofweek = libsvm_scale(dayofweek,[0,1]);
    dayofweek($)=[]; dayofweek($)=[];
    timeN(:,3)=dayofweek;
    clear dayofweek
    
    //TO MODIFY BECAUSE IT IS NOT ON THIS MATRIX
    temperature = weatherNow.thfut;
    temperature = [temperature;-10;40]; //MAX 40, min -10
    temperature = libsvm_scale(temperature,[-1,1]);
    temperature($)=[]; temperature($)=[];
    timeN = [timeN, temperature];
    clear temperature    
    //timeN is a matrix

    for i = 1:loadNow.n do
      idx = find(codes(:,1)==loadNow.meter(i));
      if ~isempty(idx) then
          user_number=evstr(codes(idx,8));
          oldEnergyValues = oldEnergyPeriod(:,meters_old(user_number):meters_old(user_number)+3);
          parameters = parameters_svm(user_number,:);
          if ~isempty(recentEnergy) then
              predP(i,:)=SVM_predictor(oldEnergyValues, oldTrainingData, recentEnergy(:,meters_old(user_number):meters_old(user_number)+3), recentTraining,timeN,parameters)
          else
              predP(i,:)=SVM_predictor(oldEnergyValues, oldTrainingData, recentEnergy, recentTraining,timeN,parameters)
          end
      else
          predP(i,:)=zeros(1,4*5);
      end
end

predP = predP * e2p_conversion; //Conversion energy to power
endfunction
