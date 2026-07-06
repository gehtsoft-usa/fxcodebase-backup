-- Id: 15109
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22967

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Dan Valcu Heikin-Ashi Delta");
    indicator:description("Dan Valcu  Heikin-Ashi Delta");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period1", "1. Smoothing Period", "", 3);	
	indicator.parameters:addInteger("Period2", "2. Smoothing Period", "", 3);	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color2", "2. Line Color" , "", core.rgb(0,0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Background");
	indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Color of Down in Up Trend", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Down", "Color of Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownUp", "Color of Up in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","",core.COLOR_BACKGROUND );
	indicator.parameters:addInteger("transparency", "Transparency", "", 80);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 8, 1 , 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta;
local Average1, Average2;
local HA, MA1, MA2;
local first;
local source = nil;
local Period1, Period2;
local Up, Down, DownUp,UpDown,Neutral;
local transparency;
local up,down;
local font;
local UpTrendColor, DownTrendColor, Size;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
   Period1=instance.parameters.Period1;
   Period2=instance.parameters.Period2;
   
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
   UpDown=instance.parameters.UpDown;
   DownUp=instance.parameters.DownUp;
   Neutral=instance.parameters.Neutral;
   UpTrendColor=instance.parameters.UpTrendColor;
   DownTrendColor=instance.parameters.DownTrendColor;
   Size =instance.parameters.Size;
   
    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);	
	if nameOnly then
		return;
	end
	
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
     up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, Down, 0);
    core.host:execute ("attachTextToChart", "Up");
	 core.host:execute ("attachTextToChart", "Dn");
	    HA= core.indicators:create("HA", source);

 
        Delta= instance:addInternalStream(0, 0);
		
		
		MA1= core.indicators:create("MVA", Delta, Period1);
		Average1 = instance:addStream("Average1", core.Line, name .. " 1. Average", " 1. Average",instance.parameters.color1, MA1.DATA:first());
		Average1:setWidth(instance.parameters.width1);
        Average1:setStyle(instance.parameters.style1);
		
		
		MA2= core.indicators:create("MVA", Average1, Period2);
		Average2 = instance:addStream("Average2", core.Line, name .. " 2. Average", " 2. Average",instance.parameters.color2, MA2.DATA:first());
		Average2:setWidth(instance.parameters.width2);
        Average2:setStyle(instance.parameters.style2);
		
		Average1:setPrecision(math.max(2, instance.source:getPrecision()));
	    Average2:setPrecision(math.max(2, instance.source:getPrecision()));
	
		
		Average1:addLevel(0); 
         instance:ownerDrawn(true);
   
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	     HA:update(mode); 
		 if period < HA.DATA:first() then  
		 return;
		 end
		 
	     Delta[period]= HA.close[period]- HA.open[period];	  
		 
		 
		  MA1:update(mode); 	 
		  if period < MA1.DATA:first() then 
		  return;
		  end
		  Average1[period]= MA1.DATA[period];
		  
		  
		  MA2:update(mode); 	 
		  if period < MA2.DATA:first() then 
		  return;
		  end
		  Average2[period]= MA2.DATA[period];
		  
		  
		  down:setNoData(period);
		  up:setNoData(period);
		   
		  if Average2[period]> 0
		  and Average2[period-1]<= 0
		  then
		   up:set(period , source.high[period ], "\217" );
		  elseif Average2[period]< 0
		  and Average2[period-1]>= 0
		  then
		  down:set(period , source.low[period], "\218");
		  end
		  
		   if  Average1[period] > Average1[period-1] then 
		   core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Average1[period], core.CR_CHART, core.H_Center, core.V_Center, font, UpTrendColor, "\108");	
		   elseif  Average1[period] < Average1[period-1] then 
		   core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Average1[period], core.CR_CHART, core.H_Center, core.V_Center, font, DownTrendColor, "\108");	
		   end
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
	
        if not init then
		 context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			 context:createPen (13, context.SOLID, 1, UpDown)       
			context:createSolidBrush(14, UpDown);
			
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
			
			 context:createPen (23, context.SOLID, 1, DownUp)       
			context:createSolidBrush(24, DownUp);
			
			context:createPen (31, context.SOLID, 1, Neutral)       
			context:createSolidBrush(32, Neutral);
			
			transparency= context:convertTransparency (instance.parameters.transparency);
		
		init = true;
		end
      local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
  
        local period;
		
			 for period= first, last, 1 do	 
			   if Average2[period]>0 then 
			      if Average2[period]< Average1[period] then
				  C1=11;
                  C2=12;
				  else
				  C1=13;
                  C2=14;
				  end
			   elseif Average2[period]<0 then
			      if Average2[period]< Average1[period] then
				  C1=21;
                  C2=22;
				  else
				  C1=23;
                  C2=24;
				  end
			   else
               C1=31;
               C2=32;
               end			   
			   x0, x1, x2 = context:positionOfBar (period);
	           context:drawRectangle (C1, C2, x1, context:top(), x2, context:bottom() ,transparency );	 
	         end
end
