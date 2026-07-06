-- Id: 920

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
    indicator:name(" Qualitative Quantitative Estimation");
    indicator:description(" Qualitative Quantitative Estimation");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("RF", "RSI Period", "RSI Period", 14);
    indicator.parameters:addInteger("RSP", "RSI  Smoothing Period", "RSI  Smoothing Period", 5);
    indicator.parameters:addInteger("AP", " ATR Period", " ATR Period", 14);
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
local RS;
local AP;
local FM;
local SM;
local Slow;
local CentalLevel;
local first;
local source = nil;

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

-- Routine
function Prepare(nameOnly)
    RF = instance.parameters.RF;
    RS = instance.parameters.RSP;
    AP = instance.parameters.AP;
    FL = instance.parameters.FL;
	SL = instance.parameters.SL;
    SM = instance.parameters.S;	 
	FM = instance.parameters.F;
	CentalLevel = instance.parameters.CentalLevel;
    source = instance.source;
    first = source:first();
	
	WildersPeriod=RF * 2 - 1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. RF .. ", " .. RS .. ", " .. AP .. ", "  .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end	
	RSI = core.indicators:create("RSI", source, RF);
	EMA = core.indicators:create("EMA", RSI.DATA, RS);
	TR =  instance:addInternalStream(0, 0);
	ATR = core.indicators:create("EMA", TR, AP);
	DELTA = core.indicators:create("EMA", ATR.DATA, WildersPeriod);
	

    QQE = instance:addStream("QQE", core.Line, name .. ".QQE", "QQE", instance.parameters.Q,  EMA.DATA:first());
    QQE:setPrecision(math.max(2, instance.source:getPrecision()));
	QQE:setWidth(instance.parameters.width1);
    QQE:setStyle(instance.parameters.style1);
	
	
	QQE:addLevel(CentalLevel, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	if FL then
	TS1 = instance:addStream("TS1", core.Line, name .. ".TS", "TS Fast", instance.parameters.T1,  DELTA.DATA:first());
    TS1:setPrecision(math.max(2, instance.source:getPrecision()));
	TS1:setWidth(instance.parameters.width1);
    TS1:setStyle(instance.parameters.style1);
	else
	TS1 =  instance:addInternalStream(0, 0);
	end
	
	
	
	if SL then
	TS2 = instance:addStream("TS2", core.Line, name .. ".TS", "TS Slow", instance.parameters.T2,  DELTA.DATA:first());
    TS2:setPrecision(math.max(2, instance.source:getPrecision()));
	TS2:setWidth(instance.parameters.width1);
    TS2:setStyle(instance.parameters.style1);
	else
	TS2 =  instance:addInternalStream(0, 0);
	end

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

		

				 RSI:update(mode);
				 
				 EMA:update(mode);
				 
				 if period < EMA.DATA:first() then
				 return;
				 end
						 
				 QQE[period] = EMA.DATA[period];
						 
				

				 if period < EMA.DATA:first()+1 then
				 return;
				 end
				 
				 TR[period] = math.abs(EMA.DATA[period] - EMA.DATA[period-1]);
				 
				 
				 
				
				 ATR:update(mode);
									 
				  DELTA:update(mode);	

               	if period < DELTA.DATA:first() then
				 return;
				 end
				 		  
												
														if EMA.DATA[period] < TS1[period-1] then														
														
														 Stop1=EMA.DATA[period] + DELTA.DATA[period]*FM;
														 
															 if Stop1 > TS1[period-1] then
															         
															 	   if EMA.DATA[period-1] <  TS1[period-1]  then 														     
															       Stop1 = TS1[period-1];
																   end
															     
															 end									
																
														elseif  EMA.DATA[period] > TS1[period-1] then
														
                                                         Stop1=EMA.DATA[period] - DELTA.DATA[period]*FM;
														 
															 if Stop1 < TS1[period-1] then
															        
															        if EMA.DATA[period-1] >  TS1[period-1]  then 														     
															       Stop1 = TS1[period-1];
																   end
															       
															 end
															 
													    end	
														
														TS1[period]=Stop1;
														
													
														
																	if EMA.DATA[period] < TS2[period-1] then														
																
																 Stop2=EMA.DATA[period] + DELTA.DATA[period]*SM;
																 
																	 if Stop2 > TS2[period-1] then
																			 
																			 if EMA.DATA[period-1] <  TS2[period-1]  then 	
																			 Stop2 = TS2[period-1];
																			 end
																	 end									
																		
																elseif  EMA.DATA[period] > TS2[period-1] then
																
																 Stop2=EMA.DATA[period] - DELTA.DATA[period]*SM;
																 
																	 if Stop2 < TS2[period-1] then
																			 
																			 if EMA.DATA[period-1] >  TS2[period-1]  then 
																			 Stop2 = TS2[period-1];
																			 end
																	 end
																	 
																end		
																
																TS2[period]=Stop2;
													
														
														
														
			

end