-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67325 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Range Bound Channel Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 100, 1, 2000);
	
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("1. Up Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("2. Up Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("1. Down Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("2. Down Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(128, 128,128));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period; 
local first;
local price = nil;
 
local RBCI,BB;
local up1, up2, dn1, dn2;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
			
    price = instance.source;
    first=price:first()+55
  
 
	
	 
   
 
	RBCI = instance:addStream("RBCI" , core.Line, "RBCI","RBCI",instance.parameters.color, first);
	RBCI:setWidth(instance.parameters.width);
    RBCI:setStyle(instance.parameters.style);
    RBCI:setPrecision(math.max(2, price:getPrecision()));
	
	
	up1 = instance:addStream("UP1" , core.Line, "UP1","UP1",instance.parameters.color1, first+Period);
	up1:setWidth(instance.parameters.width1);
    up1:setStyle(instance.parameters.style1);
    up1:setPrecision(math.max(2, price:getPrecision()));
	
	up2 = instance:addStream("UP2" , core.Line, "UP2","UP2",instance.parameters.color2, first+Period);
	up2:setWidth(instance.parameters.width2);
    up2:setStyle(instance.parameters.style2);
    up2:setPrecision(math.max(2, price:getPrecision()));
	
	
	dn1 = instance:addStream("DN1" , core.Line, "DN1","DN1",instance.parameters.color3, first+Period);
	dn1:setWidth(instance.parameters.width3);
    dn1:setStyle(instance.parameters.style3);
    dn1:setPrecision(math.max(2, price:getPrecision()));
	
	
	dn2 = instance:addStream("DN2" , core.Line, "DN2","DN2",instance.parameters.color3, first+Period);
	dn2:setWidth(instance.parameters.width4);
    dn2:setStyle(instance.parameters.style4);
    dn2:setPrecision(math.max(2, price:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	
	
    if period < first then
	return;
	end
	
	
	RBCI[period]=-35.524181940 
	* price[period-0]-29.333989650
	* price[period-1]-18.427744960 
	* price[period-2]-5.3418475670 
	* price[period-3]+7.0231636950 
	* price[period-4]+16.176281560
	* price[period-5]+20.656621040 
	* price[period-6]+20.326611580 
	* price[period-7]+16.270239060
	* price[period-8]+10.352401270
	* price[period-9]+4.5964239920 
	* price[period-10]+0.5817527531 
	* price[period-11]-0.9559211961
	* price[period-12]-0.2191111431 
	* price[period-13]+1.8617342810 
	* price[period-14]+4.0433304300 
	* price[period-15]+5.2342243280 
	* price[period-16]+4.8510862920
	* price[period-17]+2.9604408870 
	* price[period-18]+0.1815496232 
	* price[period-19]-2.5919387010 
	* price[period-20]-4.5358834460 
	* price[period-21]-5.1808556950 
	* price[period-22]-4.5422535300 
	* price[period-23]-3.0671459820 
	* price[period-24]-1.4310126580 
	* price[period-25]-0.2740437883 
	* price[period-26]+0.0260722294 
	* price[period-27]-0.5359717954 
	* price[period-28]-1.6274916400 
	* price[period-29]-2.7322958560 
	* price[period-30]-3.3589596820 
	* price[period-31]-3.2216514550 
	* price[period-32]-2.3326257940 
	* price[period-33]-0.9760510577 
	* price[period-34]+0.4132650195
	* price[period-35]+1.4202166770 
	* price[period-36]+1.7969987350
	* price[period-37]+1.5412722800 
	* price[period-38]+0.8771442423 
	* price[period-39]+0.1561848839 
	* price[period-40]-0.2797065802 
	* price[period-41]-0.2245901578
	* price[period-42]+0.3278853523
	* price[period-43]+1.1887841480
	* price[period-44]+2.0577410750 
	* price[period-45]+2.6270409820 
	* price[period-46]+2.6973742340 
	* price[period-47]+2.2289941280 
	* price[period-48]+1.3536792430 
	* price[period-49]+0.3089253193 
	* price[period-50]-0.6386689841
	* price[period-51]-1.2766707670 
	* price[period-52]-1.5136918450 
	* price[period-53]-1.3775160780
	* price[period-54]-1.6156173970 
	* price[period-55]
 
 
   if period < first+Period then
	return;
	end
    
    local Average=mathex.avg(RBCI, period-Period+1, period);
	local Stdev=mathex.stdev(RBCI, period-Period+1, period);
	
    up1[period] = Average+Stdev
	up2[period] = Average+Stdev*2
	dn1[period] = Average-Stdev
	dn2[period] = Average-Stdev*2
				  
end


 