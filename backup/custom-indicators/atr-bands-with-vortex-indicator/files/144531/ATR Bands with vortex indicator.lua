-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71731

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

function Init()
    indicator:name("ATR Bands with vortex indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 14, 1, 2000);
    indicator.parameters:addDouble("Multiplier1", "1. Multiplier", "", 1.5, 0, 2000);	
    indicator.parameters:addInteger("Period2", "2. Period", "", 14, 1, 2000);
    indicator.parameters:addDouble("Multiplier2", "2. Multiplier", "", 3, 0, 2000);		
     indicator.parameters:addInteger("Vortex_Period", "Vortex Period", "", 14, 1, 2000);
	 
    indicator.parameters:addBoolean("Apply", "Apply MA", "", true);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	
	indicator.parameters:addGroup("Bands Style"); 	
    indicator.parameters:addColor("color1", "1. Line  Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(128, 128, 128));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Signal Style"); 		
	indicator.parameters:addColor("clrUP", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Down Color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addInteger("Size", "Arrow Size", "", 15, 1, 2000);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

  
local first;
local source = nil;
local Vortex_Period; 
local Apply; 
-- Routine
 function Prepare(nameOnly)   
 
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Multiplier1= instance.parameters.Multiplier1;
	Multiplier2= instance.parameters.Multiplier2;
	Vortex_Period= instance.parameters.Vortex_Period;
	Apply= instance.parameters.Apply;
	Method= instance.parameters.Method;
	
	
	local Parameters= Period1..", "..Multiplier1..", "..Period2..", "..Multiplier2..", "..Vortex_Period..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	source = instance.source;
	ATR1 = core.indicators:create("ATR", source, Period1);
	ATR2 = core.indicators:create("ATR", source, Period2);	
	ATR = core.indicators:create("ATR", source, 1);		
    first=math.max(ATR1.DATA:first(), ATR2.DATA:first());
	
	vmp= instance:addInternalStream(0, 0);
 	vmm= instance:addInternalStream(0, 0); 
	
	
	vip_raw= instance:addInternalStream(0, 0);
 	vim_raw= instance:addInternalStream(0, 0);  

	MA1 = core.indicators:create(Method, vip_raw, Vortex_Period);
	MA2 = core.indicators:create(Method, vim_raw, Vortex_Period);		

	vip= instance:addInternalStream(0, 0);
 	vim= instance:addInternalStream(0, 0);  	
 
	Line1  = instance:addStream("Line1" , core.Line, "1. Line"," 1. Line",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));

	Line2  = instance:addStream("Line2" , core.Line, "2. Line"," 2. Line",instance.parameters.color2, first);	
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));
	
	Line3  = instance:addStream("Line3" , core.Line, "3. Line"," 3. Line",instance.parameters.color1, first);
	Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);
    Line3:setPrecision(math.max(2, source:getPrecision()));

	Line4  = instance:addStream("Line4" , core.Line, "4. Line"," 4. Line",instance.parameters.color2, first);	
	Line4:setWidth(instance.parameters.width);
    Line4:setStyle(instance.parameters.style);
    Line4:setPrecision(math.max(2, source:getPrecision()));	
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	
end

-- Indicator calculation routine
function Update(period, mode)

	if period < source:first()+1
	then
	return; 
	end
	vmp[period]=math.abs(source.high[period] - source.low[period-1]);
	vmm[period]=math.abs(source.low[period] - source.high[period-1]);

	ATR1:update(mode);
	ATR2:update(mode);
	ATR:update(mode);	
	
	if period < first
	then
	return; 
	end
 
		
    Line1[period]= source.close[period]+ATR1.DATA[period]*Multiplier1;
    Line2[period]= source.close[period]+ATR2.DATA[period]*Multiplier2;				
    Line3[period]= source.close[period]-ATR1.DATA[period]*Multiplier1;
    Line4[period]= source.close[period]-ATR2.DATA[period]*Multiplier2;		

	if period < source:first()+Vortex_Period
	then
	return; 
	end
	

   --Vortex indicator
	local VMP = mathex.sum( vmp, period-Vortex_Period+1, period);
	local VMM = mathex.sum( vmm, period-Vortex_Period+1, period);
    local str = mathex.sum( ATR.DATA, period-Vortex_Period+1, period);
	
	
	vip_raw[period] = VMP / str;
	vim_raw[period] = VMM / str;
	
	if period < source:first()+Vortex_Period*2
	then
	return; 
	end	
	
	if Apply  then
	MA1:update(mode);
	MA2:update(mode);
	vip[period] = MA1.DATA[period];
	vim[period] = MA2.DATA[period];	
	else
	vip[period] = vip_raw[period];
	vim[period] = vim[period];
	end
	
	
	up:setNoData(period);
	down:setNoData(period);	
 
 
    if vip[period]> vim[period]
	and  vip[period-1]<= vim[period-1]
	then
    up:set(period, source.high[period], "\217", source.high[period]);
    elseif vip[period]< vim[period]
	and  vip[period-1]>= vim[period-1]	
	then	
    down:set(period, source.low[period], "\218", source.low[period]);
    end	
	
end

 
