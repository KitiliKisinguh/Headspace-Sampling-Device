function response_analysis()
    % Input data
    data = [22.47, 20.27, 21.25, 20.63, 19.54, 19.9, 19.54, 19.29, 21.37, 19.54, ...
            17.58, 20.76, 20.39, 19.54, 21.49, 18.8, 21.86, 23.81, 23.81, 23.81, ...
            25.15, 25.76, 27.59, 30.16, 32.97, 33.21, 33.58, 35.16, 35.9, 40.17, ...
            39.68, 41.39, 43.71, 44.32, 47.13, 48.23, 52.01, 50.55, 54.33, 56.29, ...
            57.88, 59.1, 59.83, 58.73, 64.47, 65.57, 64.59, 66.79, 69.96, 70.09, ...
            73.63, 73.63, 74.97, 75.09, 76.19, 76.19, 76.31, 78.75, 78.27, 81.32, ...
            81.07, 83.27, 81.93, 84, 84, 83.52, 83.76, 84.74, 84.25, 84.25, ...
            83.88, 83.76, 84, 83.52, 83.76, 84.74, 84.25, 84.25, 83.88, 83.76, ...
            86.08, 87.55, 90.72, 90.48, 87.42, 87.91, 88.16, 89.5, 88.64, 86.81, ...
            88.52, 85.96, 86.69, 86.2, 86.69, 86.2, 87.55, 84.86, 85.71, 84.98, ...
            83.27, 82.66, 82.66, 84, 82.3, 85.35, 84.13, 85.1, 84.74, 86.2, ...
            86.69, 86.08, 84.62, 85.35, 86.08, 84.74, 86.32, 87.55, 87.79, 86.45, ...
            87.55, 88.03, 91.45, 87.67, 89.87, 89.13, 87.91, 89.87, 89.13, 91.21, ...
            90.6, 90.96, 90.72, 91.21, 88.03, 89.01, 91.7, 91.45, 90.6, 90.23, ...
            90.11, 91.21, 87.91, 89.87, 91.33, 88.77, 90.23, 91.82, 90.48, 91.09, ...
            88.77, 90.11, 88.64, 89.62, 89.99, 90.96, 90.72];
    
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
    title(sprintf('Temperature Response; 3.3ml\nRise Time: %.1fs, Settling Time: %.1fs, Overshoot: %.1f%%, Steady-State Error: %.2f°C', ...
          results.rise_time, results.settling_time, results.overshoot_percentage, results.steady_state_error));
    
    % Legend
    legend('Location', 'best');
    
    % Adjust axes
    ylim([min(temperature)*0.9, max(temperature)*1.1]);
    xlim([time(1), time(end)]);
    
    hold off;
end