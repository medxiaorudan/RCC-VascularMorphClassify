function [figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,varargin)
    %  WindRose  Draw a Wind Rose knowing direction and speed
    %
    %  [figure_handle,count,speeds,directions,Table] = WindRose(direction,speed);
    %  [figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,'parameter1',value1,...);
    %
    %  figure_handle is the handle of the figure containing the chart
    %  count is the frequency for each speed (ncolumns = nspeeds) and for each direction (nrows = ndirections).
    %  speeds is a 1 by n vector containing the values for the speed intervals
    %  directions is a m by 1 vector containing the values in which direction intervals are centered
    %  Table is a (4+m) by (3+m) cell array (excel-ready), containing Frequencies for each direction and for each speed. 
    %
    %  User can specify direction angle meaning North and East winds, so
    %  the graphs is shown in the desired reference
    %
    %     Example
    %     d = 360 * rand(10000,1); % My reference is North = 0, East = 90.
    %     v = 30*rand(10000,1);
    % 
    %     [figure_handle,count,speeds,directions,Table] = WindRose(d,v,'anglenorth',0,'angleeast',90,'freqlabelangle',45);
    %
    % PARAMETER          CLASS         DEFAULT VALUE         DESCRIPTION
    %------------------------------------------------------------------------------------------------------------------------------------------------------------
	% 'centeredin0'      Logical.      true                  Is first angular bin centered in 0 (-5 to 5)? -> CeteredIn0 = true // or does it start in 0 (0 to 10)? -> CeteredIn0 = false.
    % 'ndirections'      Numeric.      36                    Number of direction bins (subdivisions) to be shown.
    % 'freqround'        Numeric.      1                     Maximum frquency value will be rounded to the first higher whole multiple of FrequenciesRound. Only applies if 'maxfrequency' is specified.
    % 'nfreq'            Numeric.      5                     Draw this number of circles indicating frequency.
    % 'speedround'       Numeric.      [] (auto)             Maximum wind speed will be rounded to the first higher whole multiple of WindSpeedRound.
    % 'nspeeds'          Numeric.      [] (auto)             Draw this number of windspeeds subdivisions (bins). Default is 6 if 'speedround' is specified. Otherwise, default is automatic.
    % 'maxfrequency'     Numeric.      [] (auto) or 6        Set the value of the maximum frequency circle to be displayed. Be careful, because bins radius keep the original size.
    % 'freqlabelangle'   Numeric.      [] (auto)             Angle in which frequecy labels are shown. If this value is empty, frequency labels will NOT be shown. Trigonometric reference. 0=Right, 90=Up.
    % 'titlestring'      Cell/String.  {'Wind Rose';' '}     Figure title. It is recommended to include an empty line below the main string.
    % 'lablegend'        String.       'Wind speeds in m/s'  String that will appear at the top of the legend. Can be empty.
    % 'cmap'             String.       'jet'                 String with the name of a colormap function. If you put inv before the name of the funcion, colors will be flipped (e.g. 'invjet', 'invautum', 'invbone', ...). Use any of the built-in functions (autumn, bone, colorcube, cool, copper, flag, gray, hot, hsv, jet, lines, pink, prism, spring, summer, white, winter). See doc colormap for more information.
    % 'height'           Numeric.      2/3*screensize        Figure inner height in pixels. Default is 2/3 of minimum window dimension;
    % 'width'            Numeric.      2/3*screensize        Figure inner width in pixels.
    % 'figcolor'         Color Code.   'w'                   Figure color, any admitted matlab color format. Default is white.
    % 'textcolor'        Color Code.   'k'                   Text and axis color, any admitted matlab color format. Default is black.
    % 'labels'           CellString    {'N','S','E','W'}     Specify North South East West in a cell array of strings.
    % 'labelnorth'       String.       'N'                   Label to indicate North. Be careful if you specify 'labels' and 'labelnorth'. Last parameter specified will be the one used.
    % 'labelsouth'       String.       'S'                   Label to indicate South. Be careful if you specify 'labels' and 'labelsouth'. Last parameter specified will be the one used.
	% 'labeleast'        String.       'E'                   Label to indicate East.  Be careful if you specify 'labels' and 'labeleast' . Last parameter specified will be the one used.
    % 'labelwest'        String.       'W'                   Label to indicate West.  Be careful if you specify 'labels' and 'labelwest' . Last parameter specified will be the one used.
    % 'titlefontweight'  String.       'bold'                Title font weight. You can use 'normal','bold','light','demi'
    % 'legendvariable'   String.       'W_S'                 Variable abbreviation that appears inside the legend. You can use TeX sequences.
    % 'anglenorth'       Numeric.       90                   Direction angle meaning North wind. Default is 90 for North (trigonometric reference). If you specify 'north' angle, you need to specify 'east' angle, so the script knows how angles are referenced.
    % 'angleeast'        Numeric.       0                    Direction angle meaning East wind.  Default is  0 for East  (counterclockwise).        If you specify 'east' angle, you need to specify 'north' angle, so the script knows how angles are referenced.
    % 'minradius'        Numeric        1/30                 Minimum radius of the wind rose, relative to the maximum frequency radius. An empty circle of this size appears if greater than 0.
    % 'legendtype'       Numeric        2                    Legend type continuous = 1, separated boxes = 2
    %
    %
    % by Daniel Pereira - dpereira@s2msolutions.com
    %
    % 2014/Jul/14 - First version
    
    %% Check funciton call
    if nargin<2
        error('WindRose needs at least two inputs');
    elseif mod(length(varargin),2)~=0
        error('Inputs must be paired: WindRose(Speed,Direction,''PropertyName'',PropertyValue,...)');
    elseif ~isnumeric(speed) || ~isnumeric(speed)
        error('Speed and Direction must be numeric arrays.');
    elseif ~isequal(size(speed),size(direction))
        error('Speed and Direction must be the same size.');
    end

%% Default parameters
SCS              = get(0,'screensize');

CeteredIn0       = true;
ndirections      = 36;
FrequenciesRound = 1;
NFrequencies     = 5;
WindSpeedRound   = [];
NSpeeds          = [5];
circlemax        = [];
FreqLabelAngle   = [];
TitleString      = {'';' '};
lablegend        = '';
colorfun         = 'jet';
height           = min(SCS(3:4))*2/3;
width            = min(SCS(3:4))*2/3;
figcolor         = 'w';
TextColor        = 'k';
label.N          = '';
label.S          = '';
label.W          = '';
label.E          = '';
titlefontweight  = 'bold';
legendvariable   = 'length';
RefN             = 90;
RefE             = 0;
min_radius       = 1/30;
LegendType       = 2;

%% User-.specified parameters

for i=1:2:numel(varargin)
    switch lower(varargin{i})
        case 'centeredin0'
            CeteredIn0       = varargin{i+1};
        case 'ndirections'
            ndirections      = varargin{i+1};
        case 'freqround'
            FrequenciesRound = varargin{i+1};
        case 'nfreq'
            NFrequencies     = varargin{i+1}; 
        case 'speedround'
            WindSpeedRound   = varargin{i+1};
        case 'nspeeds'
            NSpeeds          = varargin{i+1};
        case 'freqlabelangle'
            FreqLabelAngle   = varargin{i+1};
        case 'titlestring'
            TitleString      = varargin{i+1};
        case 'lablegend'
            lablegend        = varargin{i+1};
        case 'cmap'
            colorfun         = varargin{i+1};
        case 'height'
            height           = varargin{i+1};
        case 'width'
            width            = varargin{i+1};
        case 'figcolor'
            figcolor         = varargin{i+1};
        case 'textcolor'
            TextColor        = varargin{i+1};
        case 'min_radius'
            min_radius       = varargin{i+1};
        case 'maxfrequency'
            circlemax = varargin{i+1};
        case 'titlefontweight'
            titlefontweight  = varargin{i+1};
        case 'legendvariable'
            legendvariable   = varargin{i+1};
        case 'legendtype'
            LegendType       = varargin{i+1};
        case 'labelnorth'
            label.N          = varargin{i+1};
        case 'labelsouth'
            label.S          = varargin{i+1};
        case 'labeleast'
            label.E          = varargin{i+1};
        case 'labelwest'
            label.W          = varargin{i+1};
        case 'labels'
            label.N          = varargin{i+1}{1};
            label.S          = varargin{i+1}{2};
            label.E          = varargin{i+1}{3};
            label.W          = varargin{i+1}{4};
        case 'anglenorth'
            k = any(arrayfun(@(x) strcmpi(x,'angleeast'),varargin));
            if ~k
                error('Reference angles need to be specified for AngleEAST and AngleNORTH directions');
            end
        case 'angleeast'
            k = find(arrayfun(@(x) strcmpi(x,'anglenorth'),varargin));
            if isempty(k)
                error('Reference angles need to be specified for AngleEAST and AngleNORTH directions');
            else
                RefE         = varargin{i+1};
                RefN         = varargin{k+1};
            end
            if abs(RefN-RefE)~=90
                error('The angles specified for north and east must differ in 90 degrees');
            end
        otherwise
            error([varargin{i} ' is not a valid property for WindRose function.']);
    end
end

speed            = reshape(speed,[],1);                                    % Convert wind speed into a column vector
direction        = reshape(direction,[],1);                                % Convert wind direction into a column vector
NumberElements   = numel(direction);                                       % Coun the actual number of elements, to consider winds = 0 when calculating frequency.
dir              = mod((RefN-direction)/(RefN-RefE)*90,360);               % Ensure that the direction is between 0 and 360
speed            = speed(speed>0);                                         % Only show winds higher than 0. Why? See next comment.
dir              = dir(speed>0);                                           % Wind = 0 does not have direction, so it cannot appear in a wind rose, but the number of appeareances must be considered.

% figure_handle = figure('color',figcolor,'units','pixels','position',[SCS(3)/2-width/2 SCS(4)/2-height/2 width height],'menubar','none','toolbar','none');
% figure_handle = figure('color',figcolor,'units','pixels','position',[SCS(3)/2-width/2 SCS(4)/2-height/2 width height]);
figure_handle = figure();

%% Bin Directions
N     = linspace(0,360,ndirections+1);                                     % Create ndirections direction intervals (ndirections+1 edges)
N     = N(1:end-1);                                                        % N is the angles in which direction bins are centered. We do not want the 360 to appear, because 0 is already appearing.
n     = 180/ndirections;                                                   % Angle that should be put backward and forward to create the angular bin, 1st centered in 0
if ~CeteredIn0                                                             % If user does not want the 1st bin to be centered in 0
    N = N+n;                                                               % Bin goes from 0 to 2n (N to N+2n), instead of from -n to n (N-n to N+n), so Bin is not centered in 0 (N) angle, but in the n (N+n) angle
end

%% Wind speeds/velocities
if ~isempty(WindSpeedRound)
    if isempty(NSpeeds); NSpeeds = 6; end                                  % Default value for NSpeeds if not user specified
    vmax      = ceil(max(speed)/WindSpeedRound)*WindSpeedRound;            % Max wind speed rounded to the nearest whole multiple of WindSpeedRound (Use round or ceil as desired)
                if vmax==0; vmax=WindSpeedRound; end;                      % If max wind speed is 0, make max wind to be WindSpeedRound, so wind speed bins are correctly shown.
    vwinds    = linspace(0,vmax,NSpeeds);                                  % Wind speeds go from 0 to vmax, creating the desired number of wind speed intervals
else
    figure2 = figure('visible','off'); plot(speed);                        % Plot wind speed
    vwinds = get(gca,'ytick'); delete(figure2);                            % Yaxis will automatically make divisions or us.
    if ~isempty(NSpeeds)
        vwinds = linspace(min(vwinds),max(vwinds),NSpeeds);
    end
end

%% Histogram in each direction + Draw
count     = PivotTableCount(N,n,vwinds,speed,dir,NumberElements);          % For each direction and for each speed, value of the radius that the windorose must reach (Accumulated in speed).

if isempty(circlemax)
    circlemax = ceil(max(max(count))/FrequenciesRound)*FrequenciesRound;   % Round highest frequency to closest whole multiple of theFrequenciesRound  (Use round or ceil as desired)
end
min_radius = min_radius*circlemax;

DrawPatches(N,n,vwinds,count,colorfun,figcolor,min_radius);% Draw the windrose, knowing the angles, the range for each direction, the speed ranges, the count (frequency) values and the colormap used.

%% Constant frequecy circles and x-y axes + Draw + Labels

[x,y]     = cylinder(1,50); x = x(1,:); y = y(1,:);                        % Get x and y for a unit-radius circle
circles   = linspace(0,circlemax,NFrequencies+1); circles = circles(2:end);% Radii of the circles that must be drawn (frequencies). We do not want to spend time drawing radius=0.

radius    = circles   + min_radius;
radiusmax = circlemax + min_radius;

plot(x'*radius,y'*radius,':','color',TextColor);                           % Draw circles
plot(x*radiusmax,y*radiusmax,'-','color',TextColor);                       % Redraw last circle

axisangles = 0:30:360; axisangles = axisangles(1:end-1);                   % Angles in which to draw the radial axis (trigonometric reference)
R = [min_radius;radiusmax];
plot(R*cosd(axisangles),R*sind(axisangles),':','color',TextColor);         % Draw radial axis, in the specified angles

FrequecyLabels(circles,radius,FreqLabelAngle,TextColor);                   % Display frequency labels
CardinalLabels(radiusmax,TextColor,label);                                 % Display N, S, E, W

%% Title and Legend
title(TitleString,'color',TextColor,'fontweight',titlefontweight);         % Display a title
set(gca,'outerposition',[0 0 1 1]);                                        % Check that the current axis fills the figure.
if LegendType==2
    leyenda = CreateLegend(vwinds,lablegend,legendvariable);               % Create a legend cell string
    l       = legend(leyenda,'location','southwest');                      % Display the legend wherever (position is corrected)
              PrettyLegend(l,TextColor);                                   % Display the legend in a good position
elseif LegendType==1
    disp(vwinds);
    caxis([vwinds(1) vwinds(end)]);
    colorbar('YTick',vwinds);
end
          
%% Outputs
[count,speeds,directions,Table] = CreateOutputs(count,vwinds,N,n,RefN,RefE);

function count = PivotTableCount(N,n,vwinds,speed,dir,NumberElements)
    count  = zeros(length(N),length(vwinds));
    for i=1:length(N)
        d1 = mod(N(i)-n,360);                                              % Direction 1 is N-n
        d2 = N(i)+n;                                                       % Direction 2 is N+n
        if d1>d2                                                           % If direction 1 is greater than direction 2 of the bin (d1 = -5 = 355, d2 = 5)
            cond = or(dir>=d1,dir<d2);                                     % The condition is satisfied whenever d>=d1 or d<d2
        else                                                               % For the rest of the cases,
            cond = and(dir>=d1,dir<d2);                                    % Both conditions must be met for the same bin
        end
        counter    = histc(speed(cond),vwinds);                            % If vmax was for instance 25, counter will have counts for these intervals: [>=0 y <5] [>=5 y <10] [>=10 y <15] [>=15 y <20] [>=20 y <25] [>=25]
        if isempty(counter); counter = zeros(1,size(count,2)); end         % If counter is empty for any reason, set the counts to 0.
        count(i,:) = cumsum(counter);                                      % Computing cumsum will make count to have the counts for [<5] [<10] [<15] [<20] [<25] [>=25] (cumulative count, so we have the radius for each speed)
    end
    count = count/NumberElements*100;                                      % Frequency in percentage

function DrawPatches(N,n,vwinds,count,colorfun,figcolor,min_radius)
    inv = strcmp(colorfun(1:3),'inv');                                     % INV = First three letters in cmap are inv
    if inv; colorfun = colorfun(4:end); end                                % if INV, cmap is the rest, excluding inv
    color = feval(colorfun,256);                                           % Create color map
    color = interp1(linspace(1,length(vwinds),256),color,1:length(vwinds));% Get the needed values.
    if inv; color = flipud(color); end;                                    % if INV, flip upside down the colormap
%     plot(0,0,'.','color',figcolor,'markeredgecolor',figcolor,'markerfacecolor',figcolor); % This will create an empty legend entry.
    hold on; axis square; axis off;

    for i=1:length(N)
        for j=length(vwinds):-1:1
            if j>1
                r(1) = count(i,j-1);
            else
                r(1) = 0;                                                  % For the first case, radius is 0
            end
            r(2)  = count(i,j);
            r     = r+min_radius;
            
            alpha = linspace(-n,n,100)+N(i);
            x1    = r(1) * sind(fliplr(alpha));
            y1    = r(1) * cosd(fliplr(alpha));
            x     = [x1 r(2)*sind(alpha)];                           % Create circular sectors
            y     = [y1 r(2)*cosd(alpha)];

            fill(x,y,color(j,:),'edgecolor',hsv2rgb(rgb2hsv(color(j,:)).*[1 1 0.7])); % Draw them in the specified coloe. Edge is slightly darker.
        end
    end

function FrequecyLabels(circles,radius,angulo,TextColor)
    s = sind(angulo); c = cosd(angulo);                                      % Get the positions in which labels must be placed
    if c>0; ha = 'left';   elseif c<0; ha = 'right'; else ha = 'center'; end % Depending on the sign of the cosine, horizontal alignment should be one or another
    if s>0; va = 'bottom'; elseif s<0; va = 'top';   else va = 'middle'; end % Depending on the sign of the sine  , vertical   alignment should be one or another
    for i=1:length(circles)
        text(radius(i)*c,radius(i)*s,[num2str(circles(i)) '%'],'HorizontalAlignment',ha,'verticalalignment',va,'color',TextColor); % display the labels for each circle
    end
    rmin = radius(1)-abs(diff(radius(1:2)));
    if rmin>0
        if c>0; ha = 'right'; elseif c<0; ha = 'left';   else ha = 'center'; end % Depending on the sign of the cosine, horizontal alignment should be one or another
        if s>0; va = 'top';   elseif s<0; va = 'bottom'; else va = 'middle'; end % Depending on the sign of the sine  , vertical   alignment should be one or another
        text(rmin*c,rmin*s,'0%','HorizontalAlignment',ha,'verticalalignment',va,'color',TextColor); % display the labels for each circle
    end
    
function CardinalLabels(circlemax,TextColor,labels)
    text( circlemax,0,[' ' labels.E],'HorizontalAlignment','left'  ,'verticalalignment','middle','color',TextColor); % East  label
    text(-circlemax,0,[labels.W ' '],'HorizontalAlignment','right' ,'verticalalignment','middle','color',TextColor); % West  label
    text(0, circlemax,labels.N      ,'HorizontalAlignment','center','verticalalignment','bottom','color',TextColor); % North label
    text(0,-circlemax,labels.S      ,'HorizontalAlignment','center','verticalalignment','top'   ,'color',TextColor); % South label
    xlim([-circlemax circlemax]);
    ylim([-circlemax circlemax]);
    
function leyenda = CreateLegend(vwinds,lablegend,legendvariable)
    leyenda = cell(length(vwinds),1);                                      % Initialize legend cell array
    for j=1:length(vwinds)
        if j==length(vwinds)                                               % When last index is reached
            string = sprintf('%s %s %g',legendvariable,'\geq',vwinds(j));  % Display wind <= max wind
        else                                                               % For the rest of the indices
            string = sprintf('%g %s %s < %g',vwinds(j),'\leq',legendvariable,vwinds(j+1)); % Set v1 <= v2 < v1
        end
        string = regexprep(string,'0 \leq','0 <');                         % Replace "0 <=" by "0 <", because wind speed = 0 is not displayed in the graph.
        leyenda{length(vwinds)-j+1} = string;
    end
    leyenda = [lablegend; leyenda];                                        % Add the title for the legend
    
function PrettyLegend(l,TextColor)
    set(l,'units','normalized','box','off');                               % Do not display the box
    POS = get(l,'position');                                               % get legend position (width and height)
    set(l,'position',[0 1-POS(4) POS(3) POS(4)],'textcolor',TextColor);    % Put the legend in the upper left corner
%     uistack(l,'bottom');                                                   % Put the legend below the axis
    
function [count,speeds,directions,Table] = CreateOutputs(count,vwinds,N,n,RefN,RefE)
    count          = [count(:,1) diff(count,1,2)];                         % Count had the accumulated frequencies. With this line, we get the frequency for each single direction and each single speed with no accumulation.
    speeds         = vwinds;                                               % Speeds are the same as the ones used in the Wind Rose Graph
    directions     = mod(RefN - N'/90*(RefN-RefE),360);                    % Directions are the directions in which the sector is centered. Convert function reference to user reference
    vwinds(end+1)  = inf;                                                  % Last wind direction is inf (for creating intervals)
    
    [directions,i] = sort(directions);                                     % Sort directions in ascending order
    count          = count(i,:);                                           % Sort count in the same way.
    
    wspeeds        = cell(1,length(vwinds)-1);
    for i=1:(length(vwinds)-1)
        if vwinds(i) == 0; s1 = '('; else s1 = '['; end                     % If vwinds(i) =0 interval is open, because count didn't compute windspeed = 0.
        wspeeds{i} = [s1 num2str(vwinds(i)) ' , ' num2str(vwinds(i+1)) ')'];% Create wind speed intervals
    end
    
    wdirs = cell(length(directions),1);
    for i=1:length(directions)
        wdirs{i} = sprintf('[%g , %g)',mod(directions(i)-n,360),directions(i)+n); % Create widn direction intervals
    end
    
    WindZeroFreqency = 100-sum(sum(count));                                % Wind speed = 0 appears 100-sum(total) % of the time. It does not have direction.
    WindZeroFreqency = WindZeroFreqency*(WindZeroFreqency/100>eps);        % If frequency/100% is lower than eps, do not show that value.

    Table            = [{'Frequencies (%)'},{''},{'Wind Speed Interval'},repmat({''},1,numel(wspeeds));'Direction Interval ()','Direction ~',wspeeds,'TOTAL';[wdirs num2cell(directions) num2cell(count) num2cell(sum(count,2))]]; % Create table cell. Ready to xlswrite.
    Table(end+1,:)   = [{'[0 , 360)','TOTAL'},num2cell(sum(count,1)),{sum(sum(count))}];
    Table(end+1,1:2) = {'No Direction', 'Wind Speed = 0'};  % Show Wind Speed = 0 on table.
    Table{end,end}   = WindZeroFreqency;