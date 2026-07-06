-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72066

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
    indicator:name("RSI Slowdown");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 2, 1, 2000);
    indicator.parameters:addDouble("LevelMax", "Level Max", "", 90, 1, 2000);
    indicator.parameters:addDouble("LevelMin", "Level Min", "", 10, 1, 2000); 
	indicator.parameters:addBoolean("SeekSlowdown", "Seek Slowdown", "", true);	
    indicator.parameters:addDouble("MaxDelta", "Max Slowdown", "", 5, 1, 2000); 	
 
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local RSIPeriod, LevelMin,LevelMax; 
local Indicator;
local SeekSlowdown;	
-- Routine
 function Prepare(nameOnly)   
 
    
	RSIPeriod=instance.parameters.RSIPeriod;
	LevelMin=instance.parameters.LevelMin;
	LevelMax=instance.parameters.LevelMax;
	SeekSlowdown=instance.parameters.SeekSlowdown;
	MaxDelta=instance.parameters.MaxDelta;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  RSIPeriod.. "," ..  LevelMax .. "," ..  LevelMin  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("RSI", source.close, RSIPeriod);
	first=Indicator.DATA:first() ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center,core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

	  Indicator:update(mode); 

    up:setNoData(period);
    down:setNoData(period);

     local Delta=math.abs(Indicator.DATA[period]-Indicator.DATA[period-1] )<MaxDelta;
	 
	
	 if period <= first then
	 return;
	 end
	 
	 if(Indicator.DATA[period]>=LevelMax and Indicator.DATA[period-1]<=LevelMax  and not SeekSlowdown )  	 
	 or  (Indicator.DATA[period]>=LevelMax and Indicator.DATA[period-1]<=LevelMax and  SeekSlowdown and Delta )  
	 then 
	 up:set(period, source.low[period], "\217", source.low[period]);	
	 end
	 
	 
	 if  (Indicator.DATA[period]<=LevelMin and Indicator.DATA[period-1]>=LevelMin and  not SeekSlowdown )  
	 or  (Indicator.DATA[period]<=LevelMin and Indicator.DATA[period-1]>=LevelMin and  SeekSlowdown and Delta)  
	 then
	 down:set(period, source.high[period], "\218", source.high[period]);	 
	end
	


	
end