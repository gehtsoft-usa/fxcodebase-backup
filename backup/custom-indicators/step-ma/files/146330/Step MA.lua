-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72368

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Step MA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Volty Length", "", 10, 1, 2000);
    indicator.parameters:addDouble("Kv", "Sensivity Factor", "", 1); 
	
    indicator.parameters:addInteger("StepSize", " Constant Step Size (if need)", "", 0, 0,1 );
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	
    indicator.parameters:addInteger("Advance", "Offset", "", 0);
    indicator.parameters:addDouble("Percentage", "Percentage of Up/Down Moving   ", "", 0);
	
	indicator.parameters:addBoolean("HighLow", "High/Low Mode Switch (more sensitive)	", "", false);	 
 
	
	indicator.parameters:addInteger("ColorMode", "ColorMode", "Method" , 0);
    indicator.parameters:addIntegerAlternative("ColorMode", "Line", "Line" , 0);
    indicator.parameters:addIntegerAlternative("ColorMode", "Step Line", "Step Line" , 1);	
	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, Kv;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	Kv=instance.parameters.Kv;
	StepSize=instance.parameters.StepSize; 
	Method=instance.parameters.Method;
	Advance=instance.parameters.Advance;
	Percentage=instance.parameters.Percentage;
	HighLow=instance.parameters.HighLow;
	ColorMode=instance.parameters.ColorMode;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  Kv .. "," ..  StepSize.. "," ..  Method .. "," ..  Advance.. "," ..  Percentage  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	trend = instance:addInternalStream(0, 0);
	range = instance:addInternalStream(0, 0); 
	smax = instance:addInternalStream(0, 0); 
	smin = instance:addInternalStream(0, 0); 	
	trend= instance:addInternalStream(0, 0); 	
	
	Indicator= core.indicators:create(Method, range, Length);
	first=Indicator.DATA:first() ; 
	
	

	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)


     range[period]= (source.high[period]-source.low[period]);
	 Indicator:update(mode); 
	  
	  

	 if period <= first+Length then
	 return;
	 end
	 
	local Step;
	
	
	local ATRmin, ATRmax=mathex.minmax(Indicator.DATA,first, period);
	
	if( StepSize==0 ) then
	Step=math.floor(0.5*Kv*(ATRmax+ATRmin)/source:pipSize()); 	 
	else
	Step=Kv*StepSize;
    end 
   
   
     if (HighLow) then
 
	  smax[period]=source.low[period]+2.0*Step*source:pipSize();
	  smin[period]=source.high[period]-2.0*Step*source:pipSize();
  
	else  	 
	 
	  smax[period]=source.close[period]+2.0*Step*source:pipSize();
	  smin[period]=source.close[period]-2.0*Step*source:pipSize();
	  
	  
	end 

	  
	  trend[period]=trend[period-1];   
	  
	  if (source.close[period]>smax[period-1]) then trend[period]=1;   end
	 
	  if (source.close[period]<smin[period-1]) then trend[period]=-1;  end
	 
	  if(trend[period]>0) then 
					if(smin[period]<smin[period-1]) then smin[period]=smin[period-1]; end
	Line[period]=smin[period]+Step*source:pipSize();
	  else 
					if(smax[period]>smax[period-1]) then smax[period]=smax[period-1]; end
	Line[period]=smax[period]-Step*source:pipSize();
	end
  
 
	
  
	
	if ( ColorMode == 1) then	 
			if ( trend[period]>0 ) then
			Line[period]=Line[period]-Step*source:pipSize(); 
			Line:setColor(period,  instance.parameters.Up);	
			else
			Line[period]=Line[period]+Step*source:pipSize(); 
			Line:setColor(period,  instance.parameters.Down);				
			end
	else
            Line[period]=Line[period] +Percentage/100.0*Step*source:pipSize();  
	
	end
 
	
end

 
   
 
 