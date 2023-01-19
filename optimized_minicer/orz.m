img = imread('test.png');
imwrite(img(:,:,1), 'cover\cover.jpg','Quality',70);
