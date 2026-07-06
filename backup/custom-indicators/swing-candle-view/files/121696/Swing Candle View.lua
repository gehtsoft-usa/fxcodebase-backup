
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66850

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Swing Candle View");
    indicator:description("A chart will add a new Candle show the new candle when the price goes above or below the first candle of current swing.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addString("TF", "Time Frame ", "", "H1");
    indicator.parameters:setFlag("TF" , core.FLAG_PERIODS);
	
--	indicator.parameters:addInteger("Step","Number Of Elements","", 1);
	indicator.parameters:addBoolean("Current", "Use Current Candle","", false);
	indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
   


indicator.parameters:addGroup("Range");
   indicator.parameters:addDate("from", "From","", -1000);
   indicator.parameters:addDate("to", "To","", 0);
  indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

end
local Last;
local loading;
local History;
local open, high, low, close, volume;
local offer;
local offset;
local LastTime;
local Instrument;
local FIRST;
 local TF; 
local LastCandle; 
-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    --Step = instance.parameters.Step;
	TF = instance.parameters.TF;
	Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument .. ", " .. TF 
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
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume , TF);
   
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then	    
		 handleHistory(); 
  core.host:execute("setStatus", "");		 
    elseif cookie == 2000 then  	
          loading = false;  
            handleUpdate() 		          
			 		
    end
	
end

local lastDirection;


function calcValue( Index, period)

    
	if not instance.parameters.Current then
		     period=period-1;
    end
	  
   if period < History:first() then
   return;
   end	
   
    
		
    if period== 1 then 	
	
		instance:addViewBar(History:date(1));		
		Index=Index+1; 
		open[Index] = History.open[period];  
		low[Index] = History.low[period]; 
		close[Index]=History.close[period]; 
		high[Index] = History.high[period]; 
		volume[Index] = History.volume[period]; 
		LastCandle=period;
		 
	else 
		    
			 
	         if (History.close[period] > History.high[LastCandle]			 
			 or History.close[period] < History.low[LastCandle] )
			 and LastCandle~= period
			 then 
			  
			 Index=Index+1;
			 LastCandle=period;
			 
			 instance:addViewBar(History:date(period));
			 
			 open[Index] = History.open[period];  
	    	 low[Index] = History.low[period]; 
		     close[Index]=History.close[period]; 
		     high[Index] = History.high[period]; 
			 volume[Index] = History.volume[period]; 
			 
			 
		
		     else
			 low[Index] = math.min(low[Index], History.low[period]); 
	    	 high[Index] =  math.max(high[Index], History.high[period]); 
		     close[Index]= History.close[period]; 
			 
			  volume[Index]= mathex.sum(History.volume,LastCandle,period); 
				
		     end
				
				
	end 		
	
   
	return Index; 
           
 end

function handleHistory()
    local s = History:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        current = calcValue(current, i);
    end
    loading = false;
    LastTime=History:size()-1;
	 
end

function handleUpdate()
    
	 
	  local current = open:size() - 1;	
	   local i;		   
		   
		 local i;
			for i =   LastTime, History:size()-1, 1 do
			   current = calcValue( current  ,i);
			 end 		 
	    LastTime=History:size()-1;	
end