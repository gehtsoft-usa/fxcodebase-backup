-- Id: 21765
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66410

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
    indicator:name("Three MA Trend Continuation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("1. MA Calculation");		
	 
    indicator.parameters:addInteger("Period1", "Fast Period MA", "", 10, 2, 2000 );
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method1", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method1", "PAR_MA", "PAR_MA" , "PAR_MA");  

	
	
	indicator.parameters:addGroup("2. MA Calculation");			
	indicator.parameters:addInteger("Period2", "Slow Period MA", "", 15, 2, 2000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method2", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method2", "PAR_MA", "PAR_MA" , "PAR_MA");  
	
	indicator.parameters:addGroup("3. MA Calculation");			
	indicator.parameters:addInteger("Period3", "Slow Period MA", "", 50, 2, 2000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method3", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method3", "PAR_MA", "PAR_MA" , "PAR_MA"); 

		
	indicator.parameters:addGroup("Indicator Style");   
    indicator.parameters:addColor("color1", "1. MA color", "MA color", core.rgb(0,255,0));
	indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. MA color", "MA color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
 
    indicator.parameters:addColor("color3", "3. MA color", "MA color", core.rgb(0,0,255));
	indicator.parameters:addInteger("width3", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
 
	 
	 
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("UpTrendColorExit", "Exit of Up Trend Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("DownTrendColorExit", "Exit of Down Trend Color", "", core.rgb(255, 0, 255));
	
	indicator.parameters:addInteger("Size", "Label Size", "", 15, 1 , 100);
	
	indicator.parameters:addBoolean("Show", "Show Lines", "", true);
	 
	
end
 
 
local first;
local source = nil;
local Size;
local Indicator1,Indicator2,Indicator3;
local Method1, Period1;
local Method2, Period2;
local Method3, Period3;
local MA1,MA2,MA3;
local Alert;
local UpTrendColor, DownTrendColor, UpTrendColorExit, DownTrendColorExit;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
 
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	UpTrendColorExit= instance.parameters.UpTrendColorExit;
	DownTrendColorExit= instance.parameters.DownTrendColorExit;
	Size=instance.parameters.Size;
	

	
	 
	Method1 = instance.parameters.Method1;	
	Method2 = instance.parameters.Method2;
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;	
   
	Method3 = instance.parameters.Method3;
    Period3 = instance.parameters.Period3;
	
	Show= instance.parameters.Show;

	assert(core.indicators:findIndicator( Method1 ) ~= nil, "Please, download and install ".. Method1 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method2 ) ~= nil, "Please, download and install ".. Method2 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method3 ) ~= nil, "Please, download and install ".. Method3 .. ".LUA indicator");
     
	source = instance.source; 

 
	 -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    Indicator1 = core.indicators:create(Method1, source , Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	Indicator2 = core.indicators:create(Method2, source , Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	Indicator3 = core.indicators:create(Method3, source , Period3);
	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator3.DATA:first() );

	
	if Show then 
    MA1=instance:addStream("MA1",core.Line, name .. ".MA1", "MA1", instance.parameters.color1,  Indicator1.DATA:first());
	MA1:setWidth(instance.parameters.width1);
    MA1:setStyle(instance.parameters.style1);
	
	 MA2=instance:addStream("MA2",core.Line, name .. ".MA2", "MA2", instance.parameters.color2,  Indicator2.DATA:first());
	MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2);
	
	 MA3=instance:addStream("MA3",core.Line, name .. ".MA3", "MA3", instance.parameters.color3,  Indicator3.DATA:first());
	MA3:setWidth(instance.parameters.width3);
    MA3:setStyle(instance.parameters.style3);
	
	else
	
	MA1=instance:addInternalStream(0, 0);
	MA2=instance:addInternalStream(0, 0);
	MA3=instance:addInternalStream(0, 0);
	
	end
  
		Alert=instance:addInternalStream(0, 0);
		 
     
	 instance:ownerDrawn(true);
	
end


local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 
		   if Alert:hasData(period) then
		     
		    if Alert[period] > 0 and Alert[period]~=Alert[period-1]  then			
			visible, y = context:pointOfPrice (MA3[period]);
			
			if Alert[period]== 2 then
			Color=UpTrendColor;
			Symbol="\252";
			else
			Color=UpTrendColorExit;
			Symbol="\251";
			end
			
			  width, height = context:measureText (1,  Symbol, 0);
              context:drawText (1,   Symbol, Color, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif Alert[period] < 0 and Alert[period]~=Alert[period-1] then
			visible, y = context:pointOfPrice (MA3[period]);
			
			if Alert[period]== -2 then
			Color=DownTrendColor;
			Symbol="\252";
			else
			Color=DownTrendColorExit;
			Symbol="\251";
			end
			
			
			width, height = context:measureText (1,  Symbol, 0);
			 context:drawText (1,   Symbol, Color, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
		    end
		 
		    
		 
		end
		end
		
  
end		


 


 
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 



     Indicator1:update(mode);
	 Indicator2:update(mode);
	 Indicator3:update(mode);
 
	
	
     if period > Indicator1.DATA:first() then
	 MA1[period]=  Indicator1.DATA[period];
	 end
	 
	 if period > Indicator2.DATA:first() then
	 MA2[period]=  Indicator2.DATA[period];
	 end
	 
	 if period > Indicator3.DATA:first() then
	 MA3[period]=  Indicator3.DATA[period];
	 end
	 
	 
	 
	 if period < first then
	 return;
	 end
	 
     Resolve(period);
 
end


function  Resolve(period)


if source[period]> MA1[period]
and source[period]> MA2[period]
and source[period]> MA3[period]
then
Alert[period]=2;
elseif source[period]< MA1[period]
and source[period]< MA2[period]
and source[period]< MA3[period]
then
Alert[period]=-2;
elseif source[period]< MA1[period]
and source[period]< MA2[period]
and source[period]> MA3[period]
then
Alert[period]=1;
elseif source[period]> MA1[period]
and source[period]> MA2[period]
and source[period]< MA3[period]
then
Alert[period]=-1;
else
Alert[period]=Alert[period-1];
end

end