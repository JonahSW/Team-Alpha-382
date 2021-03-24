function [R_s_p, R, q_tot] = heat_transfer(M_w_first, a_2, a_1, solar_flux, surface_area, thickness, h_tank_first, Temp_2)
%Input

%Output

%% Calculating Thickness of Tank (Based on Aluminum 7075)

a_u = 1.5E+8; % AU to Km
q_dprime_conduction = [];
q_dprime_convection = [];
q_dprime_radiation = [];
q_tot = [];
R = [];
F_g = [];
Ra = [];
Nu = [];
h = [];
liquid_hydrogen = 71; % kg/m^3
C_p = 9.58*1000; %J/kg*k
distance_C = a_2 * a_u; % in km
distance_C_m = distance_C*1000;
distance_E_m = a_1*a_u *1000;

if distance_C_m == distance_E_m
    R_s_p = a_1*a_u*1000*ones(2650);
else 
    R_s_p = distance_E_m:100000000:distance_C_m;
end 
emissivity_MLI = (6.8E-4)*(Temp_2^(0.67)); % assumed to be the same for all number of layers
k_mli = (1E-5)*(Temp_2) ; %MLI conductivity 10^-5 W/mK
alpha = 23.2E-6; % 1/C
k_A = 190; % W/m
k_liquid_hydrogen = 102/1000; %W/mK
thermal_diffusivity = k_liquid_hydrogen/(liquid_hydrogen*C_p);
T_1_c = -252.778; % degrees Celsius
Temp_1 = T_1_c + 273.15; %T_1 in Kelvin 
thickness_of_MLI = 20*0.5*(1/39.37);% MLI half inch thick
S_B_C = 5.670E-8; %stefan Boltzmann Constant W/m^2K^4
G = 6.67430E-11;
viscosity_hydrogen = ((137E6)/10); % gram/cm sec 10^6 -> kg/m sec
kinematic_viscosity_hydrogen = viscosity_hydrogen/liquid_hydrogen;
%% Calculating Boiloff 
for k = 1:length(R_s_p)
    F_g(k) = (G* (M_w_first*1000))/(R_s_p(k)^2);
    Ra(k) = (alpha*(Temp_2-Temp_1)*(h_tank_first)*F_g(k))/(kinematic_viscosity_hydrogen*thermal_diffusivity);
    if Ra(k)<= 1E7
        Nu(k) = 0.642*((Ra(k))^(1/6));
    elseif Ra(k)<1E7 && Ra(k)<=1E10
        Nu(k) = 0.167*((Ra(k))^(1/4));
    else 
        Nu(k) = 0.00053*((Ra(k))^(1/2));
    end
    h(k) = (k_liquid_hydrogen/h_tank_first)*Nu(k);
    R(k) = (thickness/k_A)+(thickness_of_MLI/k_mli);
    q_dprime_conduction(k) = -(Temp_1-Temp_2)/R(k);
    q_dprime_convection(k) = -h(k)*(Temp_1-Temp_2); % not including space convection, dont know if that adds anything else
    q_dprime_radiation(k) = -emissivity_MLI*S_B_C*((Temp_1)^4 - (Temp_2)^4);
    q_tot(k) = surface_area*(q_dprime_conduction(k)+q_dprime_convection(k)+q_dprime_radiation(k)+solar_flux(k));
end 
end 