-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74315

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Heiken RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("RSI Calculation");	
	
	
 
 	indicator.parameters:addBoolean("RSI_Smoothed", "Smoothed RSI", "", true);  
	indicator.parameters:addBoolean("RSI_Show", "Show RSI", "", true);	
    indicator.parameters:addInteger("RSI_Period", "Period", "", 5, 1, 2000); 
	
 	indicator.parameters:addGroup("HARSI Candles Calculation");	
    indicator.parameters:addInteger("HARSI_Period", "Period", "", 14, 1, 2000); 
    indicator.parameters:addInteger("HARSI_Smoothed", "Period", "", 1, 1, 2000); 	
	
	
	
 	indicator.parameters:addGroup("Stochastic RSI Calculation");	
	indicator.parameters:addBoolean("Stochastic_RSI_Show", "Show Stochastic RSI", "", true);

 

    indicator.parameters:addInteger("K_Period", "K Period", "", 3, 1, 2000); 
    indicator.parameters:addInteger("D_Period", "D Period", "", 3, 1, 2000); 
    indicator.parameters:addInteger("S_Period", "Stochastic Period", "", 14, 1, 2000); 
    indicator.parameters:addInteger("Scaling", "Scaling", "", 80, 1, 2000);

	
	 indicator.parameters:addGroup("RSI Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("RSI_color", "Line Color", "", core.rgb(0, 255, 255)); 
	 
	indicator.parameters:addGroup("Stochastic Style");		 

    indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);
	indicator.parameters:addColor("Up", "Channel Up Color","", core.rgb(0, 255, 0));
 	indicator.parameters:addColor("Down", "Channel Down Color","", core.rgb(255, 0, 0));
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 20);
	indicator.parameters:addDouble("Level2", "2. Level","", 30); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,TF; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	RSI_Period=instance.parameters.RSI_Period;
	RSI_Smoothed=instance.parameters.RSI_Smoothed;
	RSI_Show=instance.parameters.RSI_Show;
	
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;
	
	HARSI_Period=instance.parameters.HARSI_Period;
	HARSI_Smoothed=instance.parameters.HARSI_Smoothed;
	
	Stochastic_RSI_Show=instance.parameters.Stochastic_RSI_Show;
	
	
	K_Period=instance.parameters.K_Period;
	D_Period=instance.parameters.D_Period;
	S_Period=instance.parameters.S_Period;
    Scaling=instance.parameters.Scaling;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	--assert(core.indicators:findIndicator("TSR BIG TREND") ~= nil, "Please, download and install TSR BIG TREND.LUA indicator"); 
	
	rsi= core.indicators:create("RSI", source.close, RSI_Period);
	rsi_open= core.indicators:create("RSI", source.close, HARSI_Period);
	rsi_close= core.indicators:create("RSI", source.close, HARSI_Period);
	rsi_high= core.indicators:create("RSI", source.close, HARSI_Period);	
	rsi_low= core.indicators:create("RSI", source.close, HARSI_Period);	
	first=math.max(rsi.DATA:first(), rsi_low.DATA:first()) ; 
	
	

 
	
	if RSI_Show then 
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, first );
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);
    else
	RSI = instance:addInternalStream(0, 0);	
    end	
 
    Smoothed = instance:addInternalStream(0, 0);
	
	
	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("Candle", "Candle", open, high, low, close);
	
	
	open:addLevel(Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	open:addLevel(Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
	open:addLevel(-Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	open:addLevel(-Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);			
	open:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	open:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	open:addLevel(-50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
	
	
	K = instance:addInternalStream(0, 0);	
	D = instance:addInternalStream(0, 0);	
    Range = instance:addInternalStream(0, 0);		
	
    if Stochastic_RSI_Show then 
	   instance:createChannelGroup("KD", "KD", K, D, instance.parameters.Up, 100 - instance.parameters.transparency);
    end
end	 


function Update(period, mode)

	rsi:update(mode); 
	rsi_open:update(mode); 
	rsi_close:update(mode); 
	rsi_high:update(mode); 
	rsi_low:update(mode); 	

	if period <= first
	or  not source:hasData(period) 
	then
	Smoothed[period]=rsi.DATA[period];
	return;
	end
	
   	
	Smoothed[period]= ((rsi.DATA[period]-50) +Smoothed[period]) /2;
	
	if RSI_Smoothed	 then 
	RSI[period]= Smoothed[period];
	else
	RSI[period]= (rsi.DATA[period]-50);
	end
	
	
	local _high  = math.max( rsi_high.DATA[period]-50, rsi_low.DATA[period]-50 )
    local _low   = math.min( rsi_high.DATA[period]-50, rsi_low.DATA[period]-50 )
	
	
	close[period]  =(( rsi_close.DATA[period-1] -50 + _low + _high + rsi_close.DATA[period]-50 ) / 4) 	
    open[period]  =(( ( open[period-1] * HARSI_Smoothed ) + close[period-1] ) / ( HARSI_Smoothed + 1 ))	 
	
	

	high[period]= math.max( _high, math.max( open[period], close[period] ) ) ;
	low[period]= math.min( _low,  math.min( open[period], close[period] ) ) ;
	-----------------
	if period <=first + S_Period then
	return;
	end
	
	local min,max=mathex.minmax(rsi.DATA, period- S_Period+1, period);

	Range[period]=(100 * (rsi.DATA[period] - min) / (max - min) )-50;
	
	if period <=S_Period + K_Period  then
	return;
	end	
     
	K[period]=( mathex.avg(Range , period-K_Period+1, period) /100)*Scaling
	 
 	if period <=S_Period + K_Period +  D_Period then
	return;
	end	
	
	D[period]=  mathex.avg(K , period-D_Period+1, period); 

    if K[period]> D[period]	then
    K:setColor(period, instance.parameters.Up);			
	else
    K:setColor(period, instance.parameters.Down);			
	end

end

 
	


 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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