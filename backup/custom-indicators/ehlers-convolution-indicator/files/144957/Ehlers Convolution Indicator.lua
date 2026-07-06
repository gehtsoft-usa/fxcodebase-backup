-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71858

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

function Init()
    indicator:name("Ehlers Convolution");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("HPLength", "HPLength", "", 80, 2, 2000);
    indicator.parameters:addInteger("SSFLength", "SSFLength", "", 40, 2, 2000);
	indicator.parameters:addInteger("CorrLength", "CorrLength", "", 48, 2, 2000);
 
 


	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local MHPLength, SSFLength, CorrLength; 
local first;
local source = nil;
 
local Oscillator;  
local a1, a2, b1, b2, c1,c2,c3;
local hp,rfilt;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    HPLength = instance.parameters.HPLength;
	SSFLength= instance.parameters.SSFLength;
    CorrLength = instance.parameters.CorrLength;
	
	
	local Parameters= HPLength ..  ", " .. SSFLength ..  ", " .. CorrLength;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+2;
	
	hp = instance:addInternalStream(0, 0);
	rfilt = instance:addInternalStream(0, 0);
	
	pi = 2 * math.asin(1)
	twoPiPrd = 0.707 * 2 * pi / HPLength
	a1 = (math.cos(twoPiPrd) + math.sin(twoPiPrd) - 1) / math.cos(twoPiPrd)
	a2 = math.exp(-1.414 * pi / SSFLength)
	b1 = 2 * a2 * math.cos(1.414 * pi / SSFLength)
	c2 = b1
	c3 = -a2 * a2
	c1 = 1 - c2 - c3	
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Up, source:first()+CorrLength);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    
	
    if period < first then
	return;
	end
	
    hp[period]= ((1 - (a1 / 2)) * (1 - (a1 / 2)) * (source[period] - (2 * source[period-1]) +source[period-2])) + (2 * (1 - a1) *  hp[period-1]) - ((1 - a1) * (1 - a1) * hp[period-2]);
	rfilt[period]= (c1 * ((hp[period] + hp[period-1] ) / 2)) + (c2 *  rfilt[period-1] ) + (c3 * rfilt[period-2]);	
	
	local sx = 0.0;
	local sy = 0.0;
	local sxx = 0.0;
	local syy = 0.0;
	local sxy = 0.0; 

    if period < CorrLength then
    return;
    end	
	
	for n = 1,CorrLength, 1 do
    sx = 0.0;
	sy = 0.0;
	sxx = 0.0;
	syy = 0.0;
	sxy = 0.0;
	
			for i = 1,n,1 do
			
			    x =  rfilt[period-i + 1];-- i-1
				y =  rfilt[period-n + i];
				sx = sx + x;
				sy = sy + y;
				sxx = sxx + (x * x);
				sxy  = sxy + (x * y);
				syy  = syy + (y * y);
				if ((n * sxx) - (sx * sx)) * ((n * syy) - (sy * sy)) > 0 then
				Oscillator[period] =   ((n * sxy) - (sx * sy)) / math.sqrt(((n * sxx) - (sx * sx)) * ((n * syy) - (sy * sy)));
				else
				Oscillator[period]=0;
				end
				
			
		
			end
	 
    end    
   
    if hp[period] > 0 then
	Oscillator:setColor(period, instance.parameters.Up);
	else
	Oscillator:setColor(period, instance.parameters.Down);	
    end	
end

 