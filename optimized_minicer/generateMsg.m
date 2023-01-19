function [msg,msgLength] = generateMsg(coverPath,payload)

coverImg = jpeg_read(coverPath);
cover_dCoefs = coverImg.coef_arrays{1};
nzAC = nnz(cover_dCoefs) - nnz(cover_dCoefs(1:8:end,1:8:end));
msgLength = ceil(payload*nzAC);
msg = round( rand(1,msgLength) );

end
