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

//CONFIDENTIAL DATA 

function [nnodes, d, po, bus, Rng, Rgg,base,codes_lines_ENG,codes]=customerData()
// Objective: This function creates a series of matrices that represent the 
// simulated network, in this case the Terni Grid.

mode(0)
Ubase = 400; //[V]
Sbase = 100; //[kVA]
Zbase = Ubase^2/(Sbase*1000);
base = struct('Ubase',Ubase,'Sbase',Sbase,'Zbase',Zbase);
Rd06 =  (18.1/6)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Rd10 =  (18.1/10)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Rd16 =  (18.1/16)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Rd25 =  (18.1/25)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Rd70 =  (18.1/70)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Rd150 = (18.1/150)/Zbase; //[Ohm/km]/Zbase -> [p.u./km]
Xd = 0.1/Zbase; //[Ohm/km]/Zbase -> [p.u.]
Rm = 0;
Xm = 0;
l = [0.001 0.001 0.015 0.058 0.173 0.18 0.004 0.02 0.165 0.016 0.175 0.018 0.135 0.055 0.003 0.002 0.048 0.015];
//Lines data d
//          1: Branch
//          2: From
//          3: To
//          4: Phase (1,2,3,4)
//          5,6,7,8 : Ra, Rb, Rc, Rn [p.u.]
//          9,10,11,12: Xa, Xb, Xc, Xn [p.u.]
//          13: Number of element
d = [       1   1   2   1   0.000879722     Rm              Rm              Rm              0.001122199     Xm          Xm          Xm          1;
            1   1   2   2   Rm              0.000879722     Rm              Rm              Xm              0.001122199 Xm          Xm          2;
            1   1   2   3   Rm              Rm              0.000879722     Rm              Xm              Xm          0.001122199 Xm          3;
            1   1   2   4   Rm              Rm              Rm              0.000879722     Xm              Xm          Xm          0.001122199 4;
            
            2   2   3   1   0.004160        Rm              Rm              Rm              0.015449738     Xm          Xm          Xm          5;
            2   2   3   2   Rm              0.004160        Rm              Rm              Xm              0.015449738 Xm          Xm          6;
            2   2   3   3   Rm              Rm              0.004160        Rm              Xm              Xm          0.015449738 Xm          7;
            2   2   3   4   Rm              Rm              Rm              0.004160        Xm              Xm          Xm          0.015449738 8;
            
            3   3   4   1   Rd25*l(3)       Rm              Rm              Rm              Xd*l(3)         Xm          Xm          Xm          9;
            3   3   4   2   Rm              Rd25*l(3)       Rm              Rm              Xm              Xd*l(3)     Xm          Xm          10;
            3   3   4   3   Rm              Rm              Rd25*l(3)       Rm              Xm              Xm          Xd*l(3)     Xm          11;
            3   3   4   4   Rm              Rm              Rm              Rd25*l(3)       Xm              Xm          Xm          Xd*l(3)     12;
            
            4   3   5   1   Rd16*l(4)       Rm              Rm              Rm              Xd*l(4)         Xm          Xm          Xm          13;
            4   3   5   2   Rm              Rd16*l(4)       Rm              Rm              Xm              Xd*l(4)     Xm          Xm          14;
            4   3   5   3   Rm              Rm              Rd16*l(4)       Rm              Xm              Xm          Xd*l(4)     Xm          15;
            4   3   5   4   Rm              Rm              Rm              Rd16*l(4)       Xm              Xm          Xm          Xd*l(4)     16;
           
            5   3   6   1   Rd25*l(5)       Rm              Rm              Rm              Xd*l(5)         Xm          Xm          Xm          17;
            5   3   6   2   Rm              Rd25*l(5)       Rm              Rm              Xm              Xd*l(5)     Xm          Xm          18;
            5   3   6   3   Rm              Rm              Rd25*l(5)       Rm              Xm              Xm          Xd*l(5)     Xm          19;
            5   3   6   4   Rm              Rm              Rm              Rd25*l(5)       Xm              Xm          Xm          Xd*l(5)     20;
            
            6   3   7   1   Rd25*l(6)       Rm              Rm              Rm              Xd*l(6)         Xm          Xm          Xm          21;
            6   3   7   2   Rm              Rd25*l(6)       Rm              Rm              Xm              Xd*l(6)     Xm          Xm          22;
            6   3   7   3   Rm              Rm              Rd25*l(6)       Rm              Xm              Xm          Xd*l(6)     Xm          23;
            6   3   7   4   Rm              Rm              Rm              Rd25*l(6)       Xm              Xm          Xm          Xd*l(6)     24;
            
            7   7   8   1   Rd10*l(7)       Rm              Rm              Rm              Xd*l(7)         Xm          Xm          Xm          25;
            7   7   8   2   Rm              Rd10*l(7)       Rm              Rm              Xm              Xd*l(7)     Xm          Xm          26;
            7   7   8   3   Rm              Rm              Rd10*l(7)       Rm              Xm              Xm          Xd*l(7)     Xm          27;
            7   7   8   4   Rm              Rm              Rm              Rd10*l(7)       Xm              Xm          Xm          Xd*l(7)     28;
            
            8   8   9   1   Rd06*l(8)       Rm              Rm              Rm              Xd*l(8)         Xm          Xm          Xm          29;
            8   8   9   2   Rm              0               Rm              Rm              Xm              0           Xm          Xm          30;
            8   8   9   3   Rm              Rm              0               Rm              Xm              Xm          0           Xm          31;
            8   8   9   4   Rm              Rm              Rm              Rd06*l(8)       Xm              Xm          Xm          Xd*l(8)     32;            
            
            9   3   10  1   Rd25*l(9)       Rm              Rm              Rm              Xd*l(9)         Xm          Xm          Xm          33;
            9   3   10  2   Rm              Rd25*l(9)       Rm              Rm              Xm              Xd*l(9)     Xm          Xm          34;
            9   3   10  3   Rm              Rm              Rd25*l(9)       Rm              Xm              Xm          Xd*l(9)     Xm          35;
            9   3   10  4   Rm              Rm              Rm              Rd25*l(9)       Xm              Xm          Xm          Xd*l(9)     36;

            10   3  11  1   Rd16*l(10)      Rm              Rm              Rm              Xd*l(10)        Xm          Xm          Xm          37;
            10   3  11  2   Rm              Rd16*l(10)      Rm              Rm              Xm              Xd*l(10)    Xm          Xm          38;
            10   3  11  3   Rm              Rm              Rd16*l(10)      Rm              Xm              Xm          Xd*l(10)    Xm          39;
            10   3  11  4   Rm              Rm              Rm              Rd16*l(10)      Xm              Xm          Xm          Xd*l(10)    40;
            
            11  3   12  1   Rd25*l(11)      Rm              Rm              Rm              Xd*l(11)        Xm          Xm          Xm          41;
            11  3   12  2   Rm              Rd25*l(11)      Rm              Rm              Xm              Xd*l(11)    Xm          Xm          42;
            11  3   12  3   Rm              Rm              Rd25*l(11)      Rm              Xm              Xm          Xd*l(11)    Xm          43;
            11  3   12  4   Rm              Rm              Rm              Rd25*l(11)      Xm              Xm          Xm          Xd*l(11)    44;
            
            12  12  13  1   Rd16*l(12)      Rm              Rm              Rm              Xd*l(12)        Xm          Xm          Xm          45;
            12  12  13  2   Rm              Rd16*l(12)      Rm              Rm              Xm              Xd*l(12)    Xm          Xm          46;
            12  12  13  3   Rm              Rm              Rd16*l(12)      Rm              Xm              Xm          Xd*l(12)    Xm          47;
            12  12  13  4   Rm              Rm              Rm              Rd16*l(12)      Xm              Xm          Xm          Xd*l(12)    48;
            
            13  3   14  1   Rd25*l(13)      Rm              Rm              Rm              Xd*l(13)        Xm          Xm          Xm          49;
            13  3   14  2   Rm              Rd25*l(13)      Rm              Rm              Xm              Xd*l(13)    Xm          Xm          50;
            13  3   14  3   Rm              Rm              Rd25*l(13)      Rm              Xm              Xm          Xd*l(13)    Xm          51;
            13  3   14  4   Rm              Rm              Rm              Rd25*l(13)      Xm              Xm          Xm          Xd*l(13)    52;
            
            14  3   15  1   Rd150*l(14)     Rm              Rm              Rm              Xd*l(14)        Xm          Xm          Xm          53;
            14  3   15  2   Rm              Rd150*l(14)     Rm              Rm              Xm              Xd*l(14)    Xm          Xm          54;
            14  3   15  3   Rm              Rm              Rd150*l(14)     Rm              Xm              Xm          Xd*l(14)    Xm          55;
            14  3   15  4   Rm              Rm              Rm              Rd150*l(14)     Xm              Xm          Xm          Xd*l(14)    56;
            
            15  15  16  1   Rd150*l(15)     Rm              Rm              Rm              Xd*l(15)        Xm          Xm          Xm          57;
            15  15  16  2   Rm              Rd150*l(15)     Rm              Rm              Xm              Xd*l(15)    Xm          Xm          58;  
            15  15  16  3   Rm              Rm              Rd150*l(15)     Rm              Xm              Xm          Xd*l(15)    Xm          59;
            15  15  16  4   Rm              Rm              Rm              Rd150*l(15)     Xm              Xm          Xm          Xd*l(15)    60;
            
            16  15  17  1   Rd06*l(16)      Rm              Rm              Rm              Xd*l(16)        Xm          Xm          Xm          61;
            16  15  17  2   Rm              Rd06*l(16)      Rm              Rm              Xm              Xd*l(16)    Xm          Xm          62;
            16  15  17  3   Rm              Rm              Rd06*l(16)      Rm              Xm              Xm          Xd*l(16)    Xm          63;
            16  15  17  4   Rm              Rm              Rm              Rd06*l(16)      Xm              Xm          Xm          Xd*l(16)    64;
            
            17  3   18  1   Rd70*l(17)      Rm              Rm              Rm              Xd*l(17)        Xm          Xm          Xm          65;
            17  3   18  2   Rm              Rd70*l(17)      Rm              Rm              Xm              Xd*l(17)    Xm          Xm          66;
            17  3   18  3   Rm              Rm              Rd70*l(17)      Rm              Xm              Xm          Xd*l(17)    Xm          67;
            17  3   18  4   Rm              Rm              Rm              Rd70*l(17)      Xm              Xm          Xm          Xd*l(17)    68;
            
            18  3   19  1   Rd10*l(18)      Rm              Rm              Rm              Xd*l(18)        Xm          Xm          Xm          69;
            18  3   19  2   Rm              Rd10*l(18)      Rm              Rm              Xm              Xd*l(18)    Xm          Xm          70;
            18  3   19  3   Rm              Rm              Rd10*l(18)      Rm              Xm              Xm          Xd*l(18)    Xm          71;
            18  3   19  4   Rm              Rm              Rm              Rd10*l(18)      Xm              Xm          Xm          Xd*l(18)    72];
    
//Power Definition
//          1: Nodes*Phases
//          2: Active Power (p.u.)
//          3: Reactive Power (p.u.)
//          4: None (Default 0)

    nnodes = max(max(d(:,2),d(:,3))); //We are assuming that it has a continuous numbering

    po=zeros((nnodes-1)*3,4);
  
// Nodes with neutral grounding
    bus = [2]; //Random value -> not used later

// The grounding  at the LV/MV transformer (Ohms)
    Rng = [60/Zbase]; //Taken from other examples -> not used later

// The global earth impedante (between 10-12 Ohms)
    Rgg = [11/Zbase]; //Taken from other examples -> not used later
    
// This vector shows the correspondance between the lines for INPG and ENG
    codes_lines_ENG=['transformer'; //1
                    'line0'; //2
                    'line1'; //3
                    'line2'; //4
                    'line3'; //5
                    'line4'; //6
                    'line12'; //7
                    'line13'; //8
                    'line5'; //9
                    'line6'; //10
                    'line7'; //11
                    'line14'; //12
                    'line8'; //13
                    'line9'; //14
                    'line15'; //15
                    'line16'; //16
                    'line10'; //17
                    'line11'; //18
                    'line17'; //19
                    'line18'; //20
                    'line19']; //21  

//MATRIX TO TRANSLATE THE METER_ID INTO NODES, TYPE OF CONNECTION (1PHASE-3PHASE), NUMBER OF CLIENT IN THE SIMULATOR AND CUSTOMER_ID
        //New Meter ID      NU  Node  1p-3p Sector  MaxPower(W)         #    Customer ID
codes = ['0005'            '0' '4'   'rst' '1'      '50000' '0'         '1'  '0005';
         '0001'            '0' '5'   'rst' '1'      '15000' '0'         '2'  '0001';
         '0512690040067'   '0' '6'   'rst' '2'      '15000' '0'         '3'  '0512690040067';
         '0'               '0' '7'   'rst' '1'      '15000' '0'         '4'  '0';
         '0'               '0' '8'   's'   '3'      '3000'  '0'         '5'  '0';
         '0'               '0' '8'   'r'   '3'      '3000'  '0'         '6'  '0';
         '0'               '0' '8'   'rst' '1'      '15000' '0'         '7'  '0';
         '0'               '0' '9'   'r'   '3'      '3000'  '0'         '8'  '0';
         '0512690040071'   '0' '10'  'rst' '2'      '10000' '0'         '9'  '0512690040071';
         '0002'            '0' '11'  'rst' '1'      '15000' '0'         '10' '0002';
         '0512690040072'   '0' '12'  'rst' '4'      '10000' '0'         '11' '0512690040072';
         '0512690040070'   '0' '13'  'rst' '4'      '10000' '0'         '12' '0512690040070';
         '0004'            '0' '14'  'rst' '1'      '6000'  '0'         '13' '0004';
         '0512690040069'   '0' '14'  't'   '1'      '6000'  '0'         '14' '0512690040069';
         '0'               '0' '14'  'r'   '3'      '3000'  '0'         '15' '0';
         '0512690040068'   '0' '16'  'rst' '2'      '3000'  '200000'    '16' '0512690040068';
         '0512690040066'   '0' '17'  'rst' '5'      '6000'  '0'         '17' '0512690040066';
         '0003'            '0' '18'  'rst' '2'      '75000' '0'         '18' '0003';
         '0'               '0' '19'  'rst' '6'      '5000'  '0'         '19' '0'];
endfunction
