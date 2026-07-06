-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72186

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
    indicator:name("Trend Clipper");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "1. Period", "", 3, 1, 2000); 	
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 4, 0.5, 2000);
 


	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(0, 0, 255)); 	


	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 40); 
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
local Period, Multiplier; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;	
	Multiplier=instance.parameters.Multiplier;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Multiplier  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("ATR", source, Period); 
	first = Indicator.DATA:first()  ; 
	
	

	pos = instance:addInternalStream(0, 0); 
	
	isLong = instance:addInternalStream(0, 0); 
	isShort = instance:addInternalStream(0, 0); 	

  	
	
    TS = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    TS:setPrecision(math.max(2, instance.source:getPrecision()));
    TS:setWidth(instance.parameters.width);
    TS:setStyle(instance.parameters.style);
    TS:addLevel(0);	
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center,  core.V_Bottom , instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

	  Indicator:update(mode);
	  
	 if period <= first then
	 return;
	 end

	 
    local nLoss = Multiplier * Indicator.DATA[period];
	
	
	
 
	   if source.close[period] >  TS[period-1]  and  source.close[period-1] >  TS[period-1]  then
	   TS[period]=math.max( TS[period-1] , source.close[period] - nLoss);
	   elseif source.close[period] <  TS[period-1] and source.close[period-1] <  TS[period-1]  then
	   TS[period]=math.min( TS[period-1] , source.close[period] + nLoss); 
	   elseif source.close[period] >  TS[period-1]  then
	   TS[period]=source.close[period] - nLoss
	   else
	   TS[period]=source.close[period] + nLoss 
	   end
	
     if source.close[period-1] <   TS[period-1]  and source.close[period] >  TS[period-1] then
	 pos[period]=1; 
     elseif source.close[period-1] >   TS[period-1]  and source.close[period] <  TS[period-1] then
	 pos[period]=-1; 
	 else	 
	 pos[period]=pos[period-1];	 
	 end
    

	
	
	isLong[period]=	isLong[period-1];
	isShort[period]= isShort[period-1];	
	
	
	if  isLong[period]==  0 and pos[period] == 1 then LONG=true else LONG=false; end
	if  isShort[period]== 0 and pos[period] == -1 then SHORT=true else SHORT=false; end	
 
    if (LONG) then
    isLong[period]  = 1
    isShort[period]  = 0
	end
 
    if (SHORT) then
    isLong[period]  = 0
    isShort[period]  = 1
	end
	
    up:setNoData(period);
    down:setNoData(period);	
	
	
	if LONG then
    up:set(period, source.low[period], "\217", source.low[period]);	
	end
	
	if SHORT then
    down:set(period, source.high[period], "\218", source.high[period]);	
	end
	
	if pos[period]==1 then
    TS:setColor(period,  instance.parameters.color1);	 
	elseif pos[period]==-1 then
    TS:setColor(period,  instance.parameters.color2);
	else
    TS:setColor(period,  instance.parameters.color3);	
	end 
	
end
 



