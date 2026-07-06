
-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Ehlers Loops");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("periodLP", "Low-Pass Period", "", 20, 7, 2000);
    indicator.parameters:addInteger("periodHP", "High-Pass Period", "", 125, 20, 2000);
    indicator.parameters:addInteger("periodRMS", "RMS Period", "", 80, 1, 2000);	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local periodLP, Price2, Period2; 
local first;
local source = nil;
 
local PriceRMS;   

-- Routine
 function Prepare(nameOnly)    
 
    periodLP= instance.parameters.periodLP;
    periodHP= instance.parameters.periodHP;
    periodRMS = instance.parameters.periodRMS;
	 
	
	local Parameters= periodLP ..  ", " .. periodHP ..  ", " .. periodRMS;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	
 
	assert(core.indicators:findIndicator("2 POLE BUTTERWORTH HIGHPASS FILTER") ~= nil, "Please, download and install 2 POLE BUTTERWORTH HIGHPASS FILTER.LUA indicator");
	assert(core.indicators:findIndicator("2 POLE SUPER SMOOTHER FILTER") ~= nil, "Please, download and install 2 POLE SUPER SMOOTHER FILTER.LUA indicator");
	assert(core.indicators:findIndicator("FASTER ROOT MEAN SQUARE") ~= nil, "Please, download and install FASTER ROOT MEAN SQUARE.LUA indicator");    
    
	
	HP = instance:addInternalStream(0, 0);
    Price = instance:addInternalStream(0, 0);	
	
	VolHP = instance:addInternalStream(0, 0);
    Vol = instance:addInternalStream(0, 0);
	
    Indicator11 = core.indicators:create("2 POLE BUTTERWORTH HIGHPASS FILTER", source , periodHP);
    Indicator12 = core.indicators:create("2 POLE SUPER SMOOTHER FILTER", HP , periodLP);
    Indicator13 = core.indicators:create("FASTER ROOT MEAN SQUARE", Price, periodRMS);   


    Indicator21 = core.indicators:create("2 POLE BUTTERWORTH HIGHPASS FILTER", source.volume , periodHP);
    Indicator22 = core.indicators:create("2 POLE SUPER SMOOTHER FILTER", VolHP , periodLP);
    Indicator23 = core.indicators:create("FASTER ROOT MEAN SQUARE", Vol,  periodRMS);

	
    first=Indicator13.DATA:first();
	
   

   
 
	PriceRMS = instance:addStream("PriceRMS" , core.Line, " PriceRMS"," PriceRMS",instance.parameters.color1, first);
	PriceRMS:setWidth(instance.parameters.width);
    PriceRMS:setStyle(instance.parameters.style);
    PriceRMS:setPrecision(math.max(2, source:getPrecision()));
    PriceRMS:addLevel(4 )		
	PriceRMS:addLevel(2 ); 	
	PriceRMS:addLevel(1 ); 
	PriceRMS:addLevel(0 ); 	
	PriceRMS:addLevel(-1 )	
	PriceRMS:addLevel(-2 )		
    PriceRMS:addLevel(-4 )
	
 


	VolRMS = instance:addStream("VolRMS" , core.Line, " VolRMS"," VolRMS",instance.parameters.color2, first);
	VolRMS:setWidth(instance.parameters.width);
    VolRMS:setStyle(instance.parameters.style);
    VolRMS:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator11:update(mode);
    Indicator21:update(mode);
	
    if period <=  Indicator11.DATA:first() then
	return;
	end


	HP[period]=Indicator11.DATA[period];
	VolHP[period]=Indicator21.DATA[period];
	
	
    Indicator12:update(mode);
    Indicator22:update(mode); 
	
    if period <=  Indicator12.DATA:first() then
	return;
	end
	
	Price[period]=Indicator12.DATA[period];
	Vol[period]=Indicator22.DATA[period];



	
    Indicator13:update(mode); 
    Indicator23:update(mode);	
	
  
    if period <=  Indicator13.DATA:first() then
	return;
	end
  
   PriceRMS[period]= Indicator13.DATA[period];
   VolRMS[period]= Indicator23.DATA[period];


    
				  
end




 


 

 

 
 
 