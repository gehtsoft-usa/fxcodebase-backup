-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72164

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATR projections");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "ATR Period", "", 7);
    indicator.parameters:addDouble("Level", "Level", "", 0.8);	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Label Style"); 	
	indicator.parameters:addColor("label", "Label Color", "", core.COLOR_LABEL);	
	indicator.parameters:addColor("size", "Label Size", "", 10);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local TF; 
	local dayoffset;
	local weekoffset;
	local Source;
	local loading = false;   
	local Indicator;
	local label, size;
-- Streams block
    local Level = nil;

-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
   

	label = instance.parameters.label;
	size = instance.parameters.size;
	Level = instance.parameters.Level;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
 
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,Period), 100, 101);
	loading=true;
	
 

     
	Indicator = core.indicators:create("ATR", Source , Period);

 
      instance:ownerDrawn(true); 
end


 local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 
	  or not Indicator.DATA:hasData(Indicator.DATA:size()-1)
	  then
	  return;
	  end
	
        if not init then
           context:createPen (1,  context:convertPenStyle (instance.parameters.style),  context:pointsToPixels (instance.parameters.width),  instance.parameters.color)
           context:createFont (2, "Arial",  context:pointsToPixels (instance.parameters.size),  context:pointsToPixels (instance.parameters.size), 0)          
		  init = true;
        end
	
	local Top=Source.high[Source.high:size()-1] - Level*Indicator.DATA[Indicator.DATA:size()-1]
	local Bottom=Source.low[Source.low:size()-1] + Level*Indicator.DATA[Indicator.DATA:size()-1]
	
   local s, e = core.getcandle(TF,source:date(source:size()-1 ),  dayoffset, weekoffset);	

   x1, x, x = context:positionOfDate (s)
   x2, x, x = context:positionOfDate (e)
   
   visible, y1 = context:pointOfPrice (Top);
   visible, y2 = context:pointOfPrice (Bottom);
    
    context:drawLine (1, x1, y1, x2, y1)
    context:drawLine (1, x1, y2, x2, y2);	
	
	local Text1 = win32.formatNumber(Top, false, 2);
	local Text2 = win32.formatNumber(Bottom, false, 2);	
	
	width1, height1 = context:measureText (2, Text1, 0)
	width2, height2 = context:measureText (2, Text2, 0)	
	context:drawText (2, Text1, label, -1, x2, y1-height1, x2+width1, y1, 0);
	context:drawText (2, Text2, label, -1, x2, y2-height2, x2+width2, y2, 0);	
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	Indicator:update(mode); 	 

  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


