-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66862

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("HighLow Indicator");
    indicator:description("EMA Template");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addBoolean("Show", "Show Current Candle Line", "", true);
	
	indicator.parameters:addString("Type", "Price Type", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "Open/Close");
	
	
    indicator.parameters:addGroup("1. Time Frame Calculation"); 	 
    indicator.parameters:addInteger("Period1", "MA Period", "MA Period", 50);
	indicator.parameters:addString("TF1", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("2. Time Frame Calculation"); 	 
    indicator.parameters:addInteger("Period2", "MA Period", "MA Period", 50);
	indicator.parameters:addString("TF2", "Bar Size to display High/Low", "", "W1");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("3. Time Frame Calculation"); 	 
    indicator.parameters:addInteger("Period3", "MA Period", "MA Period", 50);
	indicator.parameters:addString("TF3", "Bar Size to display High/Low", "", "M1");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("1. Time Frame Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("2. Time Frame Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("3. Time Frame Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	
	local first;
	local source = nil;
	local TF={}; 
	local Source={};
	local loading={};
	local Period={};
	
	local dayoffset;
	local weekoffset;
	local Flag={};
	
	local style={};
	local width={};
	local color={};
	 
 
    local Show;
	local Type;
-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	Show = instance.parameters.Show;
	Type = instance.parameters.Type;
    
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF[1] = instance.parameters.TF1;
	TF[2] = instance.parameters.TF2;
	TF[3] = instance.parameters.TF3;
	Period[1] = instance.parameters.Period1;
	Period[2] = instance.parameters.Period2;
	Period[3] = instance.parameters.Period3;
	
	
	style[1] = instance.parameters.style1;
	width[1] = instance.parameters.width1;
	color[1] = instance.parameters.color1;
	
	style[2] = instance.parameters.style2;
	width[2] = instance.parameters.width2;
	color[2] = instance.parameters.color2;
	
	style[3] = instance.parameters.style3;
	width[3] = instance.parameters.width3;
	color[3] = instance.parameters.color3;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF[1], 0, 0, 0);
    if (e1 - s1) <= (e2 - s2) then
	Flag[1]= false;
	else
	Flag[1]= true;
	end
	
	s2, e2 = core.getcandle(TF[2], 0, 0, 0);
    if (e1 - s1) <= (e2 - s2) then
	Flag[2]= false;
	else
	Flag[2]= true;
	end
	
	
	s2, e2 = core.getcandle(TF[3], 0, 0, 0);
    if (e1 - s1) <= (e2 - s2) then
	Flag[3]= false;
	else
	Flag[3]= true;
	end
	
    for i = 1, 3 , 1 do
	Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), Period[i], 100*i, 100*i+1);
	loading[i]=true;
	end
	
 

    instance:ownerDrawn(true);  
   
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	if loading[1] and  loading[2] and loading[3] then
	return;
	end
 
    
	 
    
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then 
			
			context:createPen (1, context:convertPenStyle (style[1]), context:pointsToPixels (width[1]), color[1]);  
			context:createPen (2, context:convertPenStyle (style[2]), context:pointsToPixels (width[2]), color[2]);  
			context:createPen (3, context:convertPenStyle (style[3]), context:pointsToPixels (width[3]), color[3]);        
 
            init = true;
        end
     
	    local Last;
        for i= 1, 3, 1 do
			for p=0, Period[i], 1 do 
			Last=Source[i]:size()-1;
			if  Last-p> Source[i]:first()
			and (Show or (not Show and p~=0 ) )
			then
			
			
						if Type == "High/Low" then
						visible, y = context:pointOfPrice (Source[i].high[Last-p]);
						context:drawLine (i, context:left(), y, context:right() , y);
						visible, y = context:pointOfPrice (Source[i].low[Last-p]);
						context:drawLine (i, context:left(), y, context:right() , y);
						else
						visible, y = context:pointOfPrice (Source[i].open[Last-p]);
						context:drawLine (i, context:left(), y, context:right() , y);
						visible, y = context:pointOfPrice (Source[i].close[Last-p]);
						context:drawLine (i, context:left(), y, context:right() , y);						
						end
				end
			end
		end
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[i], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
     
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    for i=1, 3 , 1 do
		if cookie == i*100 then
			loading[i] = false;
			
		elseif cookie == i*100+1 then
			loading[i] = true;
		end
	end
	
	if not loading[1] and not loading[2] and not loading[3] then
	instance:updateFrom(0);
	end
end


