function manual_attack()

    mode = 0;
    if mode == 0
        img = imread('stego\stego.jpg');
        imwrite(img, 'stegoAfter\stegoAfter.jpg', 'Quality',80);
    else
        img = imread('cover\cover.jpg');
        imwrite(img, 'coverAfter\coverAfter.jpg', 'Quality',80)
    end

end