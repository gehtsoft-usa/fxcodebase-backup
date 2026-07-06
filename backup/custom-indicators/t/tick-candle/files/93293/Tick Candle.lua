-- Id: 11398
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60475

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Tick Candle");
    indicator:description("A chart will add a new brick After Set Number of Ticks.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	   indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", "Step","", 100);


indicator.parameters:addGroup("Range");
   indicator.parameters:addDate("from", "From","", -1000);
   indicator.parameters:addDate("to", "To","", 0);
  indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

end

local loading;
local History;
local open, high, low, close, volume;
local offer;
local offset;
local LastTime;
local Instrument;
local Count;
local FIRST;
local Step;
local LastS;
-- initializes the instance of the indicator
function Prepare(onlyName)
    FIRST=true;
    Step = instance.parameters.Step;
	Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument .. ", " .. Step  
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


    
  --  History =  core.host:execute("getSyncHistory", Instrument, "t1",instance.parameters.type, 300, 2000, 1000);
	loading = true;
 History = core.host:execute("getHistory", 1000, Instrument, "t1", instance.parameters.from, instance.parameters.to, instance.parameters.type);
  if instance.parameters.to == 0 then 
   core.host:execute("subscribeTradeEvents", 2000, "offers");  
	end
    core.host:execute("setStatus", "Loading");


    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume , "t1");
   
end

function Update(period)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then	    
		 handleHistory(); 
  core.host:execute("setStatus", "");		 
    elseif cookie == 2000 then  	
          loading = false;  		   
		  --  if message == offer then		
            handleUpdate() 		          
			--end
			
    end
	
end

local lastDirection;


function calcValue( Index, period)


   if period < History:first() then
   return;
   end

     local Last;
    
	
	
    if period== 1 then 
	
		instance:addViewBar(History:date(1));		
		Index=Index+1;
		Count=1;
		open[Index] = History[period];  
		low[Index] = History[period]; 
		close[Index]=History[period]; 
		high[Index] = History[period]; 
		
	
	else   
	    Last  = History:size() - 1;
	    Count= Count+1;
		close[Index]=History[period]; 	
		low[Index] = math.min(low[Index], History[period]); 
		high[Index]  = math.max(high[Index], History[period]); 
	end 		
	
	volume[Index] = Step; 
	
	
	if Count == Step then
	
		Index=Index+1;
		Count=0;
		
		instance:addViewBar(History:date(period));
		
		open[Index] = close[Index-1];  
		low[Index] =  close[Index-1];  
		close[Index]= close[Index-1];  
		high[Index] = close[Index-1];  
		
		
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
	   LastS= s;
end

function handleUpdate()
    
	  local s = History:size() - 1;
	  local current = open:size() - 1;	
	   local i;	
	   
	  
      if History:size()-1~=LastTime then	  
	  
	   local i;
	    for i =   LastTime, History:size()-1, 1 do
           current = calcValue( current  ,i);
		 end 		 
		 
        LastTime=History:size()-1;	
		  
      end      
end