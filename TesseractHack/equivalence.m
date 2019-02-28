savefile=fullfile('Cache','objects.mat');

if exist(savefile,'file') == 2
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end



max_h = 0;
max_w = 0;

for j=1:length(objects)
    [h,w] = size(objects(j).bwimage);
    max_h = max(max_h, h);
    max_w = max(max_w, w);
end

for j=1:length(objects)
    J = zeros([max_h,max_w],'uint8');
    BW = objects(j).bwimage;
    [h,w] = size(BW);
    x = round((max_w - w)/2);
    y = round((max_h - h)/2);
    J( (y+1):(y+h), (x+1):(x+w) ) = BW .* 255;
    objects(j).grayscaleimage = J;
    objects(j).char = ' ';
end

% Find equivalent objects

n = length(objects);
Q = zeros(n,n);
threshold = 0.5;
classified = zeros(1,n);

for j = 1:(n-1)
    classified(j)=1;
    for k = (j+1):n
        D = dissimilarity(object(j), object(k));
        if classified(k)
            continue;
        end
        if D > threshold
            Q(j,k)=1;
            classified(k) = 1;
        end
    end
end
            