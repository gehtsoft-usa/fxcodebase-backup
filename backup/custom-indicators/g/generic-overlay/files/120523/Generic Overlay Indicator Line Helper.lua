-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62211

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
    indicator:name("Generic Overlay Indicator Line Helper");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	

    indicator.parameters:addGroup("Data Selection");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);
	
	
	indicator.parameters:addString("Type", "Type", "Type" , "Slope");
    indicator.parameters:addStringAlternative("Type", "Slope", "Slope" , "Slope");
    indicator.parameters:addStringAlternative("Type", "Position relation to the signal line", "Position relation to the signal line" , "Signal");
	indicator.parameters:addStringAlternative("Type", "Level", "Level" , "Level");
	indicator.parameters:addStringAlternative("Type", "Overbought / Oversold", "Overbought / Oversold" , "Overbought/Oversold"); 
	indicator.parameters:addStringAlternative("Type", "Line Color","" , "Color"); 
	
	indicator.parameters:addInteger("Overbought", "Overbought Level", "", 80);
	indicator.parameters:addInteger("Oversold", "Oversold Level", "", 20);
	indicator.parameters:addInteger("Level", "Level", "", 0);
		
	indicator.parameters:addGroup("Signal Line");
 
	indicator.parameters:addInteger("Period", "Smoothing Period", "", 20, 1 , 1000);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
 

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Up", "Up  Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128)); 
 
 
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
   
   
end 

 
local Number;
local INDICATOR;
local final={};
local FIRST=1;
local source;
local Indicator= nil;
local Count; 
local INDEX;
local Up,Down,Neutral;
local Method;
local MA;
local Period;
local Type;
local first;
local Overbought, Oversold,Level;
local  Histogram=nil;

local  Line=nil;
local  Signal=nil;

function Prepare(nameOnly)
 
    source = instance.source;	
	 

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	 instance:name(name );
	if nameOnly then
		return;
	end
	 
	Period=instance.parameters.Period;
    Method=instance.parameters.Method; 
    INDICATOR=instance.parameters.INDICATOR;
    Overbought=instance.parameters.Overbought;
    Oversold=instance.parameters.Oversold;	
	Level=instance.parameters.Level;
	Type=instance.parameters.Type;
   	Number=instance.parameters.Number;
	Number=Number-1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	 
			assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method ..".LUA indicator");
 
	
		local iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local iparams = instance.parameters:getCustomParameters("INDICATOR");

		if  iprofile:requiredSource() == core.Tick then			
			Indicator = iprofile:createInstance( source.close, iparams);
		else
			Indicator = iprofile:createInstance(source, iparams);
		end
	
	 Count= Indicator:getStreamCount ();
	 
	 if Number >= Count then
	 Number = Count;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count  .. " stream(s).");
	 end	 
	 
	INDEX=  Indicator:getStream (Number);	
			

	if Type== "Signal" then
	MA = core.indicators:create(Method, INDEX, Period);		
	FIRST = math.max(FIRST, MA.DATA:first()) ;
    else
    FIRST = math.max(FIRST, INDEX:first()) ;	
	end		

 	Line = instance:addStream("Line", core.Line, "Line", "Line", core.rgb(0, 0, 0), FIRST);
 
 	Line:setWidth(instance.parameters.width);
 	Line:setStyle(instance.parameters.style);
		
end



function Update(period, mode)

    
	
	if period < FIRST then
	Line:setColor(period,  Neutral);
	return;
	end
	

 Indicator:update(mode);
 
 Line[period]=INDEX[period];
	
	            if Type== "Signal" then
				MA:update(mode);
				end
				
										
													if Type == "Signal" then	
														if INDEX[period]> MA.DATA[period] then
														Line:setColor(period,  Up);
														elseif  INDEX[period]< MA.DATA[period] then
														Line:setColor(period,  Down);
														else
														Line:setColor(period,  Neutral);
														end
													elseif Type == "Slope" then
														if INDEX[period]> INDEX[period-1] then
														Line:setColor(period,  Up);	
														elseif  INDEX[period]< INDEX[period-1] then
														Line:setColor(period,  Down);
														else
														C2=6;
														C1=5;
														end
													elseif Type == "Level" then
														if INDEX[period]> Level then
														Line:setColor(period,  Up);
														elseif INDEX[period]< Level then
														Line:setColor(period,  Down);
														else
														Line:setColor(period,  Neutral);
														end
													elseif Type == "Overbought/Oversold" then	
														if INDEX[period]> Overbought then
														Line:setColor(period,  Up);
														elseif INDEX[period]< Oversold then
														Line:setColor(period,  Down);
														else
														Line:setColor(period,  Neutral);
														end
													elseif Type == "Color" then	
													    Line:setColor(period,  INDEX:colorI(period));
													end
												 
									         	     			
				
	
end
 
