-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1939

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

function Init()
    
indicator:name("50avgs");
    indicator:description("50avgs");

    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Number","Number of Lines", "", 50, 1, 100); 
	indicator.parameters:addInteger("Step","Step", "", 1, 1, 100); 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("S_COLOR", "Color  rise", "", core.rgb(21, 255, 21));
    indicator.parameters:addColor("L_COLOR", "Color fall", "", core.rgb(255, 21, 21));
	indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source = nil;
local EMAL = {};   
local EMAS = {};  
 
local i;
local Number;
local Step;
local EMA={};


function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
	 Number= instance.parameters.Number;
	 Step= instance.parameters.Step;
	
     
    for i = 2,Number, 1 do
	
	       EMA[i] = core.indicators:create("EMA", source, i*Step);
           EMAL[i] = instance:addStream("P"..i, core.Line, i, "", instance.parameters.S_COLOR,  EMA[i].DATA:first());
		    EMAL[i]:setWidth(instance.parameters.width);
            EMAL[i]:setStyle(instance.parameters.style);
	       EMAS[i] = instance:addStream("N"..i, core.Line, i, "", instance.parameters.L_COLOR,  EMA[i].DATA:first());
		     EMAS[i]:setWidth(instance.parameters.width);
             EMAS[i]:setStyle(instance.parameters.style);
		  
    end
end



function Update(period,mode)

 
		
			for i = 2,Number,1 do

			EMA[i]:update(mode);
			
			                     if period > EMA[i].DATA:first() then
					
								   if EMA[i].DATA[period] > EMA[i].DATA[period-1] then
									
									   core.drawLine(EMAL[i], core.range(period-1, period),EMA[i].DATA[period-1], period-1, EMA[i].DATA[period], period);
										
									elseif EMA[i].DATA[period] < EMA[i].DATA[period-1]  then
									
									
									   core.drawLine(EMAS[i], core.range(period-1, period), EMA[i].DATA[period-1], period-1, EMA[i].DATA[period], period);
										
									end		
			                     end
	     end   
 
end