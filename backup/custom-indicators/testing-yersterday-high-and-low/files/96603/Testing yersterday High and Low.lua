
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61342

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
    indicator:name("Testing yersterday High and Low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
 

	iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"};
	indicator.parameters:addString("TF", "Time Frame", "" , "Chart");
	for i=1, 14, 1 do
    indicator.parameters:addStringAlternative("TF", iTF[i], iTF[i] , iTF[i]);
	end
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("Size", "Font Size", "", 15, 1, 1000);
	
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Size;
	local first;
	local source = nil;
	local TF;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	local Indicator;
	local font;
-- Streams block


-- Routine
function Prepare(nameOnly)
    Size = instance.parameters.Size;
    source = instance.source;
    first = source:first();
	
	TF = instance.parameters.TF;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TF) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	font  = core.host:execute("createFont", "Wingdings", Size, false, false);

 
	first= source:first() ; 		
	

	if TF== "Chart" then
	TF=source:barSize();
	SourceData=source;
	loading=false;
	else
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
    end
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
    

 end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
   
 
	  local p =  Initialization(period) 
     
	    if not p then
		return;
		end
	  
	
	       if source.close[period]> SourceData.high[p-1] then 
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center,core.V_Top ,
                             font , instance.parameters.Up, "\225");
           elseif source.close[period]< SourceData.low[p-1] then 
           core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
                             font , instance.parameters.Down, "\226");
			else
			core.host:execute ("removeLabel", source:serial(period));
            end			

	 
	  
   
    
     
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);

	   
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


