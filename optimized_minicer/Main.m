
coverDir = 'D:\DevProj\Orzminicer\cover';
stegoDir = 'D:\DevProj\Orzminicer\stego';

payload = 0.3;

coverPath = [coverDir, '\', 'cover.jpg'];
stegoPath = [stegoDir, '\', 'stego.jpg'];


[coverSync, coverForStego1D, cost] = FigureOutCost(coverPath);

[msg,msgLength] = generateMsg(coverPath,payload);

[~, stego1D,num_msg_bits,~] = stc_pm1_pls_embed(int32(coverForStego1D), cost, uint8(msg));
%msgExtract1 = stc_ml_extract(stego1D, msgLength);


[height, width] = size(coverSync);
stegoOnCoverSync = reshape(stego1D, height, width);

generateStego(stegoOnCoverSync, coverSync, coverPath, stegoPath);

no_meaning = 0;
manual_attack();

stegoAfterPath = 'D:\DevProj\Orzminicer\stegoAfter\stegoAfter.jpg';
msgExtract = ExtractMsg(stegoAfterPath, coverPath, num_msg_bits);

errorRate = sum(abs(double(msg) - double(msgExtract))) / msgLength;
disp(errorRate);
