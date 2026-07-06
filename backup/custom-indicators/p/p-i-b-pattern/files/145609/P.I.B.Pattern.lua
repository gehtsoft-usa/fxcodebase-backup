-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72061

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
    indicator:name("P.I.B.Pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
 
 

  
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "MA Period", "", 50, 1, 2000);
    indicator.parameters:addDouble("HighLowLevel", "Pin Bar Cut Off", "", 0.25, 0, 1);
  
	
	 indicator.parameters:addBoolean("Pin", "Apply Pin Filter", "", true);	
	 indicator.parameters:addBoolean("Filter", "Apply MA Filter", "", true);
 
	
	indicator.parameters:addGroup("Style");
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
local Period,Filter,Pin;
-- Routine
 function Prepare(nameOnly)   
 
    
	HighLowLevel=instance.parameters.HighLowLevel;
	Period=instance.parameters.Period;
	Filter=instance.parameters.Filter;
	Pin=instance.parameters.Pin;
 
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..    HighLowLevel .. ", " ..    Period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MA= core.indicators:create("MVA", source.close, Period);
	first=MA.DATA:first() ; 
	
	
	--LongInfo = instance:addInternalStream(0, 0);
 
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end


function Update(period, mode)


    up:setNoData(period);
    down:setNoData(period);	
	
	MA:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    
	local IB=false;
	local PB=false;
	
	if source.high[period-1]<source.high[period-2]
	and source.low[period-1]>source.low[period-2]
	then
	IB=true;	
	end
	
	local OpenClose= math.abs(source.open[period-2]-source.close[period-2])
	local HighLow= math.abs(source.high[period-2]-source.low[period-2])	
	local Top=math.abs(source.high[period-2]-math.max(source.open[period-2],source.close[period-2]));
	local Bottom=math.abs(math.min(source.open[period-2],source.close[period-2])-source.low[period-2] );
	if OpenClose< HighLow*HighLowLevel 
	then
	PB=true;	
	end	
	
	if PB and IB then
	
	        if (source.close[period] > MA.DATA[period] and Filter or not Filter)
			and (Top< Bottom and Pin or not Pin)
			and source.close[period]> source.high[period-2]
			then
			up:set(period, source.low[period], "\254", source.low[period]);	 
			end
			
 	        if (source.close[period] < MA.DATA[period] and Filter or not Filter)
			and (Top> Bottom and Pin or not Pin)
			and source.close[period]< source.low[period-2]
			then
            down:set(period, source.high[period], "\254", source.high[period]);	 
			end
			
			if (source.close[period] < MA.DATA[period]  and Filter or not Filter)
			and (Top< Bottom and Pin or not Pin)
			and source.close[period]> source.high[period-2]
			then
			up:set(period, source.low[period], "\254", source.low[period]);	 
			end
			
 	        if (source.close[period] > MA.DATA[period] and Filter or not Filter)
			and (Top> Bottom and Pin or not Pin)
			and source.close[period]< source.low[period-2]			
			then
            down:set(period, source.high[period], "\254", source.high[period]);	 
			end
  
	end
end 