function [handles] = update_cluster_plot(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    AA(1)=handles.redgraph;
    AA(2)=handles.greengraph;
    AA(3)=handles.bluegraph;
    STATS=handles.STATS;
    maxintens=max(max([STATS.MeanIntensity]));
    maxarea=max(max([STATS.Area]));
    maxstd=max(abs(double(cat(1,STATS.PixelValues))-maxintens));
    imagesc(handles.graphimage)
    hold(handles.axes1,'on')
    for io=1:length(STATS);
        STDDEV(io)=std(double(STATS(io).PixelValues));
        %rectangle('position',STATS(io).BoundingBox,'edgecolor','blue','parent',handles.axes1)
        coords=cat(1,STATS(io).PixelList); %#ok<*NASGU>
        for i=1:3
            switch AA(i)
                case 1
                    if maxstd~=0; BB(i)=((STDDEV(io)/maxstd)); end; %#ok<*AGROW>
                case 2
                    if maxintens~=0; BB(i)=STATS(io).MeanIntensity/maxintens; end;
                case 3
                    BB(i)=STATS(io).Area/maxarea;
                case 4
                    BB(i)=random('unif',0,1);
                case 5
                    BB(i)=1;
                case 6
                    BB(i)=0;
                case 7
                    BB(i)=(STATS(io).Orientation+180)/360;
                case 8
                    BB(i)=(STATS(io).Eccentricity);
            end;
        end;
        rgb=[BB(1) BB(2) BB(3)];
        hold(handles.axes1,'on')
        %plot(coords(:,1),coords(:,2),'.','color',rgb,'parent',handles.axes1)
        hull=handles.STATS(io).ConvexHull;
        plot(hull(:,1),hull(:,2),'color',rgb,'parent',handles.axes1)
        hold(handles.axes1,'off')
        handles.RGB(io,1)=BB(1);
        handles.RGB(io,2)=BB(2);
        handles.RGB(io,3)=BB(3);
    end;

end

