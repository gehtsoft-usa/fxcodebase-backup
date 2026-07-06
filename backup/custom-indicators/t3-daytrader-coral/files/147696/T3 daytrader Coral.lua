-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72789

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("T3 daytrader Coral");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Period", "Period", "",30.5, 0, 2000);
    indicator.parameters:addDouble("Hot", "Hot", "", 0.4, 0, 2000);
    indicator.parameters:addDouble("Shift", "Shift", "", 0  );	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period, Hot,Shift; 
local c1, c2, c3, c4;	
local hc1, hc2, hc3, hc4;
local lc1, lc2, lc3, lc4;
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Hot=instance.parameters.Hot;
	Shift=instance.parameters.Shift;
	source = instance.source
	
	b = Hot
	b2 = b * b
	b3 =  b * b * b
	 
	c1 = -(b * b * b)
	c2 = 3 * b2 + 3 * b3
	c3 = -6 * b2 - 3 * b - 3 * b3
	c4 = 1 + 3 *  b  + b3 + 3 * b2
	
	hb = Hot
	hb2 = hb *hb
	hb3 =  hb * hb * hb
	 
	hc1 = -(hb * hb * hb)
	hc2 = 3 * hb2 + 3 * hb3
	hc3 = -6 * hb2 - 3 * hb - 3 * hb3
	hc4 = 1 + 3 *  hb  + hb3 + 3 * hb2
	
	lb = Hot
	lb2 = lb * lb
	lb3 =  lb * lb * lb
	 
	lc1 = -(lb * lb * lb)
	lc2 = 3 * lb2 + 3 * lb3
	lc3 = -6 * lb2 - 3 * lb - 3 * lb3
	lc4 = 1 + 3 *  lb  + lb3 + 3 * lb2
 	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Hot .. "," ..   Shift  ..  ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	e1= core.indicators:create("EMA", source.close, Period );
	e2= core.indicators:create("EMA", e1.DATA, Period );
	e3= core.indicators:create("EMA", e2.DATA, Period );
	e4= core.indicators:create("EMA", e3.DATA, Period );
	e5= core.indicators:create("EMA", e4.DATA, Period );
	e6= core.indicators:create("EMA", e5.DATA, Period );
	

	h1= core.indicators:create("EMA", source.high, Period );
	h2= core.indicators:create("EMA", h1.DATA, Period );
	h3= core.indicators:create("EMA", h2.DATA, Period );
	h4= core.indicators:create("EMA", h3.DATA, Period );
	h5= core.indicators:create("EMA", h4.DATA, Period );
	h6= core.indicators:create("EMA", h5.DATA, Period );	
	
	l1= core.indicators:create("EMA", source.low, Period );
	l2= core.indicators:create("EMA", l1.DATA, Period );
	l3= core.indicators:create("EMA", l2.DATA, Period );
	l4= core.indicators:create("EMA", l3.DATA, Period );
	l5= core.indicators:create("EMA", l4.DATA, Period );
	l6= core.indicators:create("EMA", l5.DATA, Period ); 
	
 
 
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, e6.DATA:first() );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, l6.DATA:first() );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 

    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, math.max(source:first(),  h6.DATA:first()+ Shift) ,  Shift);
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style); 
	
end


function Update(period, mode)

	e1:update(mode); 
	e2:update(mode);
	e3:update(mode);
	e4:update(mode);
	e5:update(mode);
	e6:update(mode);
	
	l1:update(mode); 
	l2:update(mode);
	l3:update(mode);
	l4:update(mode);
	l5:update(mode);
	l6:update(mode);

	h1:update(mode); 
	h2:update(mode);
	h3:update(mode);
	h4:update(mode);
	h5:update(mode);
	h6:update(mode);
	
	
	 if period > e6.DATA:first() 
	 and period + Shift >= source:first() 
	 then
	 Central[period+Shift] = c1 * e6.DATA[period] + c2 * e5.DATA[period] + c3 * e4.DATA[period] + c4 * e3.DATA[period];
	 end
	 

	Top[period] = hc1 *  h6.DATA[period] + hc2 * h5.DATA[period] + hc3 * h4.DATA[period] + hc4 * h3.DATA[period] 
    Bottom[period] = lc1 *  l6.DATA[period] + lc2 *  l5.DATA[period] + lc3 *  l4.DATA[period] + lc4 * l3.DATA[period]
 
	  
	
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