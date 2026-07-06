-- Id: 13435
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61721

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
    indicator:name("MA Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Change", "Only on Change", "Change", true);
	
	Add(1, 10, "EMA");
	Add(2,50, "EMA");
	Add(3, 20, "MVA");
	Add(4, 40, "MVA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrup", "Arrow color", "", core.rgb(0, 255,0));
    indicator.parameters:addColor("clrdown", "Arrow color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "", 10);
end

function Add(id, period, ma)
   indicator.parameters:addGroup( id.. ". MA Calculation");
    indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addInteger("Period"..id, "MA Period", "", period);
	
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , ma);
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	 
end

local source;
local up, down;
local first; 
local Period={};
local Method={};
local MA={};
local Price={};
local first;
local Last;
local Change;
local Size;
function Prepare(nameOnly)
    source = instance.source;
	instance:name(profile:id());
	if nameOnly then
		return;
	end
	Change=instance.parameters.Change;
	Size=instance.parameters.Size;
	
	first = source:first();
	
	Last = instance:addInternalStream(0, 0);
	
    for i= 1 , 4  , 1 do
    Period[i]=  instance.parameters:getInteger("Period" .. i);
	Method[i]=  instance.parameters:getString("Method" .. i);
	Price[i]= instance.parameters:getString("Price" .. i);
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
	MA[i] = core.indicators:create(Method[i], source[Price[i]], Period[i]);
	first=math.max(first, MA[i].DATA:first());
	end
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrup, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrdown, 0);    
end
 

function Update(period, mode)
     
	 
	 
	 for i= 1, 4 ,  1 do
	 MA[i]:update(mode);
	 end
	 
     if period <first then
	 return;
	 end
	 
	
    
        if  MA[1].DATA[period]> MA[2].DATA[period] 
		and  MA[3].DATA[period]> MA[4].DATA[period] 
		and (Last[period-1]~= 1 or not Change )
		then        
		up:set(period, source.low[period], "\233");
		Last[period]=1;
		elseif  MA[1].DATA[period]< MA[2].DATA[period] 
		and  MA[3].DATA[period]< MA[4].DATA[period]
		and (Last[period-1]~= -1 or not Change )
		then
		down:set(period, source.high[period], "\234");
		Last[period]=-1;
		else
		 Last[period]= Last[period-1];
        end

       
end