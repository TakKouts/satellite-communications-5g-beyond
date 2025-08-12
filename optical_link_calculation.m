%% ============================================
% Ανάλυση Link Budget για Οπτική Δορυφορική Επικοινωνία Starlink
% ============================================
% Το παρόν script αναλύει το link budget για τις οπτικές επικοινωνίες
% (uplink, downlink και inter-satellite link) στο δίκτυο Starlink.
% Περιλαμβάνει ατμοσφαιρικές απώλειες, απώλειες ελεύθερου χώρου,
% και παράγοντες απόδοσης του πομπού και του δέκτη.



%% Ορισμός Βασικών Παραμέτρων
Preq = -35.5; % Απαιτούμενη ισχύς λήψης σε dBm για αξιόπιστη επικοινωνία
Ptx = 22;   % Ισχύς εκπομπής του πομπού σε dBm

%% Παράμετροι Επίγειου Σταθμού
gs = struct;
gs.Height = 1;                % Ύψος πάνω από την επιφάνεια της θάλασσας σε km
gs.OpticsEfficiency = 0.8;    % Οπτική Απόδοση Κεραίας
gs.ApertureDiameter = 1;      % Διάμετρος κεραίας
gs.PointingError = 1e-6;      % Σφάλμα κατεύθυνσης σε rad

%% Παράμετροι Δορυφόρου Starlink
satA = struct;
satA.Height = 550;            % Ύψος δορυφόρου Starlink σε km
satA.OpticsEfficiency = 0.8;  % Οπτική Απόδοση Κεραίας
satA.ApertureDiameter = 0.07; % Διάμετρος κεραίας (μικρότερη λόγω περιορισμού βάρους)
satA.PointingError = 1e-6;    % Σφάλμα κατεύθυνσης σε rad

satB = struct;
satB.OpticsEfficiency = 0.8;
satB.ApertureDiameter = 0.06;
satB.PointingError = 1e-6;


%% Παράμετροι Ζεύξης
link = struct;
link.Wavelength = 1550e-9;    % Μήκος κύματος σε μέτρα
link.TroposphereHeight = 20;  % Ύψος τροπόσφαιρας σε km
link.ElevationAngle = 50;     % Γωνία ανύψωσης ζεύξης σε μοίρες
link.SatDistance = 1000;      % Απόσταση μεταξύ δορυφόρων σε km (για τα ISL)

% Επιλογή τύπου ζεύξης: "downlink", "uplink", "inter-satellite"
link.Type = "downlink";
link.CloudType = "Thin cirrus"; % Επιλογή τύπου νεφών (επηρεάζει τις απώλειες), υπάρχει σχετικό function


%% Επιλογή Πομπού & Δέκτη ανάλογα με τον τύπο ζεύξης
if link.Type == "downlink"
    tx = satA;
    rx = gs;
elseif link.Type == "uplink"
    tx = gs;
    rx = satA;
else
    tx = satA;
    rx = satB;
end

%% Υπολογισμός Κέρδους transmitter και receiver
txGain = (pi * tx.ApertureDiameter / link.Wavelength)^2;
Gtx = 10 * log10(txGain);
rxGain = (pi * rx.ApertureDiameter / link.Wavelength)^2;
Grx = 10 * log10(rxGain);

%% Υπολογισμός Απωλειών Κατεύθυνσης για πομπό και δέκτη (Pointing Loss)
txPointingLoss = 4.3429 * txGain * (tx.PointingError)^2;
rxPointingLoss = 4.3429 * rxGain * (rx.PointingError)^2;

%% Υπολογισμός Απωλειών Διάδοσης (Path Loss)
if link.Type == "inter-satellite"
    % Απώλειες ελεύθερου χώρου μεταξύ των δύο δορυφόρων (δεν έχουμε ατμοσφαιρικά φαινόμενα)
    pathLoss = fspl(link.SatDistance * 1e3, link.Wavelength);
    linkMargin = Ptx + 10*log10(tx.OpticsEfficiency) + 10*log10(rx.OpticsEfficiency) + ...
        Gtx + Grx - txPointingLoss - rxPointingLoss - pathLoss - Preq;
    disp("Link margin for inter-satellite link: " + num2str(linkMargin) + " dB");

elseif (link.Type == "uplink") || (link.Type == "downlink") %%αν έχουμε downlink ή uplink
%% Υπολογισμός Απωλειών Ατμόσφαιρας
absorptionLoss = 0.01; % Απώλεια απορρόφησης σε dB

    % Υπολογισμός της απόστασης της οπτικής δέσμης που διαδίδεται
    % στην τροπόσφαιρα σε km
    dT = (link.TroposphereHeight - gs.Height) * cscd(link.ElevationAngle);
    % Υπολογισμός απόστασης μεταξύ επίγειου σταθμού και δορυφόρου σε m
    dGS = slantRangeCircularOrbit(link.ElevationAngle, satA.Height*1e3, gs.Height*1e3);
    % Υπολογισμός απώλειας διαδρομής μεταξύ σταθμού και δορυφόρου σε dB
    pathLoss = fspl(dGS, link.Wavelength);
    
    % Υπολογισμός γεωμετρικής διασποράς
    [cnc, lwc] = getCloudParameters(link.CloudType);
    visibility = 1.002 / ((lwc * cnc)^0.6473);
    
    % Προσαρμόζουμε ορατότητα για ανερχόμενη και κατερχόμενη
    if link.Type == "uplink"
        visibility = visibility * 0.8; % Μείωση ορατότητας λόγω της πυκνότερης ατμόσφαιρας
    else
        visibility = visibility * 1.2; % Αύξηση
    end
    
    delta = 1.3; % τιμή για καθαρό ουρανό
    geoCoeff = (3.91 / visibility) * ((link.Wavelength * 1e9 / 550)^-delta);
    geoScaLoss = 4.3429 * geoCoeff * dT;
    
    % Υπολογισμός διασποράς Μι
    lambda_mu = link.Wavelength * 1e6;
    a = 0.000487 * lambda_mu^3 - 0.002237 * lambda_mu^2 + 0.003864 * lambda_mu - 0.004442;
    b = -0.00573 * lambda_mu^3 + 0.02639 * lambda_mu^2 - 0.04552 * lambda_mu + 0.05164;
    c = 0.02565 * lambda_mu^3 - 0.1191 * lambda_mu^2 + 0.20385 * lambda_mu - 0.216;
    d = -0.0638 * lambda_mu^3 + 0.3034 * lambda_mu^2 - 0.5083 * lambda_mu + 0.425;
    mieER = a * gs.Height^3 + b * gs.Height^2 + c * gs.Height + d;
    mieScaLoss = (4.3429 * mieER) / sind(link.ElevationAngle);
    
    % Αλλαγή διασποράς Μι ανάλογα για ανερχόμενη και κατερχόμενη
    if link.Type == "uplink"
        mieScaLoss = mieScaLoss * 1.2; 
    else
        mieScaLoss = mieScaLoss * 0.8; 
    end
    
    % Υπολογισμός τελικού περιθώριου συνδέσμου σε dB
    linkMargin = Ptx + 10*log10(tx.OpticsEfficiency) + 10*log10(rx.OpticsEfficiency) + ...
        Gtx + Grx - txPointingLoss - rxPointingLoss - pathLoss - absorptionLoss - ...
        geoScaLoss - mieScaLoss - Preq;
    disp("Link margin for " + link.Type + " is " + num2str(linkMargin) + " dB");
end
