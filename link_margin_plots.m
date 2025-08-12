%% ============================================
% Γράφημα Περιθωρίου Σύνδεσης (Link Margin) σε Συνάρτηση με το Χρόνο
% ============================================
% Το παρόν script χρησιμοποιεί τα υπολογισμένα περιθώρια σύνδεσης
% (uplink, downlink, inter-satellite) και τα απεικονίζει σε ξεχωριστά
% γραφήματα με την πάροδο του χρόνου.

%% Ορισμός Χρονικού Διαστήματος Προσομοίωσης
% Ορίζουμε το χρονικό διάστημα σε μία ώρα με διαστήματα των 60 δευτερολέπτων.
time = 0:60:3600; % Χρόνος σε δευτερόλεπτα (0 έως 3600 δευτ.)

%% Χρήση των Υπολογισμένων Περιθωρίων Σύνδεσης
% Χρησιμοποιούμε τα αποτελέσματα από το MATLAB script που υπολογίζει το link margin
link_margin_uplink = linspace(10.8765, 9.5, length(time));    % Υποθέτουμε σταδιακή μείωση
link_margin_downlink = linspace(11.1668, 9.8, length(time));  % Υποθέτουμε σταδιακή μείωση
link_margin_isl = linspace(1.9703, 1.5, length(time));        % Μικρές διακυμάνσεις στο ISL

%% Γράφημα Περιθωρίου Σύνδεσης Ανερχόμενης Ζεύξης (Uplink)
figure;
plot(time / 60, link_margin_uplink, 'bo-', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Time (minutes)');
ylabel('Link Margin (dB)');
title('Optical Uplink Link Margin Over Time');
grid on;
legend('Optical Uplink Link Margin');
set(gca, 'FontSize', 11);

%% Γράφημα Περιθωρίου Σύνδεσης Κατερχόμενης Ζεύξης (Downlink)
figure;
plot(time / 60, link_margin_downlink, 'rs-', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Time (minutes)');
ylabel('Link Margin (dB)');
title('Optical Downlink Link Margin Over Time');
grid on;
legend('Optical Downlink Link Margin');
set(gca, 'FontSize', 11);

%% Γράφημα Περιθωρίου Σύνδεσης Δια-Δορυφορικής Ζεύξης (ISL)
figure;
plot(time / 60, link_margin_isl, 'gd-', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Time (minutes)');
ylabel('Link Margin (dB)');
title('Optical Inter-Satellite Link Margin Over Time');
grid on;
legend('Optical ISL Link Margin');
set(gca, 'FontSize', 11);