function [ NewInfo OldInfo] = Zspan(INFORMATION,Creq,minframe,maxframe,reqframe)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%Creq(minframe).list=Creq;
Creq(maxframe+1).list=[];
%disp(size(Creq(reqframe).list))
NewInfo(maxframe+1,1).PixelList=[];
NewInfo(maxframe+1,1).Area=[];
NewInfo(maxframe,+1).ClusterID=[];
OldInfo=INFORMATION;
%disp(NewInfo)

for meaninglessindex=1:2;
    
    %move up through the stack===============================================
    for frame=reqframe:maxframe
        if min(size(Creq(frame).list))==0; continue; end;
        %disp(frame)
        for id=1:length([INFORMATION(frame,:)])
            uniques=length(unique(...
                cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list),...
                'rows'));
            %If 10 percent of the pixels in each set are the same,
    %         disp([num2str(uniques) ' ' num2str(length(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list)))])
    %          disp(size(Creq(frame).list))
    %          disp(size(INFORMATION(frame,id).PixelList))
    %          disp(size(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list)))
            if uniques<length(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list));
                Creq(frame+1).list=cat(1,Creq(frame+1).list,INFORMATION(frame,id).PixelList);
                NewInfo(frame,id).PixelList=INFORMATION(frame,id).PixelList;
                NewInfo(frame,id).Area=INFORMATION(frame,id).Area;
                NewInfo(frame,id).ClusterID=INFORMATION(frame,id).ClusterID;
                OldInfo(frame,id).PixelList=[];
            end;
        end;
    end;
    %move down through the  stack================================================
    for Xframe=minframe:maxframe
        %disp('The Program is looping over the second interval')
        frame=maxframe-Xframe+minframe;
        if min(size(Creq(frame).list))==0; continue; end;
        %disp(frame)
        %disp('DAMNIT')
        for id=1:length([INFORMATION(frame,:)])
            uniques=length(unique(...
                cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list),...
                'rows'));

            %If 10 percent of the pixels in each set are the same,
    %         disp([num2str(uniques) ' ' num2str(length(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list)))])
    %          disp(size(Creq(frame).list))
    %          disp(size(INFORMATION(frame,id).PixelList))
    %          disp(size(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list)))
            if uniques<length(cat(1,INFORMATION(frame,id).PixelList,Creq(frame).list));
                %disp('The Program is finding new linkage in Zspace')
                if frame>1;
                    Creq(frame-1).list=unique(cat(1,Creq(frame-1).list,INFORMATION(frame,id).PixelList),'rows');
                end;
                %disp('FUUUUUUUUUU')
                NewInfo(frame,id).PixelList=INFORMATION(frame,id).PixelList;
                NewInfo(frame,id).Area=INFORMATION(frame,id).Area;
                NewInfo(frame,id).ClusterID=INFORMATION(frame,id).ClusterID;
                OldInfo(frame,id).PixelList=[];
            end;
        end;
    end;
    INFORMATION=OldInfo;
end;

%OldInfo=INFORMATION;
%NewInfo=INFORMATION(list);
%disp('Old Info')
%disp(OldInfo)
%disp(NewInfo)

end

