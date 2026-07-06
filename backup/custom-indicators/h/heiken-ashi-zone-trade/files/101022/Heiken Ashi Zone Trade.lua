-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62332


--+------------------------------------------------------------------+
--|                               Copyright ? 2018, Gehtsoft USA LLC | 
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
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of ภั and ภฮ red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("Heiken Ashi Zone Trade");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Source", "AO/AC Indicator Source Data", "Source Data" , "Price");
    indicator.parameters:addStringAlternative("Source", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Source", "HA", "HA" , "HA")
	
    indicator.parameters:addInteger("FM", "AC/AO fast moving average", "", 5);
    indicator.parameters:addInteger("SM", "AC/AO slow moving average", "", 35);
    indicator.parameters:addInteger("AM", "A/C moving average", "", 5);
	indicator.parameters:addGroup("Zone Trade or AO and AC Separately");
	indicator.parameters:addInteger("MT" , "Zone Trade", "" , 1);	
    indicator.parameters:addIntegerAlternative("MT", "Awesome oscillator(AO)", "ZONE" , 2);
    indicator.parameters:addIntegerAlternative("MT", "Acceleration/Deceleration (AC)", "" , 3);
	indicator.parameters:addIntegerAlternative("MT", "B.W. Zone AC + AO", "" , 1);
	
	
	
	
	indicator.parameters:addString("Method", "Presentation Method", "Method" , "Heiken Ashi");
    indicator.parameters:addStringAlternative("Method", "Heiken Ashi", "Heiken Ashi" , "Heiken Ashi");
    indicator.parameters:addStringAlternative("Method", "Price", "Price" , "Price")
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FM;
local SM;
local AM;

local Method=nil;

local AO;
local AC;

local first;
local source = nil;
local Source;
-- Streams block
--local HZU = nil;
--local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
local HA;

-- Routine
 function Prepare(nameOnly) 
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    AM = instance.parameters.AM;
	MT= instance.parameters.MT;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	Method = instance.parameters.Method;
	Source = instance.parameters.Source;
	
    source = instance.source;
   
   
    local name = profile:id() .. "(" .. source:name() .. ", "  .. FM .. ", " .. SM .. ", " .. AM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	
 
	HA = core.indicators:create("HA", source);	
	
	if Source == "Price" then
    AC = core.indicators:create("AC", source, FM, SM, AM);
    AO = core.indicators:create("AO", source, FM, SM);
	else
	AC = core.indicators:create("AC", HA:getCandleOutput(0), FM, SM, AM);
    AO = core.indicators:create("AO", HA:getCandleOutput(0), FM, SM);
	end

    first = math.max( AC.DATA:first(), AO.DATA:first(), HA.DATA:first());	

   
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    HA:update(mode);
    AC:update(mode);
    AO:update(mode);
	
	if Method == "Price" then
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	else		 
	high[period]= HA.high[period];
	low[period]= HA.low[period];		   
	close[period] = HA.close[period];
	open[period]  = HA.open[period];
	end
     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
  
				   
   
        local acdir, aodir;      
		
        if AO.DATA[period] > AO.DATA[period - 1] then
            aodir = true;
        elseif AO.DATA[period] < AO.DATA[period - 1] then
            aodir = false;
        end
        if AC.DATA[period] > AC.DATA[period - 1] then
            acdir = true;
        elseif AC.DATA[period] < AC.DATA[period - 1] then
            acdir = false;
        end
		
		
		if   MT== 1 then
				if aodir  and acdir then 
				open:setColor(period, Up);
				elseif  not aodir  and  not acdir then
				open:setColor(period, Down);	
				else
				open:setColor(period, Neutral);
				end
		elseif 	MT== 2 then
		            
				if aodir   then
				open:setColor(period, Up);
				elseif  not aodir then
				open:setColor(period, Down);				  
		        end
		  
		elseif  MT== 3 then
		
		        if  acdir then
				open:setColor(period, Up);
				elseif  not acdir then
				open:setColor(period, Down);				  
			    end 
		end	              
				   
				  
    end

