%% === Υπολογισμός Μετατόπισης Doppler για Starlink ===

% 1. Ορισμός Σταθερών
c = 3.0e8;  % Ταχύτητα φωτός (m/s)
f0 = 12e9;  % Συχνότητα φορέα (Hz), από τις παραμέτρους Starlink

% 2. Ορισμός Δορυφορικών και Επίγειων Παραμέτρων
altitude = 550e3;    % Ύψος του Starlink (m) από το TLE
inclination = 53.0552;  % Κλίση τροχιάς από το TLE
earth_radius = 6371e3;  % Ακτίνα της Γης (m)

% 3. Υπολογισμός Ταχύτητας Δορυφόρου
% Χρησιμοποιούμε τον νόμο του Κέπλερ για να εκτιμήσουμε την ταχύτητα
mu = 3.986e14; % Γεωκεντρική σταθερά βαρύτητας (m^3/s^2)
orbital_radius = earth_radius + altitude; % Απόσταση από το κέντρο της Γης
v_sat = sqrt(mu / orbital_radius);  % Υπολογισμός ταχύτητας δορυφόρου (m/s)

% 4. Ορισμός Γωνιών Ανύψωσης (Elevation Angles)
% Αυτές είναι οι ίδιες γωνίες που χρησιμοποιήσαμε στο link budget
elevAngles = [1.18 5.34 10.56 17.71 28.84 49.08 81.95 51.97];

% 5. Υπολογισμός Doppler Shift για κάθε γωνία ανύψωσης
doppler_shift = zeros(size(elevAngles)); % Δημιουργία πίνακα για τις τιμές

for i = 1:length(elevAngles)
    theta = deg2rad(elevAngles(i)); % Μετατροπή γωνίας από μοίρες σε ακτίνια
    v_rel = v_sat * cos(theta); % Υπολογισμός σχετικής ταχύτητας
    doppler_shift(i) = (v_rel / c) * f0; % Υπολογισμός μετατόπισης Doppler (Hz)
end

% 6. Εμφάνιση Αποτελεσμάτων σε Πίνακα 
disp("Doppler Shift για διάφορες γωνίες ανύψωσης:")
table(elevAngles', doppler_shift', 'VariableNames', ...
    ["Elevation Angle (degrees)", "Doppler Shift (Hz)"])

% 7. Γράφημα Μετατόπισης Doppler
figure;
plot(elevAngles, doppler_shift, 'o-', 'LineWidth', 1.5);
title("Doppler Shift as a Function of Elevation Angle");
xlabel("Elevation Angle (degrees)");
ylabel("Doppler Shift (Hz)");
grid on;
