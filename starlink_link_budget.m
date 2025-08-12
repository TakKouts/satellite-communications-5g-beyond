% ============================================
% ΑΝΑΛΥΣΗ LINK BUDGET ΣΕ STARLINK ΣΥΝΔΕΣΗ
% ============================================

% Επιλογή συγκεκριμένων δορυφόρων από το TLE
selectedNames = ["STARLINK-1337", "STARLINK-1293"];
selectedSatellites = [];

for i = 1:length(starlinkSatellites)
    if ismember(starlinkSatellites(i).Name, selectedNames)
        selectedSatellites = [selectedSatellites, starlinkSatellites(i)];
    end
end

% Προσθήκη επίγειων σταθμών για την ανάλυση ζεύξης
gsAthens = groundStation(sc, 37.9838, 23.7275, Name="Athens GS");  
gsBerlin = groundStation(sc, 52.5200, 13.4050, Name="Berlin GS");

% Προσθήκη gimbals στους δορυφόρους και σταθμούς εδάφους
gimbalSat1 = gimbal(selectedSatellites(1));
gimbalSat2 = gimbal(selectedSatellites(2));

gimbalGsAthens = gimbal(gsAthens);
gimbalGsBerlin = gimbal(gsBerlin);

%% Προσθήκη δεκτών και πομπών στους δορυφόρους
% Πομπός στον δορυφόρο 2
gainToNoiseTemperatureRatio = 5; % dB/K
systemLoss = 3; % dB
rxSat1 = receiver(gimbalSat1, Name="Satellite 1 Receiver", ...
    GainToNoiseTemperatureRatio=gainToNoiseTemperatureRatio, ...
    SystemLoss=systemLoss);

dishDiameter = 0.5; % m
apertureEfficiency = 0.5;
gaussianAntenna(rxSat1, DishDiameter=dishDiameter, ApertureEfficiency=apertureEfficiency);

% Πομπός στον δορυφόρο 2
frequency = 27e9; % Hz
power = 20; % dBW
bitRate = 20; % Mbps
txSat2 = transmitter(gimbalSat2, Name="Satellite 2 Transmitter", ...
    Frequency=frequency, Power=power, BitRate=bitRate, SystemLoss=systemLoss);
gaussianAntenna(txSat2, DishDiameter=dishDiameter, ApertureEfficiency=apertureEfficiency);


% Πομπός στον σταθμό της Αθήνας
frequency = 30e9; % Hz
power = 40; % dBW
bitRate = 20; % Mbps
txGsAthens = transmitter(gimbalGsAthens, Name="Athens GS Transmitter", ...
    Frequency=frequency, Power=power, BitRate=bitRate);

dishDiameterGs = 5; % m
gaussianAntenna(txGsAthens, DishDiameter=dishDiameterGs);

% Δέκτης στον σταθμό του Βερολίνου
requiredEbNo = 14; % dB
rxGsBerlin = receiver(gimbalGsBerlin, Name="Berlin GS Receiver", RequiredEbNo=requiredEbNo);
gaussianAntenna(rxGsBerlin, DishDiameter=dishDiameterGs);


% Ευθυγράμμιση κεραίων (Tracking)
pointAt(gimbalGsAthens, selectedSatellites(1));
pointAt(gimbalSat1, gsAthens);
pointAt(gimbalSat2, gsBerlin);
pointAt(gimbalGsBerlin, selectedSatellites(2));

% Δημιουργία uplink και downlink ζεύξεων
uplink = link(txGsAthens, rxSat1);
downlink = link(txSat2, rxGsBerlin);

% Αποθήκευση του σεναρίου για ανάλυση στο Link Budget Analyzer
save("StarlinkScenario.mat","sc");