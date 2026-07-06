-- Id: 20493
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65510

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
    indicator:name("Detrended Price Oscillator (DPO)");
    indicator:description("Detrended Price Oscillator (DPO)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "Period", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDPO", "Color of DPO Line", "Color of DPO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
   
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addBoolean("Lines", "Show Lines", "" , false); 
	  indicator.parameters:addBoolean("Channel", "Show Channel", "" , true); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
end

local first;
local source = nil;
local MA;
local N;
local Shift;
local Up, Down,Neutral;
local Lines,Channel;
local Transparency;
local Zero;
 function Prepare(nameOnly)   
 
    source = instance.source;
    N=instance.parameters.N;
   Up = instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   Lines= instance.parameters.Lines;
   Channel= instance.parameters.Channel;
   
    Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	
	Shift = (N / 2 + 1);
	
    MA = core.indicators:create("MVA", source, N);
    first = MA.DATA:first()+Shift;
    if Lines then
    DPO = instance:addStream("DPO", core.Line, name .. ".DPO", "DPO", instance.parameters.clrDPO, first+Shift);
	DPO:setWidth(instance.parameters.width);
    DPO:setStyle(instance.parameters.style);
	else	
	DPO = instance:addStream("DPO", core.Line, name .. ".DPO", "DPO", instance.parameters.clrDPO, first+Shift);
	DPO:setWidth(instance.parameters.width);
    DPO:setStyle(core.LINE_NONE);
	end
	
	 
	
   if Channel then    
   Zero=instance:addStream("Zero", core.Line, name, "Zero", core.rgb( 128, 128, 128), first);
   instance:createChannelGroup("Group","Group" , DPO, Zero, Neutral, Transparency);
   else   
   Zero=instance:addInternalStream(first, 0);
   end
	
    DPO:setPrecision(math.max(2, instance.source:getPrecision()));
	Zero:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA:update(mode);
    if (period<first) then
	return;
	end
	
     DPO[period]=source[period]-MA.DATA[period-Shift];
	 Zero[period]=0;
	
	 
	 
	            if DPO[period] > 0 then 
				DPO:setColor(period, Up);
				elseif  DPO[period]< 0  then
				DPO:setColor(period, Down);	
				else
				DPO:setColor(period, Neutral);
				end
 
end

