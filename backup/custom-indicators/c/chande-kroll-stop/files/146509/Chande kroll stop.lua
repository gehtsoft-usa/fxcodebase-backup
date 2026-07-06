-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72426

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
    indicator:name("Chande kroll stop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("ATRPeriod", "ATR Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("Kv", "Multiplier", "", 3, 0, 2000);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Trend Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length, ATRPeriod, Kv; 
local ATR;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	ATRPeriod=instance.parameters.ATRPeriod;
	Kv=instance.parameters.Kv;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  ATRPeriod .. "," ..  Kv  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, ATRPeriod);
	first=ATR.DATA:first() ; 
	
	
	min = instance:addInternalStream(0, 0);
 	max = instance:addInternalStream(0, 0);
	
	
    UpTrend = instance:addStream("UpTrend", core.Line, name, "UpTrend", instance.parameters.color1, first+ ATRPeriod + Length  );
    UpTrend:setPrecision(math.max(2, instance.source:getPrecision()));
    UpTrend:setWidth(instance.parameters.width);
    UpTrend:setStyle(instance.parameters.style);
    UpTrend:addLevel(0);	
 
    DownTrend = instance:addStream("DownTrend", core.Line, name, "UpTrend", instance.parameters.color2, first+ ATRPeriod + Length  );
    DownTrend:setPrecision(math.max(2, instance.source:getPrecision()));
    DownTrend:setWidth(instance.parameters.width);
    DownTrend:setStyle(instance.parameters.style);
    DownTrend:addLevel(0);	 
end


function Update(period, mode)

	ATR:update(mode); 

	 if period <= first+ ATRPeriod  then
	 return;
	 end
	 
    local Min, Max= mathex.minmax(source, period-ATRPeriod+1, period);	 
	
    min[period]= Max - Kv*ATR.DATA[period]; 
    max[period]= Min + Kv*ATR.DATA[period]; 
	
	 if period <=  first+ ATRPeriod + Length  then
	 return;
	 end

    local   Max= mathex.min(max, period-Length+1, period);	 
    local   Min= mathex.max(min, period-Length+1, period);	 
	
	UpTrend[period]= Min;
	DownTrend[period]= Max;	
end


--[[
	for(shift=limit;shift>=0;shift--) 
   {	
   smin[shift]=High[Highest(NULL,0,MODE_HIGH,ATRPeriod,shift)] - Kv*iATR(NULL,0,ATRPeriod,shift); 
   smax[shift]=Low [Lowest (NULL,0,MODE_LOW ,ATRPeriod,shift)] + Kv*iATR(NULL,0,ATRPeriod,shift);      
   
   UpTrend[shift] = -10000000; 
   DnTrend[shift] =  10000000;
     
      for (int i = Length-1;i>=0;i--)
      {
      UpTrend[shift] = MathMax( UpTrend[shift], smin[shift+i]); 
      DnTrend[shift] = MathMin( DnTrend[shift], smax[shift+i]);
      }

]]