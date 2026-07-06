-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=139


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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Gann Hi-lo Activator SSL");
    indicator:description("When red line is above the candle, sell.When red line is below the canle, buy.");    
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Calculation");   
	
	indicator.parameters:addString("TF", "Time frame to calculate MA", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("N", "Number of periods", "The number of periods.", 10, 2, 1000);
	
	
	indicator.parameters:addGroup("Style");    
	indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Up", "Up Line Color", "Color of the Up line.", core.rgb(0, 255, 0));    
	indicator.parameters:addColor("Dn", "Up Line Color", "Color of the Up line.", core.rgb(255, 0, 0)); 
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams

-- Parameters block
local first;
local source = nil;
local pips;

-- Streams block
local SSL = nil;

-- Internal streams and indicators
local Indicator = nil;

local TF, dayoffset, weekoffset, SourceData,loading;

-- Routine
function Prepare(nameOnly)
    source = instance.source;    
    local n = instance.parameters.N;                  
    first = n + source:first();
    
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("SSL") ~= nil, "Please, download and install SSL.LUA indicator");
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	 
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,first), 100, 101);
	loading=true; 
     
 
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	local Test = core.indicators:create("SSL", source ,n);   
	first= Test.DATA:first() ; 		
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,first), 100, 101);
	loading=true;
	
	
    
    Indicator = core.indicators:create("SSL", SourceData , n,instance.parameters.Up, instance.parameters.Dn);
     
    
    SSL = instance:addStream("SSL", core.Line, name, "SSL", instance.parameters.Up, first);   
    SSL:setWidth(instance.parameters.width);
	SSL:setStyle(instance.parameters.style);	
    SSL:setPrecision(math.max(2, source:getPrecision()));
end

         
-- Indicator calculation routine
function Update(period, mode)   



    local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
    Indicator:update(mode);
    
    if period <first then   
    return;
    end
	

        
       
            SSL[period] = Indicator.DATA[p]; 
			 
            SSL:setColor(period,Indicator.DATA:colorI(p))
     
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


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

