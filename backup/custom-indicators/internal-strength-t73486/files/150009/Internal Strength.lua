-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73486

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
    indicator:name("Internal Strength");
    indicator:description("Internal Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 

	
    indicator.parameters:addInteger("Period", "RSI Period", "Period", 14);
	
		
	indicator.parameters:addString("Method", "Method", "Method" , "RSI");
    indicator.parameters:addStringAlternative("Method", "Raw", "Raw" , "Raw");
	indicator.parameters:addStringAlternative("Method", "RSI", "RSI" , "RSI");
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of Raw Line", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of RSI Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 55);
    indicator.parameters:addDouble("oversold","Oversold Level","", 45);
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
local Period; 
local first;
local source = nil;
 -- Streams block
local Raw;
local Method;
local Internal, Strength; 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 
	Method= instance.parameters.Method; 
    source = instance.source;
    first = source:first()+Period;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	Raw = instance:addInternalStream(0, 0);	
	rsi = core.indicators:create("RSI", Raw, Period);	
 
	InternalStrength = instance:addStream("IS", core.Line, name .. ".IS", "IS", instance.parameters.color2, source:first()+Period);
	InternalStrength:setWidth(instance.parameters.width2);
	InternalStrength:setStyle(instance.parameters.style2);		
	if Method=="RSI" then
	InternalStrength:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	InternalStrength:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    else
	InternalStrength:addLevel(instance.parameters.oversold/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	InternalStrength:addLevel(instance.parameters.overbought/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	end
	InternalStrength:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
  
   
     if period <= source:first()
	or not source:hasData(period)
	then
	return;
	end	
	
	Raw[period]=(source.close[period]-source.low[period]) / (source.high[period] -source.low[period]);	
	rsi:update(mode);
	
	if period <= first
	or not source:hasData(period)
	then
	return;
	end
	
    if Method=="RSI" then
    InternalStrength[period]= rsi.DATA[period];
	else
    InternalStrength[period]= Raw[period];	
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

--[[
/--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double hl=high[i]-low[i];
      BufferRAW[i]=(hl!=0 ? (close[i]-low[i])/hl : 0);
      if(InpMode==MODE_HLC)
         BufferData[i]=BufferRAW[i];
     }
   if(InpMode==MODE_RSI)
      return(RSIOnArray(rates_total,prev_calculated,0,period_rsi,BufferRAW,BufferPos,BufferNeg,BufferData));

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index on array                                 |
//+------------------------------------------------------------------+
template<typename T>
int RSIOnArray(const int rates_total,
               const int prev_calculated,
               const int begin,
               const int period,
               const T &price[],
               double &buffer_pos[],
               double &buffer_neg[],
               double &buffer_rsi[]
              )
  {
   int   i;
   T     diff;
//--- check for rates count
   if(period<1 || rates_total-begin<period) return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_rsi=ArrayGetAsSeries(buffer_rsi);
   if(as_series_price)
      ArraySetAsSeries(price,false);
   if(as_series_rsi)
     {
      ArraySetAsSeries(buffer_rsi,false);
      ArraySetAsSeries(buffer_pos,false);
      ArraySetAsSeries(buffer_neg,false);
     }
//--- preliminary calculations
   int pos=prev_calculated-1;
   if(pos<=period)
     {
      //--- first RSIPeriod values of the indicator are not calculated
      buffer_rsi[0]=0.0;
      buffer_pos[0]=0.0;
      buffer_neg[0]=0.0;
      T SumP=0.0;
      T SumN=0.0;
      for(i=1; i<=period; i++)
        {
         buffer_rsi[i]=0.0;
         buffer_pos[i]=0.0;
         buffer_neg[i]=0.0;
         diff=price[i]-price[i-1];
         SumP+=(diff>0 ? diff : 0);
         SumN+=(diff<0 ?-diff : 0);
        }
      //--- calculate first visible value
      buffer_pos[period]=double(SumP/period);
      buffer_neg[period]=double(SumN/period);
      
      buffer_rsi[period]=100.0-(100.0/(1.0+buffer_pos[period]/(buffer_neg[period]>0 ? buffer_neg[period] : DBL_MIN)));
      //--- prepare the position value for main calculation
      pos=period+1;
     }
//--- the main loop of calculations
   for(i=pos;i<rates_total && !IsStopped();i++)
     {
      diff=price[i]-price[i-1];
      buffer_pos[i]=(buffer_pos[i-1]*(period-1)+(diff>0.0 ? diff : 0.0))/period;
      buffer_neg[i]=(buffer_neg[i-1]*(period-1)+(diff<0.0 ?-diff : 0.0))/period;
      buffer_rsi[i]=100.0-100.0/(1+buffer_pos[i]/(buffer_neg[i]>0 ? buffer_neg[i] : DBL_MIN));
     }
]]