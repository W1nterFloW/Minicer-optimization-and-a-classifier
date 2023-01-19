function [outputArg1,outputArg2] = generateStego(stegoOnCoverSync, coverSync, coverPath, stegoPath)

yEita = double(stegoOnCoverSync) - double(coverSync);
coverImg = jpeg_read(coverPath);
cover_qCoef = coverImg.coef_arrays{1};

stegoImg = coverImg;
stego_qCoef = cover_qCoef;
stego_qCoef(yEita~=0) = stegoOnCoverSync(yEita~=0);
stegoImg.coef_arrays{1} = double(stego_qCoef);

jpeg_write(stegoImg, stegoPath);

end