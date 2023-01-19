function [coverSync, coverForStego1D, cost] = FigureOutCost(coverPath)

coverImg = jpeg_read(coverPath);
cover_qCoefs = coverImg.coef_arrays{1};
coverQuanTbl = coverImg.quant_tables{1};

fun = @(x) x.data .* coverQuanTbl;
cover_dCoef = blockproc(cover_qCoefs, [8 8], fun);
fun = @(x) idct2(x.data);
coverSpat = blockproc(cover_dCoef,[8 8],fun);
wetBlock = zeros(size(coverSpat));
wetBlock(coverSpat>127) = 1;
wetBlock(coverSpat<-128) = 1;
coverSpat(coverSpat>127) = 127;
coverSpat(coverSpat<-128) = -128;
fun = @(x) dct2(x.data);
coverSpat = blockproc(round(coverSpat),[8 8],fun);

wetPointConst = 10^13;
[miuP_orig, miuM_orig] = J_UNIWARD(coverPath);

% please set breakpoint and AfterChannelPath here.
no_meaning = 0;
coverAfterChannelPath = 'D:\DevProj\Orzminicer\coverAfter\coverAfter.jpg';

coverAfterChannelImg = jpeg_read(coverAfterChannelPath);
coverAfterChannel_qCoefs = coverAfterChannelImg.coef_arrays{1};
coverAfterChanneQuanTbl = coverAfterChannelImg.quant_tables{1};

% synchronous
fun = @(x) round((x.data.*coverAfterChanneQuanTbl)./coverQuanTbl);
coverSync_qCoefs = blockproc(coverAfterChannel_qCoefs,[8 8],fun); 

% calculate miu
fun = @(x) double(x.data .*coverQuanTbl);
toCalcMiuP = blockproc(coverSync_qCoefs+1,[8 8],fun);
toCalcMiuM = blockproc(coverSync_qCoefs-1,[8 8],fun);

miuP = miuP_orig.*abs(toCalcMiuP-cover_dCoef);
miuM = miuM_orig.*abs(toCalcMiuM-cover_dCoef);
miuP(miuP_orig==wetPointConst) = wetPointConst;
miuM(miuM_orig==wetPointConst) = wetPointConst;

% set wet block
fun = @(x) sum(sum(abs(x.data)))*ones(8,8);
wetBlock = blockproc(wetBlock,[8 8],fun);
miuP(wetBlock~=0) = wetPointConst;
miuM(wetBlock~=0) = wetPointConst;

% set wet point
% cumpute DCT coefficients to spatial
allZero = zeros(8,8);
Aj= zeros(8,8,64);
for i_point = 1 : 8
    for j = 1 : 8
        aj = allZero;
        aj(i_point,j) = aj(i_point,j) + 1;
        fun = @(x) idct2(x.data);
        Aj(:,:,j+(i_point-1)*8) = blockproc(double(aj.*coverQuanTbl),[8 8],fun);
    end
end
[height,width] = size(coverSpat);
heightBlockCnt = floor(height/8);
widthBlockCnt = floor(width/8);
Aj_max = max(Aj,[],3);
wetPointP = zeros(size(coverSpat));
wetPointM= zeros(size(coverSpat));
for i_block = 1:heightBlockCnt
    for j_block = 1:widthBlockCnt
        if all(all(wetBlock((i_block-1)*8+1:i_block*8,(j_block-1)*8+1:j_block*8)==ones(8,8)))
            continue;
        end
        if ~all(all((coverSpat((i_block-1)*8+1:i_block*8,(j_block-1)*8+1:j_block*8)+Aj_max)<127))
            for i_point = 1 : 8
                for j_point= 1 : 8
                    if ~all(all((coverSpat((i_block-1)*8+1:i_block*8,(j_block-1)*8+1:j_block*8)+Aj(:,:,j_point+(i_point-1)*8))<127))
                        wetPointP((i_block-1)*8+i_point,(j_block-1)*8+j_point) = 1;
                    end
                end
            end
        end
        if ~all(all((coverSpat((i_block-1)*8+1:i_block*8,(j_block-1)*8+1:j_block*8)-Aj_max)>-128))
            for i_point = 1 : 8
                for j_point = 1 : 8
                    if ~all(all((coverSpat((i_block-1)*8+1:i_block*8,(j_block-1)*8+1:j_block*8)-Aj(:,:,j_point+(i_point-1)*8))<127))
                        wetPointM((i_block-1)*8+i_point,(j_block-1)*8+j_point) = 1;
                    end
                end
            end
        end
    end
end
miuP(wetPointP~=0) = wetPointConst;
miuM(wetPointM~=0) = wetPointConst;

coverSync = coverSync_qCoefs;
coverForStego1D = reshape(coverSync_qCoefs, 1, []);
[~, length] = size(coverForStego1D);
cost = zeros(3, length,'single');
cost(1,:) = reshape(miuP,1,[]);
cost(3,:) = reshape(miuM,1,[]);
end