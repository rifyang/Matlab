clc; clear;

% -------------------------------
% 1. 实验数据（每行：时间点，每列：Ya, Yb, Yc, Yd）
E = [1.0000    0.0000    0.0000    0.0000;
     0.9274    0.0726    0.0000    0.0000;
     0.5151    0.2137    0.2192    0.0520;
     0.4081    0.1993    0.3453    0.0474;
     0.4165    0.1824    0.3633    0.0378;
     0.3788    0.2234    0.3286    0.0692];
 
valid_times = [0.001; 0.010; 0.100; 0.500; 0.750; 1.000];  % 实验时间点

% -------------------------------
% 2. 初始条件和时间设置
Y0 = [1; 0; 0; 0; 0];
tspan = [0.001, 1];

% -------------------------------
% 3. k0 范围
k0_range = linspace(0.01, 10, 100);
R_values = zeros(size(k0_range));

% -------------------------------
% 4. 误差搜索主循环
min_R = inf;
for i = 1:length(k0_range)
    k0 = k0_range(i);

    % 定义矩阵 R1
    R1 = k0 * [ 2  -1   0  -1   0;
               -1   2  -1   0   0;
                0  -1   2   0  -1;
               -1   0   0   2  -1;
                0   0  -1  -1   2];

    % 求解 ODE
    [t, Y] = ode45(@(t, Y) -R1 * Y, tspan, Y0);
    Y_combined = [Y(:,1), Y(:,2), Y(:,3) + Y(:,4), Y(:,5)];

    % 插值获取模拟值
    S = interp1(t, Y_combined, valid_times, 'linear');

    % 误差计算
    R = sqrt(sum((E - S).^2, 'all'));
    R_values(i) = R;

    % 更新最优值
    if R < min_R
        min_R = R;
        best_k0 = k0;
        best_Y = Y_combined;
        best_t = t;
    end
end

% -------------------------------
% 5. 显示最小误差信息
fprintf('\n最小误差 R = %.6f，对应的 k0 = %.4f\n', min_R, best_k0);

% -------------------------------
% 6. 插值并绘制模拟曲线（平滑）
t_common = logspace(log10(0.001), log10(1), 200);
Y_interp = interp1(best_t, best_Y, t_common, 'spline');

figure;
semilogx(t_common, Y_interp, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Distribution');
title(sprintf('最佳拟合结果曲线 (k0 = %.4f)', best_k0));
legend('Ya', 'Yb', 'Yc (Y3+Y4)', 'Yd');
grid on;

% -------------------------------
% 7. 绘制误差图并标注最优点
figure;
plot(k0_range, R_values, '-o', 'LineWidth', 1.5);
xlabel('k0');
ylabel('Error R');
title('误差 R 关于 k0 的变化');
grid on;
hold on;
plot(best_k0, min_R, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(best_k0, min_R, sprintf('  min R = %.3f', min_R), 'FontSize', 10, 'Color', 'r');