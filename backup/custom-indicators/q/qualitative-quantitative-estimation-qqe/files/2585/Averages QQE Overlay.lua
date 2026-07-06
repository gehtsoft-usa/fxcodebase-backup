
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1347&p=2585#p2585

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Averages Qualitative Quantitative Estimation Overlay");
    indicator:description("Qualitative Quantitative Estimation Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addString("Mode", "Overlay Method", "", "QQE/FAST");
    indicator.parameters:addStringAlternative("Mode", "QQE/FAST", "", "QQE/FAST");
    indicator.parameters:addStringAlternative("Mode", "QQE/SLOW", "", "QQE/SLOW");
	indicator.parameters:addStringAlternative("Mode", "FAST/SLOW", "", "FAST/SLOW");
	
    indicator.parameters:addInteger("RF", "RSI Period", "RSI Period", 14);
	
	 indicator.parameters:addString("DSM", "Delta  Smoothing Method", "", "EMA");
    indicator.parameters:addStringAlternative("DSM", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DSM", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("DSM", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("DSM", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("DSM", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("DSM", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("DSM", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("DSM", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("DSM", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("DSM", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("DSM", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("DSM", "T3", "", "T3");
    indicator.parameters:addStringAlternative("DSM", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("DSM", "Median", "", "Median");
    indicator.parameters:addStringAlternative("DSM", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("DSM", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("DSM", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("DSM", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("DSM", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("DSM", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("DSM", "KAMA", "", "KAMA");
	
    indicator.parameters:addInteger("RSP", "RSI  Smoothing Period", "RSI  Smoothing Period", 5);
    indicator.parameters:addString("RSM", "RSI  Smoothing Method", "", "EMA");
    indicator.parameters:addStringAlternative("RSM", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("RSM", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSM", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("RSM", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSM", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("RSM", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("RSM", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("RSM", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSM", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("RSM", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("RSM", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("RSM", "T3", "", "T3");
    indicator.parameters:addStringAlternative("RSM", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("RSM", "Median", "", "Median");
    indicator.parameters:addStringAlternative("RSM", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("RSM", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("RSM", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("RSM", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("RSM", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("RSM", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("RSM", "KAMA", "", "KAMA");
	
	indicator.parameters:addInteger("AP", " ATR Period", " ATR Period", 14);
	
	indicator.parameters:addString("ASM", "ATR  Smoothing Method", "", "EMA");
    indicator.parameters:addStringAlternative("ASM", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("ASM", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("ASM", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("ASM", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("ASM", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("ASM", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("ASM", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("ASM", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("ASM", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("ASM", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("ASM", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("ASM", "T3", "", "T3");
    indicator.parameters:addStringAlternative("ASM", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("ASM", "Median", "", "Median");
    indicator.parameters:addStringAlternative("ASM", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("ASM", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("ASM", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("ASM", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("ASM", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("ASM", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("ASM", "KAMA", "", "KAMA");
	
	
    indicator.parameters:addDouble("F", "Fast ATR Multipliers", "Fast ATR Multipliers", 2.618 );
	indicator.parameters:addDouble("S", "Slow ATR Multipliers", "Slow ATR Multipliers", 4.236);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RF;
local RSP;
local RSM;
local AP;
local FM;
local SM;
local Slow;
local ASM;
local first;
local source = nil;
local DSM;
-- Streams block
local RSI=nil;
local EMA=nil;
local TR=nil;
local ATR=nil;

local Stop1=nil;
local Stop2=nil;

local QQE = nil;
local TS1 = nil;
local TS2 = nil;
 
local WildersPeriod=nil
local Up, Down,Neutral;
local Mode;

local open,close, high,low;
-- Routine
function Prepare(nameOnly)
    RF = instance.parameters.RF;
    RSP = instance.parameters.RSP;
	RSM = instance.parameters.RSM;
    AP = instance.parameters.AP;
	ASM= instance.parameters.ASM; 
    SM = instance.parameters.S;	 
	FM = instance.parameters.F;
	DSM = instance.parameters.DSM;
	
	Mode = instance.parameters.Mode;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
    source = instance.source;
    first = source:first();
	
	WildersPeriod=RF * 2 - 1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. RF.. ", " .. DSM .. ", " .. RSP .. ", " .. RSM ..", " .. AP ..", " .. ASM.. ", "  .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
	end
		
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

	
	RSI = core.indicators:create("RSI", source.close, RF);
	MA = core.indicators:create("AVERAGES", RSI.DATA, RSM, RSP, false);
	TR =  instance:addInternalStream(0, 0);
	
	ATR  = core.indicators:create("AVERAGES", TR, ASM, AP, false); 
	DELTA = core.indicators:create("AVERAGES", ATR.DATA, DSM, WildersPeriod, false);

    QQE  =  instance:addInternalStream(0, 0); 	 
	TS1 =  instance:addInternalStream(0, 0); 
	TS2 =  instance:addInternalStream(0, 0);
 
    open = instance:addStream("open", core.Line, name .. ".open", "open", Neutral,  source:first());
	close  = instance:addStream("close", core.Line, name .. ".close", "close", Neutral,  source:first());
	high = instance:addStream("high", core.Line, name .. ".high", "high", Neutral,  source:first());
	low = instance:addStream("low", core.Line, name .. ".low", "low", Neutral,  source:first());
	instance:createCandleGroup("ZONE", "", open, high, low, close );
	

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

		open[period]=source.open[period];
		close[period]=source.close[period];
		high[period]=source.high[period];
		low[period]=source.low[period];

				 RSI:update(mode);
				 
				 MA:update(mode);
				 
				 if period < MA.DATA:first() then
				 open:setColor(period, Neutral);
				 return;
				 end
						 
				 QQE[period] = MA.DATA[period];
						 
				

				 if period < MA.DATA:first()+1 then
				 open:setColor(period, Neutral);
				 return;
				 end
				 
				 TR[period] = math.abs(MA.DATA[period] - MA.DATA[period-1]);
				 
				 
				 
				
				 ATR:update(mode);
									 
				  DELTA:update(mode);	

               	if period < DELTA.DATA:first() then
				open:setColor(period, Neutral);
				 return;
				 end
				 		  
												
														if MA.DATA[period] < TS1[period-1] then														
														
														 Stop1=MA.DATA[period] + DELTA.DATA[period]*FM;
														 
															 if Stop1 > TS1[period-1] then
															         
															 	   if MA.DATA[period-1] <  TS1[period-1]  then 														     
															       Stop1 = TS1[period-1];
																   end
															     
															 end									
																
														elseif  MA.DATA[period] > TS1[period-1] then
														
                                                         Stop1=MA.DATA[period] - DELTA.DATA[period]*FM;
														 
															 if Stop1 < TS1[period-1] then
															        
															        if MA.DATA[period-1] >  TS1[period-1]  then 														     
															       Stop1 = TS1[period-1];
																   end
															       
															 end
															 
													    end	
														
														TS1[period]=Stop1;
														
													
														
																	if MA.DATA[period] < TS2[period-1] then														
																
																 Stop2=MA.DATA[period] + DELTA.DATA[period]*SM;
																 
																	 if Stop2 > TS2[period-1] then
																			 
																			 if MA.DATA[period-1] <  TS2[period-1]  then 	
																			 Stop2 = TS2[period-1];
																			 end
																	 end									
																		
																elseif  MA.DATA[period] > TS2[period-1] then
																
																 Stop2=MA.DATA[period] - DELTA.DATA[period]*SM;
																 
																	 if Stop2 < TS2[period-1] then
																			 
																			 if MA.DATA[period-1] >  TS2[period-1]  then 
																			 Stop2 = TS2[period-1];
																			 end
																	 end
																	 
																end		
																
																TS2[period]=Stop2;
													
														
													
					if Mode== "QQE/FAST" then
						if QQE[period]> TS1[period] then
						open:setColor(period, Up);
						elseif   QQE[period]< TS1[period] then
						open:setColor(period, Down);
						else
						open:setColor(period, Neutral);
						end
						
                    elseif Mode =="QQE/SLOW" then
					    if QQE[period]> TS2[period] then
						open:setColor(period, Up);
						elseif  QQE[period]< TS2[period] then
						open:setColor(period, Down);
						else
						open:setColor(period, Neutral);
						end
                    else
					
					   if TS1[period]> TS2[period] then
						open:setColor(period, Up);
						elseif TS1[period]< TS2[period] then
						open:setColor(period, Down);
						else
						open:setColor(period, Neutral);
						end
                    end  					
			

end