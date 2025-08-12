% ============================================
% ΔΟΡΥΦΟΡΙΚΟ ΣΕΝΑΡΙΟ ΜΕ STARLINK
% ============================================
% Αυτό το script δημιουργεί ένα απλό δορυφορικό σενάριο στο MATLAB χρησιμοποιώντας
% το Satellite Communications Toolbox. Οι δορυφόροι του αστερισμού Starlink
% φορτώνονται από ένα αρχείο TLE.

% Ορισμός χρονικού διαστήματος προσομοίωσης
startTime = datetime(2025,2,18,18,0,0);
stopTime = startTime + hours(1);
sampleTime = 60; % δευτερόλεπτα
sc = satelliteScenario(startTime,stopTime,sampleTime);

% Δημιουργία Viewer
viewer = satelliteScenarioViewer(sc, ShowDetails=false);

% Εισαγωγή του αστερισμού Starlink μέσω αρχείου TLE
tleFile = "starlink.tle"; 
starlinkSatellites = satellite(sc, tleFile);

% Ορισμός παραμέτρων εκπομπής του Starlink
fq = 12e9; % Συχνότητα εκπομπής: 12 GHz (Ku-band)
txpower = 40; % Ισχύς πομπού: 40 dBW
antennaType = "Gaussian";
halfBeamWidth = 10; % Πλάτος beam σε μοίρες

% Προσθήκη πομπών στους δορυφόρους
if antennaType == "Gaussian"
    lambda = physconst('lightspeed')/fq; % meters
    dishD = (70*lambda)/(2*halfBeamWidth); % meters
    tx = transmitter(starlinkSatellites, ...
        Frequency=fq, ...
        Power=txpower); 
    gaussianAntenna(tx,DishDiameter=dishD);
end

if antennaType == "Custom 48-Beam"
    antenna = helperCustom48BeamAntenna(fq);
    tx = transmitter(starlinkSatellites, ...
        Frequency=fq, ...
        MountingAngles=[0,-90,0], ... % [yaw, pitch, roll] with -90 using Phased Array System Toolbox convention
        Power=txpower, ...
        Antenna=antenna);  
end

% Προβολή κεραίας και ισχύς
isotropic = arrayConfig(Size=[1 1]);
pattern(tx,Size=500000);