-- Id: 12039

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60838

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("CCI Stochastic");
    indicator:description("CCI Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("CCIPeriod", "CCI Period", "CCI Period", 14);
    indicator.parameters:addInteger("StochPeriod", "Stochastic Period", "Stochastic Period", 14);
    indicator.parameters:addInteger("StochSmooth", "Stochastic Smooth", "Stochastic Smooth", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CciStochastic_color", "Color of CciStochastic", "Color of CciStochastic", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addBoolean("ShowArrows", "Show Arrows", "", true);
	indicator.parameters:addBoolean("ShowArrowsOnZoneEnter", "Show Arrows On Zone Enter", "", true);
	indicator.parameters:addBoolean("ShowArrowsOnZoneExit", "Show Arrows On Zone Exit", "", true);
	indicator.parameters:addBoolean("ShowArrowsOnCentalLineCross", "Show Arrows On Central Line Cross", "", true);
	indicator.parameters:addInteger("Size", "Arrows Size", "", 10);
    indicator.parameters:addColor("Up", "Up Arrow Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down Arrow Color","", core.rgb(255, 0, 0));
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CCIPeriod;
local StochPeriod;
local StochSmooth;
	local  ShowArrows ,ShowArrowsOnZoneEnter,ShowArrowsOnZoneExit,ShowArrowsOnCentalLineCross;
local first;
local source = nil;

-- Streams block
local stoch;
local rawstoch;
local cci;
local ma;
local Text;
local tup,tdown;
local bup,bdown;
local cup,cdown;
local Size;
local OB,OS;
-- Routine
function Prepare(nameOnly)
    CCIPeriod = instance.parameters.CCIPeriod;
    StochPeriod = instance.parameters.StochPeriod;
    StochSmooth = instance.parameters.StochSmooth;
	ShowArrows = instance.parameters.ShowArrows;
	ShowArrowsOnCentalLineCross = instance.parameters.ShowArrowsOnCentalLineCross;
	Size = instance.parameters.Size;
	ShowArrowsOnZoneEnter = instance.parameters.ShowArrowsOnZoneEnter;
	ShowArrowsOnZoneExit = instance.parameters.ShowArrowsOnZoneExit;
    source = instance.source;
    OB=instance.parameters.overbought;
    OS=instance.parameters.oversold;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CCIPeriod) .. ", " .. tostring(StochPeriod) .. ", " .. tostring(StochSmooth) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 cci = core.indicators:create("CCI", source, CCIPeriod);
	 rawstoch = instance:addInternalStream(0, 0);
	 ma = core.indicators:create("MVA", rawstoch, StochSmooth);
	 first = cci.DATA:first();

     
        stoch = instance:addStream("CciStochastic", core.Line, name, "CCI Stochastic", instance.parameters.CciStochastic_color, ma.DATA:first());
		stoch:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		stoch:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		stoch:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		stoch:setWidth(instance.parameters.width);
        stoch:setStyle(instance.parameters.style);
		
		stoch:setPrecision(math.max(2, instance.source:getPrecision()));
		
		if ShowArrows then
		
		 tup = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
         tdown = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Dn, 0);
		 
		 bup = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
         bdown = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Dn, 0);
		 
		 cup = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
         cdown = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Dn, 0);
	
		core.host:execute ("attachTextToChart", "Up");
		core.host:execute ("attachTextToChart", "Dn");
		end
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    cci:update(mode);
	
   if period < first+StochPeriod  then 
   return;
   end
	
	 local TodayCCI = cci.DATA[period] ; 
     local TodayLowCCI = mathex.min(cci.DATA, period-StochPeriod+1, period ) ; 
     local TodayHighCCI = mathex.max(cci.DATA, period-StochPeriod+1, period ) ; 
   
	   rawstoch[period]=100*(TodayCCI - TodayLowCCI)/(TodayHighCCI - TodayLowCCI);  
    
    ma:update(mode);
	
	if period < ma.DATA:first() then
	return;
	end
	
	stoch[period] = ma.DATA[period];
    
	
	if ShowArrows then
	tdown:setNoData(period);
    tup:setNoData(period);
	bdown:setNoData(period);
    bup:setNoData(period);	
	cdown:setNoData(period);
    cup:setNoData(period);
	Arrows(period);
	end
end


function Arrows(period)

  if ShowArrowsOnZoneEnter then
	   if stoch[period] > OB and stoch[period-1]<= OB then
	   tup:set(period , source.low[period], "\217", source.low[period ]);
	   end
	   if stoch[period] < OS and stoch[period-1]>= OS then
       bdown:set(period , source.high[period], "\218", source.high[period ]);
	   end
  end
  
  if ShowArrowsOnZoneExit then
  
       if stoch[period] < OB and stoch[period-1]>= OB then
	   tdown:set(period , source.high[period], "\218", source.high[period ]);
	   end
	   if stoch[period] > OS and stoch[period-1]<= OS then
        bup:set(period , source.low[period], "\217", source.low[period ]);
	   end
  
  end
  
  
    if ShowArrowsOnCentalLineCross then
	
	  if stoch[period] < 50 and stoch[period-1]>= 50 then
	   cdown:set(period , source.high[period], "\218", source.high[period ]);
	   end
	   if stoch[period] > 50 and stoch[period-1]<= 50 then
        cup:set(period , source.low[period], "\217", source.low[period ]);
	   end
	
	end

end
 