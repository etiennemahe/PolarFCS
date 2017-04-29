% Source code for the principle function used by PolarFCS (contains nested functions). 
% This function takes input data (first argument), an n x m matrix
% n rows are assumed to represent events and m columns assumed to be parameters (column/row headers absent)
% Variable arguments: 
% 'Parameters' a cell of strings to be used as parameter labels for plotting
% 'PlotTitle' a string title for the plot
% 'ColorProfile' RGB format color data, either a single vector (eg [0 0 1] for blue) 
% or n x 3 matrix with event-specific color settings (for data subset specific coloring)
function makefcspolarscatter(Data,varargin)
    % validate Data: must be matrix and non-negative
    if ~ismatrix(Data) | (Data<0)
        error('Invalid input data type');
    end
    % establish default parameter names
    [~,n]=size(Data);
    defParms = {};
    for i=1:n
        defParms = [defParms,{strcat('Parameter',num2str(i))}];
    end
    % use MATLAB input parser for parameter validation
    p = inputParser;
    p.FunctionName = 'makefcspolarscatter';
    addRequired(p,'Data')
    valParms = @(x) iscell(x) && isequal(numel(x),n);
    % parameter name list
    addParameter(p,'Parameters',defParms,valParms)
    % plot title
    addParameter(p,'PlotTitle','PolarFCS',@ischar);
    % color scheme; default dot color is blue
    valcolor = @(x) (isequal(size(x,1),1) || isequal(size(x,1),n)) && isequal(size(x,2),3);
    addParameter(p,'ColorProfile',[0 0 1],valcolor)
    parse(p,Data,varargin{:});
    data = p.Results.Data;
    warning('off');
    f = figure;
    hold;
    uicontrol(f,'Style','pushbutton','String','Re-Calculate','Position',[20 20 100 20],'Callback',@recalc);
    % define initial polar coordinate parameter axis theta values based on the number of parameters
    inittheta = (2*pi/n)*[1:n];
    % convert input data from polar coordinates to cartesian coordinate based polygon vertices
    [xi,yi] = pol2cart(inittheta,data);
    % calculate center of mass from polygon vertices (see polygon method below)
    [x,y] = polygon(xi,yi);
    % set dot plot dimensions & other plot parameters
    pmax = max(max([x y]))+100;
    ax = gca;
    ax.Title.String = p.Results.PlotTitle;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    ax.XLim = [-pmax pmax];
    ax.YLim = [-pmax pmax];
    ax.XTick = [];
    ax.YTick = [];
    % define initial polar axis locations & tag with parameter names
    ptarray = {}; plts = {};
    for i = 1:n
        [x1,x2]=pol2cart(inittheta(i),pmax);
        ptarray{i} = impoint(ax,x1,x2);
        setString(ptarray{i},p.Results.Parameters{i});
        plts{i} = plot(ax,[0,x1],[0,x2],'-k');
    end
    % plot calculation gate; this is a triangle that can be used to provide the user 
    % with a calculation of the number of events within it
    triangle = impoly(ax,[0,0;pmax/2,pmax/2;pmax/2,0]);
    setColor(triangle,'k');
    posn = getPosition(triangle);
    [in,on] = inpolygon(x,y,posn(:,1),posn(:,2));
    rectlab = impoint(ax,posn(2,1),posn(2,2));
    setString(rectlab,[num2str(numel(x(in))+numel(x(on))),' of ',num2str(numel(in)),' total events']);
    scatter(ax,x,y,2,p.Results.ColorProfile);
    % define line & calculation gate callbacks to make the poles and calculation gate user-alterable
    for i = 1:n
        addNewPositionCallback(ptarray{i},@(varargin)mkplt);
    end
    addNewPositionCallback(triangle,@(varargin)mkplt);
    addNewPositionCallback(rectlab,@(varargin)mkplt);
    % re-calculate callback method, invoked after users alter polar axis locations or move the calculation gate
    function mkplt()
        pos = cell2mat(transpose(cellfun(@(x) getPosition(x),ptarray,'UniformOutput',false)));
        for ii = 1:n
            set(plts{ii},'XData',[0,pos(ii,1)],'YData',[0,pos(ii,2)]);
        end
    end
    % invoked after users alter the plot in order to replot events using altered polar axis positions & scaling factors
    function recalc(source,event)
        w = waitbar(0,'Please Wait: Re-calculating...');
        items = get(ax, 'Children');
        delete(items(1)); delete(items(2))
        pos = cell2mat(transpose(cellfun(@(x) getPosition(x),ptarray,'UniformOutput',false)));
        [theta,rho]=cart2pol(pos(:,1),pos(:,2));
        [xi,yi]=pol2cart(transpose(theta),data.*(transpose(rho)/pmax));
        [x,y]=polygon(xi,yi);
        waitbar(0.5);
        posn = getPosition(triangle);
        [in,on] = inpolygon(x,y,posn(:,1),posn(:,2));
        rectlab = impoint(ax,posn(2,1),posn(2,2));
        setString(rectlab,[num2str(numel(x(in))+numel(x(on))),' of ',num2str(numel(in)),' total events']);
        scatter(ax,x,y,2,p.Results.ColorProfile);
        close(w);
    end
    % this function calculates the center of mass of an input cartesian coordinate polygon
    % inputs to this function are vectors of the x-coordinates and y-coordinates, respectively, of the polygon vertices
    % output is the x,y-coordinate pair of the polygon's center of mass
    function [x_cen,y_cen] = polygon( x, y ) 
        if ~isequal( size(x), size(y) )
          error( 'X and Y must be the same size');
        end
        xm = mean(x,2);
        ym = mean(y,2);
        x = x - xm;
        y = y - ym;
        xp = x(:, [2:end 1] );
        yp = y(:, [2:end 1] );
        a = dot(x,yp,2) - dot(xp,y,2);
        A = sum( a ) /2;
        if isequal(A,0)
            A = 0.0000000001;
        end
        xc = sum( (x+xp).*a, 2  ) /6/A;
        yc = sum( (y+yp).*a, 2  ) /6/A;
        x_cen = xc + xm;
        y_cen = yc + ym;
    end
end

