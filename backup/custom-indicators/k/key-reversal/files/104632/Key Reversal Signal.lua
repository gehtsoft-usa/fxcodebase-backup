-- Id: 20694
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63114


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
    indicator:name("Key Reversal");
    indicator:description("Key Reversal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
 
	indicator.parameters:addBoolean("Trend", "Use Trend Filter", "", true);
	indicator.parameters:addInteger("Period", "Trend Period", "", 2);
 --   indicator.parameters:addInteger("Size", "Font Size", "", 10);
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	
end

--local ArrowSize;
local source;
local Up, Down,Neutral;
--local font, Size;
local Trend;
local SignalBar;
 function Prepare(nameOnly)   
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Trend=instance.parameters.Trend;
	Period=instance.parameters.Period;
    local name =  profile:id() .. ","  .. instance.source:name() .. ","  .. Period;
	instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	 
    source = instance.source;
	first= source:first(); 	 
	
	SignalBar = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", Neutral,  first);
    SignalBar:setPrecision(math.max(2, instance.source:getPrecision()));
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   
 

function Update(period)
    
	core.host:execute ("removeLabel", source:serial(period))
	
    if    period  < first then
    return;
    end	
	
	SignalBar[period]=0;
	SignalBar:setColor(period, Neutral);
	
          if Verification(period) == 1 then 
		  SignalBar[period]=1;
		  SignalBar:setColor(period, Up);
		  end
          if  Verification(period) == -1 then 
		  SignalBar[period]=-1;
		  SignalBar:setColor(period, Down);
          end  
		
end
 
function Verification(period)

 
  
  local Signal=0;
  if  source.close[period]> source.high[period-1]  then
  Signal=1;
  end
  
  if  source.close[period]< source.low[period-1]  then
  Signal=-1;
  end
   
  
  if not Trend then
  return Signal;
  end
  
  for i= 1, Period, 1 do
	  if Signal == 1
	  and source.close[period-i] > source.open[period-i] then
      Signal=0;
	  break;
	  end
	  
	  if Signal == -1
	  and source.close[period-i] < source.open[period-i] then
	  Signal=0;
	  break;
	  end
  end
  
  
  
  return Signal;
  
end