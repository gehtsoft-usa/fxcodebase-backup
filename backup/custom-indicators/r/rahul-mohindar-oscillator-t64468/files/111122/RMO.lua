-- Id: 17676
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64468

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
    indicator:name("Rahul Mohindar Oscillator");
    indicator:description("Rahul Mohindar Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Len1", "Len 1", " ", 2 );
	indicator.parameters:addInteger("Len2", "Len 2", " ", 10 );
	indicator.parameters:addInteger("Len3", "Len 3", " ", 30 );
	indicator.parameters:addInteger("Len4", "Len 3", " ", 81 );
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of RMO", core.rgb(0, 255, 0));
   indicator.parameters:addColor("Down", "Color of Down", "Color of RMO", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of RMO", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local EMA1, EMA2, EMA3, EMA4,EMA5, EMA6;
local MA1, MA2, MA3, MA4,MA5, MA6,MA7, MA8, MA9, MA10;
local Len1, Len2, Len3, Len4;
local FIRST;
local source = nil;
local Raw1, RMO,Raw2,Raw3;
local Up, Down,Neutral;
 
-- Routine
function Prepare(nameOnly)
     
 
	Len1 = instance.parameters.Len1;
	Len2 = instance.parameters.Len2;
	Len3 = instance.parameters.Len3;
	Len4 = instance.parameters.Len4;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
    source = instance.source;
  
	
    local name = profile:id() .. "(" .. source:name()    .. ")";
    instance:name(name);
	if nameOnly then
	end
	MA1 = core.indicators:create("MVA", source.close, Len1);
	MA2 = core.indicators:create("MVA", MA1.DATA, Len1);
	MA3 = core.indicators:create("MVA", MA2.DATA, Len1);
	MA4 = core.indicators:create("MVA", MA3.DATA, Len1);
	MA5 = core.indicators:create("MVA", MA4.DATA, Len1);
	MA6 = core.indicators:create("MVA", MA5.DATA, Len1);
	MA7 = core.indicators:create("MVA", MA6.DATA, Len1);
	MA8 = core.indicators:create("MVA", MA7.DATA, Len1);
	MA9 = core.indicators:create("MVA", MA8.DATA, Len1);
	MA10 = core.indicators:create("MVA", MA9.DATA, Len1);
	
 

	
	
	Raw1 = instance:addInternalStream(0, 0);
	Raw2= instance:addInternalStream(0, 0);
	Raw3= instance:addInternalStream(0, 0);
	
	EMA1 = core.indicators:create("EMA", Raw1, Len3);
	EMA2 = core.indicators:create("EMA", EMA1.DATA, Len3);
		
	EMA3 = core.indicators:create("EMA", Raw2, Len3);
	EMA4 = core.indicators:create("EMA", EMA3.DATA, Len3);
	
	EMA5 = core.indicators:create("EMA", Raw1, Len4);
	EMA6 = core.indicators:create("EMA", EMA3.DATA, Len4);
	
   FIRST= math.max(EMA1.DATA:first(), EMA2.DATA:first(), EMA3.DATA:first(), EMA4.DATA:first(), EMA5.DATA:first(), EMA6.DATA:first());
	
   

    if (not (nameOnly)) then
     RMO = instance:addStream("RMO", core.Bar, name, "RMO", Up, FIRST );    
    RMO:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	MA5:update(mode);
	MA6:update(mode);
	MA7:update(mode);
	MA8:update(mode);
	MA9:update(mode);
	MA10:update(mode);
	
	if period < math.max(MA10.DATA:first(), source:first()+ Len2) then
	return;
	end

  local min,max=mathex.minmax(source, period-Len2+1, period);
  local fix= max-min;
  
 
            if  math.abs(fix) == 0 then
                fix = 1;
			end
			
 
            Raw1[period] = 100*(source.close[period] -  (MA1.DATA[period] + MA2.DATA[period] + MA3.DATA[period]
                                    + MA4.DATA[period] + MA5.DATA[period] + MA6.DATA[period]
                                    + MA7.DATA[period] + MA8.DATA[period] + MA9.DATA[period]
                                    + MA10.DATA[period])/10)/fix;

	EMA1:update(mode);
	EMA2:update(mode);
	
    if period < EMA2.DATA:first() then
    return;
    end
	
	Raw2[period] = 2*EMA1.DATA[period] - EMA2.DATA[period];
	  
	  
	EMA3:update(mode);
	EMA4:update(mode);
	
	
	 if period < EMA4.DATA:first() then
    return;
    end
	Raw3[period] = 2*EMA3.DATA[period] - EMA4.DATA[period];
	  
	  
	EMA5:update(mode);
	EMA6:update(mode);		

   if period < FIRST then
   return;
   end
   

 
 
 
   RMO[period] = 2*EMA5.DATA[period] - EMA6.DATA[period];
 	
  
  
             if (RMO[period] > 0  and Raw2[period] > 0  and Raw3[period] > 0) then  RMO:setColor(period, Up);
             elseif (RMO[period] < 0   and Raw2[period] < 0  and Raw3[period] < 0)  then      RMO:setColor(period, Down);
             else
             RMO:setColor(period, Neutral);
			 end
				
end
