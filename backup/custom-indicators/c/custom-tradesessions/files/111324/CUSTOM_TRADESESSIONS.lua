-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64501

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
    indicator:name("The indicator highlights trade sessions");
    indicator:description("The indicator can be applied on 1-minute to 1-hour charts");
    indicator:requiredSource(core.Bar);
	indicator:setTag("AllowAllSources", "y");
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("session_start", "Session start hour", "", 8);
	indicator.parameters:addInteger("session_length", "Session length", "", 8);
    indicator.parameters:addColor("session_color", "Session color", "", core.rgb(255, 0, 0));

	--indicator.parameters:addGroup("Data To Show");

    --indicator.parameters:addBoolean("S_H", "Show session high", "", true);
   -- indicator.parameters:addBoolean("S_L", "Show session low", "", true);

    indicator.parameters:addGroup("Grid Lines");
    indicator.parameters:addBoolean("S_SM", "Show mid line", "", false);
    indicator.parameters:addInteger("SM_STYLE", "Mid line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SM_STYLE", core.FLAG_LINE_STYLE);

   -- indicator.parameters:addBoolean("S_SE", "Show start/end line", "", false);
    --indicator.parameters:addInteger("SE_STYLE", "Start/end line Style", "", core.LINE_SOLID);
    --indicator.parameters:setFlag("SE_STYLE", core.FLAG_LINE_STYLE);

 
   --indicator.parameters:addInteger("TR_STYLE", "Triangulation line Style", "", core.LINE_SOLID);
   -- indicator.parameters:setFlag("TR_STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addGroup("Styles");

    indicator.parameters:addInteger("STYLE", "Session Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("STYLE", core.FLAG_LINE_STYLE);
   -- indicator.parameters:addInteger("FS", "Font Size", "", 6, 4, 24);
end

-- Parameters block
local first;
local source = nil;
local host;
 
--local day_offset, week_offset;
local pipsize;
local S_N, S_H, S_L, S_OD, S_OH;
local   S_SM;
--local barsize;
local SM_STYLE, SE_STYLE, TR_STYLE;
local Source,loading;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	pipsize = source:pipSize();
    first = source:first();
    host = core.host;
   -- day_offset = host:execute("getTradingDayOffset");
   -- week_offset = host:execute("getTradingWeekOffset");

   
    --S_H = instance.parameters.S_H;
   -- S_L = instance.parameters.S_L;
 
    S_SM = instance.parameters.S_SM;
     
    SM_STYLE = instance.parameters.SM_STYLE;
    --SE_STYLE = instance.parameters.SE_STYLE;
    TR_STYLE = instance.parameters.TR_STYLE;

    local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    s = math.floor(s * 86400 + 0.5);  -- >>in seconds
    e = math.floor(e * 86400 + 0.5);  -- >>in seconds
    assert((e - s) <= 3600, "The source time frame must not be bigger than 1 hour");
   -- barsize = (e - s) / 86400;

    local name = profile:id() .. "()";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Source = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), first, 100, 101);
	loading=true;
     
 
end
 
-- Indicator calculation routine
function Update(period)
    if period < first 
	or loading
	then
	return;
	end
	  
    Process(  period);
end

-- Process the specified session
function Process(  period)
 

    -- find the start of the session
    local date = source:date(period);       -- bar date;
    local sfrom, sto;

    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(date * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t -  instance.parameters.session_start * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t +  instance.parameters.session_start * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom +  instance.parameters.session_length * 3600;   -- end of the session

    sfrom = sfrom / 86400;
    sto = sto / 86400;
	
	
	if not ( date == sto 
	or date== Source:date(Source:size()-1))
	then
	return;
	end
	
	
 
	
	  p1=core.findDate (Source, sfrom, true);
	  p2=core.findDate (Source, sto, true);
	  
	  if p1==-1
	  or p2==-1 
	  then
	  return;
	  end
	  
	
	    --if period == sto  then
		lo, hi = mathex.minmax(Source,p1, p2 );
		--else
		--lo, hi = mathex.minmax(Source,p1, Source:size()-1 );
		--end
		
		close=Source.close[p2];
	   	open=Source.open[p1];
	    local baseid = math.floor(sfrom * 24 + 0.5) * 30;
 

                    host:execute("drawLine", baseid + 0, sfrom, open, sto, open, instance.parameters.session_color, TR_STYLE);
                    host:execute("drawLine", baseid + 1, sfrom, close, sto, close, instance.parameters.session_color, TR_STYLE);
                    host:execute("drawLine", baseid + 2, sfrom, hi, sto, hi, instance.parameters.session_color, TR_STYLE);
                    host:execute("drawLine", baseid + 3, sfrom, lo, sto, lo, instance.parameters.session_color, TR_STYLE);
 
              
 

                if S_SM then
                    host:execute("drawLine", baseid + 11, sfrom, lo+(hi - lo) / 2, sto, lo+(hi - lo) / 2, instance.parameters.session_color, SM_STYLE);
                end
   
end
 


function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end




