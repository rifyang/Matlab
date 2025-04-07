% Define parameters
k0 = 5; % Given rate constant
R1 = k0 * [2 -1  0 -1  0;
           -1  2 -1  0  0;
            0 -1  2  0 -1;
           -1  0  0  2 -1;
            0  0 -1 -1  2]; % Matrix A

Y0 = [1; 0; 0; 0; 0]; % Initial condition (column vector)
tspan = [0.001, 1]; % Time span in s

% Define the matrix ODE function
matrix_ode = @(t, Y) -R1 * Y;

% Solve the ODE using ode45 with continuous output
[t, Y] = ode45(matrix_ode, tspan, Y0);

% Combine Y3 and Y4 into one variable: Yc = Y3 + Y4
% 构造新的矩阵：第一列为 Y1, 第二列为 Y2, 第三列为 Y3+Y4, 第四列为 Y5
Y_combined = [Y(:,1), Y(:,2), Y(:,3) + Y(:,4), Y(:,5)];

% Plot the smooth, continuous solution for the 4 curves
figure;
semilogx(t, Y_combined, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Distribution');
title('Solution of dY/dt = -R1 * Y (Combined Y3+Y4)');
legend('Ya (Y1)', 'Yb (Y2)', 'Yc (Y3+Y4)', 'Yd (Y5)');
grid on;

% Define desired time points for output
t_desired = [0.001, 0.005, 0.010, 0.020, 0.050, 0.100, 0.300, 0.500, 0.750, 1.000];

% Interpolate the solution to get Y values at the desired time points
Y_interp = interp1(t, Y_combined, t_desired, 'linear');  % 也可用 'spline' 进行平滑插值

% Output the desired time points and corresponding Y values for the 4 curves
disp('Desired time points and corresponding Y values (4 curves):');
for i = 1:length(t_desired)
    fprintf('t = %8.3f s: Ya = %8.4f, Yb = %8.4f, Yc = %8.4f, Yd = %8.4f\n', ...
            t_desired(i), Y_interp(i,1), Y_interp(i,2), Y_interp(i,3), Y_interp(i,4));
end


