-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66531

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

-- Indicator profile initialization routine

function Init()
    indicator:name("EUR_USD_USDOLLAR_Ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
 
 
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "EUR/USD Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "EURUSDX Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local   Period ; 
local first;
local source = nil;
 
local Oscillator;  
local ma,MA,EURUSDX;
local Source={};
local loading={};

local dayoffset;
local weekoffset;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period= instance.parameters.Period;
			
    source = instance.source;
    first= source:first();
  
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	 
    Source[1] = core.host:execute("getSyncHistory", "EUR/USD", source:barSize(), source:isBid(), 0, 100, 101);
	loading[1]=true;
	
	
	Source[2] = core.host:execute("getSyncHistory", "USDOLLAR", source:barSize(), source:isBid(), 0, 200, 201);
	loading[2]=true;
	
	
	
   
    
   local row = core.host:findTable("offers"):find("Instrument", "EUR/USD");
    assert(row ~= nil, "You must be subscribed for the EUR/USD");
	
	local row = core.host:findTable("offers"):find("Instrument", "USDOLLAR");
    assert(row ~= nil, "You must be subscribed for the USDOLLAR");
   
 
	MA = instance:addStream("MA" , core.Line, " MA "," MA ",instance.parameters.color1, first);
	MA :setWidth(instance.parameters.width1);
    MA :setStyle(instance.parameters.style1);
	
	MA:setPrecision (Source[1]:getPrecision ());
	
	
	EURUSDX = instance:addStream("EURUSDX" , core.Line, " EURUSDX "," EURUSDX ",instance.parameters.color2, first);
	EURUSDX :setWidth(instance.parameters.width2);
    EURUSDX :setStyle(instance.parameters.style2);
	
	EURUSDX:setPrecision (Source[1]:getPrecision ());
    
	ma = core.indicators:create("EMA", EURUSDX , Period);
	
end

-- Indicator calculation routine
function Update(period, mode)

   if period < first then
	return;
	end
   
   if loading1 or loading2 then
   return;
   end
   
   local p1=Initialization(1, period);
   local p2=Initialization(2, period);
   
   if p1== false or p2 == false then
   return;
   end
   
   
 
  
	
	
    
	
		
   
	
	 EURUSDX[period]=Source[1].close[p1]/Source[2].close[p2];
	
	  ma:update(mode);
	  
	  MA[period]=ma.DATA[period];			  
end

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
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


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	
	if cookie == 200 then
        loading[2] = false;
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	
	if not loading1 and not loading2 then
	
    instance:updateFrom(0);
	
	end
end