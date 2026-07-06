-- Id: 11132
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=60310


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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tide Signal");
    indicator:description("Tide Signal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("CMO", "Use CMO", "", true);
	indicator.parameters:addBoolean("CCI", "Use CCI", "", true);
	indicator.parameters:addBoolean("ADX", "Use ADX", "", true);
	indicator.parameters:addBoolean("DMI", "Use DMI", "", true);
	
	
	  indicator.parameters:addGroup("CMO Calculation");
	 indicator.parameters:addInteger("CMO_Period", "CMO Period", "",9);
	 
	 
	  indicator.parameters:addGroup("CCI Calculation");
	 indicator.parameters:addInteger("CCI_Period", "CCI Period", "",14);
	 indicator.parameters:addInteger("CCI_OB", "CCI OB Level", "",100);
	 indicator.parameters:addInteger("CCI_OS", "CCI OS Level", "",-100);
	 
	 
	 indicator.parameters:addGroup("ADX Calculation");
	 indicator.parameters:addInteger("ADX_Period", "ADX Period", "",14);
	 indicator.parameters:addInteger("ADX_Level", "ADX OB Level", "", 20);
	 
	 indicator.parameters:addGroup("DMI Calculation");
	 indicator.parameters:addInteger("DMI_Period", "DMI Period", "",14);
	 
	 indicator.parameters:addGroup("MA Calculation");
	 indicator.parameters:addInteger("MA_Period", "MA Period", "",5);
	 	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 
	  indicator.parameters:addGroup("Style");
	  
	  indicator.parameters:addColor("Up", "Up Arrow Color","", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Down", "Down Arrow Color","", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("Size", "Font Size","",10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local On={};
local Up, Down, Size, up, down;
local first;
local source = nil;
local Indicator={};
local Parameters={};  
function Prepare(nameOnly)
    
    source = instance.source; 
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	On["ADX"]=instance.parameters.ADX;
	On["CMO"]=instance.parameters.CMO;
	On["CCI"]=instance.parameters.CCI;
	On["DMI"]=instance.parameters.DMI;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Size=instance.parameters.Size;
	
	Parameters["CMO_Period"]=instance.parameters.CMO_Period;	
	Indicator["CMO"]=   core.indicators:create("CMO", source.close, Parameters["CMO_Period"]);
	 
	 
	 Parameters["CCI_Period"]=instance.parameters.CCI_Period;	
	 Parameters["CCI_OB"]=instance.parameters.CCI_OB;
	 Parameters["CCI_OS"]=instance.parameters.CCI_OS;
	Indicator["CCI"]=   core.indicators:create("CCI", source, Parameters["CCI_Period"]);
	
	
	 Parameters["ADX_Period"]=instance.parameters.ADX_Period;	
	 Parameters["ADX_Level"]=instance.parameters.ADX_Level; 
	Indicator["ADX"]=   core.indicators:create("ADX", source, Parameters["ADX_Period"]);
	
	 Parameters["DMI_Period"]=instance.parameters.DMI_Period;	
	Indicator["DMI"]=   core.indicators:create("DMI", source, Parameters["DMI_Period"]);
	
	 Parameters["MA_Period"]=instance.parameters.MA_Period;		
	 Parameters["MA_Method"]=instance.parameters.Method;
	 
    assert(core.indicators:findIndicator(Parameters["MA_Method"]) ~= nil, Parameters["MA_Method"] .. " indicator must be installed");
	Indicator["High"]=   core.indicators:create(Parameters["MA_Method"], source.high, Parameters["MA_Period"]);
	Indicator["Low"]=   core.indicators:create(Parameters["MA_Method"], source.low, Parameters["MA_Period"]);
	 
	first =  math.max(Indicator["CMO"].DATA:first(), Indicator["CCI"].DATA:first(), Indicator["ADX"].DATA:first(), Indicator["High"].DATA:first(),  Indicator["DMI"].DATA:first());

    

    up = instance:createTextOutput ("Up", "Up", "Wingdings",Size, core.H_Center, core.V_Top, Up, first);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, Down, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Indicator["CMO"]:update(mode);
	Indicator["CCI"]:update(mode);
	Indicator["ADX"]:update(mode);
	Indicator["High"]:update(mode);
	Indicator["Low"]:update(mode);
	Indicator["DMI"]:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end 
	
	if source.close[period]> Indicator["High"].DATA[period]
	and  source.close[period-1]<= Indicator["High"].DATA[period-1]
	and (Indicator["ADX"].DATA[period]>Parameters["ADX_Level"] or not On["ADX"] )
	and (Indicator["DMI"].DIP[period]>Indicator["DMI"].DIM[period] or not On["DMI"] )
	and (Indicator["CCI"].DATA[period]>Parameters["CCI_OB"] or not On["CCI"] )
	and (Indicator["CMO"].DATA[period]> 0 or not On["CMO"] )
	then	
	 up:set(period , source.high[period], "\217");
	 elseif source.close[period]< Indicator["Low"].DATA[period]
	and  source.close[period-1]>= Indicator["Low"].DATA[period-1]	
	and (Indicator["ADX"].DATA[period]>Parameters["ADX_Level"] or not On["ADX"] )
	and (Indicator["DMI"].DIP[period]<Indicator["DMI"].DIM[period] or not On["DMI"] )
	and (Indicator["CCI"].DATA[period]<Parameters["CCI_OS"] or not On["CCI"] )
	and (Indicator["CMO"].DATA[period]< 0 or not On["CMO"] )
	then
	 down:set(period , source.low[period ], "\218" );
	else
	 up:setNoData(period);
     down:setNoData(period );
	 end

	
end

