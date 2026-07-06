
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=949

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("Averages Slope direction line");
    indicator:description("Slope direction line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 80);
    indicator.parameters:addString("Method1", "1.  MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method1", "VAMA", "", "VAMA");
	
    indicator.parameters:addString("Method2", "2.  MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method2", "VAMA", "", "VAMA");


    indicator.parameters:addString("Method3", "3.  MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method3", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method3", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method3", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method3", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method3", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method3", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method3", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method3", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method3", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method3", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method3", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method3", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method3", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method3", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method3", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method3", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method3", "VAMA", "", "VAMA");

	
	indicator.parameters:addBoolean("Single", "Single Stream", "", false);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrUp", "Color of Slope Direction Line (UP)", "Color of Slope Direction Line (Up)", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDn", "Color of Slope Direction Line (Dn)", "Color of Slope Direction Line (Dn)", core.rgb(255, 0, 0));
   indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

local first;
local source = nil;
local MA1;
local MA2;
local Period;
local Method;
local Pr;
local vect;
local MA_A;
local trend;
local SDL;
local Single;
local Trend;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method1=instance.parameters.Method1;
    Method2=instance.parameters.Method2;
    Method3=instance.parameters.Method3;	
	Single=instance.parameters.Single;
    
    vect = instance:addInternalStream(0, 0);
    trend = instance:addInternalStream(0, 0);
    SDL = instance:addInternalStream(0, 0);
  
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Averages.lua" .. " indicator must be installed");
     MA1 = core.indicators:create("AVERAGES", source, Method1, Period);
     MA2 = core.indicators:create("AVERAGES", source, Method2, math.floor(Period/2));
	 first1 = math.max(MA1.DATA:first(),MA2.DATA:first() );
	 
     MA_A = core.indicators:create("AVERAGES", vect, Method3, math.floor(math.sqrt(Period)));
     first2=MA_A.DATA:first();
	 
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method1 .. ", " .. Method2.. ", " .. Method3.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
		if Single then
		Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.clrUp, first);
		Trend:setWidth(instance.parameters.width);
        Trend:setStyle(instance.parameters.style);
		else	
		UpTrend = instance:addStream("UpTrend", core.Line, name .. ".UpTrend", "UpTrend", instance.parameters.clrUp, first2);
		UpTrend:setWidth(instance.parameters.width);
        UpTrend:setStyle(instance.parameters.style);
		DnTrend = instance:addStream("DnTrend", core.Line, name .. ".DnTrend", "DnTrend", instance.parameters.clrDn, first2);
		DnTrend:setWidth(instance.parameters.width);
        DnTrend:setStyle(instance.parameters.style);
		end
	end

function Update(period, mode)	
	
	 if period < first1 then
	return;
	end
				MA1:update(mode);
				MA2:update(mode);
				
				vect[period]=2.*MA2.DATA[period]-MA1.DATA[period];
				
	if period < first2 then
	return;
	end				 

						MA_A:update(mode);
						
 
	
						SDL[period]=MA_A.DATA[period];
					
						
						if period> Period  + math.floor(math.sqrt(Period)) +1 then
						 trend[period]=trend[period-1];
						 
						 
						 if SDL[period]>SDL[period-1] then
						  trend[period]=1;
						 end
						 if SDL[period]<SDL[period-1] then
						  trend[period]=-1;
						 end
						 
						 if period > Period  + math.floor(math.sqrt(Period))+2 then 
						 
						 
						 if Single then
						 
						 Trend[period]= SDL[period];
						 
						 
					               if trend[period]>0 then
								  Trend:setColor(period, instance.parameters.clrUp);
								 end
								 
								 if trend[period]<0 then
								 Trend:setColor(period, instance.parameters.clrDn);
								 end
						 
						 
						 else
						 
								 if trend[period]>0 then
								 
								 
								  UpTrend[period]=SDL[period];
								  
									  if trend[period-1]<0 then
									   UpTrend[period-1]=SDL[period-1];
									  end
								  DnTrend[period]=nil;
								 end
								 
								 if trend[period]<0 then
								  DnTrend[period]=SDL[period];
									  if trend[period-1]>0 then
									   DnTrend[period-1]=SDL[period-1];
									  end
								  UpTrend[period]=nil;
								 end
						end							 
								
								 
						end
					end
			 

end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+