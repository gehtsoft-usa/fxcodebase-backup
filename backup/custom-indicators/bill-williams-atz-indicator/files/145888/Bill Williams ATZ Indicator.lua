-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72147

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
    indicator:name("Bill Williams ATZ Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
 
	
	indicator.parameters:addGroup("MACD Calculation");	
    indicator.parameters:addInteger("MACD_a", "MACD A", "", 12); 
    indicator.parameters:addInteger("MACD_b", "MACD B", "", 26); 
    indicator.parameters:addInteger("MACD_c", "MACD C", "", 9); 
	
	
	indicator.parameters:addGroup("Alligator Calculation");
    indicator.parameters:addInteger("JawN", "Jaw Period","", 13, 1, 300);
    indicator.parameters:addInteger("JawS", "Jaw Shift", "", 8, 1, 300);

    indicator.parameters:addInteger("TeethN", "Teeth Period", "", 8, 1, 300);
    indicator.parameters:addInteger("TeethS", "Teeth Shift", "", 5, 1, 300);

    indicator.parameters:addInteger("LipsN", "Lips Period", "", 5, 1, 300);
    indicator.parameters:addInteger("LipsS", "Lips Shift", "", 3, 1, 300);

    indicator.parameters:addString("MTH", "Method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH",  "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "REGRESSION", "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH","VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "VIDYA92", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH","WMA", "", "WMA");
	
	
	indicator.parameters:addGroup("AO Calculation");
    indicator.parameters:addInteger("AO1", "Fast Period","", 5, 1, 1000);
    indicator.parameters:addInteger("AO2", "Slow Period", "", 35, 1, 1000);
	
	
	indicator.parameters:addGroup("AC Calculation");
    indicator.parameters:addInteger("AC1", "Fast Period","", 5, 1, 1000);
    indicator.parameters:addInteger("AC2", "Slow Period", "", 35, 1, 1000);
    indicator.parameters:addInteger("AC3", "MA Period for Acceleration Slowdown ", "", 5, 1, 1000);	
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 40); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local MACD_a,MACD_b,MACD_c;	
local first;
local source = nil; 
local Indicator;
local Bar;	
local up, down;
local MACD_main, MACD_signal;
local Alligator;
local a_jaw,a_teeth,a_lips;
local AO1, AO2;
local AC1, AC2, AC3;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	MACD_a=instance.parameters.MACD_a;
	MACD_b=instance.parameters.MACD_b;
	MACD_c=instance.parameters.MACD_c;
	
	JawN=instance.parameters.JawN;
	JawS=instance.parameters.JawS;
	TeethN=instance.parameters.TeethN;
	TeethS=instance.parameters.TeethS;
	LipsN=instance.parameters.LipsN;
	LipsS=instance.parameters.LipsS;
	MTH=instance.parameters.MTH;
	
	AO1=instance.parameters.AO1;
	AO2=instance.parameters.AO2;
    AC1=instance.parameters.AC1;
	AC2=instance.parameters.AC2;
	AC3=instance.parameters.AC3;
	
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MACD = core.indicators:create("MACD", source.close, MACD_a, MACD_b, MACD_c); 
    Alligator= core.indicators:create("ALLIGATOR", source , JawN, JawS, TeethN,TeethS,LipsN ,LipsS, MTH); 
    AO= core.indicators:create("AO", source , AO1, AO2); 
    AC= core.indicators:create("AC", source , AC1, AC2, AC3); 
	
    MACD_main= MACD.MACD;
    MACD_signal= MACD.SIGNAL;
	
	a_jaw=Alligator.Jaw;
	a_teeth=Alligator.Teeth;
	a_lips=Alligator.Lips;
	
		
	first=math.max(MACD.SIGNAL:first(), Alligator.DATA:first(), AO.DATA:first(), AC.DATA:first());  
	
 
	tz= instance:addInternalStream(0, 0);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom , instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

    MACD:update(mode);
    Alligator:update(mode);
    AO:update(mode);
    AC:update(mode);	
	
	 if period < first then
	 return;
	 end
	  
	tz[period]=0;
	
	if(AO.DATA[period] < AO.DATA[period-1] and AC.DATA[period] < AC.DATA[period-1]) then tz[period]=-1 end;
    if(AO.DATA[period] > AO.DATA[period-1] and AC.DATA[period] > AC.DATA[period-1]) then tz[period]=1 end; 
	
	
	local a_trend=0;
	
	if(a_lips[period] > a_teeth[period] and a_teeth[period] > a_jaw[period]) then
    a_trend = 1;
    elseif(a_lips[period] < a_teeth[period] and a_teeth[period] < a_jaw[period]) then
    a_trend = -1;
	end		
	
	
	local  long_dangerous = false;
    local  short_dangerous = false;
    if(source.close[period] > a_lips[period] and MACD_main[period] < MACD_signal[period]) then long_dangerous = true; end
    if(source.close[period] < a_lips[period] and MACD_main[period] > MACD_signal[period]) then short_dangerous = true; end
		
			
 
	  
    up:setNoData(period);
    down:setNoData(period);	
	
	
	if(tz[period] == 1 and tz[period-1] ~=  1 and a_trend == 1 and source.close[period] > source.open[period] and long_dangerous == false)  then	 
    up:set(period, source.low[period], "\217", source.low[period]);	 
	end
	
	if(tz[period] == -1 and tz[period-1] ~=  -1 and a_trend == -1 and source.close[period] <  source.open[period] and short_dangerous == false) then
    down:set(period, source.high[period], "\218", source.high[period]);	
	end
	 
	
	
end