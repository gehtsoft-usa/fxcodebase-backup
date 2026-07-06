-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67174

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("SVE Volatility Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("BandsPeriod", "BandsPeriod", "", 20, 1, 2000);
    indicator.parameters:addDouble("BandsDeviation", "Bands Deviation", "", 2.4 );
	indicator.parameters:addDouble("LowBandAdjust", "LowBand Adjust", "", 0.9);
	indicator.parameters:addInteger("MidLineLength", "MidLine Length", "", 20, 1, 2000);
 
	
    
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Top Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local BandsPeriod, BandsDeviation,LowBandAdjust, MidLineLength;



local first;
local source = nil;
 
local ATR,WMA;
local Typical;
-- Routine
 function Prepare(nameOnly)   
 
 
 
    BandsPeriod= instance.parameters.BandsPeriod;
	BandsDeviation= instance.parameters.BandsDeviation;
	LowBandAdjust= instance.parameters.LowBandAdjust;
	MidLineLength= instance.parameters.MidLineLength;
 
	
	
	local Parameters= BandsPeriod ..  ", " .. BandsDeviation ..  ", " .. LowBandAdjust ..  ", " .. MidLineLength;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    ATR  = core.indicators:create("ATR", source, (BandsPeriod * 2 - 1));
	WMA = core.indicators:create("WMA", source, BandsPeriod);
    Typical= core.indicators:create("WMA", source.typical, MidLineLength);
    first=math.max(ATR.DATA:first(),WMA.DATA:first(),Typical.DATA:first());
	
	 
   
   
   
    HighBand = instance:addStream("HighBand" , core.Line, " HighBand"," HighBand",instance.parameters.color1, first);
	HighBand:setWidth(instance.parameters.width1);
    HighBand:setStyle(instance.parameters.style1);
	
	LowBand = instance:addStream("LowBand" , core.Line, " LowBand"," LowBand",instance.parameters.color2, first);
	LowBand:setWidth(instance.parameters.width2);
    LowBand:setStyle(instance.parameters.style2);
	
 
	
	
	MidLine = instance:addStream("MidLine" , core.Line, " MidLine"," MidLine",instance.parameters.color3, first);
	MidLine:setWidth(instance.parameters.width3);
    MidLine:setStyle(instance.parameters.style3);
  
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ATR:update(mode);
	WMA:update(mode);
	Typical:update(mode);
	
    if period < first then
	return;
	end
	
		
    local  ATRVal=ATR.DATA[period]* BandsDeviation;
	
	
	HighBand[period] = WMA.DATA[period] + WMA.DATA[period]  * ( ATRVal / source.close[period] ) ;
    LowBand[period] = WMA.DATA[period] - WMA.DATA[period]  * ( ATRVal * LowBandAdjust / source.close[period] ) ;
	MidLine	[period] = Typical.DATA[period];
end
