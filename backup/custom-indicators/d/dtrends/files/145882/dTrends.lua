-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72142

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
    indicator:name("dTrends");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	 
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("ema_period", "EMA Period", "", 13); 
    indicator.parameters:addDouble("dist", "Distance from Zero in pips ", "", 2.3); 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local ema_period,dist;	
local first;
local source = nil; 
local Indicator; 
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	ema_period=instance.parameters.ema_period;
	dist=instance.parameters.dist;
	Price=instance.parameters.Price;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," ..  ema_period.. "," ..  dist.. "," ..  Price .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("EMA", source[Price], ema_period); 
	first=source:first()+ema_period ;  
	 
    Value = instance:addInternalStream(0, 0);  	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

    up:setNoData(period);
    down:setNoData(period);	
	
 
	  Indicator:update(mode); 
	  
	 if period < first then
	 return;
	 end
	  

    local Bears=source.low[period]-Indicator.DATA[period];
    local Bulls=source.high[period]-Indicator.DATA[period];
	
	
	
 
    Value[period] = - (Bears + Bulls)/source:pipSize(); 
	   
	  
       if((Value[period-1]>=0) and (Value[period]<-dist)) then
       down:set(period, source.high[period], "\218" );	  
       elseif((Value[period-1]<=0) and (Value[period]>dist)) then
       up:set(period, source.low[period], "\217" );  
       end 
end