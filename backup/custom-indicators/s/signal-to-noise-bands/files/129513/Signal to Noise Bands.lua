-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69076

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

function Init()
    indicator:name("Signal to Noise Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("signal_length", "signal_length", "", 250, 1, 2000);
    indicator.parameters:addInteger("dev_length", "dev_length", "", 10,12, 2000);	
    indicator.parameters:addDouble("power", "power", "",2);
 
  
	indicator.parameters:addGroup("M+ Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("M- Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("S+ Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(100, 100, 100));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("S- Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(100, 100, 100));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("S Line Style"); 	
    indicator.parameters:addColor("color5", "Line Color", "", core.rgb(100, 100, 100));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Color={};
local Style={};
local Width={};

local first;
local source = nil;
local Label={"M+", "M-", "S+", "S-", "S"}; 
 
local Line={};
local range1, range2; 
local signal_length, dev_length, power;
 
-- Routine
 function Prepare(nameOnly)   
 
    
	source = instance.source; 
    first=source:first() ;
	
	
	signal_length=instance.parameters.signal_length;
	dev_length=instance.parameters.dev_length;
	power=instance.parameters.power; 
	
	local Parameters= signal_length..", "..dev_length..", "..power;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 

    if   (nameOnly) then
        return;
    end
	
	
	  local i;
    for i= 1, 5, 1 do
	
	Style[i]=instance.parameters:getInteger("style" .. i);
	Width[i]=instance.parameters:getInteger("width" .. i);
	Color[i]=instance.parameters:getColor("color" .. i);
	
	Line[i] = instance:addStream("Line" .. i, core.Line, Label[i], Label[i],Color[i], first);
	Line[i]:setWidth(Width[i]);
    Line[i]:setStyle(Style[i]);
    Line[i]:setPrecision(math.max(2, source:getPrecision()));
    end
 
	
	range1= instance:addInternalStream(0, 0);
	range2= instance:addInternalStream(0, 0); 
    max_value= instance:addInternalStream(0, 0);  
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()  +signal_length
	then
	return;
	end
	
    --{"M+", "M-", "S+", "S-", "S"}; 	
		
  
	local signal=mathex.avg(source, period-signal_length+1, period);
	local stdev= mathex.stdev(source, period-dev_length+1, period);
	range1[period]= math.abs(stdev * math.log10(math.pow(signal, power) / math.pow(stdev, power)));
	Line[5][period]=signal;
	Line[3][period]=signal+range1[period];
    Line[4][period]=signal-range1[period];
 
	
 
    
 
    range2[period]=range1[period-1] * 0.618  ;

   
 
	max_value[period]=math.max( range2[period], max_value[period-1]);	
		
    Line[1][period] = signal + max_value[period];
    Line[2][period] = signal - max_value[period];
 

				  
end


 