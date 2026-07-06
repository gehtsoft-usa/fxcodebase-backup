-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5227

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
    indicator:name("Alfa");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Prices");
    indicator.parameters:addString("Src", "The source stream", "", "close");
    indicator.parameters:addStringAlternative("Src", "open", "", "open");
    indicator.parameters:addStringAlternative("Src", "high", "", "high");
    indicator.parameters:addStringAlternative("Src", "low", "", "low");
    indicator.parameters:addStringAlternative("Src", "close", "", "close");
    indicator.parameters:addStringAlternative("Src", "median", "", "median");
    indicator.parameters:addStringAlternative("Src", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Src", "weighted", "", "weighted");
	
    indicator.parameters:addString("INST", "The instrument to compare with", "", "");
    indicator.parameters:setFlag("INST", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Dst", "The  stream to compare width", "", "close");
    indicator.parameters:addStringAlternative("Dst", "open", "", "open");
    indicator.parameters:addStringAlternative("Dst", "high", "", "high");
    indicator.parameters:addStringAlternative("Dst", "low", "", "low");
    indicator.parameters:addStringAlternative("Dst", "close", "", "close");
    indicator.parameters:addStringAlternative("Dst", "median", "", "median");
    indicator.parameters:addStringAlternative("Dst", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Dst", "weighted", "", "weighted");
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "", 14, 2, 1000);
    
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
   

end

local source;                             -- the indicator source
                       -- flag indicating the other data stream is being loaded
local instrument;                         -- the instrument to be loaded
local PERIOD;
local  price_first;  -- prices
local output, output_first;               -- output stream
local Indicator={};

local SourceData, loading;
local dayoffset;
local weekoffset;

function Prepare(nameOnly)
    source = instance.source;   
    price_first = source:first();
    PERIOD=instance.parameters.PERIOD;
    instrument = instance.parameters.INST;
	
	  dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    local name;
    name = profile:id() .. "(" .. source:name() .. "." .. instance.parameters.Src .. "," .. instrument .. "." .. instance.parameters.Dst .. "." .. PERIOD .. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end

   
    SourceData = core.host:execute("getSyncHistory", instrument, source:barSize(), source:isBid(), PERIOD*2, 100, 101);
	loading=true;
	
	Indicator["SRC"]=core.indicators:create("ROC", source[instance.parameters.Src],2);
	Indicator["DST"]=core.indicators:create("ROC", SourceData[instance.parameters.Dst],2);


    output = instance:addStream("C", core.Line, name, "C", instance.parameters.clr, price_first+PERIOD*2 );
    output:setWidth(instance.parameters.width);
    output:setStyle(instance.parameters.style);
    output:setPrecision(2);
   
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
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


function Update(period, mode)



     if loading then
    return;
    end
	

		 

	local p =  Initialization(period) ;
	
	
	
	 if not p then
		return;
		end
		
		
		
	Indicator["SRC"]:update(mode);
    Indicator["DST"]:update(mode);	
	
	if period < Indicator["SRC"].DATA:first() +PERIOD
	or p < Indicator["DST"].DATA:first() +PERIOD
	then
	return;
	end
	
	
 
		
		local Covar = mathex.covar (Indicator["SRC"].DATA, Indicator["DST"].DATA, period-PERIOD+1, period, p-PERIOD+1, p);
		local StDev = mathex.stdev (Indicator["DST"].DATA, p-PERIOD+1, p);        
		local beta = (Covar/StDev)^2;   
		
	if period < Indicator["SRC"].DATA:first() +PERIOD*2
	or p < Indicator["DST"].DATA:first() +PERIOD*2
	then
	return;
	end
		 
 
        output[period] = mathex.avg( Indicator["SRC"].DATA, period-PERIOD+1 , period )-   beta* mathex.avg( Indicator["DST"].DATA, p-PERIOD+1 , p ) ;      

    
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
	 return core.ASYNC_REDRAW ;
end

