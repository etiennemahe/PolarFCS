function makefcspolarscatter(Data,varargin)
    if ~ismatrix(Data) | (Data<0)
        error('Invalid input data type');
    end
    [~,n]=size(Data);
    defParms = {};
    for i=1:n
        defParms = [defParms,{strcat('Parameter',num2str(i))}];
    end
    p = inputParser;
    p.FunctionName = 'makefcspolarscatter';
    addRequired(p,'Data')
    valParms = @(x) iscell(x) && isequal(numel(x),n);
    addParameter(p,'Parameters',defParms,valParms)
    addParameter(p,'PlotTitle','PolarFCS',@ischar);
    valcolor = @(x) (isequal(size(x,1),1) || isequal(size(x,1),n)) && isequal(size(x,2),3);
    addParameter(p,'ColorProfile',[0 0 1],valcolor)
    parse(p,Data,varargin{:});
    data = p.Results.Data;
    warning('off');
    f = figure;
    hold;
    uicontrol(f,'Style','pushbutton','String','Re-Calculate','Position',[20 20 100 20],'Callback',@recalc);
    % define initial scatter
    inittheta = (2*pi/n)*[1:n];
    % SLOW HERE
    [xi,yi] = pol2cart(inittheta,data);
    [x,y] = polygon(xi,yi);
    % END SLOW
    pmax = max(max([x y]))+100;
    ax = gca;
    ax.Title.String = p.Results.PlotTitle;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    ax.XLim = [-pmax pmax];
    ax.YLim = [-pmax pmax];
    ax.XTick = [];
    ax.YTick = [];
    % define initial polar axis locations
    ptarray = {}; plts = {};
    for i = 1:n
        [x1,x2]=pol2cart(inittheta(i),pmax);
        ptarray{i} = impoint(ax,x1,x2);
        setString(ptarray{i},p.Results.Parameters{i});
        plts{i} = plot(ax,[0,x1],[0,x2],'-k');
    end
    % plot initial calculation rectangle
    triangle = impoly(ax,[0,0;pmax/2,pmax/2;pmax/2,0]);
    setColor(triangle,'k');
    posn = getPosition(triangle);
    [in,on] = inpolygon(x,y,posn(:,1),posn(:,2));
    rectlab = impoint(ax,posn(2,1),posn(2,2));
    setString(rectlab,[num2str(numel(x(in))+numel(x(on))),' of ',num2str(numel(in)),' total events']);
    scatter(ax,x,y,2,p.Results.ColorProfile);
    %define line & rectangle callbacks
    for i = 1:n
        addNewPositionCallback(ptarray{i},@(varargin)mkplt);
    end
    addNewPositionCallback(triangle,@(varargin)mkplt);
    addNewPositionCallback(rectlab,@(varargin)mkplt);
    % re-calculate callback method
    function mkplt()
        pos = cell2mat(transpose(cellfun(@(x) getPosition(x),ptarray,'UniformOutput',false)));
        for ii = 1:n
            set(plts{ii},'XData',[0,pos(ii,1)],'YData',[0,pos(ii,2)]);
        end
    end
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

