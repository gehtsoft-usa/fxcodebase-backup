-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71727

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
    indicator:name("Impulse Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 	 
 	indicator.parameters:addInteger("length", "length", "", 21, 1, 2000);
 	indicator.parameters:addInteger("smoothing", "smoothing", "", 4, 1, 2000)	

	indicator.parameters:addGroup("Up Bar Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
	
	
	indicator.parameters:addGroup("Down Bar	Style"); 	
    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	
	
    indicator.parameters:addColor("color3", "Top Line Color", "", core.rgb(128, 128, 128));	
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	indicator.parameters:addInteger("width1", "Line Width", "", 5, 1, 5);

	
	
    indicator.parameters:addColor("color4", "Bottom Line Color", "", core.rgb(128, 128, 128));		
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);	
	indicator.parameters:addInteger("width2", "Line Width", "", 5, 1, 5);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;
local length,smoothing; 
 
-- Routine
 function Prepare(nameOnly)   
 
 
	length=instance.parameters.length;
	smoothing=instance.parameters.smoothing;
	
	local Parameters= length ..", ".. smoothing;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+1;
	
	inner_range= instance:addInternalStream(0, 0);
   
 
	up_sequence = instance:addStream("up_sequence" , core.Bar, " up_sequence"," up_sequence",instance.parameters.color1, first );
    up_sequence:setPrecision(math.max(2, source:getPrecision()));
	
	down_sequence = instance:addStream("down_sequence" , core.Bar, " down_sequence"," down_sequence",instance.parameters.color2, first );
    down_sequence:setPrecision(math.max(2, source:getPrecision()));
	SMA1 = core.indicators:create("MVA", up_sequence, length);
	EMA1 = core.indicators:create("EMA", SMA1.DATA, smoothing);
	SMA2 = core.indicators:create("MVA", down_sequence, length);
	EMA2 = core.indicators:create("EMA", SMA2.DATA, smoothing);


	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color3, first );
	Top:setWidth(instance.parameters.width3);
	Top:setStyle(instance.parameters.style3);	
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color4, first );
	Bottom:setWidth(instance.parameters.width4);
	Bottom:setStyle(instance.parameters.style4);	
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
	
	
	BearSqueeze= instance:addStream("BearSqueeze" , core.Dot, " BearSqueeze"," BearSqueeze",instance.parameters.color2, first );
	BearSqueeze:setWidth(instance.parameters.width1);	
	
	BullSqueeze= instance:addStream("BullSqueeze" , core.Dot, " BullSqueeze"," BullSqueeze",instance.parameters.color1, first );	
	BullSqueeze:setWidth(instance.parameters.width2);	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	inner_range[period] = source[period] - source[period-1];

	if source[period] < source[period-1] then 
	up_sequence[period]=0 
	else
	up_sequence[period]=up_sequence[period-1] + inner_range[period];
	end

	if source[period] > source[period-1] then
	down_sequence[period]=0
	else
	down_sequence[period]= down_sequence[period-1] + inner_range[period];
	end
	 
	SMA1:update(mode);
	SMA2:update(mode);

	EMA1:update(mode);
	EMA2:update(mode);
	
	Top[period]=EMA1.DATA[period];
	Bottom[period]=EMA2.DATA[period];	


 if EMA1.DATA[period] >= SMA1.DATA[period] then 
 BearSqueeze[period]=Top[period]
 else 
 BearSqueeze[period]=nil;
 end
 
 if EMA2.DATA[period] <= SMA2.DATA[period] then 
 BullSqueeze[period]=Bottom[period] 
 else
 BearSqueeze[period]=nil;
 end
 
end


 
