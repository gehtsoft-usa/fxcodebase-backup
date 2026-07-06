-- Id: 2547

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2287

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
    indicator:name("Multi Time Frame Moving Average");
    indicator:description("Multi Time Frame Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 14);
    indicator.parameters:addString("MA", "Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA", "Wilders*", "", "WMA");
	indicator.parameters:addStringAlternative("MA", "VAMA (VWAP)", "", "VAMA");
    indicator.parameters:addString("TF", "Time frame", "", "H1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addString("S", "Price", "", "close");
    indicator.parameters:addStringAlternative("S", "open", "", "open");
    indicator.parameters:addStringAlternative("S", "high", "", "high");
    indicator.parameters:addStringAlternative("S", "low", "", "low");
    indicator.parameters:addStringAlternative("S", "close", "", "close");
    indicator.parameters:addStringAlternative("S", "median", "", "median");
    indicator.parameters:addStringAlternative("S", "typical", "", "typical");
    indicator.parameters:addStringAlternative("S", "weighted", "", "weighted");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color", "Color of the line line", "", core.rgb(255, 0, 0));

end

local source;
local MA;
local OUT;
local dayoffset, weekoffset;
local TF;
local Source;
local loading;
local host;
local alive;
local first;

function Prepare(nameOnly) 
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "." .. instance.parameters.S .. "," .. instance.parameters.MA .. "(" .. instance.parameters.TF .. "," .. instance.parameters.N  .. "))";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

    source = instance.source;
    host = core.host;
	first= source:first();
	
	TF=instance.parameters.TF;

    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    alive = source:isAlive();

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);

    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
    assert (core.indicators:findIndicator(instance.parameters.MA )~= nil , "Please download " .. instance.parameters.MA.. " from the FxCodeBase.com");

    Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,instance.parameters.N), 100, 101);
	loading=true;
	   
	   
		if instance.parameters.MA ~= "VAMA" then
    assert(core.indicators:findIndicator(instance.parameters.MA) ~= nil, instance.parameters.MA .. " indicator must be installed");
        MA = core.indicators:create(instance.parameters.MA, Source[instance.parameters.S], instance.parameters.N);
		else
		MA = core.indicators:create(instance.parameters.MA, Source, instance.parameters.N);
		end
 
 
   
    OUT = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color, 0, 0);
    OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function Update(period, mode)

    if period <  first or not source:hasData(period) then
	return;
	end
 

        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	
 
        MA:update(mode);
		
		    if not MA.DATA:hasData(p) then
	        return;
	        end
		
	 
              
                    OUT[period] = MA.DATA[p];
               
        
end
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
