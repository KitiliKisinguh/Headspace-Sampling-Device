function response_analysis()
    % Input data
    data = [24.18, 23.32, 25.15, 23.93, 22.1, 23.57, 24.05, 23.08, 23.69, 24.42, ...
            26.25, 25.89, 27.96, 27.96, 30.4, 32.72, 33.94, 32.97, 37.48, 35.65, ...
            41.03, 42.12, 43.59, 45.79, 49.57, 49.57, 52.01, 53.6, 54.82, 58.73, ...
            58.36, 60.93, 62.39, 62.39, 66.91, 66.79, 69.72, 69.11, 72.28, 74.36, ...
            74.11, 76.31, 78.27, 78.88, 80.83, 82.3, 84, 86.45, 85.59, 87.06, ...
            86.69, 87.91, 88.77, 89.13, 89.26, 90.35, 90.6, 89.87, 91.94, 91.45, ...
            92.43, 91.58, 92.55, 91.94, 91.82, 90.96, 92.19, 92.92, 93.41, 93.04, ...
            92.67, 92.43, 92.55, 92.67, 91.82, 93.16, 92.55, 91.82, 92.67, 91.33, ...
            91.82, 90.96, 92.19, 91.7, 91.45, 93.41, 93.04, 84, 91.58, 91.82, ...
            91.82, 92.19, 90.11, 90.72, 92.92, 92.06, 90.48, 91.94, 93.16, 91.94, ...
            93.65, 93.77, 91.21, 92.67, 92.19, 91.45, 92.67, 94.63, 90.84, 90.48, ...
            92.67, 91.82, 90.23, 91.94, 91.94, 91.58, 91.82, 91.09, 90.48, 89.99, ...
            91.09, 90.84, 91.82, 91.82, 91.09, 90.23, 91.82, 92.43, 90.72, 91.82, ...
            91.09, 90.23, 91.82, 92.43, 90.72, 93.04, 92.67, 92.19, 91.94, 93.89, ...
            91.94, 91.82, 92.55, 89.5, 91.21, 89.99, 90.96, 92.19, 90.35, 91.82, ...
            89.13, 89.01, 88.16, 90.48];

    % Parameters
    setpoint = 90;
    settling_percentage = 2; % 2% settling band
    sample_time = 5; % seconds per sample
    
    % Create time vector
    time = (0:length(data)-1) * sample_time;
    temperature = data;
    
    % Calculate response characteristics
    [results] = calculate_response_parameters(time, temperature, setpoint, settling_percentage);
    
    % Display results (now includes steady-state error)
    display_results(results, setpoint);
    
    % Plot response
    plot_response(time, temperature, setpoint, results, settling_percentage);
end

function [results] = calculate_response_parameters(time, temperature, setpoint, settling_percentage)
    % Initialize results structure
    results = struct();
    
    % Basic characteristics
    results.min_value = min(temperature);
    results.max_value = max(temperature);
    
    % Calculate steady-state value (average of last 20 samples for better accuracy)
    steady_state_window = min(20, length(temperature)); % Use last 20 samples or all if <20
    results.steady_state = mean(temperature(end-steady_state_window+1:end));
    
    % Rise Time (10% to 90%)
    v10 = results.min_value + 0.1 * (results.max_value - results.min_value);
    v90 = results.min_value + 0.9 * (results.max_value - results.min_value);
    
    t10_idx = find(temperature >= v10, 1, 'first');
    t90_idx = find(temperature >= v90, 1, 'first');
    results.rise_time = time(t90_idx) - time(t10_idx);
    results.t10 = time(t10_idx);
    results.t90 = time(t90_idx);
    
    % Overshoot
    results.overshoot_percentage = ((results.max_value - results.steady_state) / ...
                                   results.steady_state) * 100;
    
    % Steady-State Error (always positive)
    results.steady_state_error = abs(setpoint - results.steady_state);  % <-- Key change
    results.steady_state_error_percentage = (results.steady_state_error / setpoint) * 100;
    
    % Settling Time
    settling_band = settling_percentage / 100 * results.steady_state;
    lower_bound = results.steady_state - settling_band;
    upper_bound = results.steady_state + settling_band;
    
    % Find last point outside the band
    outside_band = (temperature < lower_bound) | (temperature > upper_bound);
    settling_idx = find(outside_band, 1, 'last');
    
    if ~isempty(settling_idx) && settling_idx < length(time)
        results.settling_time = time(settling_idx + 1);
    else
        results.settling_time = 0;
    end
    
    % Store bounds for plotting
    results.lower_bound = lower_bound;
    results.upper_bound = upper_bound;
end

function display_results(results, setpoint)
    fprintf('=== System Response Analysis ===\n');
    fprintf('Rise Time (10%%-90%%): %.2f seconds\n', results.rise_time);
    fprintf('Settling Time (2%% band): %.2f seconds\n', results.settling_time);
    fprintf('Overshoot: %.2f%%\n', results.overshoot_percentage);
    fprintf('Steady-State Value: %.2f°C\n', results.steady_state);
    fprintf('Steady-State Error: %.2f°C (%.2f%% of setpoint)\n', ...
            results.steady_state_error, results.steady_state_error_percentage);
    fprintf('Setpoint: %.2f°C\n', setpoint);
end

function plot_response(time, temperature, setpoint, results, settling_percentage)
    figure('Position', [100, 100, 800, 600]);
    
    % Main plot
    plot(time, temperature, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Temperature');
    hold on;
    grid on;
    
    % Setpoint line
    plot([time(1), time(end)], [setpoint, setpoint], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Setpoint');
    
    % Steady-state line with error annotation
    steady_state_line = plot([time(1), time(end)], [results.steady_state, results.steady_state], ...
         'g:', 'LineWidth', 1.5, 'DisplayName', sprintf('Steady-State (%.2f°C)', results.steady_state));
    
    % Annotate steady-state error
    text(time(end), results.steady_state, ...
        sprintf('Error: %.2f°C', results.steady_state_error), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
        'Color', 'green', 'FontWeight', 'bold');
    
    % Rise time indicators
    plot([results.t10, results.t10], [min(temperature), max(temperature)], 'b--', 'LineWidth', 0.5);
    plot([results.t90, results.t90], [min(temperature), max(temperature)], 'b--', 'LineWidth', 0.5);
    patch([results.t10, results.t90, results.t90, results.t10], ...
          [results.min_value+0.1*(results.max_value-results.min_value), ...
           results.min_value+0.1*(results.max_value-results.min_value), ...
           results.min_value+0.9*(results.max_value-results.min_value), ...
           results.min_value+0.9*(results.max_value-results.min_value)], ...
          'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Rise Time');
    
    % Settling time indicators
    if results.settling_time > 0
        settling_line = plot([results.settling_time, results.settling_time], [min(temperature), max(temperature)], ...
             'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Settling Time (%.1fs)', results.settling_time));
    end
    
    % Settling band
    settling_band = patch([time(1), time(end), time(end), time(1)], ...
          [results.lower_bound, results.lower_bound, ...
           results.upper_bound, results.upper_bound], ...
          'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', sprintf('±%d%% Band', settling_percentage));
    
    % Labels and title
    xlabel('Time (seconds)');
    ylabel('Temperature (°C)');
    title(sprintf('Temperature Response; 6.6ml\nRise Time: %.1fs, Settling Time: %.1fs, Overshoot: %.1f%%, Steady-State Error: %.2f°C', ...
          results.rise_time, results.settling_time, results.overshoot_percentage, results.steady_state_error));
    
    % Legend
    legend('Location', 'best');
    
    % Adjust axes
    ylim([min(temperature)*0.9, max(temperature)*1.1]);
    xlim([time(1), time(end)]);
    
    hold off;
end