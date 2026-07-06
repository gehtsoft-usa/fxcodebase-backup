-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60726

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Double Bollinger Bands as described in Mark Whistler's book 'Volatility Illuminated'
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Double Bollinger Bands");
    indicator:description("2 Bollinger Bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("BB1 Settings");
	indicator.parameters:addInteger("BB1", "Period", "", 14);
	indicator.parameters:addDouble("Dev1", "Standard Deviation", "", 2.2);
	
	indicator.parameters:addGroup("BB1 Style");
	indicator.parameters:addBoolean("HideUpperBB1", "Hide Upper Band", "", false);
    indicator.parameters:addColor("colorUpperBB1", "Upper Band Color","", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("widthUpperBB1", "Upper Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleUpperBB1", "Upper Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleUpperBB1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideLowerBB1", "Hide Lower Band", "", false);
    indicator.parameters:addColor("colorLowerBB1", "Lower Band Color","", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("widthLowerBB1", "Lower Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLowerBB1", "Lower Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLowerBB1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideMidlineBB1", "Hide Midline", "", false);
    indicator.parameters:addColor("colorMidlineBB1", "Midline Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMidlineBB1", "Midline Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMidlineBB1", "Midline Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMidlineBB1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("BB2 Settings");
	indicator.parameters:addInteger("BB2", "Period", "", 50);
	indicator.parameters:addDouble("Dev2", "First Standard Deviation", "", 1.2);
	indicator.parameters:addDouble("Dev3", "Second Standard Deviation", "", 2.2);		
	indicator.parameters:addDouble("Dev4", "Third Standard Deviation", "", 3.2);		
	
	indicator.parameters:addGroup("BB2 Style");
	
	indicator.parameters:addBoolean("HideFirstUpperBB2", "Hide First Upper Band", "", false);
    indicator.parameters:addColor("colorFirstUpperBB2", "First Upper Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthFirstUpperBB2", "First Upper Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirstUpperBB2", "First Upper Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirstUpperBB2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideFirstLowerBB2", "Hide First Lower Band", "", false);
    indicator.parameters:addColor("colorFirstLowerBB2", "First Lower Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthFirstLowerBB2", "First Lower Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirstLowerBB2", "First Lower Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirstLowerBB2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideSecondUpperBB2", "Hide Second Upper Band", "", false);
    indicator.parameters:addColor("colorSecondUpperBB2", "Second Upper Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthSecondUpperBB2", "Second Upper Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSecondUpperBB2", "Second Upper Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecondUpperBB2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideSecondLowerBB2", "Hide Second Lower Band", "", false);
    indicator.parameters:addColor("colorSecondLowerBB2", "Second Lower Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthSecondLowerBB2", "Second Lower Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSecondLowerBB2", "Second Lower Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecondLowerBB2", core.FLAG_LEVEL_STYLE);	
	
    indicator.parameters:addBoolean("HideThirdUpperBB2", "Hide Third Upper Band", "", false);
    indicator.parameters:addColor("colorThirdUpperBB2", "Third Upper Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthThirdUpperBB2", "Third Upper Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleThirdUpperBB2", "Third Upper Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleThirdUpperBB2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addBoolean("HideThirdLowerBB2", "Hide Third Lower Band", "", false);
    indicator.parameters:addColor("colorThirdLowerBB2", "Third Lower Band Color","", core.rgb(0, 64, 6));
    indicator.parameters:addInteger("widthThirdLowerBB2", "Third Lower Band Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleThirdLowerBB2", "Third Lower Band Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleThirdLowerBB2", core.FLAG_LEVEL_STYLE);

	indicator.parameters:addBoolean("HideMidlineBB2", "Hide Midline BB2", "", false);
    indicator.parameters:addColor("colorMidlineBB2", "BB2 Midline Color","", core.rgb(0, 128, 0));
    indicator.parameters:addInteger("widthMidlineBB2", "BB2 Midline Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMidlineBB2", "BB2 Midline Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMidlineBB2", core.FLAG_LEVEL_STYLE);	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BB1;
local BB2;
local D1;
local D2;
local D3;
local D4; 
local firstPeriod1;
local firstPeriod2;
local source = nil;

-- Streams block
local TL1 = nil;
local BL1 = nil;
local AL1 = nil;
local TL2 = nil;
local BL2 = nil;
local AL2 = nil;
local TL3 = nil;
local BL3 = nil;
local TL4 = nil;
local BL4 = nil;


-- Routine
 function Prepare(nameOnly)  
    BB1 = instance.parameters.BB1;
    D1 = instance.parameters.Dev1;
	BB2 = instance.parameters.BB2;
	D2 = instance.parameters.Dev2;
    D3 = instance.parameters.Dev3;
	D4 = instance.parameters.Dev4;	
    source = instance.source;
    firstPeriod1 = source:first() + BB1 - 1;
	firstPeriod2 = source:first() + BB2 - 1;

    local name = " (" .. BB1 .. ",  " .. D1 .. ")"..   " (" .. BB2 .. ",  " .. D2 .. ",  " .. D3 .. ",  " .. D4 .. ")"

    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	if not instance.parameters.HideUpperBB1 then
    TL1 = instance:addStream("TL1", core.Line, name .. ".TL1", "TL1", instance.parameters.colorUpperBB1, firstPeriod1);
    TL1:setWidth(instance.parameters.widthUpperBB1);
    TL1:setStyle(instance.parameters.styleUpperBB1);
	else	
	    TL1 = instance:addInternalStream(0,0);
		end
		
		if not instance.parameters.HideLowerBB1 then
    BL1 = instance:addStream("BL1", core.Line, name .. ".BL1", "BL1", instance.parameters.colorLowerBB1, firstPeriod1);
    BL1:setWidth(instance.parameters.widthLowerBB1);
    BL1:setStyle(instance.parameters.styleLowerBB1);
	else	
	    BL1 = instance:addInternalStream(0,0);
		end
		
		if not instance.parameters.HideMidlineBB1 then
    AL1 = instance:addStream("AL1", core.Line, name .. ".AL1", "AL1", instance.parameters.colorMidlineBB1, firstPeriod1);
    AL1:setWidth(instance.parameters.widthMidlineBB1);
    AL1:setStyle(instance.parameters.styleMidlineBB1);
	else	
	    AL1 = instance:addInternalStream(0,0);
		end	
    
	if not instance.parameters.HideFirstUpperBB2 then
    TL2 = instance:addStream("TL2", core.Line, name .. ".TL2", "TL2", instance.parameters.colorFirstUpperBB2, firstPeriod2);
    TL2:setWidth(instance.parameters.widthFirstUpperBB2);
    TL2:setStyle(instance.parameters.styleFirstUpperBB2);
	else	
	    TL2 = instance:addInternalStream(0,0);
		end
		
	if not instance.parameters.HideFirstLowerBB2 then
    BL2 = instance:addStream("BL2", core.Line, name .. ".BL2", "BL2", instance.parameters.colorFirstLowerBB2, firstPeriod2);
    BL2:setWidth(instance.parameters.widthFirstLowerBB2);
    BL2:setStyle(instance.parameters.styleFirstLowerBB2);
	else	
	    BL2 = instance:addInternalStream(0,0);
		end	
		
	if not instance.parameters.HideSecondUpperBB2 then
    TL3 = instance:addStream("TL3", core.Line, name .. ".TL3", "TL3", instance.parameters.colorSecondUpperBB2, firstPeriod2);
    TL3:setWidth(instance.parameters.widthSecondUpperBB2);
    TL3:setStyle(instance.parameters.styleSecondUpperBB2);
	else	
	    TL3 = instance:addInternalStream(0,0);
		end
		
	if not instance.parameters.HideSecondLowerBB2 then
    BL3 = instance:addStream("BL3", core.Line, name .. ".BL3", "BL3", instance.parameters.colorSecondLowerBB2, firstPeriod2);
    BL3:setWidth(instance.parameters.widthSecondLowerBB2);
    BL3:setStyle(instance.parameters.styleSecondLowerBB2);
	else	
	    BL3 = instance:addInternalStream(0,0);
		end		
		
	if not instance.parameters.HideThirdUpperBB2 then
    TL4 = instance:addStream("TL4", core.Line, name .. ".TL4", "TL4", instance.parameters.colorThirdUpperBB2, firstPeriod2);
    TL4:setWidth(instance.parameters.widthThirdUpperBB2);
    TL4:setStyle(instance.parameters.styleThirdUpperBB2);
	else	
	    TL4 = instance:addInternalStream(0,0);
		end
		
	if not instance.parameters.HideThirdLowerBB2 then
    BL4 = instance:addStream("BL4", core.Line, name .. ".BL4", "BL4", instance.parameters.colorThirdLowerBB2, firstPeriod2);
    BL4:setWidth(instance.parameters.widthThirdLowerBB2);
    BL4:setStyle(instance.parameters.styleThirdLowerBB2);
	else	
	    BL4 = instance:addInternalStream(0,0);
		end			
		
	if not instance.parameters.HideMidlineBB2 then
    AL2 = instance:addStream("AL2", core.Line, name .. ".AL2", "AL2", instance.parameters.colorMidlineBB2, firstPeriod2);
    AL2:setWidth(instance.parameters.widthMidlineBB2);
    AL2:setStyle(instance.parameters.styleMidlineBB2);
	else	
	    AL2 = instance:addInternalStream(0,0);
		end				
  
	
end

--Indicator calculation routine
function Update(period)
    if period < firstPeriod1 then
	return;
	end
        local p = core.rangeTo(period, BB1);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);

        TL1[period] = ml + D1 * d;
        BL1[period] = ml - D1 * d;
        AL1[period] = ml;
		
   
		if period < firstPeriod2 then
		return;
	    end
		
        local p = core.rangeTo(period, BB2);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);
		
		TL2[period] = ml + D2 * d;
        BL2[period] = ml - D2 * d;
        AL2[period] = ml;
		TL3[period] = ml + D3 * d;
		BL3[period] = ml - D3 * d;
		TL4[period] = ml + D4 * d;
		BL4[period] = ml - D4 * d;
		
		
    end





