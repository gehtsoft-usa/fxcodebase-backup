-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65729

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

function Init()
    indicator:name("Range Volume Price Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "Period", "", 15, 2, 2000);
	indicator.parameters:addInteger("price_smoothing", "Price Smoothing", "", 15 );
	indicator.parameters:addInteger("signal_smoothing", "Signal Smoothing", "", 15 );
	indicator.parameters:addInteger("range_period", "Range Period", "", 150 );  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color Down", "", core.rgb(0,255,0 ));
	 indicator.parameters:addColor("color2", "Line Color Up", "", core.rgb(255,0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	

	 indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0,0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local length,price_smoothing,signal_smoothing,range_period; 
local first;
local source = nil;
local MVA,EMA1,EMA2,EMA3;
local vpc,signal;

-- Routine
 function Prepare(nameOnly) 

     length = instance.parameters.length; 
	 price_smoothing = instance.parameters.price_smoothing;
	 signal_smoothing= instance.parameters.signal_smoothing;
	 range_period= instance.parameters.range_period;
 
    local name = profile:id() .. "(" ..  instance.source:name().. ", " ..  length .. ", " ..  signal_smoothing .. ", " ..  range_period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
			
    source = instance.source;
    
    raw_vpc = instance:addInternalStream(0, 0);    
   
	if price_smoothing> 1 then
    EMA1 = core.indicators:create("EMA", source.close, price_smoothing); 
	EMA2= core.indicators:create("EMA", source.volume, price_smoothing); 
	
	MVA= core.indicators:create("MVA", EMA2.DATA, length); 
    first=MVA.DATA:first();
	else
	MVA= core.indicators:create("MVA", source.volume, length); 
    first=MVA.DATA:first();
	end
 
	vpc = instance:addStream("vpc" , core.Line, "vpc","vpc",instance.parameters.color1, first);
	vpc:setWidth(instance.parameters.width1);
    vpc:setStyle(instance.parameters.style1);
	vpc:setPrecision(math.max(2, instance.source:getPrecision()));
	
    
    if signal_smoothing > 1 then
	
	EMA3= core.indicators:create("EMA", vpc, signal_smoothing); 
	signal = instance:addStream("signal" , core.Line, "signal","signal",instance.parameters.color3, first);
	signal:setWidth(instance.parameters.width2);
    signal:setStyle(instance.parameters.style2);
	
	signal:setPrecision(math.max(2, instance.source:getPrecision()));

	end
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	if price_smoothing >  1 then
			EMA1:update(mode); 
			EMA2:update(mode);
			MVA:update(mode); 
			
			if period < MVA.DATA:first() then
			return;
			end
			
			raw_vpc[period] = (EMA1.DATA[period]- EMA1.DATA[period-length+1]) * MVA.DATA[period];	
			
	
 
	else
				MVA:update(mode);
				
				if period < MVA.DATA:first() then
				return;
				end
				
				raw_vpc[period] = (source.close[period]- source.close[period-length+1]) * MVA.DATA[period];
			 
	end			
				
	if  period <= MVA.DATA:first() +range_period then
	return;
	end
	
	local min, max= mathex.minmax(raw_vpc, period-range_period+1, period)
	
	vpc[period]=(((raw_vpc[period]-min)/(max-min))*200-100)
	
				
		if signal_smoothing > 1 then
				EMA3:update(mode);
				
				if period < EMA3.DATA:first() then
				return
				end
				
				signal[period]=EMA3.DATA[period];
				
				if vpc[period]> signal[period] then
				vpc:setColor(period, instance.parameters.color1);
				else
				vpc:setColor(period, instance.parameters.color2);
				end
				
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