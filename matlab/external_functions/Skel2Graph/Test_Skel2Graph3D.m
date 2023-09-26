clear all;
close all;

% load example binary skeleton image
load skel

w = size(skel,1);
l = size(skel,2);
h = size(skel,3);

% convert skeleton to graph structure
[A,node,link] = Skel2Graph3D(skel,4);

% convert graph structure back to (cleaned) skeleton
skel2 = Graph2Skel3D(node,link,w,l,h);

% iteratively convert until there are no more 2-nodes left
[A2,node2,link2] = Skel2Graph3D(skel2,4);
while(min(cellfun('length',{node2.conn}))<3)
    skel2 = Graph2Skel3D(node2,link2,w,l,h);
    [A2,node2,link2] = Skel2Graph3D(skel2,4);
end;

% display result
figure();
hold on;
for i=1:length(node2)
    x1 = node2(i).comx;
    y1 = node2(i).comy;
    z1 = node2(i).comz;
    for j=1:length(node2(i).links)    % draw all connections of each node
        if(node2(i).conn(j)<1)
            col='b'; % branches are blue
        else
            col='r'; % links are red
        end;
        
        % draw edges as lines using voxel positions
        for k=1:length(link2(node2(i).links(j)).point)-1            
            [x3,y3,z3]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k));
            [x2,y2,z2]=ind2sub([w,l,h],link2(node2(i).links(j)).point(k+1));
            line([y3 y2],[x3 x2],[z3 z2],'Color',col,'LineWidth',3);
        end;
    end;
    
    % draw all nodes as yellow circles
    plot3(y1,x1,z1,'o','Markersize',9,...
        'MarkerFaceColor','y',...
        'Color','k');
end;
axis image;axis off;
set(gcf,'Color','white');
drawnow;
view(-17,46);

