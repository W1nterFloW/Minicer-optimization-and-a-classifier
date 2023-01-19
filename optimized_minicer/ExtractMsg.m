function [msgExtract] = ExtractMsg(stegoAfterPath, coverPath, msgLength)

stegoAfterImg = jpeg_read(stegoAfterPath);
stegoAfter_qCoefs = stegoAfterImg.coef_arrays{1};
stegoAfterQuanTbl = stegoAfterImg.quant_tables{1};
coverImg = jpeg_read(coverPath);
coverQuanTbl = coverImg.quant_tables{1};

fun = @(x) double(round((x.data.*stegoAfterQuanTbl)./coverQuanTbl));
stegoAfterSync = blockproc(stegoAfter_qCoefs,[8 8],fun); 

msgExtract = stc_ml_extract(int32(reshape(stegoAfterSync,1,[])), msgLength);

end