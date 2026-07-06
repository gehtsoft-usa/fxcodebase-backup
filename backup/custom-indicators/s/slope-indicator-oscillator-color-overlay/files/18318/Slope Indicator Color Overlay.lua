-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8277
-- Id: 5060

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Slope Indicator Color Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
		
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_ONLYINDICATORS);
	
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local Number;
local INDICATOR;
local OUT={};
local final={};
local FIRST=1;
local source;
local Indicator= nil;
local Count; 
local TEMP;  
local INDEX={};
local Up,Down,Neutral;

function Prepare(nameOnly)
    INDICATOR=instance.parameters.INDICATOR;
	source = instance.source;   
   	Number=instance.parameters.Number;
	Number=Number-1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	  local name =  profile:id()  ;
	
	local i;
  
     name = name..", ("  ..  INDICATOR .. ")";  	
	instance:name(name);
	if nameOnly then
		return;
	end
	
		local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local tmpparams = instance.parameters:getCustomParameters("INDICATOR");

		if  tmpprofile:requiredSource() == core.Tick then
			-- was: 
    assert(core.indicators:findIndicator(INDICATOR) ~= nil, INDICATOR .. " indicator must be installed");
			--TEMP= core.indicators:create(INDICATOR, source.close, tmpiparams);
			-- must be:
			TEMP = tmpprofile:createInstance( source.close, tmpparams);
		else
			-- was: 
			--TEMP= core.indicators:create(INDICATOR, source, tmpiparams);
			-- must be:
			TEMP = tmpprofile:createInstance(source, tmpparams);
		end
	
	 Count= TEMP:getStreamCount ();
	 
	 if Number >= Count then
	 Number = Count;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count  .. " stream(s).");
	 end			
			            i=Number;
						INDEX[i]=  TEMP:getStream (i);	
						 						
						OUT[i] = instance:addStream("out" .. i , core.Line,  i , i,  instance.parameters.Up, INDEX[i]:first());
						OUT[i]:setPrecision(5);	
						
						OUT[i]:setWidth(instance.parameters.width);
                        OUT[i]:setStyle(instance.parameters.style);
						
						FIRST = math.max(FIRST, INDEX[i]:first());				
end

function Update(period, mode)
    
	if period < FIRST then
	return;
	end
	
	TEMP:update(mode);
	local Color;
	
	OUT[ Number][period]= INDEX[Number][period];
	
	if 	OUT[ Number][period] > 	 OUT[ Number][period-1]	then
	 OUT[ Number]:setColor(period, Up);	
    elseif 	OUT[ Number][period] <	 OUT[ Number][period-1]	then
	OUT[ Number]:setColor(period, Down);
	else
	OUT[ Number]:setColor(period, Neutral);
    end	

end
	

