%% HW 2 Part B
clc;
clear all
close all

%% Load Loma Prieta Record
% Data has multiple columns
data = readmatrix('Ground_motions_assignment_1.csv');  
% Time data in first column
t_record = data(:, 1);

% Ground Motion Parking NS is in column 2
ag     = data(:, 2);       % acceleration in cm/s^2

% Find ground motion time interval
dt  = t_record(2) - t_record(1);   % 0.005 s

g = 981; % cm/s^2

%% Structure Cases
% Shared properties
    % Damping ratio
    z = 0.05;
% Structure 1 Properties (3 stories)
    % Natural period 
    Tn1 = 0.4;

% Structure 2 Properties (8 stories)
    % Natural period
    Tn2 = 1.0;

    
%% Section A - Computing Elastic Force Demand
% System will be elastic if Cy > A/g
% A = wn^2 * Sd
% Ce = Fe/W = A/g

% Calculate wn for each stucture
wn1 = 2*pi/Tn1;
wn2 = 2*pi/Tn2;

% First, assume high Cy (elastic system)
Cy_elastic = 5;

% Find response for each structure
[u1, ~, ~, ~, Sd_inelastic1, ~] = SDOF_Response_NL_1(Tn1, z, ag, dt, 0, 0, Cy_elastic, 'Cy', 'linear');
[u2, ~, ~, ~, Sd_inelastic2, ~] = SDOF_Response_NL_1(Tn2, z, ag, dt, 0, 0, Cy_elastic, 'Cy', 'linear');

% Elastic strength demand = peak absolute acceleration / g
% Using max displacement
Cy_el_1_u = wn1^2*max(abs(u1)) / g;   
Cy_el_2_u = wn2^2*max(abs(u2)) / g; 

Cy_el_1_s = (wn1^2*Sd_inelastic1) / g;   
Cy_el_2_s = (wn2^2*Sd_inelastic2) / g; 

fprintf('Part a: Elastic Lateral Strength\n')
fprintf('Seismic coefficient (lateral strength) elastic 3-story structure (Tn = 0.4s): Cy = %.4f\n', Cy_el_1_u)
fprintf('Seismic coefficient (lateral strength) elastic 8-story structure (Tn = 1.0s): Cy = %.4f\n\n', Cy_el_2_u)

%% Section B - R = 8 Design
% Cy for the stuctures is 1/8 of elastic design strength
R = 8;

% Cy for Structure 1
Cy1 = Cy_el_1_u/R;
Cy2 = Cy_el_2_u/R;

% Find response for each structure
[u1, ud1, udd_abs1, Fs1, Sd_inelastic1, mu1] = SDOF_Response_NL_1(Tn1, z, ag, dt, 0, 0, Cy1, 'Cy', 'linear');
[u2, ud2, udd_abs2, Fs2, Sd_inelastic2, mu2] = SDOF_Response_NL_1(Tn2, z, ag, dt, 0, 0, Cy2, 'Cy', 'linear');

% Rebuild time vector (may have been interpolated inside function)
t1 = (0:length(u1)-1)' * (Tn1/40);
t2 = (0:length(u2)-1)' * (Tn2/40);

% Plotting

% Figure 1: Structure 1 - Time Histories
figure('Name', 'Structure 1: Tn=0.4s', 'Position', [100 100 900 700])

subplot(5,1,1)
plot(t_record, ag, 'k', 'LineWidth', 0.8)
xlabel('Time (s)'); ylabel('a_g (cm/s^2)')
title('Ground Motion - Loma Prieta NS Parking')
grid on

subplot(5,1,2)
plot(t1, u1, 'b', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('u (cm)')
title(sprintf('Relative Displacement  |  Tn=%.1fs, \\zeta=%.0f%%, Cy=%.2f', Tn1, z*100, Cy1))
grid on

subplot(5,1,3)
plot(t1, ud1, 'r', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('cm/s')
title('Relative Velocity Time History')
grid on

subplot(5,1,4)
plot(t1, udd_abs1, 'r', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('cm/s^2')
title('Absolute Acceleration Time History')
grid on

% Figure 2: Structure 1 - Hysteretic Behavior
figure('Name', 'Hysteretic Behavior Structure 1', 'Position', [100 100 900 400])


plot(u1, Fs1/g, 'b', 'LineWidth', 1)
xlabel('Displacement u (cm)'); ylabel('Fs/W')
title(sprintf('Tn=%.1fs, Cy=%.2f,  \\mu=%.2f', Tn1, Cy1, mu1))
grid on

% Figure 3: Structure 2 - Time Histories
figure('Name', 'Structure 2: Tn=1.0s', 'Position', [100 100 900 700])

subplot(5,1,1)
plot(t_record, ag, 'k', 'LineWidth', 0.8)
xlabel('Time (s)'); ylabel('a_g (cm/s^2)')
title('Ground Motion - Loma Prieta NS Parking')
grid on

subplot(5,1,2)
plot(t2, u2, 'b', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('u (cm)')
title(sprintf('Relative Displacement  |  Tn=%.1fs, \\zeta=%.0f%%, Cy=%.2f', Tn2, z*100, Cy2))
grid on

subplot(5,1,3)
plot(t2, ud2, 'r', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('cm/s')
title('Relative Velocity Time History')
grid on

subplot(5,1,4)
plot(t2, udd_abs2, 'r', 'LineWidth', 1)
xlabel('Time (s)'); ylabel('cm/s^2')
title('Absolute Acceleration Time History')
grid on

% Figure 4: Structure 2 - Hysteretic Behavior
figure('Name', 'Hysteretic Behavior Structure 2', 'Position', [100 100 900 400])


plot(u2, Fs2/g, 'b', 'LineWidth', 1)
xlabel('Displacement u (cm)'); ylabel('Fs/W')
title(sprintf('Tn=%.1fs, Cy=%.2f,  \\mu=%.2f', Tn2, Cy2, mu2))
grid on

fprintf('Part b: R=8 Design\n')
fprintf('3-story (Tn=0.4s) Displacement Ductility Demand: mu = %.3f, Cy = %.4f \n', mu1, Cy1)
fprintf('8-story (Tn=1.0s) Displacement Ductility Demand: mu = %.3f, Cy = %.4f \n', mu2, Cy2)


%% SECTION C
% Goal
mu_goal = 4;
% Goal tolerance
mu_tol = 0.01; % 1% tolerance

% Structure 1 Iterative Test
% Initialize variables for iterative test
% start with elastic condition as upper bound to iterate between
Cy1 = Cy_el_1_u;
% create an initial Cy at lower bound to iterate between
Cy0 = 0.0000001;
% set initial mu_1
mu_1 = 0;

% while loop to continue iteration until tolerance acheived
while abs((mu_1-mu_goal)/mu_goal) > mu_tol
    Cy_1 = (Cy1+Cy0)/2;
    
    [~,~,~,~,~,mu_1] = SDOF_Response_NL_1(Tn1, z, ag, dt, 0, 0, Cy_1, 'Cy', 'linear');

    % Change Cy1 based on result
    % if mu is too high, Cy is too low, raise the lower bound
    if mu_1 > mu_goal
        Cy0 = Cy_1; % Raise the lower bound
    % if mu is too low, Cy is too high, lower the upper bound
    else
        Cy1 = Cy_1; % Lower the upper bound

    end
   
 
end

% Structure 2 Iterative Test
% Initialize variables for iterative test
% start with elastic condition as upper bound to iterate between
Cy2 = Cy_el_2_u;
% create an initial Cy at lower bound to iterate between
Cy0 = 0.0000001;
% set initial mu_2
mu_2 = 0;

% while loop to continue iteration until tolerance acheived
while abs((mu_2-mu_goal)/mu_goal) > mu_tol
    Cy_2 = (Cy2+Cy0)/2;
    
    [~,~,~,~,~,mu_2] = SDOF_Response_NL_1(Tn2, z, ag, dt, 0, 0, Cy_2, 'Cy', 'linear');

    % Change Cy1 based on result
    % if mu is too high, Cy is too low, raise the lower bound
    if mu_2 > mu_goal
        Cy0 = Cy_2; % Raise the lower bound
    % if mu is too low, Cy is too high, lower the upper bound
    else
        Cy2 = Cy_2; % Lower the upper bound
    end
   
   
end

fprintf('\n\nPart c: Ductility Demand = 4\n')
fprintf('Tn = %.1fs: Cy = %.4f, mu = %.3f\n', Tn1, Cy_1, mu_1)
fprintf('Tn = %.1fs: Cy = %.4f, mu = %.3f\n', Tn2, Cy_2, mu_2)


%% Section d
mu_goal = 4;

% From Miranda 1991/1993
% Phi for alluvium sites
    % phi = 1 + 1/(12*T-mu*T) - 2/(5*T) * exp(-2*(ln(T)-1/5)^2))
% Ru calculation
    % Ru = (u - 1)/phi +1 >= 1
% Approximate Cy is Cy elastic divided by Ru

% Calculate Ru for Structure 1 based on the provided formula
phi1 = 1 + 1/(12*Tn1 - mu_goal*Tn1) - 2/(5*Tn1) * exp(-2*(log(Tn1) - 1/5)^2);
Ru1 = max(1,(mu_goal - 1) / phi1 + 1);

% Calculate Ru for Structure 2 based on the provided formula
phi2 = 1 + 1/(12*Tn2 - mu_goal*Tn2) - 2/(5*Tn2) * exp(-2*(log(Tn2) - 1/5)^2);
Ru2 = max(1,(mu_goal - 1) / phi2 + 1);

% Approximate inelastic strength demand
Cy_1_approx = Cy_el_1_u / Ru1;
Cy_2_approx = Cy_el_2_u / Ru2;

fprintf('\n\nPart d: Approximate Inelastic Strength Demand\n')
fprintf('Tn = %.1fs: Cy = %.4f\n', Tn1, Cy_1_approx)
fprintf('Tn = %.1fs: Cy = %.4f\n', Tn2, Cy_2_approx)

fprintf('\nComparison with exact nonlinear analysis (part c):\n')
fprintf('Tn=%.1fs: Cy_exact=%.4f  Cy_approx=%.4f  diff=%.1f%%\n', ...
    Tn1, Cy_1, Cy_1_approx, 100*(Cy_1_approx - Cy_1)/Cy_1)
fprintf('Tn=%.1fs: Cy_exact=%.4f  Cy_approx=%.4f  diff=%.1f%%\n', ...
    Tn2, Cy_2, Cy_2_approx, 100*(Cy_2_approx - Cy_2)/Cy_2)

%% Part e
% Generate a Cy range from 0 to above elastic
Cy_range = 0:0.001:Cy_el_1_u;


% Create vectors for mu
mu_range_1 = zeros(1,length(Cy_range));
mu_range_2 = zeros(1,length(Cy_range));

% Calculate mu for each Cy in the range for Structure 1
for i = 1:length(Cy_range)
    [~,~,~,~,~,mu_range_1(i)] = SDOF_Response_NL_1(Tn1, z, ag, dt, 0, 0, Cy_range(i), 'Cy', 'linear');
end

% Calculate mu for each Cy in the range for Structure 2
for i = 1:length(Cy_range)
    [~,~,~,~,~,mu_range_2(i)] = SDOF_Response_NL_1(Tn2, z, ag, dt, 0, 0, Cy_range(i), 'Cy', 'linear');
end

% Plot the results for Structure 1 and Structure 2
figure('Name', 'Part e', 'Position', [100 100 900 700])
plot(mu_range_1,Cy_range, 'r', 'LineWidth', 1);
hold on;
plot( mu_range_2, Cy_range, 'g', 'LineWidth', 1);
ylabel('C_y');
xlim([0 20]);
xlabel('Displacement Ductility Demand \mu');
title('Ductility Demand vs. C_y for Structures 1 and 2');
legend('Structure 1', 'Structure 2');
grid on;
hold off;
% Apply the requested ylim command with correct syntax


