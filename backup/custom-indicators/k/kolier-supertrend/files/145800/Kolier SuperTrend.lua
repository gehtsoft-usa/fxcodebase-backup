-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72117

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
    indicator:name("Kolier SuperTrend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("ATR_Multiplier", "ATR_Multiplier", "", 3, 0, 2000); 
	indicator.parameters:addBoolean("TrendMode", "Trend Mode", "", false);	
	
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
local ATR_Period, ATR_Multiplier,TrendMode; 
local ATR;
local PHASE_NONE= 0;
local PHASE_BUY= 1;
local PHASE_SELL= -1;	

-- Routine
 function Prepare(nameOnly)   
 
    
	ATR_Period=instance.parameters.ATR_Period;
	ATR_Multiplier=instance.parameters.ATR_Multiplier;
	TrendMode=instance.parameters.TrendMode;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ATR_Period.. "," ..  ATR_Multiplier  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, ATR_Period);
	first=ATR.DATA:first() ; 
	
	
	phase = instance:addInternalStream(0, 0);
    band_upper = instance:addInternalStream(0, 0);
	band_lower = instance:addInternalStream(0, 0);
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
	
   
	
 
 
end


function Update(period, mode)

	ATR:update(mode); 

	 if period <= first then
	 
	 phase[period]=PHASE_NONE;
	 return;
	 end
	 
	phase[period]=phase[period-1];
	
    band_upper[period] = (source.high[period]+source.low[period])/2 + ATR_Multiplier * ATR.DATA[period];
    band_lower[period] = (source.high[period]+source.low[period])/2 - ATR_Multiplier * ATR.DATA[period];
	
	
	
	  if(phase[period]==PHASE_NONE) then
       
       Line[period]=(source.high[period-1]+source.low[period-1])/2; 
 
       end


     if(phase[period]~=PHASE_BUY and source.close[period]>Line[period-1] ) then
    
         phase[period] = PHASE_BUY;
         Line[period]=band_lower[period]; 
     end
	 
	 
	 
      if(phase[period]~=PHASE_SELL and source.close[period]<Line[period-1]  ) then
        
         phase[period] = PHASE_SELL;
         Line[period]=band_upper[period]; 
     end
	 
	 
	 
	   if(phase[period]==PHASE_BUY
         and ((not TrendMode  and phase[period-1]==PHASE_BUY) or TrendMode)) then
        
			 if(band_lower[period]>Line[period-1]) then
			  
				Line[period]=band_lower[period];
			 
			 else 
			  
				Line[period]=Line[period-1];
			   end
       end
      if(phase[period]==PHASE_SELL
         and ((not TrendMode  and phase[period-1]==PHASE_SELL) or TrendMode)) then
      
         if(band_upper[period]<Line[period-1]) then
          
            Line[period]=band_upper[period];
            
         else 
      
            Line[period]=Line[period-1];
          end
       end
	   
	   if phase[period]==PHASE_BUY then
	   Line:setColor(period,  instance.parameters.Up);	
	   else
	   Line:setColor(period,  instance.parameters.Down);	
       end	   
end