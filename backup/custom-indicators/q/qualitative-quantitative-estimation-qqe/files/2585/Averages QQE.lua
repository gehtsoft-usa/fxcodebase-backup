-- Id: 12651

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1347&p=2585#p2585

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

function Init()
    indicator:name("Averages Qualitative Quantitative Estimation");
    indicator:description("Qualitative Quantitative Estimation");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
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
	
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("SL", "Show Slow trailing stop", "", false);
	indicator.parameters:addBoolean("FL", "Show Fast trailing stop", "", true);
	
	indicator.parameters:addGroup("Style");
		indicator.parameters:addColor("Q", "Color of QQE", "Color of QQE", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("T1", "Color of Fast trailing stop", "Color of Fast trailing stop", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
	indicator.parameters:addColor("T2", "Color of Slow trailing stop", "Color of Slow trailing stop", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

	indicator.parameters:addGroup("Cental Line Style");
	indicator.parameters:addDouble("CentalLevel", "Central Level", "Central Level", 50 );
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
local FL, SL;
local WildersPeriod=nil
local CentalLevel;
-- Routine
function Prepare(nameOnly)
    RF = instance.parameters.RF;
    RSP = instance.parameters.RSP;
	RSM = instance.parameters.RSM;
    AP = instance.parameters.AP;
	ASM= instance.parameters.ASM;
    FL = instance.parameters.FL;
	SL = instance.parameters.SL;
    SM = instance.parameters.S;	 
	FM = instance.parameters.F;
	DSM = instance.parameters.DSM;
	CentalLevel= instance.parameters.CentalLevel;
    source = instance.source;
    first = source:first();
	
	WildersPeriod=RF * 2 - 1;
	local name = profile:id() .. "(" .. source:name() .. ", " .. RF.. ", " .. DSM .. ", " .. RSP .. ", " .. RSM ..", " .. AP ..", " .. ASM.. ", "  .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

	
	RSI = core.indicators:create("RSI", source, RF);
	MA = core.indicators:create("AVERAGES", RSI.DATA, RSM, RSP, false);
	TR =  instance:addInternalStream(0, 0);
	
	ATR  = core.indicators:create("AVERAGES", TR, ASM, AP, false);
	
	--DELTA = core.indicators:create("EMA", ATR.DATA, WildersPeriod);
	DELTA = core.indicators:create("AVERAGES", ATR.DATA, DSM, WildersPeriod, false);

    QQE = instance:addStream("QQE", core.Line, name .. ".QQE", "QQE", instance.parameters.Q,  MA.DATA:first());
	QQE:setWidth(instance.parameters.width1);
    QQE:setStyle(instance.parameters.style1);
	
	QQE:addLevel(CentalLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	if FL then
	TS1 = instance:addStream("TS1", core.Line, name .. ".TS", "TS Fast", instance.parameters.T1,  DELTA.DATA:first());
	TS1:setWidth(instance.parameters.width2);
    TS1:setStyle(instance.parameters.style2);
	else
	TS1 =  instance:addInternalStream(0, 0);
	end
	
	
	
	if SL then
	TS2 = instance:addStream("TS2", core.Line, name .. ".TS", "TS Slow", instance.parameters.T2,  DELTA.DATA:first());
	TS2:setWidth(instance.parameters.width3);
    TS2:setStyle(instance.parameters.style3);
	else
	TS2 =  instance:addInternalStream(0, 0);
	end
	
 
		TS2:setPrecision(math.max(2, instance.source:getPrecision()));
		TS1:setPrecision(math.max(2, instance.source:getPrecision()));
		QQE:setPrecision(math.max(2, instance.source:getPrecision()));

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

		

				 RSI:update(mode);
				 
				 MA:update(mode);
				 
				 if period < MA.DATA:first() then
				 return;
				 end
						 
				 QQE[period] = MA.DATA[period];
						 
				

				 if period < MA.DATA:first()+1 then
				 return;
				 end
				 
				 TR[period] = math.abs(MA.DATA[period] - MA.DATA[period-1]);
				 
				 
				 
				
				 ATR:update(mode);
									 
				  DELTA:update(mode);	

               	if period < DELTA.DATA:first() then
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
													
														
														
														
			

end