-- Id: 2548
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=843

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
    indicator:name("Correlations");
    indicator:description("	Currency Correlations");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Instrument1", "1. Instrumet", "", "");
    indicator.parameters:setFlag("Instrument1", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addString("Instrument2", "2. Instrumet", "", "");
    indicator.parameters:setFlag("Instrument2", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Period", "Period", "Period", 25,2,250);
	

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
 
end

local source; 
local loading ={};
local dayoffset;
local weekoffset;
local Number=2; 
local Instrument={}; 
local Source={};
local Period;
local Correlation;
local Price1, Price2;

function Prepare(nameOnly)

    source = instance.source; 
    host = core.host; 
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;
	
	Period = instance.parameters.Period; 
	Instrument[1] = instance.parameters.Instrument1;
	Instrument[2] = instance.parameters.Instrument2;
 
	 local name = profile:id().." (".. Instrument[1]..") / (".. Instrument[2]   ..")";
    instance:name(name);
	
	if (not (nameOnly)) then 
        local id=0;
        for i= 1, Number, 1 do
            id=id+1;	
            Source[i] = core.host:execute("getSyncHistory",Instrument[i], source:barSize(), source:isBid(), Period, 200+id, 100+id);
            loading[i]= true;
        end
        
        Correlation = instance:addStream("Correlation", core.Line, name, "Correlation", instance.parameters.Color, source:first());
    Correlation:setPrecision(math.max(2, instance.source:getPrecision()));
		Correlation:setWidth(instance.parameters.width);
        Correlation:setStyle(instance.parameters.style);
    end

   
     
end
 
-- the function which is called to calculate the period
function Update(period, mode)

    
	local p1= Initialization(period,1);
	local p2= Initialization(period,2);
	
	if not p1 or not p2
	or p1 < Period or  p2 < Period
	then
	return;
	end
	
	Correlation[period]= mathex.correl (Source[1][Price1], Source[2][Price2], p1-Period+1, p1, p2-Period+1, p2);
      
end
 
 
 
function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local id=0;
		
    for j = 1, Number, 1 do
		id=id+1;
			  if cookie == (100+id) then
			  loading[j] = true;
		      elseif  cookie == (200+id) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		end
			     
        
		return core.ASYNC_REDRAW ;
end

 