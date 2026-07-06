-- Id: 19619
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65319

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
    indicator:name("Matrix Series");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Smoother", "SmootherPeriod", "",5);
	indicator.parameters:addInteger("Lookback", "Lookback", "",50);
	indicator.parameters:addDouble("PerCent", "SupResPercentage", "",100);
	indicator.parameters:addInteger("Pds", "PricePeriod", "",16);
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0));
	   indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0));
	   
	      indicator.parameters:addColor("Alert", "Top/Bottom Color", "", core.rgb(0, 0, 255));
	   
	   indicator.parameters:addInteger("Size", "Font Size", "", 9);
 
	  indicator.parameters:addColor("color1", "Resistance Line Color", "", core.rgb(0, 0, 255));  
	 indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
     indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	 
	  indicator.parameters:addColor("color2", "Support Line Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
     indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
     indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
   
   
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 200);
    indicator.parameters:addDouble("oversold","Oversold Level","", -200);
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

local first;
local source = nil;


local nn;
local Lookback;
local PerCent;
local Pds;
local OB, OS;

-- Streams block
local ys1;
local rk3;
local rk5,rk6;
local up, down;

local Open,Close,High,Low;

local Value1;

local UpColor, DownColor,Alert;

local ResistanceLine, SupportLine;
local Top, Bottom,Size;	
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	Size=instance.parameters.Size;
	UpColor=instance.parameters.UpColor;
	DownColor=instance.parameters.DownColor;
	Alert=instance.parameters.Alert;
    
     nn=instance.parameters.Smoother;
     Lookback=instance.parameters.Lookback;
     PerCent=instance.parameters.PerCent;
     Pds=instance.parameters.Pds;
	 
	 OB=instance.parameters.overbought
	 OS=instance.parameters.oversold;

    local name = profile:id() .. "(" .. source:name() .. ", " .. nn.. ", " .. Lookback.. ", " .. PerCent.. ", " .. Pds .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	ys1 = instance:addInternalStream(0, 0);
	rk3= core.indicators:create("EMA", ys1,nn);
	
	
	rk5 = instance:addInternalStream(0, 0);	
	rk6= core.indicators:create("EMA", rk5,nn);
	up= core.indicators:create("EMA", rk6.DATA,nn);
	down= core.indicators:create("EMA", up.DATA,nn);
	
	Value1= core.indicators:create("CCI", source,Pds);
	
	
 

 
      ResistanceLine = instance:addStream("ResistanceLine", core.Line, name, "ResistanceLine", instance.parameters.color1, Value1.DATA:first()+Lookback );
    ResistanceLine:setPrecision(math.max(2, instance.source:getPrecision()));
	  ResistanceLine:setWidth(instance.parameters.width1);
      ResistanceLine:setStyle(instance.parameters.style1);
	  
	   SupportLine = instance:addStream(" SupportLine", core.Line, name, " SupportLine", instance.parameters.color2, Value1.DATA:first()+Lookback );
    SupportLine:setPrecision(math.max(2, instance.source:getPrecision()));
	   SupportLine:setWidth(instance.parameters.width2);
       SupportLine:setStyle(instance.parameters.style2);
		
 
		 Open = instance:addInternalStream(0, 0);
		 Close = instance:addInternalStream(0, 0);
		 High = instance:addInternalStream(0, 0);
		 Low = instance:addInternalStream(0, 0);
		 instance:createCandleGroup("ZONE", "", Open, High, Low, Close);
		
        ResistanceLine:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		ResistanceLine:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
	     Top = instance:createTextOutput ("Top", "Top", "Wingdings", Size, core.H_Center, core.V_Top, Alert, 0);
         Bottom = instance:createTextOutput ("Bottom", "Bottom", "Wingdings", Size, core.H_Center, core.V_Bottom, Alert, 0);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < source:first() then
	return;
	end
	

    ys1[period] = ( source.high[period] + source.low[period] + source.close[period] * 2 ) / 4
	
	rk3:update(mode);	
	
	if period < rk3.DATA:first() then
	return;
	end
	
	
 
	local rk4=mathex.stdev(ys1, period-nn+1, period)
	rk5[period] = (ys1[period] - rk3.DATA[period] ) * 200 / rk4
	   	
	rk6:update(mode);
    up:update(mode);	
    down:update(mode);		
	
	if period < down.DATA:first() then
	return;
	end
	
 
	
	if up.DATA[period]<down.DATA[period] then 
	Open[period] = up.DATA[period]  ;
	Open:setColor(period, DownColor);
	else
	Open[period]= down.DATA[period] ;
	Open:setColor(period, UpColor);
	end
	 
	if up.DATA[period]<down.DATA[period] then 
	 Close[period] = down.DATA[period] ;
	else
	 Close[period] = up.DATA[period] ;
	end
	
	High[period]= math.max( Close[period],  Open[period]);
	Low[period]= math.min( Close[period],  Open[period]);
	
	
	Value1:update(mode);	
	 
	 if period < Value1.DATA:first()+Lookback then
	return;
	end
	 
    local Value3, Value2 = mathex.minmax(Value1.DATA, period-Lookback+1, period)
	local Value4 = Value2 - Value3
	local Value5 = Value4 * ( PerCent / 100 );
	
	
	ResistanceLine[period] = Value3 + Value5
    SupportLine[period] = Value2 - Value5

  local UPshape, DOWNshape;
  
	--Overbought/Oversold/Warning Detail
   if up.DATA[period] > OB and up.DATA[period]>down.DATA[period]  then
   UPshape = true;
   else
   UPshape=false;
   end
   
   if down.DATA[period] < OS and up.DATA[period]>down.DATA[period] then
   DOWNshape =true;
   else
   DOWNshape =false;
   end
   
    Top:setNoData(period );
	Bottom:setNoData(period );
	 
	 if UPshape then
	 Top:set(period, High[period], "\253");
	 elseif DOWNshape then
	 Bottom:set(period, Low[period], "\253");
	 end
	 
	 
    
   
   
end

 
 
 

 