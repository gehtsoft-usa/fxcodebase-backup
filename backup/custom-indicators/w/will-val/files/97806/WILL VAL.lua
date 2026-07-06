-- Id: 13298

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61620

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
    indicator:name("WILL VAL");
    indicator:description("WILL VAL");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Instrument" , "Instrument", "", "XAU/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Len1", "Len1", "Len", 22);
	indicator.parameters:addInteger("Len2", "Len2", "Len", 2);
	indicator.parameters:addInteger("Len3", "Len3", "Len", 365);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of  WILL VAL", "Color of WILL VAL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 75);
    indicator.parameters:addDouble("oversold","Oversold Level","", 25);
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
local loading;
local Source;
local Instrument;
-- Streams block
local WILL;
local Price;
local Value;
local Len1,Len2,Len3;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
	Instrument=instance.parameters.Instrument; 
	Len1=instance.parameters.Len1;
	Len2=instance.parameters.Len2;
	Len3=instance.parameters.Len3;
	    
		
			

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 

    if (not (nameOnly)) then
		Source = core.host:execute("getSyncHistory",Instrument, source:barSize(), source:isBid(), 1, 200, 100);
		loading=true;
			
				
		Price = instance:addInternalStream(0, 0);
		
		MA1 = core.indicators:create("EMA",Price, Len1);
		MA2 = core.indicators:create("EMA", Price, Len2);
		
		 first = math.max(MA1.DATA:first(),MA2.DATA:first());
		
		Value = instance:addInternalStream(0, 0);     
        WILL = instance:addStream("WILL", core.Line, name, "WILL", instance.parameters.color, source:first()+math.max(Len1,Len2) +Len3);
    WILL:setPrecision(math.max(2, instance.source:getPrecision()));
		WILL:setWidth(instance.parameters.width);
        WILL:setStyle(instance.parameters.style);
		
        WILL:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		WILL:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    end
end

	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode) 
	
	if loading  then
	return;
	end
	
	local Period = core.findDate ( Source, source:date(period), false) ;
	 if  Period < 0 then
	 return;
	 end
	
	Price[period]= (source.close[period]/Source.close[Period]) ;
	
	MA1:update(mode);
	MA2:update(mode);
	
	if period < math.max(MA1.DATA:first(), MA2.DATA:first())    then
	return;
	end 
	
    Value[period] = MA1.DATA[period] - MA2.DATA[period];
	
	if period < math.max(MA1.DATA:first(), MA2.DATA:first()) +Len3   then
	return;
	end
	
	local min,max= mathex.minmax(Value,period-Len3+1, period );
	
	if (max - min)~= 0 then
    WILL[period] =((Value[period] - min) / (max - min))*100;
	else
	WILL[period]=nil;
	end
	

end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    
	
			  if cookie == 100 then
			  loading = true;
			  core.host:execute ("setStatus", "loading");
		      elseif  cookie == 200 then
			  core.host:execute ("setStatus", "");
			  loading = false;	
              instance:updateFrom(0);				  
              end 
			  
		return core.ASYNC_REDRAW ;
end