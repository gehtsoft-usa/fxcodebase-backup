-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73160

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
    indicator:name("BUY & SELL PRESSURE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "1. Period", "", 21, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 55, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 5, 1, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Regression Force Up Color", "", core.rgb(0, 255, 255)); 
	 indicator.parameters:addColor("color2", "Regression Force Down Color", "", core.rgb(255, 0, 255)); 
	 
	 indicator.parameters:addColor("color3", "Buy Pressure Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color4", "Sell Pressure Line Color", "", core.rgb(255, 0, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+1; 
 
    SProc = instance:addInternalStream(0, 0);
    BProc = instance:addInternalStream(0, 0);	
    SPprc = instance:addInternalStream(0, 0);
    BPprc = instance:addInternalStream(0, 0);
	
    Line1 = instance:addInternalStream(0, 0);
    Line2 = instance:addInternalStream(0, 0);	
    Line3 = instance:addInternalStream(0, 0);
    Line4 = instance:addInternalStream(0, 0);	
	
	Indicator1= core.indicators:create("MVA", BProc, Period1);	
	Indicator2= core.indicators:create("MVA", BPprc, Period1);	
	Indicator3= core.indicators:create("MVA", SProc, Period1);	
	Indicator4= core.indicators:create("MVA", SPprc, Period1);	
	Indicator5= core.indicators:create("MVA", source.volume, Period2);	
	
	Indicator6= core.indicators:create("MVA", Line2, Period3);	
	Indicator7= core.indicators:create("MVA", Line3, Period3);		
	
    RegressionForce = instance:addStream("RegressionForce", core.Bar, name, "Regression Force", instance.parameters.color1, first +math.max(Period1,Period2) +Period3 );
    RegressionForce:setPrecision(math.max(2, instance.source:getPrecision())); 
    RegressionForce:addLevel(0);	
	
	
    BuyPressure = instance:addStream("BuyPressure", core.Line, name, "Buy Pressure", instance.parameters.color3, first +math.max(Period1,Period2) +Period3 );
    BuyPressure:setPrecision(math.max(2, instance.source:getPrecision()));
    BuyPressure:setWidth(instance.parameters.width);
    BuyPressure:setStyle(instance.parameters.style);
    BuyPressure:addLevel(0);

    SellPressure = instance:addStream("SellPressure", core.Line, name, "Sell Pressure", instance.parameters.color4, first +math.max(Period1,Period2) +Period3 );
    SellPressure:setPrecision(math.max(2, instance.source:getPrecision()));
    SellPressure:setWidth(instance.parameters.width);
    SellPressure:setStyle(instance.parameters.style);
    SellPressure:addLevel(0);	
 
end


function Update(period, mode)


	if  not source:hasData(period) 
	then
	return;
	end
 
	if period <= first 
	then
	return;
	end
	
	local Hm    = math.max(source.high[period],source.close[period-1])
    local Lm    = math.min(source.low[period],source.close[period-1])
	  
	SProc[period] = math.abs((Hm-source.close[period])/Hm)
    BProc[period] =  math.abs((source.close[period]-Lm)/Lm)
    
	
	SPprc[period] = Hm-source.close[period]
    BPprc[period] = source.close[period]-Lm

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 
	Indicator4:update(mode);
	Indicator5:update(mode);

	if period <= first +math.max(Period1,Period2)
	then
	return;
	end	
	
	local Vn    = source.volume[period]/Indicator4.DATA[period]; 
	
	Line1[period]  = (BProc[period]/Indicator1.DATA[period])*12*Vn
	Line2[period]  = (BPprc[period]/Indicator2.DATA[period])*12*Vn
	Line3[period]  = (SProc[period]/Indicator3.DATA[period])*12*Vn
	Line4[period]  = (SPprc[period]/Indicator4.DATA[period])*12*Vn
 	
	
	if period <= first +math.max(Period1,Period2) +Period3
	then
	return;
	end		
	
	local BPo   = mathex.lreg(Line1, period-Period3+1, period)
    local SPo   = mathex.lreg(Line3, period-Period3+1, period)

	RegressionForce[period]= (BPo - SPo);
	
	
	if RegressionForce[period]> 0 then
	RegressionForce:setColor(period,  instance.parameters.color1);	
	else
	RegressionForce:setColor(period,  instance.parameters.color2);	
	end
	
	Indicator6:update(mode);
	Indicator7:update(mode); 

	BuyPressure[period]= Indicator6.DATA[period]; 
	SellPressure[period]= Indicator7.DATA[period]; 
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