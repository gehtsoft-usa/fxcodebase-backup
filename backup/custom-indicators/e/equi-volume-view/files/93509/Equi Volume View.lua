-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60540

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Equi Volume View");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
   indicator.parameters:addString("TF", "Time Frame", "", "m1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
   


indicator.parameters:addGroup("Range");
   indicator.parameters:addDate("from", "From","", -1000);
   indicator.parameters:addDate("to", "To","", 0);
  indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
  
    indicator.parameters:addInteger("Size", "Size", "Size", 5, 0, 20);
   indicator.parameters:addColor("Up", "Up Color", "", core.COLOR_UPCANDLE );
    indicator.parameters:addColor("Down", "Down Color", "",core.COLOR_DOWNCANDLE );
end

local loading;
local History;
local open, high, low, close, volume;
local LastTime;
local Instrument;
local TF;
local Up,Down;
local Size;
-- initializes the instance of the indicator
function Prepare(onlyName)
    
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	TF = instance.parameters.TF;
	Size= instance.parameters.Size;
	Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument .. ", " .. TF;  
    instance:name(name);

    if onlyName then
        return ;
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row=nil;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == Instrument then
            break;
        end
        row = enum:next();
    end
	

    assert(row ~= nil, "Selected instrument is not available");
    offer = row.OfferID;

    instance:initView(Instrument, row.Digits, row.PointSize, true, true);

 History = core.host:execute("getHistory", 1000, Instrument, TF, instance.parameters.from, instance.parameters.to, instance.parameters.type);
 loading = true;
	
  if instance.parameters.to == 0 then 
   core.host:execute("subscribeTradeEvents", 2000, "offers");  
	end
    core.host:execute("setStatus", "Loading");


    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
	--volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);
 --instance:createCandleGroup("candle", "candle", open, high, low, close, volume , TF);
	
	open:setVisible(false);
    high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
   --volume:setVisible(false);
	
	 instance:ownerDrawn(true);
  
   
end

local Initialized= false;

function Draw (stage, context)

 
   
 if stage ~= 2 then
 return;
 end
 
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    local First, Last = context:firstBar(), context:lastBar();
 
           if not Initialized then
		   
            context:createPen(1, context.SOLID, 1, Up);
			context:createSolidBrush(2, Up );
			
			context:createPen(3, context.SOLID, 1, Down );
			context:createSolidBrush(4, Down );
			transparency = context:convertTransparency(0);
			 
            Initialized = true;           
           end

	local i,j,x,x1,x2,y1,y2,y3,y4;	
	
	local max;
	
    for j= History:first(),History:size() - 1, 1 do	
	i= (j-1)*Size+2
	
	if j> Size  and  i >= First  and i <= Last  then
	max=mathex.max(History.volume, j-Size,j);
	
	
	
	visible, y1=  context:pointOfPrice (open[i]);
    visible, y2=  context:pointOfPrice (close[i]);
	visible, y3=  context:pointOfPrice (low[i]);
    visible, y4=  context:pointOfPrice (high[i]);
	
	x , x1, x2 = context:positionOfBar (i);
	local width = ((((x2-x1)/2)*(Size))/100)* ((History.volume[j]/ max)*100);
	x1=x - width;
	x2=x + width;
	
	if x2< x1 then
	x2=x;
     x1=x;
	end
	
 
		if y1 > y2 then
		context:drawRectangle(1, 2, x1, y1, x2 + 1,  y2 + 1, transparency);
		 context:drawLine (1, x, y3, x, y4 + 1);
		else
		context:drawRectangle(3, 4, x1, y1, x2 + 1,  y2 + 1, transparency);
		 context:drawLine (3, x, y3, x, y4 + 1);
		end
    end	
 
	
 end
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then	    
		 handleHistory(); 
  core.host:execute("setStatus", "");		 
    elseif cookie == 2000 then  	
          loading = false;   
           handleUpdate() ;  
    end
	
end




function calcValue(  period)


   if period < History:first() then
   return;
   end	
        if period == 1 then
		instance:addViewBar(History.close:date(0));		
		end
		
	
		
		if (not  open:hasData((period-1)*Size+Size))
		then	

        for k= 1, Size, 1 do 		
		instance:addViewBar(History.close:date(period)+0.000001*k);	
		end
   	
        end
		
		
		for k= 1, Size, 1 do
		open[(period-1)*Size+k] = History.open[period];  
		low[(period-1)*Size+k] = History.low[period]; 
		close[(period-1)*Size+k]=History.close[period]; 
		high[(period-1)*Size+k] = History.high[period]; 
		--volume[(period-1)*Size+k] = History.volume[period]; 
		
		end
		
  
		
           
 end

function handleHistory()
   
   
    for i = 1, History:size() - 1, 1 do
         calcValue( i);
    end
    loading = false;
    LastTime=History:size()-1;

end

function handleUpdate()
    
	   local i;
	    for i =   LastTime, History:size()-1, 1 do
           calcValue(  i);
		 end 		 
		 
        LastTime=History:size()-1;	
	    
end