-- Id: 14508

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MK combo with Real volume/Transactions");
    indicator:description("MK combo with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
	
	indicator.parameters:addGroup("SSD Calculation");
    indicator.parameters:addInteger("k", "%K periods","", 5, 2, 1000);
    indicator.parameters:addInteger("sd", "%D slowing periods","", 3, 2, 1000);
    indicator.parameters:addInteger("d","%D period","", 3, 2, 1000);
	
 
	indicator.parameters:addGroup("TBS Calculation"); 

    indicator.parameters:addInteger("K", "%K periods","", 5, 2, 1000);
    indicator.parameters:addInteger("SD",  "%D slowing periods","", 3, 2, 1000);
    indicator.parameters:addInteger("D", "%D period","", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Combo_color", "Color of Combo", "Color of Combo", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local k, sd, d,ssd;
local first;
local source = nil;
local MVAT_K, MVAT_D, K,SD,D,tbs,Price;
-- Streams block
local Combo = nil;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)
    source = instance.source;   
	k=instance.parameters.k;
	sd=instance.parameters.sd;
	d=instance.parameters.d;
	MVAT_K=instance.parameters.MVAT_K;
	MVAT_D=instance.parameters.MVAT_D;
	K=instance.parameters.K;
	SD=instance.parameters.SD;
	D=instance.parameters.D;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
		
	assert(core.indicators:findIndicator("TBS") ~= nil, "Please, download and install TBS.LUA indicator");
	
	ssd = core.indicators:create("SSD", source, k, sd, d);
	tbs= core.indicators:create("TBS", Ind.DATA, "B",K, SD, D,MVAT_K,MVAT_D );
	first = math.max(ssd.D:first(),tbs.D:first());

   

    if (not (nameOnly)) then
        Combo = instance:addStream("Combo", core.Line, name, "Combo", instance.parameters.Combo_color, first);
    Combo:setPrecision(math.max(2, instance.source:getPrecision()));
		Combo:setWidth(instance.parameters.width);
        Combo:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end

    ssd:update(mode);
	tbs:update(mode);
    if period < first or not source:hasData(period) then
	return;
	end
	
 
        Combo[period] = Combo[period-1]+(ssd.K[period] - ssd.D[period])*(tbs.K[period] - tbs.D[period]);
     
end

function AsyncOperationFinished(cookie, success, message)

end
