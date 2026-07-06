-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64609
-- Id: 18017

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Corelation Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    
    indicator.parameters:addGroup("Calculation");  	
    indicator.parameters:addInteger("Multiplier", "Multiplier","",10000);
	
	indicator.parameters:addString("TF", "Time Frame", "", "H1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("color", "Line Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplier;
local first;
local source = nil;
local TF;
-- Streams block
local Out = nil;
local Source={};
local loading={};
local Instrument={"EUR/CHF", "EUR/USD", "USD/CHF"};

local dayoffset;
local weekoffset;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Multiplier=instance.parameters.Multiplier;
	TF=instance.parameters.TF;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local InstrumentFlag=nil;
	
	 dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	for i= 1, 3 , 1 do	
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", Instrument[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  Instrument[i] );    
	Source[i] = core.host:execute("getSyncHistory", Instrument[i], TF, source:isBid(), 0, 100+i, 200+i);
	loading[i]=true;
	end
     
		Out = instance:addStream("Out", core.Line, name, "Out", instance.parameters.color, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
	    Out:setWidth(instance.parameters.width);
        Out:setStyle(instance.parameters.style);
	 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


    for i= 1, 3 , 1 do
		if cookie == 100+i then
			loading[i] = false;			
		elseif cookie == 200+i then
			loading[i] = true;
		end
	
	end
	
	if not loading[1]  and not loading[2] and not loading[3] then	
	instance:updateFrom(0);
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function Update(period)

  local p1=Initialization(1, period);
  local p2=Initialization(2, period); 
  local p3=Initialization(3, period); 
  
     if not p1 or not p2 or not p3  then
	 return;
	 end

  Out[period]= Multiplier*(Source[1].close[p1] -(Source[2].close[p2] * Source[3].close[p3]))
end



