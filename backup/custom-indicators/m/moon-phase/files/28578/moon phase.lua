-- Id: 6153
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15090

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
    indicator:name("moon phase");
    indicator:description("moon phase");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Size", "Moon Size", "", 30);
    indicator.parameters:addColor("full", "Full Moon Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("new", "New Moon Color", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;
local Decode;
local first;
local source = nil;
local full, new;
local font;
-- Streams block
function ReleaseInstance()
       core.host:execute("deleteFont", font);     
end


-- Routine
function Prepare(nameOnly)
    full = instance.parameters.full;
	new = instance.parameters.new;
    Size = instance.parameters.Size;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    Decode=nil;
	
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	
	 local date = source:date(period);
	 local t = core.dateToTable(date);
	 	
    local Phase =  moon_phase(t.year,  t.month, t.day);
	
	  
      if  Phase <= 1 and Decode ~= 1 then
	  Decode = 1;     
	  
	  core.host:execute("drawLabel1", source:serial(period) , source:date(period), core.CR_CHART , 0, core.CR_CHART, core.H_Center, core.V_Top,
                             font, full, "\108");

							 
	  elseif Phase  >= 7  and Decode ~= 8 then	  
	  Decode = 8;
	  
	  core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top,
                             font, new, "\108");
							 
     else
	 core.host:execute ("removeLabel", source:serial(period));
							 
      end
	  
	 -- S1[period]= Decode;
end



function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function moon_phase(y,  m, d)

    --[[
      calculates the moon phase (0-7), accurate to 1 segment.
      0 = > new moon.
      4 => full moon.
      ]]

    local c,e;
    local  jd;
    local b;

    if  m < 3 then
        y=y-1;
        m =m+ 12;
    end
    m=m+1;
	
    c = 365.25*y;
    e = 30.6*m;
    jd = c+e+d-694039.09;  --/* jd is total days elapsed */
    jd = jd  / 29.53;           --/* divide by the moon cycle (29.53 days) */
    b = round(jd, 0);		   --/* int(jd) -> b, take integer part of jd */
    jd = jd- b;		  -- /* subtract integer part to leave fractional part of original jd */
    b = jd*8 + 0.5;	  -- /* scale fraction from 0-8 and round by adding 0.5 */
    b = b % 8;		   --/* 0 and 8 are the same so turn 8 into 0 */
    return math.abs(b-4)/0.5;
	
end
