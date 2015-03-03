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

// Author : Wendy  Briceno and Ahmad Hadjsaid
// Date : 2012
// Modified by : Emmanuelle Vanet
// Update : March 2014
// Modified by : Jose Sanchez Torres
// Update : November 2014

function [noeuds,lignes,V_bus,I_ligne,VoltageDrop, losses_ligne] = loadFlow_INP(d,po,bus_gr,Rng,Rgg,base)

// Create output variables 
lignes=[];
V_bus=[];
I_ligne=[];

// Affiche un avertissement pour une exception en virgule flottante
ieee(1);

//% Initialisation
// Initialisation values of Zbus and PQ (p.u)

// d matrix :
// Columns 5,6,7,8 => Ra, Rb, Rc, Rn
// Columns 9,10,11,12 => Xa, Xb, Xc, Xn

Zbus = d(:,5:8)+(1*%i)*d(:,9:12); //Eq (1) from [1]

// po matrix :
// Column 1 : Bus
// Column 2 : P[p.u.] - Active Power
// Column 3 : Q[p.u.] - Reactive Power
// Column 4 : Not Used

S = po(:,2)+(1*%i)*po(:,3); //Eq (4) from [1]

// d matrix :
// Column 2 : From
// Column 3 : To
// We assumed a continued numbering of nodes
n = max(max(d(:,2),d(:,3))); // Number of nodes 

noeuds = 1:n;// Nodes vector
lignes = 1:(n-1);// Lines vector

// Flat start : The initial voltage for all nodes should be equal to the root node voltage
a = exp(1*%i * 2 * %pi / 3); //Eq (6) from [2]
phase_init = [1;exp(1*%i)*(a^2);exp(1*%i)*(a);0]; //Eq (6) from [2]

// Initial Voltages according to Eq (6) from [2]
Vref = [1;1;1;0];

V = zeros(4*(n-1),1);
for i = 1:n-1
  V(4*(i-1)+1,1) = Vref(1,1)*phase_init(1,1);
  V(4*(i-1)+2,1) = Vref(2,1)*phase_init(2,1);
  V(4*(i-1)+3,1) = Vref(3,1)*phase_init(3,1);
  V(4*(i-1)+4,1) = Vref(4,1)*phase_init(4,1);
end;

//% Development of BIBC (Bus-Injection to Branch-Current) matrix
// According to the Section A from [1]
BIBC = zeros(n);

for i = 1:4:(n-1)*4
  BIBC(d(i,1),d(i,3)) = 1; // Section A from [1]
end;

for i = 1:4:(n-1)*4
  for j = 1:4:(n-1)*4
    if d(i,3) == d(j,2) then
      BIBC(d(i,1),d(j,3)) = 1; // Section A from [1]
    end;
  end;
end;

i = n*4;
for k = 1:4:(n-1)*4
  i = i-4;
  for j = 1:4:(n-1)*4
    if d(i,3)==d(j,2) then
      BIBC(d(i,1),:) = BIBC(d(i,1),:) | BIBC(d(j,1),:); // Section A from [1]
    end;
  end;
end;

BIBC = BIBC(1:n-1,2:n); //Remove first node (slack node)

// Development of 4 wires BIBC (Bus-Injection to Branch-Current) matrix
l = 1;
for i = 1:n-1
  k = 1;
  for j = 1:n-1
    BIBC_4(l:l+3,k:k+3) = BIBC(i,j);
    k = k+4;
  end;
  l = l+4;
end;

BIBC = BIBC_4;

for j = 1:4:(n-1)*4
  for i = 1:4:(n-1)*4
    if BIBC(i,j)~=0 then
      BIBC(i:i+3,j:j+3) = eye(4,4);
    end;
  end;
end;

// Development of 4 wires BCBV (Branch-Current to Bus-Voltage) matrix

BCBV = BIBC';
for i = 1:4:(n-1)*4
  for j = 1:4:(n-1)*4
    if BCBV(i,j) ~=0 then
      BCBV(i:i+3,j:j+3) = Zbus(j:j+3,:); // Based on Eq (10a) from [1]
    end;
  end;
end;

// LOAD FLOW
accuracy = 1;

Vinit = ones(4*(n-1),1); //MODIFIED in MATLAB VERSION Vinit=V(5:$,1)
I = zeros(4*(n-1),1);//Injected currents in nodes (n nodes but the first one (N1) is already initialized)
B = zeros(4*(n-1),1);//Flowing currents in lines (n-1 lines)


Vk = Vinit;// Vk is not known but a guess value is given
Vk = V;// Vk is not known but a guess value is given CHANGE!
dV1 = 0;
iter = 0;

// Repetitive process
maxiter = 50;

while accuracy>0.001 & iter<maxiter
  // Step 1 : Nodal current calculation
  for i = 1:n-1
    I(4*(i-1)+1,1) = conj(S(3*(i-1)+1,1)/Vk(4*(i-1)+1,1));  //prod I>0, cons I<0
    I(4*(i-1)+2,1) = conj(S(3*(i-1)+2,1)/Vk(4*(i-1)+2,1));  //prod I>0, cons I<0
    I(4*(i-1)+3,1) = conj(S(3*(i-1)+3,1)/Vk(4*(i-1)+3,1));  //prod I>0, cons I<0
  end

  //Compute injected neutral current at each node
  line_gr = bus_gr-1;  //Index shifting (N1 is already defined : it remains only n-1 nodes)
  Znn = zeros(n-1,1);
  for i = 1:n-1
    Znn(i,1) = Zbus(4*(i-1)+4,4);  //Neutral impedance of line i
  end
  //Zg = Rng + Rgg;  //Grounding impedance + earth global impedance (impedances in series)

  //for j = 1:max(size(line_gr))
    //I(4*(line_gr(j,1)-1)+4,1) = -(Zg/(Znn(line_gr(j,1),1)+Zg))*(I(4*(line_gr(j,1)-1)+1,1)+I(4*(line_gr(j,1)-1)+2,1)+I(4*(line_gr(j,1)-1)+3,1));
  //end;

  // Step 2 : Backward sweep - section current calculation
  B = BIBC*I;

  DLF = BCBV*BIBC;
  
  // Step 3 : Forward sweep - nodal voltage calculation
  dV = DLF*I;
  
  Vk = Vk + dV; //FOR EMMANUEL IT IS Vk1=V(5:end,1)-dV
  
  // Convergence criterion
  accuracy = max(abs(dV1-dV));
  dV1 = dV;
  iter = iter+1;
end

if iter==maxiter then
    disp(' WARNING: No convergence')
    [report,err]=mopen('Report_simulator.txt','a+');
    mputl(string(iter)+' iterations - No convergence',report); 
    mclose(report);
    // report is a global variable - this line updates the txt file report

else
    [report,err]=mopen('Report_simulator.txt','a+');
    mputl(string(iter)+' iterations | '+ string(accuracy)+' accuracy',report); 
    mclose(report);
end

//% Results
// Construct v_bus
v_bus = [Vref;Vk];

// Convert v_bus into V_bus
V_bus = zeros(n,4);
j = 0;
for i = 1:4:n*4
  j = j+1;
  V_bus(j,:) = [v_bus(i,1),v_bus(i+1,1),v_bus(i+2,1),v_bus(i+3,1)];
end

V_bus(:,4)=[];

// Convert flowing currents into I_ligne

I_ligne = zeros(n-1,4);
j = 0;
for i = 1:4:(n-1)*4
  j = j+1;
  I_ligne(j,:) = [B(i,1),B(i+1,1),B(i+2,1),B(i+3,1)];
end

I_ligne(:,4)=[]; // We are interested only on the three phases

V_ligne = zeros(n-1,3);
for i = 1:4:(n-1)*4
    ligne=d(i,1);
    from=d(i,2);
    to=d(i,3);
    V_ligne(ligne,1) = V_bus(from,1)-V_bus(to,1);
    V_ligne(ligne,2) = V_bus(from,2)-V_bus(to,2);
    V_ligne(ligne,3) = V_bus(from,3)-V_bus(to,3);
end

VoltageDrop = abs((V_ligne(:,1)+V_ligne(:,2)+V_ligne(:,3))/3)*(base.Ubase/sqrt(3));  // Voltage drop in V

losses = zeros(n-1,3);

for i = 1:n-1
    for j = 1:3
        losses(i,j)=V_ligne(i,j)*conj(I_ligne(i,j));
    end
end

losses = abs(losses)*base.Sbase*1000;
losses_ligne = losses(:,1)+losses(:,2)+losses(:,3); // Losses in W

endfunction
