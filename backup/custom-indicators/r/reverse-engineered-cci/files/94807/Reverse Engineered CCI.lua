-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60880

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
    indicator:name("Reverse Engineered Commodity Channel Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N","CCI Period","", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Cental Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width1", "Line Color","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("Color2", "OverBought Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width2", "Line Color","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("Color3", "OverSold Line Color","", core.rgb(255, 0,0));
    indicator.parameters:addInteger("width3", "Line Color","", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addColor("Color4", "CCI Line Color","", core.rgb(0, 0,255));
    indicator.parameters:addInteger("width4", "Line Color","", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels"); 
    indicator.parameters:addDouble("OB", "OverBought Level", "", 100, -1000, 1000);
    indicator.parameters:addDouble("OS",  "OverSOld Level","", -100, -1000, 1000);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local OB, OS;
local first;
local source = nil;
local tp = nil;

-- Streams block
local Top,Bottom, Central,CCI;
-- Routine
 function Prepare(nameOnly)   
 
 
     n = instance.parameters.N;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " .. n .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
     


    source = instance.source.typical;
    first = source:first();
	OB = (instance.parameters.OB) ;
	OS = (instance.parameters.OS);
	
 
    first = source:first() + n - 1;
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.Color1, first);
    Central:setWidth(instance.parameters.width1);
    Central:setStyle(instance.parameters.style1);
    Central:setPrecision(2);
	
	Top = instance:addStream("OB", core.Line, name, "OverBought", instance.parameters.Color2, first);
    Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
    Top:setPrecision(2);
	
	
	Bottom = instance:addStream("OS", core.Line, name, "OverSold", instance.parameters.Color3, first);
    Bottom:setWidth(instance.parameters.width3);
    Bottom:setStyle(instance.parameters.style3);
    Bottom:setPrecision(2);
	
	CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.Color4, first);
    CCI:setWidth(instance.parameters.width4);
    CCI:setStyle(instance.parameters.style4);
    CCI:setPrecision(2);

     
end

-- Indicator calculation routine
function Update(period)
    if period <= first then
	return;
	end
        local from = period - n + 1;
        local to = period;

        local mean = mathex.avg(source, from, to);
        local meandev = mathex.meandev(source, from, to);
   
        CCI[period]=source[period];
        Central[period]= mean ;
		
        if (meandev ~= 0) then 
		Top[period]= mean+  OB*meandev* 0.015 ;		
		Bottom[period]= mean+ OS*meandev * 0.015;
		end
    
end







