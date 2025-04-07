
% plot_weighted_simulation - 使用加权矩阵进行模拟并绘图
%
% 输入：
%   R1_base: 基础矩阵 R1（不含 k0）
%   R2_base: 基础矩阵 R2（不含 k0）
%   k0     : 反应速率常数
%   a      : 加权系数（0 到 1）
%
% 示例调用：
%   R1 = [...]; R2 = [...];
%   plot_weighted_simulation(R1, R2, 5, 0.3);

    %--------------------------------------
    % 初始化
    Y0 = [1; 0; 0; 0; 0];
    tspan = [0.001, 1];
    k0 = 3; % Given rate constant
    a = 0.5;
    % 定义 5x5 的矩阵 R2
        R1 = k0 * [ 1   0   0  -1   0;
                     -1   1   0   0   0;
                      0  -1   1   0   0;
                      0   0   0   1  -1;
                      0   0  -1   0   1];

        R2 = k0 * [ 1  -1   0   0   0;
                      0   1  -1   0   0;
                      0   0   1   0  -1;
                     -1   0   0   1   0;
                     0   0   0  -1   1];

    %--------------------------------------
    % 求解 ODE
    [t1, Y1] = ode45(@(t, Y) -R1 * Y, tspan, Y0);
    [t2, Y2] = ode45(@(t, Y) -R2 * Y, tspan, Y0);

    % 组合变量：Ya = Y1, Yb = Y2, Yc = Y3+Y4, Yd = Y5
    Y_combined1 = [Y1(:,1), Y1(:,2), Y1(:,3)+Y1(:,4), Y1(:,5)];
    Y_combined2 = [Y2(:,1), Y2(:,2), Y2(:,3)+Y2(:,4), Y2(:,5)];

    %--------------------------------------
    % 定义统一时间轴（用于插值和平滑图像）
    t_common = logspace(log10(0.001), log10(1), 200);  % 平滑点

    % 插值到统一时间点
    Y1_interp = interp1(t1, Y_combined1, t_common, 'spline');
    Y2_interp = interp1(t2, Y_combined2, t_common, 'spline');

    % 加权计算
    Y_weighted = a * Y1_interp + (1 - a) * Y2_interp;

    %--------------------------------------
    % 绘图
    figure;
    semilogx(t_common, Y_weighted, 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Distribution');
    title(sprintf('加权结果：a = %.2f, k0 = %.2f', a, k0));
    legend('Ya', 'Yb', 'Yc (Y3+Y4)', 'Yd', 'Location', 'best');
    grid on;

    %--------------------------------------
    % 可选输出：显示关键点
    t_check = [0.001, 0.005, 0.010, 0.020, 0.050, 0.100, 0.300, 0.500, 0.750, 1.000];
    Y_check = interp1(t_common, Y_weighted, t_check, 'linear');
    disp('关键时间点对应的加权结果 (Ya, Yb, Yc, Yd):');
    for i = 1:length(t_check)
        fprintf('t = %7.3f s: Ya = %.4f, Yb = %.4f, Yc = %.4f, Yd = %.4f\n', ...
            t_check(i), Y_check(i,1), Y_check(i,2), Y_check(i,3), Y_check(i,4));
    end