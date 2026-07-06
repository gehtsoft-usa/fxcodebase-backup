-- Id: 13873
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62049

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
    indicator:name("Overbought/Oversold Indicator");
    indicator:description("Overbought/Oversold Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("OBOS Calculation");	
    indicator.parameters:addInteger("Period", "OBOS Period", "", 9);
	
	indicator.parameters:addGroup("CCI Calculation");	
	 indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 14);
	 
	 
	indicator.parameters:addGroup("Filter");	
	indicator.parameters:addBoolean("Filter"  , "Use Filter", "", false);	
	indicator.parameters:addDouble("OB", "OB Level", "", 50);
	indicator.parameters:addDouble("OS", "OS Level", "", -50);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DN_color", "Color of DOWN", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addInteger("Size", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local FIRST;
local Filter;
local source = nil;

-- Streams block
local open,low, high, close;
 
local cci, CCI_Period;
local UP, DOWN;
local UP_color,DN_color;
local font, Size;
local OB,OS,OBOS;

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	CCI_Period = instance.parameters.CCI_Period;
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
	Filter = instance.parameters.Filter;
	UP_color= instance.parameters.UP_color;
	DN_color= instance.parameters.DN_color;
	Size= instance.parameters.Size;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(CCI_Period) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	    
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	cci= core.indicators:create("CCI",  source,  CCI_Period);
    OBOS= core.indicators:create("OBOS",  source,  Period);	  
	first=math.max(OBOS.DATA:first(), cci.DATA:first())+1;	  
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   
	 
    cci:update(mode);
	OBOS:update(mode);	

    if period < first  then
        return;		
    end
	 
  	
	 

	  if core.crossesOver(cci.DATA, OBOS.high, period) 
	  and (not Filter or (Filter and OBOS.low[period]  < OS))
	  then
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UP_color, "\108");
	elseif core.crossesUnder(cci.DATA,OBOS.low,period) 
	and (not Filter or (Filter and OBOS.high[period]  > OB))
	then 
	 core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DN_color, "\108");
	 else
	  core.host:execute ("removeLabel", source:serial(period)); 
	end
	
end