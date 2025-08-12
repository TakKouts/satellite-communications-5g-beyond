function [cnc,lwc] = getCloudParameters(cloudType)
% cnc - Cloud number concentration in 1/cm^3
% lwc - Liquid water content g/m^3
switch cloudType
    case "Cumulus"
        cnc = 250;
        lwc = 1;
    case  "Stratus"
        cnc = 250;
        lwc = 0.29;
    case "Stratocumulus"
        cnc = 250;
        lwc = 0.15;
    case "Altostratus"
        cnc = 400;
        lwc = 0.41;
    case "Nimbostratus"
        cnc = 200;
        lwc = 0.65;
    case "Cirrus"
        cnc = 0.025;
        lwc = 0.06405;
    case "Thin cirrus"
        cnc = 0.5;
        lwc = 3.128*1e-4;
end
end
