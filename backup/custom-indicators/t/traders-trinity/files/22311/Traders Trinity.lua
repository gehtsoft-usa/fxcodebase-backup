-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10882

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



function Init()
    indicator:name("Traders Trinity");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Bigger Time Frame");
	indicator.parameters:addString("BS", "Time frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	 indicator.parameters:addBoolean("Previous", "Use Previous Period", "", true); 
	
	indicator.parameters:addGroup("Levels");
    indicator.parameters:addBoolean("HL", "Show Levels", "", true); 
	
	
	LEV(1, 75);
	LEV(2, 62.5);
	LEV(3, 50);
	LEV(4, 37.5);
	LEV(5, 25);

	
	indicator.parameters:addGroup("Style");
	  

	
	indicator.parameters:addInteger("widthlow", "Low Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylelow", "Low Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylelow", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("low", "Low Line Color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("widthhigh", "High Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("stylehigh", "High Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stylehigh", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("high", "High Line Color", "", core.rgb(0, 255, 0));
	

	STYLE(1);
	STYLE(2);
	STYLE(3);
	STYLE(4);
	STYLE(5);
  
   end
   
 function STYLE(id)
 
    indicator.parameters:addInteger("width"..id, id.. ". Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, id.. ". Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
	
	local Color;
	
	if id ~= 3 then
	 Color= core.rgb(0, 0, 255);
    else
	 Color= core.rgb(255, 0, 0);
    end	
    indicator.parameters:addColor("color"..id, id..". Line Color", "", Color);

end   
   
  function  LEV (id, Level)
  
   indicator.parameters:addGroup(id.. "Level");
  
   indicator.parameters:addBoolean("Show"..id , "Show ".. id.. ". line", "", true);
   indicator.parameters:addDouble("Level"..id , id..". Level", "", Level);
  end


local source;                   -- the source
local bf_data = nil;          -- the high/low data
local BS;
local host;
local DATA;
local HIGH, LOW;
local HL;
local MID;
local day_offset;
local week_offset;
local Level={};
local Levels={};
local Show={};
local Previous;

local Source;
local loading;

 function Prepare(nameOnly) 
    source = instance.source;
    host = core.host;
	
	 local  name = profile:id() .. "(" .. source:name() ..")";
    instance:name(name);
   
	
	if   (nameOnly) then
        return;
    end
	
	  local i;
	for i = 1, 5 , 1 do
	 Level[i] =   instance.parameters:getInteger("Level" .. i); 
	 Show[i]=   instance.parameters:getBoolean("Show" .. i); 
  
    end
	Previous = instance.parameters.Previous;	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
	HL = instance.parameters.HL;
	
    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) < (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
   

   
    
	for i = 1, 5, 1 do
	
		if Show[i] and HL then
		Levels[i] = instance:addStream("Line" .. i, core.Line, name .. tostring(i), tostring(i) ,  instance.parameters:getInteger("color" .. i) , 0);
		Levels[i]:setWidth(instance.parameters:getInteger("width" .. i));
		Levels[i]:setStyle(instance.parameters:getInteger("style" .. i));
		else
		Levels[i]= instance:addInternalStream(0, 0);		  
		end
	end
	

	HIGH = instance:addStream("HIGH", core.Line, name .. ".HIGH", "HIGH", instance.parameters.high, 0);
	HIGH:setWidth(instance.parameters.widthhigh);
	HIGH:setStyle(instance.parameters.stylehigh);
	
	LOW = instance:addStream("LOW", core.Line, name .. ".LOW", "LOW", instance.parameters.low, 0);
	LOW:setWidth(instance.parameters.widthlow);
	LOW:setStyle(instance.parameters.stylelow);
	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), first, 100, 101);
	loading=true;

end



-- the function which is called to calculate the period
function Update(period, mode)

    local p =  Initialization(period) 
     
	    if not p 
		or p== 1  
		then
		return;
		end
		 
	
	if Previous then 
	p= p-1;
	end
   
		HIGH[period] = Source.high[p];
		LOW[period] = Source.low[p];
		
		
		for i = 1, 5 , 1 do
			  if Show[i] then
			  Levels[i][period] = LOW[period] + ((HIGH[period] - LOW[period])/100) *Level[i];
			  end
		end
	  

  if HIGH[period]~= HIGH[period-1] then
 
  HIGH:setBreak(period, true);
  LOW:setBreak(period, true);
  
	  for i = 1, 5 ,1  do
		  if Show[i] then
		  Levels[i]:setBreak(period, true);
		  end
	  end
  end
 
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), day_offset, week_offset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
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

