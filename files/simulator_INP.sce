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
//Last version : 06/07/2015

function output = updateDataFile(newData, filename, maxData)
    //This function updates a csv file "filename", inserting at the end the "newData", it has to control a maximum of rows of "maxData"
    //INPUTS:
    //          newData : The new row we want to insert
    //          filename : name of the csv file
    //          maxData : Maximum number of allowed rows
    //OUTPUTS:
    //          0 : There was a problem
    //..........1 : No problems!
    output = 1;
    // 1. VERIFY THAT THE FILE ACTUALLY EXISTS
    [xLoad, ierrLoad] = fileinfo(filename);
    
    if ierrLoad ~= -1 then
        oldData = read_csv(filename,',','decimal','double');
    else
        oldData = newData;
    end
    // 2. VERIFY newData and the matrix from the file have the same number of columns
    // 2.1. Insert new Data on the matrix
    if ~isempty(oldData) then
        if oldData($,1) ~= newData (1,1) then
            [rows, columns]= size(oldData);
            newcolumns = length(newData);
            if columns == newcolumns then
                oldData = [oldData;newData];
            else
                output = 0;
            end
        end
    end
    // 3. Verify the number of rows<= maxData
    // 3.1 Remove first row if rows>maxData
    [newrows, newcolumns]= size(oldData);
    while (newrows > maxData) do
        oldData(1,:)=[];
        [newrows, newcolumns]= size(oldData);
    end
    // 5. Save the new matrix on the file
    write_csv(oldData,filename,',')
endfunction

function [valeur, newValues]= fileCheck(typeFile, values, time)
    //INPUTS :
    //typeFile 1 if loadsFile, 2 if weatherFile
    //values is the matrix with the former loads
    //time is the time of the loadsFile in order to compare with the weatherFile
    //OUTPUTS:
    // valeur = 0 if is OK
    // valeur = 1 if loadsFile has different times
    // valeur = 2 if weather does not match with loadsFile
    // valeur = 3 if values is an empty matrix
    // valeur = 4 if there is a new "values" matrix
    newValues = [];
    valeur = 0;
    if typeFile == 1 then //loadsFile
        if isempty(values) then
            valeur = 3;
        elseif (length(unique(values(:,1)))) > 1 then// VERIFY THE COLUMN NUMBER              
            rep = unique(values(:,1));
            nRep = length(rep);
            maxPos = [];
            for i = 1:nRep do
                [pos,Y]=find(values(:,1)==rep(i));
                if length(pos)>length(maxPos) then
                    maxPos = pos;
                end 
            end
            nValues = length(values(:,1));
            if nValues/2 < length(maxPos) then
                newValues = maxPos;
                valeur = 4;
                disp(' WARNING: Some data from meters are not synchronized');
            else 
                valeur = 1;
                disp(' ERROR: Data from meters are not synchronized')   
            end
        else
            newValues = values;
        end
    elseif typeFile ==2 & values(1,1) ~= time then //weatherFile VERIFY THE COLUMN NUMBER
            valeur = 2;
            disp(' ERROR: Weather data is not synchronized with meters data')
    end
    
endfunction
function [power, weather, err]=load_data(filepath,e2p_conversion)
    err = 0;
    inputfile_load = strcat([filepath,"/loadData.csv"]);
    inputfile_weather = strcat([filepath,"/weatherData.csv"]);
    [xLoad, ierrLoad] = fileinfo(inputfile_load);
    [xWeather, ierrWeather] = fileinfo(inputfile_weather);
    if ierrLoad ~= -1 & ierrWeather ~= -1 then
            NETWORKvalues = read_csv(inputfile_load,';');
            testValues = NETWORKvalues;
            testValues(:,1) = [];
            [ierrload, newPos] = fileCheck(1, evstr(testValues),0);
            if ierrload == 0 | ierrload == 4 then
                if ierrload == 4
                    NETWORKvalues = NETWORKvalues(newPos,:);
                end
                AP = NETWORKvalues(:,4);
                Q1 = NETWORKvalues(:,5);
                Q4 = NETWORKvalues(:,6);
                Al = NETWORKvalues(:,7);
                Pnetwork = (evstr(AP)-evstr(Al)).*e2p_conversion;
                Qnetwork = (evstr(Q1)-evstr(Q4)).*e2p_conversion;
                power = struct('timeR',NETWORKvalues(:,1),'time',NETWORKvalues(1,2),'meter',NETWORKvalues(:,3),'Q',Qnetwork,'P',Pnetwork,'n',length(Pnetwork),'energy',NETWORKvalues(:,3:7));
                NETWORKweather = read_csv(inputfile_weather,';');
                testValues = NETWORKweather; //MODIFY HERE
                testValues(1)=[];
                [ierrWeather newtestValues] = fileCheck(2, evstr(testValues),evstr(power.time));
                if ierrWeather == 0 then
                    futTemp = [evstr(NETWORKweather(9));evstr(NETWORKweather(13));evstr(NETWORKweather(17));evstr(NETWORKweather(21));evstr(NETWORKweather(25));evstr(NETWORKweather(29));evstr(NETWORKweather(33));evstr(NETWORKweather(37));evstr(NETWORKweather(41));evstr(NETWORKweather(45));evstr(NETWORKweather(49));evstr(NETWORKweather(53));evstr(NETWORKweather(57));evstr(NETWORKweather(61));evstr(NETWORKweather(65));evstr(NETWORKweather(69));evstr(NETWORKweather(73));evstr(NETWORKweather(77));evstr(NETWORKweather(81));evstr(NETWORKweather(85));evstr(NETWORKweather(89));evstr(NETWORKweather(93));evstr(NETWORKweather(97));evstr(NETWORKweather(101))];
                    weather = struct('timeR',NETWORKweather(1),'time',NETWORKweather(2),'sunrise',NETWORKweather(3),'currentTemp',evstr(NETWORKweather(7)),'sunset',NETWORKweather(4),'thfut',futTemp);
                else
                    err = 1;
                    power = [];
                    weather = [];
                    [report,errfile]=mopen('Report_simulator.txt','a+');
                    mputl('ERROR: Weather data is not synchronized with meters data',report); 
                    mclose(report);
                end
            else

                power = [];
                weather = [];
                [report,errfile]=mopen('Report_simulator.txt','a+');
                mputl('ERROR: Data from meters are not synchronized',report); 
                mclose(report);
                err = 1;
            end
       else
            power = [];
            weather = [];
            disp(' ERROR: No input ')
            [report,errfile]=mopen('Report_simulator.txt','a+');
            mputl('No input files',report); 
            mclose(report);
            err = 1;
    end
endfunction

function [P, Q]=unknownMetersInformation(posProfile,id_meter,data_csv)
    //This function returns the Active and Reactive power (the load) of the uninstalled meter
    //The netProfile matrix is historical data from the physical system for one year consumption
    //This function adds a white noise in order to simulate the variations during the year
    noisegen(1.0,1,0.01);
    noiseLoad = 1-Noise(1); //This is a percentage value [0...1] around 1
    pProfile = evstr(data_csv(posProfile,(id_meter*2)-1));
    qProfile = evstr(data_csv(posProfile,(id_meter*2)));
    P = noiseLoad * pProfile;
    Q = noiseLoad * qProfile;
endfunction

function minute = minuteDay(minuteComplete)
     if minuteComplete>7 & minuteComplete<=22 then
         minute = 1;
     elseif minuteComplete>22 & minuteComplete<=37 then
         minute = 2;
     elseif minuteComplete>37 & minuteComplete<=52 then
         minute = 3;
     elseif minuteComplete>=0 & minuteComplete<=7 then
         minute = 0;
     else
         minute = 4; //Jumps to the next hour
     end
endfunction

function position_profile = getPositionProfile(time)
     timeReal = getdate(evstr(time));
     minute = minuteDay(timeReal(8));     
     position_profile = (timeReal(3)-1)*672 + (timeReal(5)-1)*96 + (timeReal(7)*4) + minute + 1;
endfunction

function [timenh] = getNowFuture(time)
    currentTime = evstr(time);
    time1h  = currentTime + (60*60);
    time2h  = currentTime + (60*60*2);
    time3h  = currentTime + (60*60*3);
    time4h  = currentTime + (60*60*4);
    time5h  = currentTime + (60*60*5);
    time6h  = currentTime + (60*60*6);
    time12h = currentTime + (60*60*12);
    time24h = currentTime + (60*60*24);
    time1hVector = getdate(time1h);
    time3hVector = getdate(time3h);
    time6hVector = getdate(time6h);
    time12hVector = getdate(time12h);
    time24hVector = getdate(time24h);
     
     timenh = zeros(24,6);
     for i=1:24 do
         timeih = currentTime + (60*60*i);
         timevector = getdate(timeih);
         timenh(i,2) = timevector(3); //WEEK
         timenh(i,3) = timevector(5); //DAY OF WEEK
         timenh(i,1) = timevector(7); //HOUR
         //SEASON ; Winter -> 0     : Week
         //         Spring -> 0.33
         //         Summer -> 0.66
         //         Fall -> 1
         if timevector(3)>13 & timevector(3)<26 then 
             timenh(i,6) = 0.33; //Season
         elseif timevector(3)>25 & timevector(3)<40 then
             timenh(i,6) = 0.66; //Season
         elseif timevector(3)>39 & timevector(3)<52 then
             timenh(i,6) = 1; //Season
         else
             timenh(i,6) = 0;
         end
         
         if timenh(i,3)>7 & timenh(i,3)<20 then //AM/PM
             timenh(i,4) = 1;
         else
             timenh(i,4) = 0;
         end
         if timenh(i,2)>1 & timenh(i,2)<7 then //WEEKDAY?
             timenh(i,5) = 1;
         else
             timenh(i,5) = 0;
         end
     end
endfunction

function [maxVal, minVal, result]= scale(matrixValues)
    maxVal = max(matrixValues);
    minVal = min(matrixValues);
    nMatrix = length(matrixValues);
    if maxVal==0 & minVal==0 then
        result = zeros(nMatrix,1);
    else
        result = (2 * (matrixValues-minVal)./(maxVal-minVal)) - 1; 
    end
endfunction

function result= unScale(matrixValues,maxVal,minVal)
    if maxVal==0 & minVal==0 then
        nMatrix = length(matrixValues);
        result = zeros(nMatrix,1);
    else
        result = (matrixValues.*(maxVal-minVal)+maxVal+minVal)./2;        
    end
endfunction

function result= isOclock(time)
    currentTime = evstr(time);
    timevector = getdate(currentTime);
    if timevector(8)>52 | timevector(8)<7  then
        result = 1;
    else
        result = 0;
    end
endfunction

function trainingTime = getDataInfo(time)
    currentTime = evstr(time);
    timevector = getdate(currentTime);
    week = timevector(3); //WEEK
    dayofweek = timevector(5); //DAY OF WEEK
    hour = timevector(7); //HOUR
    //SEASON ; Winter -> 0     : Week
    //         Spring -> 0.33
    //         Summer -> 0.66
    //         Fall -> 1
    if timevector(3)>13 & timevector(3)<26 then 
        season = 0.33; //Season
    elseif timevector(3)>25 & timevector(3)<40 then
        season = 0.66; //Season
    elseif timevector(3)>39 & timevector(3)<52 then
        season = 1; //Season
    else
        season = 0;
    end
         
    if hour>7 & hour<20 then //AM/PM
        AmPm = 1;
    else
        AmPm = 0;
    end
    if dayofweek>1 & dayofweek<7 then //WEEKDAY?
       weekend = 1;
    else
       weekend = 0;
    end

    trainingTime =  [hour, week, dayofweek, AmPm, weekend, season];
endfunction

function trainingEnergy = organizeEnergyData(energyValues, codes)
    meters_old = [9, 17,41,25,73,69,29,57,33,21,37,49,45,61,65, 1,13, 5,53];
    [rows, colums] = size(codes);
    trainingEnergy = zeros(1,4*19);
    for i = 1:rows do
        meterID = codes(i,1);
        [posEnergy,Y]=find(energyValues(:,1)==codes(i,1));
        if ~isempty(posEnergy) then
            position = meters_old(evstr(codes(i,8)));
            trainingEnergy(1,position)=evstr(energyValues(posEnergy,2));
            trainingEnergy(1,position+1)=evstr(energyValues(posEnergy,2));
            trainingEnergy(1,position+2)=evstr(energyValues(posEnergy,3));
            trainingEnergy(1,position+3)=evstr(energyValues(posEnergy,4));
        end
    end
endfunction

function simulator_INP(windowstime,yearinit,monthinit,dayinit,hourinit,minuteinit, typepred)

mode(0)
format(15); // To avoid Scientific Notation
ieee(2);

exec('simulator_properties.sce',-1)
[filepath,filepath_input,filepath_output]=simulator_properties();

exec('loadFlow_INP.sce',-1);    // Load Flow algorithm
exec('customerData.sce',-1);   // System data

if typepred == 1 then
    exec('predictor_INP.sce',-1);
else
    typepred = 1; //For the moment only one type of predictor
    exec('predictor_INP.sce',-1);
end

[report,err]=mopen('Report_simulator.txt','w+');
mputl('Copyright (C) 2013-2015 Grenoble INP - G2ELAB',report);
mputl('SIMULATION REPORT',report);
mputl(string(yearinit)+'/'+string(monthinit)+'/'+string(dayinit)+' '+string(hourinit)+':'+string(minuteinit),report);
mputl(' ',report);
mclose(report);


// Calculates the coefficient to convert energy to power, if windowstime=900 (15 minutes) e2p_conversion=4
if windowstime > 3600 then
    e2p_conversion = 3600/modulo(windowstime,3600)
else
    e2p_conversion = 3600/windowstime;
end

//Converts the start time on a computer time
tt=datenum(yearinit,monthinit,dayinit,hourinit,minuteinit,00)*24*3600; // Starting point

// Verifies that the simulation start time is AFTER the current time
if tt < now()*24*3600 then
    disp(" ERROR: Initial Time");
    [report,err]=mopen('Report_simulator.txt','a+');
    mputl('ERROR: Initial Time',report);
    mclose(report);
    abort
else
    disp(" INFO: Loading initial files");
end
                   
data_csv=read_csv('loadData_Profil.csv',',');
//oldPower = read_csv('loadData_history.csv',';','decimal','double');
//oldWeather = read_csv('weatherData_history.csv',';','decimal','double');

clc
disp(" INFO: Files loaded");

flagInit = 1;
steps = 1; // To show in the screen the first simulation
firstTime = 1;
errorVal = [];
while steps>0 do
    tn = now();
    if tn*24*3600 >= tt+windowstime | (tn*24*3600 >= tt & flagInit) then
        [report,err]=mopen('Report_simulator.txt','a+');
        mputl('Time '+string(tn*24*3600),report);
        mclose(report);
        if steps == 1 then
            disp(' INFO: Simulation started at time :'+string(tn*24*3600));
            steps = steps+1;
        end
        
        if ~flagInit then
            tt =tt+windowstime;
        else
            flagInit = 0;
        end
        
        // Load the System Data (resistances, configuration, others)        
        [nnodes, d, p0, bus, Rng, Rgg,base,codes_lines_ENG,codes]=customerData();
        p0ini = p0;
        //Load data from meters, it is reading the file from ENG
        [power, weather, err]=load_data(filepath_input,e2p_conversion); //Load data from Meters Information in W and VAR by counter
        
        if err == 0 then
        // PROFILE OF UNINSTALLED METERS 
        // This part can be ommited if all meters are installed
        
        pos_profile = getPositionProfile(power.time);
        
        // END PROFILE OF UNINSTALLED METERS
        
        //We organize the input data for the power flow algorithm
        id_User = [];
        for i = 1:power.n do //This loop is only for known meters
            [pos,Y]=find(codes(:,1)==power.meter(i));
            if ~isempty(pos) then
                id_User = [id_User; codes(pos,9)];
            end
                
            if ~isempty(pos) & length(pos)<2 then
                node=evstr(codes(pos,3));
                if (~strcmp(codes(pos,4),'rst')) & node~=1 then //It is a 3-phase cable  //We ignore the slack node                  
                        node=node-1; //We ignore the slack node
                        //Phase R
                        p0(3*node-2,2) = p0(3*node-2,2)+power.P(i)/(3*base.Sbase*1000); //Active power
                        p0(3*node-2,3) = p0(3*node-2,3)+power.Q(i)/(3*base.Sbase*1000); // Reactive power
                        //Phase S
                        p0(3*node-1,2) = p0(3*node-1,2)+power.P(i)/(3*base.Sbase*1000);
                        p0(3*node-1,3) = p0(3*node-1,3)+power.Q(i)/(3*base.Sbase*1000);
                        //Phase T
                        p0(3*node,2) = p0(3*node,2)+power.P(i)/(3*base.Sbase*1000);
                        p0(3*node,3) = p0(3*node,3)+power.Q(i)/(3*base.Sbase*1000);    
                elseif (~strcmp(codes(pos,4),'r') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node-2,2) = p0(3*node-2,2)+power.P(i)/(base.Sbase*1000);
                        p0(3*node-2,3) = p0(3*node-2,3)+power.Q(i)/(base.Sbase*1000);
                elseif (~strcmp(codes(pos,4),'s') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node-1,2) = p0(3*node-1,2)+power.P(i)/(base.Sbase*1000);
                        p0(3*node-1,3) = p0(3*node-1,3)+power.Q(i)/(base.Sbase*1000);
                elseif (~strcmp(codes(pos,4),'t') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node,2) = p0(3*node,2)+power.P(i)/(base.Sbase*1000);
                        p0(3*node,3) = p0(3*node,3)+power.Q(i)/(base.Sbase*1000);
                end
            else 
                if strcmp(power.meter(i),'0512690040076') | strcmp(power.meter(i),'5555555555555')//We don't take into account the transformer meter
                   [report,err]=mopen('Report_simulator.txt','a+');
                   disp(' WARNING: Unknown meter ID :'+ power.meter(i));
                   mputl('WARNING: Unknown meter ID :'+ power.meter(i),report);
                   mclose(report);
                end
            end
        end

        // Now I will verify if there are meters without information - i.e. without new code
        guessed = [];
        [ncodes temp]=size(codes);
        for i = 1:ncodes do
            if evstr(codes(i,1)) == 0 then //If the node doesn't have new code
                [pP, pQ] = unknownMetersInformation(evstr(pos_profile),evstr(codes(i,8)),data_csv);
                
                node = evstr(codes(i,3))-1;
                guessed = [guessed;codes(i,8) string(pP) string(pQ)];
                if (~strcmp(codes(i,4),'rst')) then //It is a 3-phase cable
                            id_node = 3*node-2;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);
                            //Phase S
                            id_node = id_node + 1;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);
                            //Phase T
                            id_node = id_node + 1;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);  
                elseif (~strcmp(codes(i,4),'r')) //It is a 1-phase cable
                            id_node = 3*node-2;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);  
                elseif (~strcmp(codes(i,4),'s')) //It is a 1-phase cable
                            id_node = 3*node-1;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);     
                elseif (~strcmp(codes(i,4),'t')) //It is a 1-phase cable   
                            id_node = 3*node;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);                            
                end;
            end;
        end
        
        p0(:,1)=(1:(nnodes-1)*3)';

        //Load Flow
        [noeuds,lignes,V_bus,I_ligne,VoltageDrop,losses_ligne] = loadFlow_INP(d,p0,bus,Rng,Rgg,base);
        
        // UPLOAD DATA TO THE CSV FILES
        //FILE 1
        time_sim=[];
        lines_ENG = [];
        for k=1:max(lignes) do
            time_sim = [time_sim;power.time];
            lines_ENG=[lines_ENG; codes_lines_ENG(k)];
        end;
        VD = round(VoltageDrop*10^3)/10^3; 
        LL = round(losses_ligne*10^3)/10^3; 
        file1 = string([VD LL]);
        //Date | Line number | Voltage Drop | losses_ligne
        outputfile1 = strcat([filepath_output,"powerLosses_VoltageDrops.csv"]);
        
        // I HAVE TO CHOOSE:
        //    1st TIME -> Prediction with old values
        //             -> Save energy and weather values
        //    2nd TIME -> Save energy and weather values
        //    Nnd TIME -> If it is o'clock time -> Prediction!
        
        if firstTime then
            firsTime = 0;
            flagPrediction = 1;
            //predict with history values
            //Save former values
            trainingTime = getDataInfo(power.time);
            trainingTemperature = weather.currentTemp;
            trainingEnergy = organizeEnergyData(power.energy, codes);
            
            newData = [trainingTime, trainingTemperature, trainingEnergy];
            errlog=updateDataFile(newData,'onlineHistory.csv',24*7*2); //Two weeks data
            if ~errlog then
                disp('ERROR : Updating online history file');
            end

        elseif isOclock(power.time) then
            //predict with history and last 2 weeks values
            flagPrediction = 2;
            trainingTime = getDataInfo(power.time);
            trainingTemperature = weather.currentTemp;
            trainingEnergy = organizeEnergyData(power.energy,codes);
            newData = [trainingTime, trainintTemperature, trainingEnergy];
            errlog=updateDateFile(newData,'onlineHistory.csv',24*7*2); //Two weeks data
            if ~errlog then
                disp('ERROR : Updating online history file');
            end
        else
            //save values
            //define newData format
            // 1 Hour
            // 2 Week
            // 3 Day of week
            // 4 AM/PM-+
            
            // 5 WeekDat
            // 6 Season
            // 7 Temperature
            // 8 Energy values
            flagPrediction = 3;
            trainingTime = getDataInfo(power.time);
            trainingTemperature = weather.currentTemp;
            trainingEnergy = organizeEnergyData(power.energy,codes);
            newData = [trainingTime, trainintTemperature, trainingEnergy];
            errlog=updateDateFile(newData,'onlineHistory.csv',24*7*2); //Two weeks data
            if ~errlog then
                disp('ERROR : Updating online history file');
            end
        end
        
        //**************************************************************
        //                  PREDICTION ALGORITHM CALL
        //**************************************************************
        
       if flagPrediction == 1 | flagPrediction == 2 then
        
        if flagPrediction == 1 then // It is the first time -> Send empty matrix
            recentHistory = [];
        else //It is the o'clock time 
            //read the onlineHistory
            recentHistory = read_csv('onlineHistory.csv',',','decimal','double');
        end
        
        //FILE 2
        //Date | Meter number | Voltage
        outputfile2 = strcat([filepath_output,"predictions.csv"]);
        n_meters= size(power.meter);
        n_meters = n_meters(1);
        // For the moment zero values ==> NEW FUNCTION WILL FILL THIS DATA
        id_User($+1)='-';
        [predTP]=predictor_INP(power, weather, recentHistory, codes, e2p_conversion);//predTP in Watts
        //predTP => Al Q4 Ap Q1
        meters = power.meter;
        file_2_time = [];
        for jj = 1:n_meters do
            file_2_time = [file_2_time; power.time];
        end
        meters=string(meters);
        id_User=string(id_User);
        predTP2=round(predTP*10^3)/10^3; //To round to only 3-decimal places
        predTP2=string(predTP2);
        outputvalue2 = [file_2_time meters id_User predTP2];
        write_csv(outputvalue2,outputfile2,';');
        
        
        //I predicted a lot of values before -> Now I perform the Load flow for
        //1h 3h 6h 12h 24h
        file1B=[];
        for predLoadFlow = 1:5 do
            p0 = p0ini;
            for i = 1:power.n do //This loop is only for known meters
                [pos,Y]=find(codes(:,1)==power.meter(i));
                IdxpredTP = 3*(predLoadFlow-1)+predLoadFlow;
                if ~isempty(pos) & length(pos)<2 then
                    node=evstr(codes(pos,3));
                    if (~strcmp(codes(pos,4),'rst')) & node~=1 then //It is a 3-phase cable  //We ignore the slack node                  
                        node=node-1; //We ignore the slack node
                        
                        //Phase R
                        p0(3*node-2,2) = p0(3*node-2,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(3*base.Sbase*1000); //Active power
                        p0(3*node-2,3) = p0(3*node-2,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(3*base.Sbase*1000); // Reactive power
                        //Phase S
                        p0(3*node-1,2) = p0(3*node-1,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(3*base.Sbase*1000);
                        p0(3*node-1,3) = p0(3*node-1,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(3*base.Sbase*1000);
                        //Phase T
                        p0(3*node,2) = p0(3*node,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(3*base.Sbase*1000);
                        p0(3*node,3) = p0(3*node,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(3*base.Sbase*1000);    
                    elseif (~strcmp(codes(pos,4),'r') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node-2,2) = p0(3*node-2,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(base.Sbase*1000);
                        p0(3*node-2,3) = p0(3*node-2,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(base.Sbase*1000);
                    elseif (~strcmp(codes(pos,4),'s') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node-1,2) = p0(3*node-1,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(base.Sbase*1000);
                        p0(3*node-1,3) = p0(3*node-1,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(base.Sbase*1000);
                    elseif (~strcmp(codes(pos,4),'t') & node~=1) //It is a 1-phase cable
                        node=node-1;
                        p0(3*node,2) = p0(3*node,2)+(predTP(i,IdxpredTP+2)-predTP(i,IdxpredTP))/(base.Sbase*1000);
                        p0(3*node,3) = p0(3*node,3)+(predTP(i,IdxpredTP+3)-predTP(i,IdxpredTP+1))/(base.Sbase*1000);
                    end
                end
            end // for i = 1:power.n do

            // Now I will verify if there are meters without information - i.e. without new code
            guessed = [];
            [ncodes temp]=size(codes);
            for i = 1:ncodes do
                if evstr(codes(i,1)) == 0 then //If the node doesn't have new code
                    //[pP, pQ] = guessPower(evstr(codes(i,6)),evstr(codes(i,7)),evstr(codes(i,5)),pr_Comm,pr_Ind,pr_Dom,pr_PubLight); //N;N
                    [pP, pQ] = unknownMetersInformation(evstr(pos_profile),evstr(codes(i,8)),data_csv);
                
                    node = evstr(codes(i,3))-1;
                    guessed = [guessed;codes(i,8) string(pP) string(pQ)];
                    if (~strcmp(codes(i,4),'rst')) then //It is a 3-phase cable
                            id_node = 3*node-2;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);
                            //Phase S
                            id_node = id_node + 1;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);
                            //Phase T
                            id_node = id_node + 1;
                            p0(id_node,2) = p0(id_node,2)+pP/(3*base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(3*base.Sbase*1000);  
                    elseif (~strcmp(codes(i,4),'r')) //It is a 1-phase cable
                            id_node = 3*node-2;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);  
                    elseif (~strcmp(codes(i,4),'s')) //It is a 1-phase cable
                            id_node = 3*node-1;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);     
                 elseif (~strcmp(codes(i,4),'t')) //It is a 1-phase cable   
                            id_node = 3*node;
                            p0(id_node,2) = p0(id_node,2)+pP/(base.Sbase*1000);
                            p0(id_node,3) = p0(id_node,3)+pQ/(base.Sbase*1000);                            
                    end;
                end;
            end //i = 1:ncodes do
        
            //Load Flow
            
            p0(:,1)=(1:(nnodes-1)*3)';
            [noeuds,lignes,V_bus,I_ligne,VoltageDrop,losses_ligne] = loadFlow_INP(d,p0,bus,Rng,Rgg,base);
            VD = round(VoltageDrop*10^3)/10^3; 
            LL = round(losses_ligne*10^3)/10^3; 
            file1B = [file1B VD LL];
        end
        
        file1B = string(file1B);
        file1 = [time_sim lines_ENG file1 file1B];
        write_csv(file1,outputfile1,';');
        
        end //Prediction according to flagPrediction
        
        //**************************************************************
        //               END PREDICTION ALGORITHM CALL
        //**************************************************************
        
        [report,err]=mopen('Report_simulator.txt','a+');
        mputl(' ',report);   
        mclose(report);
        end
    end
end
endfunction
