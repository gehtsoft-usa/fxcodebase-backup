-- Id: 16295

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63626

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
    indicator:name("CDUR");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period11", "Period", "", 9, 2, 2000);
    indicator.parameters:addInteger("Period12", "Period", "", 19, 2, 2000);
	indicator.parameters:addInteger("Period13", "Period", "", 6, 2, 2000);
	indicator.parameters:addInteger("Period14", "Period", "", 5, 2, 2000);
 
    indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period21", "Period", "", 45, 2, 2000);
    indicator.parameters:addInteger("Period22", "Period", "", 95, 2, 2000);
	indicator.parameters:addInteger("Period23", "Period", "", 6, 2, 2000);
	indicator.parameters:addInteger("Period24", "Period", "", 8, 2, 2000);
 

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", " CDURUTC Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color2", " CDURUTS Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local  Period11;
local  Period12;
local  Period13;
local  Period14;
local  Period21;
local  Period22;
local  Period23;
local  Period24;
 
local first1, first2;
local source = nil;
 
local CDURUTC, CDURUTS;

local e1,e2;
local Dema11, Dema12, Dema13;
local Dema21, Dema22, Dema23;
local hausse1, baisse1;
local hausse2, baisse2;
local Wma11, Wma12;
local Wma21, Wma22;
-- Routine
function Prepare(nameOnly) 
    Period11= instance.parameters.Period11;
    Period12= instance.parameters.Period12;
	Period13= instance.parameters.Period13;
	Period14= instance.parameters.Period14;
			
	Period21= instance.parameters.Period21;
    Period22= instance.parameters.Period22;
	Period23= instance.parameters.Period23;
	Period24= instance.parameters.Period24;
	
    source = instance.source;
	
	
	
	local name = profile:id() .. " , " .. source:name();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("DEMA") ~= nil, "Please, download and install DEMA.LUA indicator");
    
      e1 = instance:addInternalStream(0, 0);
	  e2 = instance:addInternalStream(0, 0);
	  
	  hausse1 = instance:addInternalStream(0, 0);
	  baisse1 = instance:addInternalStream(0, 0);
	  
	  hausse2 = instance:addInternalStream(0, 0);
	  baisse2 = instance:addInternalStream(0, 0);
	  
     Dema11  = core.indicators:create("DEMA", source, Period11);
     Dema12  = core.indicators:create("DEMA", source, Period12);
     Dema13  = core.indicators:create("DEMA", e1, Period13);
	 
	 
	 Dema21  = core.indicators:create("DEMA", source, Period21);
     Dema22  = core.indicators:create("DEMA", source, Period22);
     Dema23  = core.indicators:create("DEMA", e2, Period23);
	 
	 Wma11  = core.indicators:create("WMA", hausse1, Period14);
     Wma12  = core.indicators:create("WMA", baisse1, Period14);
	 
	 Wma21  = core.indicators:create("WMA", hausse2, Period24);
     Wma22  = core.indicators:create("WMA", baisse2, Period24);
	 
	 
    first1=math.max(Dema11.DATA:first(),Dema12.DATA:first());
	first2=math.max(Dema21.DATA:first(),Dema22.DATA:first());
	 
   
  
	CDURUTC = instance:addStream("CDURUTC" , core.Line, " CDURUTC"," CDURUTC",instance.parameters.color1, Wma11.DATA:first());
	CDURUTC:setWidth(instance.parameters.width1);
    CDURUTC:setStyle(instance.parameters.style1);
	
	CDURUTC:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	CDURUTC:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	
	CDURUTS = instance:addStream("CDURUTS" , core.Line, " CDURUTS"," CDURUTS",instance.parameters.color2, Wma21.DATA:first());
	CDURUTS:setWidth(instance.parameters.width2);
    CDURUTS:setStyle(instance.parameters.style2);
	
	
	CDURUTC:setPrecision(math.max(2, instance.source:getPrecision()));
	CDURUTS:setPrecision(math.max(2, instance.source:getPrecision()));
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)
  
     One(period,mode);
	 Two(period,mode);
				  
end

function One(period, mode)
Dema11:update(mode);
Dema12:update(mode);

if period < first1 then
return;
end

e1[period]= Dema11.DATA[period]-Dema12.DATA[period];

Dema13:update(mode);

if period < Dema13.DATA:first() then
return;
end

hausse1[period] = math.max(0, Dema13.DATA[period] - Dema13.DATA[period-1]);
baisse1[period] = math.max(0, Dema13.DATA[period-1] - Dema13.DATA[period]);

Wma11:update(mode);
Wma12:update(mode);

if period< Wma11.DATA:first() then
return;
end

 
local RS=Wma11.DATA[period]/ Wma12.DATA[period];

CDURUTC[period]= 100 - 100 / (1 + RS);
end

function Two(period,mode)
Dema21:update(mode);
Dema22:update(mode);

if period < first2 then
return;
end

e2[period]= Dema21.DATA[period]-Dema22.DATA[period];

Dema23:update(mode);

if period < Dema23.DATA:first() then
return;
end

hausse2[period] = math.max(0, Dema23.DATA[period] - Dema23.DATA[period-1]);
baisse2[period] = math.max(0, Dema23.DATA[period-1] - Dema23.DATA[period]);

Wma21:update(mode);
Wma22:update(mode);

if period< Wma21.DATA:first() then
return;
end

 
local  RS=Wma21.DATA[period]/ Wma22.DATA[period];

CDURUTS[period]= 100 - 100 / (1 + RS);

end

 