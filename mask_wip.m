StimSizePix = [500 800];
[mX, mY] = meshgrid(1:StimSizePix(1), 1:StimSizePix(2));
maskcenter = StimSizePix/2;
maskradius = StimSizePix/2; % Adjust the radius as needed


maskmat = (mX / (StimSizePix(1)/2)).^2 + ...
    (mY / (StimSizePix(2)/2)).^2 <= 1; % Equation of an oval

dH = (mX - maskcenter(1)) / maskradius(1);
dV = (mY- maskcenter(2)) / maskradius(2);

% Create a binary mask where points inside the ellipse are ones and outside are zeros
maskmat = (dH.^2 + dV.^2 <= 1);
maskbg = ~isnan(maskmat).* 0.5;

subplot(1,2,1);imagesc(maskmat)
subplot(1,2,2);imagesc(maskbg)


%%
masktext(:,:,2) = maskmat;



% Define the size of the image
imageSize = [100, 100]; % Adjust the size as needed

% Create a grid of coordinates
[x, y] = meshgrid(1:imageSize(2), 1:imageSize(1));

% Define the center and radius of the circle
center = [50, 50]; % Adjust the center as needed
radius = 20; % Adjust the radius as needed

% Create a binary mask where the circle is ones and the background is zeros
binaryMask = (x - center(1)).^2 + (y - center(2)).^2 <= radius^2;

% Display the mask
imshow(binaryMask);







%StimMask = Screen('MakeTexture', monitor.w, uint8(masktext));