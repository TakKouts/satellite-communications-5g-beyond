% Ορισμός Δορυφορικών Παραμέτρων (Starlink-1337)
satellite = struct;
satellite.EIRPDensity = 57;   % EIRP από το Link Budget Analyzer (dBW/MHz)
satellite.RxGByT = 15;        % G/T για Starlink (εκτιμώμενο, dB/K)
satellite.Altitude = 550e3;   % Υψόμετρο από το TLE (550 km)


% Ορισμός Παραμέτρων Επίγειου Τερματικού (UE - Χρήστης)
ue = struct;
ue.TxPower = 23;               % Ισχύς μετάδοσης (dBm)
ue.TxGain = 0;                 % Κέρδος κεραίας πομπού (dBi)
ue.TxCableLoss = 0;            % Απώλειες καλωδίων (dB)
ue.RxNoiseFigure = 7;          % Παράγοντας θορύβου δέκτη (dB)
ue.RxGain = 0;                 % Κέρδος κεραίας δέκτη (dBi)
ue.RxAntennaTemperature = 290; % Θερμοκρασία κεραίας (K)
ue.RxAmbientTemperature = 290; % Θερμοκρασία περιβάλλοντος (K)
ue.Altitude = 0;               % Ύψος τερματικού χρήστη (επίγειος σταθμός)

% 1 = Χρήση ITU-R P.618, 0 = Σταθερές απώλειες
useP618PropagationLosses = 1;           % 0 (false), 1 (true)

% Ορισμός Χαρακτηριστικών Ζεύξης
link = struct;
link.Direction = "downlink";    % "uplink", "downlink"
link.ElevationAngle = [1.18 5.34 10.56 17.71 28.84 49.08 81.95 51.97]; %Μοίρες ανύψωσης όπως έχουν υπολογιστεί από το analyzer app 
%για κατερχόμενη σύνδεση
link.Frequency = 12e9;                    % Συχνότητα (Hz) - Starlink Ku-band
link.Bandwidth = 240e6;                   % Εύρος ζώνης (Hz)
link.ShadowMargin = 3;                    % Περιθώριο εξασθένησης λόγω εμποδίων (dB)
link.AdditionalLosses = 2;                % Πρόσθετες απώλειες (dB)
link.PolarizationLoss = 3;                % Απώλειες λόγω πόλωσης (dB)

% Ορισμός Ατμοσφαιρικών Απωλειών
if useP618PropagationLosses == 0
    % Χρήση σταθερών τιμών όταν ΔΕΝ χρησιμοποιείται ITU-R P.618
    link.ScintillationLosses = 1.5;           % Απώλειες από σπινθηροβολία (dB)
    link.AtmosphericLosses = 1.0;             % Ατμοσφαιρικές απώλειες (dB)
else
    % Χρήση ITU-R P.618 για δυναμικό υπολογισμό απωλειών
    link.P618Configuration = p618Config;
    link.P618Configuration.Latitude = 37.98;     % Συντεταγμένες σταθμού Athens GS 
    link.P618Configuration.Longitude = 23.73;    % Συντεταγμένες σταθμού Athens GS 
    link.P618Configuration.GasAnnualExceedance = 1;
    link.P618Configuration.CloudAnnualExceedance = 1;
    link.P618Configuration.ScintillationAnnualExceedance = 1;
    link.P618Configuration.TotalAnnualExceedance = 1;
    link.P618Configuration.PolarizationTiltAngle = 0;    % σε μοίρες
    link.P618Configuration.AntennaDiameter = 1;          % Διάμετρος κεραίας σταθμού (m)
    link.P618Configuration.AntennaEfficiency = 0.5;
end
modulation = "QPSK"; % Τύπος διαμόρφωσης
nBits = 208;                       % Αριθμός χρήσιμων bit (transport block size)
nSymbols = 160;                    % Αριθμός συμβόλων ανά μετάδοση
nRep = 1;                          % Αρχικός αριθμός επαναλήψεων
nSF = 8;                           % Αριθμός subframes στο downlink
nRU = 1;                           % Αριθμός των πόρων που έχουν χρησιμοποιηθεί (Μόνο για ανερχόμενη ζεύξη).
nDSC = 72;                         % Αριθμός των δεδομένων που χρησιμοποιούνται
nFFT = 128;                        % Μήκος FFT 
tsamp = 1/1.92e6;                  % (s)
td = nFFT*tsamp;                   % Διάρκεια συμβόλου (s)
nCP = 9;                           % Αριθμός κυκλικών prefix δειγμάτων
tCP = nCP*tsamp;                   % Κυκλική διάρκεια prefix (s)
osr = 1;                           % Συντελεστής Δειγματοληψίας
% Eb/No σε dB
if modulation == "16-QAM"
  % 16-QAM απαιτεί υψηλότερο Eb/No
  ebnoRef = 14.4;
else 
    % Για BPSK ή QPSK
    ebnoRef = 10.5;
end
m = 1;
if modulation == "QPSK"
    m = 2;
elseif modulation == "16-QAM"
    m = 4;
end

% Number of CRC bits
nCRC = 24;

% Υπολογισμός reference CNR
if link.Direction == "downlink"
    Reff = (nBits + nCRC)/(nSF*nSymbols*m*nRep);
else % "uplink"
    Reff = (nBits + nCRC)/(nRU*nSymbols*m*nRep);
end
cnrRef = ebnoRef + 10*log10(m*Reff) + 10*log10(nDSC/nFFT) + ...
        10*log10(td/(td + tCP)) - 10*log10(osr);

disp("Reference CNR: " + cnrRef + " dB")

% Υπολογισμός EIRP όταν ο δορυφόρος είναι πομπός (dB)
% Για να πάρουμε τιμή σε ντεσιμπέλ από πυκνότητα:
% Τιμή σε dB = Τιμή σε dB/MHz + 10*log10[BW σε MHz]
satellite.EIRP = satellite.EIRPDensity + 10*log10(link.Bandwidth/1e6);

% Υπολογισμός EIRP όταν το UE είναι πομπός (dB)
% Για να μετατρέψουμε μια τιμή σε ντεσιμπέλ από dBm: dB = dBm - 30
ue.EIRP = (ue.TxPower-30) + ue.TxGain - ue.TxCableLoss;

% Υπολογισμός της θερμοκρασίας κέρδους σε θόρυβο ή την τιμή της αξίας για το UE
% ως δέκτης.
ue.RxGByT = ue.RxGain - ue.RxNoiseFigure ...
    - 10*log10(ue.RxAmbientTemperature + ...
    (ue.RxAntennaTemperature-ue.RxAmbientTemperature)*10^(-0.1*ue.RxNoiseFigure));

% Ρύθμιση τον πομπό και τον δέκτη με βάση την κατεύθυνση σύνδεσης
if link.Direction == "uplink"
    tx = ue;
    rx = satellite;
else
    tx = satellite;
    rx = ue;
end

% Εύρος γωνιών ανύψωσης
elevAngles = link.ElevationAngle(:);
numElevAngles = numel(elevAngles);

% Υπολογίζουμε την απόσταση από τον δορυφόρο στο UE για όλες τις γωνίες
d = slantRangeCircularOrbit(elevAngles,satellite.Altitude,ue.Altitude); % m

% Συνολικές ατμοσφαιρικές απώλειες για κάθε γωνία ανύψωσης
totalAtmosphericLoss = zeros(numElevAngles,1);
if useP618PropagationLosses == 1
    maps = exist("maps.mat","file");
    p836 = exist("p836.mat","file");
    p837 = exist("p837.mat","file");
    p840 = exist("p840.mat","file");
    matFiles = [maps p836 p837 p840];
    if ~all(matFiles)
        if ~exist("ITURDigitalMaps.tar.gz","file")
            url = "https://www.mathworks.com/supportfiles/spc/P618/ITURDigitalMaps.tar.gz";
            websave("ITURDigitalMaps.tar.gz",url);
            untar("ITURDigitalMaps.tar.gz")
        else
            untar("ITURDigitalMaps.tar.gz")
        end
    end
    link.P618Configuration.Frequency = link.Frequency;
    elevAnglesToConsider = elevAngles;
    if any(elevAngles < 5)
        warning("The prediction method for scintillation losses is valid for elevation " + ... 
            "angle greater than 5 degree. For elevation angle less than 5 degree, the " + ... 
            "nearest valid value of 5 degree will be used in the computation.")
        elevAnglesToConsider(elevAngles < 5) = 5;
    end
    for index = 1:numElevAngles
        link.P618Configuration.ElevationAngle = elevAnglesToConsider(index);
        pl = p618PropagationLosses(link.P618Configuration);
        totalAtmosphericLoss(index) = pl.At;
    end
else
    totalAtmosphericLoss(:) = link.AtmosphericLosses + link.ScintillationLosses;
end

% Ορισμός παραμέτρων διαμόρφωσης
config = satelliteCNRConfig;
config.TransmitterPower = tx.EIRP;
config.TransmitterAntennaGain = 0;
config.Frequency = link.Frequency/1e9;          % GHz
config.GainToNoiseTemperatureRatio = rx.RxGByT;
config.Bandwidth = link.Bandwidth/1e6;          % MHz

% Υπολογισμός CNR και free space path loss για κάθε γωνία 
cnr = zeros(numElevAngles,1);
pathLoss = cnr;
for index = 1:numElevAngles
    config.Distance = d(index)/1e3;                                         % km
    config.MiscellaneousLoss = totalAtmosphericLoss(index) + ...
         link.PolarizationLoss + link.ShadowMargin + link.AdditionalLosses;
    [cnr(index),cnrInfo] = satelliteCNR(config);
    pathLoss(index) = cnrInfo.FSPL;
end

% Βάζουμε τα αποτελέσματα σε πίνακα
table(elevAngles,cnr,pathLoss,VariableNames=["Elevation Angle (degrees)", "CNR (dB)", "FSPL (dB)"])
% Γράφημα του CNR ως συνάρτηση της γωνίας ανύψωσης
plot(elevAngles,cnr,"*")
title("CNR As a Function of Elevation Angle")
xlabel("Elevation Angle (degrees)")
ylabel("CNR (dB)")
ylim([min(cnr)-0.2 max(cnr)+0.2])
xlim([min(elevAngles)-1 max(elevAngles)+1])
grid on

% Υπολογισμός περιθωρίου συνδέσμου
linkMargin = cnr - cnrRef;

% Ελάχιστος αριθμός επιπλέον επαναλήψεων που απαιτούνται μέχρι το LM να
% είναι 0 ή 1
minRepetitions = 10.^(-linkMargin./10);
idx = linkMargin >= 0;
additionalRepetitions = minRepetitions;
additionalRepetitions(idx) = 0;
% Όταν το LM είναι αρνητικό, βελτιώνουμε το CNR προσθέτοντας επαναλήψεις.
% Υπολογίζουμε τον απαιτούμενο αριθμό πρόσθετων επαναλήψεων.
additionalRepetitions(~idx) = ceil(nRep*(additionalRepetitions(~idx)-1));

% Γωνία | LM | Ελάχ. απαιτούμενες επαναλήψεις
table(elevAngles,linkMargin,additionalRepetitions, ...
    VariableNames=["Elevation Angle (degrees)", ...
    "Link Margin (dB)", "NRep_Add"])