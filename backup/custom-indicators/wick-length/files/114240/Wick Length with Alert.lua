-- Id: 18834
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63410

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
    indicator:name("Wick Length");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addString("Method", "Calculation Method", "Method" , "Separated");
    indicator.parameters:addStringAlternative("Method", "Separated", "Separated" , "Separated");
	indicator.parameters:addStringAlternative("Method", "Separated Opposite Only", "Separated Opposite Only" , "Separated Opposite Only");
    indicator.parameters:addStringAlternative("Method", "Cumulative", "Cumulative" , "Cumulative");
    indicator.parameters:addStringAlternative("Method", "Difference", "Difference" , "Difference");
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Bar color", "Bar Color", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("color2", "Down Bar color", "Bar Color", core.rgb(255, 0, 0));

    indicator.parameters:addGroup("Alerts"); 
    indicator.parameters:addBoolean("ChartAlert", "Chart alert", "", true);  
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);  
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    indicator.parameters:addFile("AlertSound", "Alert Sound", "", "");
    indicator.parameters:setFlag("AlertSound", core.FLAG_SOUND);
    indicator.parameters:addBoolean("SendEmail", "Send email", "", false);
    indicator.parameters:addString("Email", "Email address", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local source;
local Method;
local Up, Down, Cumulative, Difference;
local LastTime;
-- Routine

function Signal(Msg)
  if instance.parameters.ChartAlert then
   core.host:execute("prompt", 1, "Alert" , Msg);
  end
  
  if instance.parameters.PlaySound then
   terminal:alertSound(instance.parameters.AlertSound, instance.parameters.RecurrentSound); 
  end

  if instance.parameters.SendEmail then
   terminal:alertEmail(Email, "Alert", Msg);
  end

end

 function Prepare(nameOnly)  
   
	Method= instance.parameters.Method;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name()  .. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	if Method== "Separated" or  Method== "Separated Opposite Only"  then
    Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.color1, source:first());
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.color2, source:first());
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Up = instance:addInternalStream(source:first(), 0);
	Down = instance:addInternalStream(source:first(), 0);
	end
		 
	if Method== "Difference" then
    Difference = instance:addStream("Difference", core.Bar, name .. ".Difference", "Difference", instance.parameters.color1, source:first());
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Difference = instance:addInternalStream(source:first(), 0);
	end
	
	if Method== "Cumulative" then
    Cumulative = instance:addStream("Cumulative", core.Bar, name .. ".Cumulative", "Cumulative", instance.parameters.color1, source:first());    
    Cumulative:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Cumulative = instance:addInternalStream(source:first(), 0);
	end
	 
end

-- Indicator calculation routine
function Update(period, mode)
    
	Up[period]= (source.high[period]- math.max(source.open[period], source.close[period]))/source:pipSize();
	Down[period]=- ( math.min(source.open[period], source.close[period]) -source.low[period])/source:pipSize();
	
	if  Method== "Separated Opposite Only"  then
		if source.close[period]>  source.open[period] then
		Up[period]=0;
		else
		Down[period]=0;
		end	
	end
   
    Difference[period]= Up[period]-math.abs(Down[period]);
	Cumulative[period]= Up[period]+math.abs(Down[period]);

	if period==source:size()-1 and LastTime~=source:date(period) then
		LastTime=source:date(period);
		if source.close[period-1]>source.open[period-1] and Down[period-1]==0 then
			Signal("No bottom wick of the up candle");
		end
		if source.close[period-1]<source.open[period-1] and Up[period-1]==0 then
			Signal("No top wick of the down candle");
		end
	end
end

function AsyncOperationFinished(cookie)

end




