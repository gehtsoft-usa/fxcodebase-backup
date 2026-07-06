-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=68489


--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Colored Bollinger Band");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
 
	
    indicator.parameters:addInteger("Period", "Number of Periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation", "Number of standard deviations", "", 2.0, 0.0001, 1000.0); 
	indicator.parameters:addDouble("Narrow_Width", "Narrow width (in pips)", "", 10, 0, 10000);
	
	
    indicator.parameters:addGroup("Band Style");
 
    indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_NONE);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
 
    indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_NONE);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addGroup("Average line Style");
    indicator.parameters:addBoolean("HideAve", "Hide average line", "", false);
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb( 0, 0, 255));
    indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Channel Style");
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100); 
    indicator.parameters:addColor("Increase", "Color of increase", "Color of increase", core.rgb( 0, 255, 0)); 
    indicator.parameters:addColor("Decrease", "Color of decrease", "Color of decrease", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("IncreaseNarrow", "Color of increase (narrow)", "Color of increase", core.rgb( 0, 100, 0)); 
    indicator.parameters:addColor("DecreaseNarrow", "Color of decrease (narrow)", "Color of decrease", core.rgb(100, 0, 0));
	
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Deviation;
local Period;
local IncreaseNarrow, DecreaseNarrow;
local Increase, Decrease, Neutral;

local first;
local source = nil;
local Narrow_Width;
local Price;

-- Streams block
local TL = nil;
local BL = nil;
local AL = nil;
local Transparency;
local Indicator;
local Width;
-- Routine
function Prepare(nameOnly) 
	Price = instance.parameters.Price;
    Period = instance.parameters.Period;
    Deviation= instance.parameters.Deviation;
	Narrow_Width= instance.parameters.Narrow_Width;
	Transparency= instance.parameters.Transparency;	
	Transparency= 100-Transparency;
	
	Increase= instance.parameters.Increase;
	Decrease= instance.parameters.Decrease;
	Neutral= instance.parameters.Neutral;
	IncreaseNarrow= instance.parameters.IncreaseNarrow;
	DecreaseNarrow= instance.parameters.DecreaseNarrow;
	
    source = instance.source;	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Deviation .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Indicator = core.indicators:create("BB", source, Period, Deviation);
	
	first =Indicator.TL:first(period);
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", Neutral, first)
    TL:setWidth(instance.parameters.width1);
    TL:setStyle(instance.parameters.style1);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", Neutral, first)
    BL:setWidth(instance.parameters.width2);
    BL:setStyle(instance.parameters.style2);
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.color3, first);
        AL:setWidth(instance.parameters.width3);
        AL:setStyle(instance.parameters.style3);
	else	
	    AL = instance:addInternalStream(0,0);
    end
	
	Width = instance:addInternalStream(0,0);
	
	instance:createChannelGroup("Channel","Channel" , TL,BL, Neutral, Transparency);
end

-- Indicator calculation routine
function Update(period, mode)

	
 
    Indicator:update(mode);
    if period < first then
	return;
	end
   
	    AL[period] =  Indicator.AL[period];	         
        TL[period] = Indicator.TL[period];	         
        BL[period] =Indicator.BL[period];	      

    local Color= Neutral;

    
	Width[period]=(Indicator.TL[period]-Indicator.BL[period])/source:pipSize();
	
	if Width[period] < Narrow_Width then
	
	
	    if Width[period] > Width[period-1] then
		Color=IncreaseNarrow;
		else	
		Color=DecreaseNarrow;
		end
		
	
	else
	
		if Width[period] > Width[period-1] then
		Color=Increase;
		else	
		Color=Decrease;
		end
	end
	
    TL:setColor(period,Color);
	BL:setColor(period,  Color);	
		
end





