maze = [0,0,-1,0,0; 0,1,1,1,1; 0,0,0,0,0; 1,0,1,1,0; ...
        0,0,0,1,1; 1,0,1,0,1; 1,0,1,0,0; 0,0,0,0,0;  ...
        0,1,0,1,2];
% visualize maze
% s=min(maze,[],"all");d=max(maze,[],"all");
% [x,y] = ind2sub(size(maze),find(maze==s));
% [xx,yy] = ind2sub(size(maze),find(maze==d));
% colormap([0 0 0; 1 1 1]);
% mazee=abs(maze-1);
% image(mazee .* 255); %點乘（對應元素相乘）
% hold on; %有無黑色方塊
% p=plot(y,x,'rpentagram',yy,xx,'bo');
% p(1).MarkerSize=25;p(2).MarkerSize=25;
% xticks(1:5);

%initstate = find(maze==-1);
[~,ii]=min(maze,[],"all");
row=mod(ii,size(maze,1)); %直的第幾個
col=ceil(ii/size(maze,1));
initstate = [row,col];

%agent = Agent(maze, initState);
QTable = zeros(size(maze,1),size(maze,2),4); %三維全零
eGreddy = 0.8;
actionList = ["up" "down" "left" "right"];

%###############################
%check variables
cnt=0;r=0; stepss=[];
for j=1:30
    state = initstate;
    i = 0; result=false;
    tes=[];tess=[];detail=[];
    while true
        i=i+1; 
        % Get next step from the Agent
        if rand() > eGreddy
            act = randsample(actionList,1);
        else %根據qtable找最大值來執行act
            ii=state(1);iii=state(2);
            Qsa = QTable(ii,iii,:); %1*1*4
            [~,iii] = max(Qsa);
            act = actionList(iii);
        end
        % Give the action to the Environment to execute
        row = state(1); col=state(2);
        if act=="up"
            row=row-1;
        elseif act=="down"
            row=row+1;
        elseif act=="left"
            col=col-1;
        elseif act=="right"
            col=col+1;
        end
        nextstatee = [row,col];

        tess=[tess;nextstatee];
        flag=0;
        try
            % beyond or hit wall, 有考慮index err
            if (row<=0)||(col<=0)||(maze(row,col)==1)||(row>size(maze,1))||(col>size(maze,2))
                nextstate = state; result = false; detail=[detail; 1]; flag=1;
%             end
            % goal
            elseif maze(row,col)==2
                nextstate = nextstatee; result = true; cnt=cnt+1; detail=[detail; 2];
            %forward
            else 
                nextstate = nextstatee; result = false; detail=[detail; 3];
            end 
        catch %兩種index error但後面再覆蓋就好
            nextstate = state; result = false; flag=2;
        end   
%         if flag==2; 
%             nextstate = nextstatee; result = true; cnt=cnt+1; detail=[detail; 2];
%         end
        tes=[tes; nextstate];


        % No move
        if nextstate == state
            reward = -10;
        % Goal
        elseif result==true
            reward = 100;
        % Forward
        else
            reward = -1;
        end
        
        % Update Q Table based on Environmnet's response
%         lr=0.7; gamma=0.9;
%         ii=state(1);iii=state(2); actindex=find(actionList==act);
%         Qs = QTable(ii,iii,:); %取出q table
%         Qsa = Qs(actindex); %找對應action(ex:'up')的index
%         ii=nextstate(1);iii=nextstate(2);
%         Qs(actindex) = (1-lr)*Qsa + lr*(reward+gamma*(max(QTable(ii,iii,:))));
%         QTable()
        lr = 0.7;
        gamma = 0.9;
        % Get current state's Q-values
        ii = state(1);
        iii = state(2);
        Qs = QTable(ii, iii, :);       
        % Find index of current action
        actindex = find(actionList == act);       
        % Get Q-value of current action
        Qsa = Qs(actindex);       
        % Calculate the new Q-value using the update equation
        ii = nextstate(1);
        iii = nextstate(2);
        nextMaxQ = max(QTable(ii, iii, :));
        Qs(actindex) = (1 - lr) * Qsa + lr * (reward + gamma * nextMaxQ);       
        % Update Q-table with the new Q-value
        QTable(ii, iii, :) = Qs;

        % Agent's state changes
        state = nextstate; 
        if result==true   
            stepss=[stepss; i];
            break
        end
    end
    if i==14
        break
    end
    ss=sort(stepss);
end