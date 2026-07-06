-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68778

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
    indicator:name("TMMS");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("RSI Calculation"); 
	indicator.parameters:addString("RSI_Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("RSI_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("RSI_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("RSI_Price", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("RSI_Period", "Period", "", 14, 2, 2000);
	
	
	indicator.parameters:addGroup("1. Stochastic Calculation");
    indicator.parameters:addInteger("K1", "Number of periods for %K", "", 8, 2, 1000);
    indicator.parameters:addInteger("SD1", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D1", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS1", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS1", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS1", "FS","", "FS");
    
    indicator.parameters:addString("DS1", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS1", "EMA", "", "EMA");
	
	
	
	
	indicator.parameters:addGroup("2. Stochastic Calculation");
    indicator.parameters:addInteger("K2", "Number of periods for %K", "", 14, 2, 1000);
    indicator.parameters:addInteger("SD2", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D2", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS2", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS2", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS2", "FS","", "FS");
    
    indicator.parameters:addString("DS2", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS2", "EMA", "", "EMA");
   
 
	
	indicator.parameters:addGroup("RSI Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("1. Stochastic Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("2. Stochastic Style"); 	
	
	indicator.parameters:addBoolean("Show", "Show", "Show", false);
	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Bar Style"); 	
    indicator.parameters:addColor("color4", "Up Bar Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("color5", "Down Bar Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color6", "Down Bar Color", "", core.rgb(0, 0, 255)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local RSI_Price,RSI_Period; 
local Stochastic_1, Stochastic_2;

local first;
local source = nil;
local threshold=50;
local limit=0;
local Oscillator1, Oscillator2, Oscillator3, Oscillator4;
local RSI;
local Show;
-- Routine
 function Prepare(nameOnly)   
 
 
    RSI_Price= instance.parameters.RSI_Price;
	RSI_Period= instance.parameters.RSI_Period;
	Show= instance.parameters.Show;
	
	local Parameters="";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	RSI = core.indicators:create("RSI", source[RSI_Price], RSI_Period);
	Stochastic_1= core.indicators:create("STOCHASTIC", source , instance.parameters.K1,instance.parameters.SD1,instance.parameters.D1,instance.parameters.KS1,instance.parameters.DS1);
	Stochastic_2= core.indicators:create("STOCHASTIC", source , instance.parameters.K2,instance.parameters.SD2,instance.parameters.D2,instance.parameters.KS2,instance.parameters.DS2);
    first=math.max(Stochastic_1.D:first(), Stochastic_2.D:first(),RSI.DATA:first());
	

   
 
	Oscillator1 = instance:addStream("RSI" , core.Line, " RSI"," RSI",instance.parameters.color1, first );
	Oscillator1:setWidth(instance.parameters.width1);
    Oscillator1:setStyle(instance.parameters.style1);
    Oscillator1:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator2 = instance:addStream("STOCHASTIC1" , core.Line, " 1. Stochastic"," 1. Stochastic",instance.parameters.color2, first );
	Oscillator2:setWidth(instance.parameters.width2);
    Oscillator2:setStyle(instance.parameters.style2);
    Oscillator2:setPrecision(math.max(2, source:getPrecision()));
	
	if Show then
	Oscillator3 = instance:addStream("STOCHASTIC2" , core.Line, " 2. Stochastic"," 2. Stochastic",instance.parameters.color3, first );
	Oscillator3:setWidth(instance.parameters.width3);
    Oscillator3:setStyle(instance.parameters.style3);
    Oscillator3:setPrecision(math.max(2, source:getPrecision()));
	
	else
	Oscillator3= instance:addInternalStream(0, 0);
	end
	
	Oscillator4 = instance:addStream("BAR" , core.Bar, "Bar"," Bar",instance.parameters.color4, first ); 
    Oscillator4:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
     
	 
	RSI:update(mode);
	Stochastic_1:update(mode);
	Stochastic_2:update(mode);
 
	if period < source:first()  
	then
	return;
	end 
		
    Oscillator1[period]=RSI.DATA[period]-threshold;
    Oscillator2[period]=Stochastic_1.DATA[period]-threshold;
    Oscillator3[period]=Stochastic_2.DATA[period]-threshold;
	
	
	if(Oscillator1[period] >limit and Oscillator2[period]>limit and Oscillator3[period]>limit) then
    Oscillator4:setColor(period, instance.parameters.color4);    
    elseif(Oscillator1[period]<limit and Oscillator2[period]<limit and Oscillator3[period]<limit) then
    Oscillator4:setColor(period, instance.parameters.color5);  
    else
	Oscillator4:setColor(period, instance.parameters.color6)
	end
        

	Oscillator4[period]=Oscillator3[period];
		   
end


 
