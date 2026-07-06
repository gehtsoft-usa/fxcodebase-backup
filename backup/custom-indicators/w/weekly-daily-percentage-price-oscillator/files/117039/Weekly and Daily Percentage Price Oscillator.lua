-- Id: 20368
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65629

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Weekly & Daily Percentage Price Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length1", "Length 1", "Period", 60);
	indicator.parameters:addInteger("Length2", "Length 2", "Period", 130);
	indicator.parameters:addInteger("Length3", "Length 3", "Period", 12);
	indicator.parameters:addInteger("Length4", "Length 4", "Period", 26);
	
	 indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("S1", "Show Weekly percentage price Line ", "", true);
	indicator.parameters:addBoolean("S2", "Show Daily percentage price Line ", "", false);
	indicator.parameters:addBoolean("S3", "Show Relative daily  percentage price Line ", "", true);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Weekly percentage price Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Daily percentage price Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Relative daily percentage price Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	
 

end

local first;
local source = nil;
local MA1,MA2,MA3,MA4;
local Length1, Length2, Length3,Length4;
local WPP, DPP,RDPP;
local S1, S2, S3;


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	
    source = instance.source;

	
	Length1=instance.parameters.Length1;
	Length2=instance.parameters.Length2;
	Length3=instance.parameters.Length3;	
	Length4=instance.parameters.Length4;
	S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
	
    MA1 = core.indicators:create("EMA", source, Length1);
	MA2 = core.indicators:create("EMA", source, Length2);
	MA3 = core.indicators:create("EMA", source, Length3);
	MA4 = core.indicators:create("EMA", source, Length4);
    first = math.max(MA1.DATA:first(),MA2.DATA:first(),MA3.DATA:first(),MA4.DATA:first());
    
	
	
	if S1 then
	WPP = instance:addStream("WPP", core.Line, name .. ".WPP", "WPP", instance.parameters.color1, first);
	WPP:setWidth(instance.parameters.width1);
    WPP:setStyle(instance.parameters.style1);
	else
	WPP = instance:addInternalStream(0, 0);
	end
	
	if S2 then
    DPP = instance:addStream("DPP", core.Line, name .. ".DPP", "DPP", instance.parameters.color2, first);
	DPP:setWidth(instance.parameters.width2);
    DPP:setStyle(instance.parameters.style2);
	else
	DPP = instance:addInternalStream(0, 0);
	end
	
	if S3 then
	RDPP = instance:addStream("RDPP", core.Line, name .. ".RDPP", "RDPP", instance.parameters.color3, first);
	RDPP:setWidth(instance.parameters.width3);
    RDPP:setStyle(instance.parameters.style3);
	else
	RDPP = instance:addInternalStream(0, 0);
	end
	
	
	WPP:setPrecision(math.max(2, instance.source:getPrecision()));
	DPP:setPrecision(math.max(2, instance.source:getPrecision()));
	RDPP:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

function Update(period, mode)
    MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	
    if (period<first) then
	return;
	end
	
	
 
	WPP[period]= ((MA1.DATA[period] - MA2.DATA[period])/MA2.DATA[period])*100;   
	DPP[period]= ((MA3.DATA[period] - MA4.DATA[period])/MA2.DATA[period])*100;
	RDPP[period]=WPP[period]+DPP[period]; 
	
end

