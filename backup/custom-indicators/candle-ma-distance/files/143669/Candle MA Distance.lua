-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71513
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Candle MA Distance");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "MA Period", "", 20, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
    indicator.parameters:addInteger("Period2", "ATR Period", "", 14, 1, 2000);
	
    indicator.parameters:addDouble("min_treshold", "Min Treshold", "", 1.5);	
    indicator.parameters:addInteger("max_array_size", "Max Array Size", "", 15); 
    indicator.parameters:addInteger("Fractal", "Fractal Period", "", 10); 	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("SU", "Strong Up Line Color", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("U", "Up Line Color", "", core.rgb(0,100, 0));
    indicator.parameters:addColor("SD", "Strong Down Line Color", "", core.rgb(255,0 , 0));
    indicator.parameters:addColor("D", "Down Line Color", "", core.rgb(100,0 , 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Period2,Method; 
local first;
local source = nil;
local min_treshold;
local Oscillator;  
local filt1,filt2;
local ATR;
local max_array_size;
local Fractal;
-- Routine
 function Prepare(nameOnly)   
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Method= instance.parameters.Method;
	min_treshold= instance.parameters.min_treshold;
	max_array_size= instance.parameters.max_array_size;
	Fractal= instance.parameters.Fractal;
	
	local Parameters= Period1 .. ", "..  Method .. ", ".. Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	ATR = core.indicators:create("ATR", source, Period2);
	MA = core.indicators:create(Method, source.close, Period1);	
    first=math.max(ATR.DATA:first(),MA.DATA:first());
	
	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), 0);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), 0);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), 0);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), 0);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	top= instance:addInternalStream(0, 0);	
	bottom= instance:addInternalStream(0, 0);	
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first+Fractal );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first+Fractal );
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 	ATR:update(mode);
 	MA:update(mode);	
	if period < first
	then
	return;
	end
	
	

    open[period]= get_ohlc(source.open,period) 
    close[period]= get_ohlc(source.close,period) 
    high[period]= get_ohlc(source.high,period) 
    low[period]= get_ohlc(source.low,period)

	if period <= first+Fractal then
	return;
	end
	
	if period >= source:size()-1 - Fractal then
	--return;
	end
	
    FindMinMax(period );
	
end

function FindMinMax(period)

    local min,max;
    p= period- period%Fractal;
	p=p-Fractal;
 
	p1=math.max(first, p-Fractal);
	p2=math.min(source:size()-1, p+Fractal);	
	
 
	
	if p1== p2 then
	return;
	end
	
	 local max=mathex.max(high,p1, p2 )
	 local min=mathex.min(low,p1,p2 )
 
	if max >  min_treshold  then
	max=min_treshold; 
	end
 
	
	if min <  -min_treshold  then
	min=-min_treshold ;
	end
	
	
	for i= p1, p2, 1 do
	top[i]=max;
 	bottom[i]=min;	
	end 
	
local AverageTop=top[period];
local AverageBottom=bottom[period];
local TopCount=1;
local BottomCount=1;
local LastTop=top[period];
local LastBottom=bottom[period];
	
	for  i=period, first, -1 do
	
	
			if LastTop~=top[i] and TopCount < max_array_size then
			LastTop=top[i];
			TopCount=TopCount+1;
			AverageTop=AverageTop+top[i];
			end
			if LastBottom~=bottom[i] and BottomCount < max_array_size then
			LastBottom=bottom[i];
			BottomCount=BottomCount+1;
			AverageBottom=AverageBottom+bottom[i];
			end
			
			if  TopCount == max_array_size
			and BottomCount == max_array_size
			then
			break;
			end
			
	
	end
	
	
	for i= p1, p2, 1 do	
	Top[i]=AverageTop/TopCount;
	Bottom[i]=AverageBottom/BottomCount;
    end
 
end 

function get_ohlc(Source,period)

if ATR.DATA[period]==0 then
return 0;
end

return (Source[period]-MA.DATA[period])/ATR.DATA[period];
end

 