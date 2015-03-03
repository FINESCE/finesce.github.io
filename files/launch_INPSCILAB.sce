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

function launch_INPSCILAB()
    tstart=now();
    dateVector = datevec(tstart+1/3600);//Simulation starts in 1 minute
    exec('simulator_INP.sce',-1);
    simulator_INP(900, dateVector(1), dateVector(2), dateVector(3), dateVector(4), dateVector(5), 1)
endfunction
