-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15195
-- Id: 6171

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Generic Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
		
    indicator.parameters:addGroup("Data Selection");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);
		
	indicator.parameters:addGroup("Data Smoothing");
	indicator.parameters:addBoolean("Smoothing", "Use Data Smoothing", "", false);	
	indicator.parameters:addInteger("Period", "Smoothing Period", "", 20, 1 , 1000);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA"); 	
	
	indicator.parameters:addGroup("Channel Calculation");		
	indicator.parameters:addInteger("SDP", "SD Period", "", 20, 1 , 1000);
	indicator.parameters:addDouble("Multi", "SD Period", "", 1);	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show Central Line", "", false);
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Mid", "Central Line Color", "", core.rgb(0, 0,255));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));

end

local Number;
local INDICATOR;
local final={};
local FIRST=1;
local source;
local Indicator= nil;
local Count; 
local TEMP;  
local INDEX={};
local Up,Down,Neutral;
local SDP;
local Top, Bottom, Central;
local Smoothing,Show;
local Method,Multi;
local MA;
local Period;
function Prepare(nameOnly)
    Period=instance.parameters.Period;
    Multi=instance.parameters.Multi;
     Method=instance.parameters.Method; 
     Smoothing=instance.parameters.Smoothing;
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Show=instance.parameters.Show;
	Mid=instance.parameters.Mid;

    INDICATOR=instance.parameters.INDICATOR;
	SDP=instance.parameters.SDP;
	
	
	source = instance.source;   
   	Number=instance.parameters.Number;
	Number=Number-1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	  local name =  profile:id()  ;
	
	local i;
	
			assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method ..".LUA indicator");

	
  
     name = name..", ("  ..  INDICATOR ..", " ..SDP ..", " .. Multi .. ", " .. Method .. ", " ..Period .. ")";  	
	instance:name(name);
	if nameOnly then
		return;
	end
	
		local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local tmpparams = instance.parameters:getCustomParameters("INDICATOR");

		if  tmpprofile:requiredSource() == core.Tick then			
			TEMP = tmpprofile:createInstance( source.close, tmpparams);
		else
			TEMP = tmpprofile:createInstance(source, tmpparams);
		end
	
	 Count= TEMP:getStreamCount ();
	 
	 if Number >= Count then
	 Number = Count;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count  .. " stream(s).");
	 end			
			            i=Number;
						INDEX[i]=  TEMP:getStream (i);	

   
						
				
						FIRST = math.max(FIRST, INDEX[i]:first()) ;		

		
    if (not (nameOnly)) then
	
	     if not Smoothing and not Show then
		 Central = instance:addInternalStream( FIRST , 0);
		 elseif Smoothing and  Show then		 
		 Central = instance:addStream("CENTRAL", core.Line, name,  Method .." of " .. INDICATOR , Mid, FIRST);
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		 elseif Show then		 
		 Central = instance:addStream("CENTRAL", core.Line, name,  INDICATOR , Mid, FIRST);
		 else
		  Central = instance:addInternalStream( FIRST , 0);
		 end
		 
		   if Smoothing then
			MA = core.indicators:create(Method, TEMP.DATA, Period);			
			end	
	
         Top = instance:addStream("TOP", core.Line, name, "Top", Up, FIRST + SDP);		
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		 Bottom = instance:addStream("BOTTOM", core.Line, name, "Bottom", Down, FIRST + SDP);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    end				  
    
end

function Update(period, mode)

    TEMP:update(mode);
	
	if period < FIRST then
	return;
	end
	
	if Smoothing then
		MA:update(mode);
		  if period > MA.DATA:first() then
		  Central[period] = MA.DATA[period];
		  end
	else
	Central[period] = INDEX[Number][period];
	end
    
	if period < FIRST + SDP then
	return;
	end
	
	local STDEV;
	
	
	STDEV= mathex.stdev (Central, period-SDP+1, period);
	
	
   Top[period] = Central[period] +  STDEV* Multi ;
   Bottom[period] = Central[period] - STDEV* Multi;
	
end
	

