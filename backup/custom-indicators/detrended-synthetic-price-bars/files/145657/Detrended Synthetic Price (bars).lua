-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72079

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
    indicator:name("Detrended Synthetic Price (bars)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("DspPeriod", "DSP Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("SignalPeriod", "Signal Period", "", 9, 1, 2000);
	
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addString("Mode", "Signal Mode", "", "1");
    indicator.parameters:addStringAlternative("Mode", "Zero cross", "", "1");
    indicator.parameters:addStringAlternative("Mode", "Cross", "", "2");
    indicator.parameters:addStringAlternative("Mode", "Cross Continuous ", "", "3");
    indicator.parameters:addStringAlternative("Mode","Slope change", "", "4"); 
 
 
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local DspPeriod, SignalPeriod,Price,Mode; 
local Indicator;
local alpha;	

local Up,Down, Neutral;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

-- Routine
 function Prepare(nameOnly)   
 
    
	DspPeriod=instance.parameters.DspPeriod;
	SignalPeriod=instance.parameters.SignalPeriod;
	Price=instance.parameters.Price;
	Mode=instance.parameters.Mode;
	source = instance.source
	
    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  DspPeriod.. "," ..  SignalPeriod.. "," ..  Price  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    alpha = 2.0/(1.0+SignalPeriod);	
	
	Indicator= core.indicators:create("EMA", source[Price], DspPeriod);
	first=Indicator.DATA:first() ; 
	
	
	val = instance:addInternalStream(0, 0);
	levelu = instance:addInternalStream(0, 0);
	leveld = instance:addInternalStream(0, 0);	
	
	Signal = instance:addInternalStream(0, 0);	
 
	open = instance:addStream("openup", core.Line, name, "", Neutral, first);
    high = instance:addStream("highup", core.Line, name, "", Neutral, first);
    low = instance:addStream("lowup", core.Line, name, "", Neutral, first);
    close = instance:addStream("closeup", core.Line, name, "", Neutral, first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close); 
end


function Update(period, mode)

	  Indicator:update(mode); 
	  
	 leveld[period]=0;
	 levelu[period]=0;
	 
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	 
	  if period <= first+1 then
	  open:setColor(period, Neutral);		 
	  return;
	  end
	 
	 val[period]=Indicator.DATA[period]-Indicator.DATA[period-1];
	 

		 if (val[period]>0) then
		 levelu[period]=levelu[period-1]+alpha*(val[period]-levelu[period-1])
		 else
		 levelu[period]=levelu[period-1]
		 end
		 if (val[period]<0) then
		 leveld[period]=leveld[period-1]+alpha*(val[period]-leveld[period-1]) 
		 else
		 leveld[period]=leveld[period-1]
		 end
 
 
        if Mode== "4" then
			if (val[period]>val[period-1]) then 
			Signal[period]= 1  
			elseif (val[period]<val[period-1]) then
			Signal[period]= -1 ;
			else
			Signal[period]=Signal[period-1];		
			end		
		end
 
        if Mode== "1" then
			if (val[period]>0) then 
			Signal[period]= 1  
			elseif (val[period]<0) then
			Signal[period]= -1 ; 
			else		
			Signal[period]= 0 ; 		
			end		
		end

        if Mode== "2" then
			if (val[period]>levelu[period]) then 
			Signal[period]= 1  
			elseif (val[period]<leveld[period]) then
			Signal[period]= -1 ; 
			else		
			Signal[period]= 0 ; 		
			end	
		end
 
              
         if Mode== "3" then
			if (val[period]>levelu[period]) then 
			Signal[period]= 1  
			elseif (val[period]<leveld[period]) then
			Signal[period]= -1 ; 
			else		
			Signal[period]= Signal[period-1] ; 		
			end	
		end
		
		
		if Signal[period]== 1     then		
		open:setColor(period,  Up);
        elseif Signal[period]== -1  then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
	
end