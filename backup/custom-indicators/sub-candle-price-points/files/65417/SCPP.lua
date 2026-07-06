-- Id: 9248
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=39870

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
    indicator:name("Sub Candle Price Points");
    indicator:description("Sub Candle Price Points");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addString("Type", "Price Type", "Price Type" , "median");
    indicator.parameters:addStringAlternative("Type", "Median", "Median" , "median");
    indicator.parameters:addStringAlternative("Type", "Typical", "Typical" , "typical");
    indicator.parameters:addStringAlternative("Type", "Weighted", "Weighted" , "weighted");

	indicator.parameters:addString("TF" , "Time frame", "", "Chart");
	indicator.parameters:addStringAlternative("TF" , "Chart Time Frame", "Chart Time Frame" , "Chart");
	indicator.parameters:addStringAlternative("TF" , "m1", "" , "m1");
	indicator.parameters:addStringAlternative("TF" , "m5", "" , "m5");
	indicator.parameters:addStringAlternative("TF" , "m15", "" , "m15");
	indicator.parameters:addStringAlternative("TF" , "m30", "" , "m30");
	indicator.parameters:addStringAlternative("TF" , "H1", "" , "H1");
    indicator.parameters:addStringAlternative("TF" , "H2", "" , "H2");
	indicator.parameters:addStringAlternative("TF" , "H3", "" , "H3");
	indicator.parameters:addStringAlternative("TF" , "H4", "" , "H4");
	indicator.parameters:addStringAlternative("TF" , "H6", "" , "H6");
	indicator.parameters:addStringAlternative("TF" , "H8", "" , "H8");
	indicator.parameters:addStringAlternative("TF" , "D1", "" , "D1");
	indicator.parameters:addStringAlternative("TF" , "W1", "" , "W1");
	indicator.parameters:addStringAlternative("TF" , "M1", "" , "M1");
	
	
	
  
    indicator.parameters:addColor("color", "Dot Color", "Dot Color", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 
 
local Type;
local first;
local source = nil;
local TF;
local Source, Loading; 
	local offset;
	local weekoffset;
	local color;
-- Routine
function Prepare(nameOnly)
   TF = instance.parameters.TF;
   Type = instance.parameters.Type;
   offset = core.host:execute("getTradingDayOffset");
   color = instance.parameters.color;
    weekoffset = core.host:execute("getTradingWeekOffset");
	   
    source = instance.source;
    first = source:first();
	
	if  TF ==  "Chart"  then
	TF= source:barSize();
	end
	
	
	 local s,e, s1, s2; 
            s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
            s1, e1 = core.getcandle(TF, core.now(), 0, 0);
			
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");			
			

    local name = profile:id() .. "(" .. source:name().. ", " .. Type .. ", " .. TF  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	if TF ~= source:barSize() then
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0 , 2 , 1);
	Loading = true;  
    else
	Source= source;
	Loading = false;  
	end
	
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)



        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
		
		 local s1, e1;
  	      s1, e1 = core.getcandle(TF, Source:date(p), 0, 0);
           core.host:execute("drawLine", Source:serial(p), s1, Source[Type] [p], e1, Source[Type] [p],color);
     
end


function   Initialization(period)


   if  TF == source:barSize()  then
   return period;
   end

    local Candle;
    Candle = core.getcandle(TF, source:date(period), offset, weekoffset);

  
    if Loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source , Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function AsyncOperationFinished(cookie)
    
			  if cookie == 1 then
			  Loading  = true;
		      elseif  cookie == 2 then
			  Loading  = false;            
			  instance:updateFrom(0);			  
			  end
		      
        
    return 0;
end
