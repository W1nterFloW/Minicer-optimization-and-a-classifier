function QT=quantizationTable(q)
% 
q50 = [16 11 10 16 24 40 51 61 ;
    12 12 14 19 26 58 60 55 ;
    14 13 16 24 40 57 69 56 ;
    14 17 22 29 51 87 80 62 ;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99];
% 
if q<50
    QT = round((50/q).*q50);
    QT(QT>255) = 255;
else
    QT = round(2*(1-q/100).*q50);
    QT(QT<1) = 1;
end

