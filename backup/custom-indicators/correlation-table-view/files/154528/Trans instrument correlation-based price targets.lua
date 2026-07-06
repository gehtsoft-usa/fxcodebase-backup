-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74647

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init()
	indicator:name("Trans instrument correlation-based price targets")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")

	--indicator.parameters:addString("TF", "Time Frame", "", "D1");
	--indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000)	
	
	
    for i = 1, 6, 1 do
        indicator.parameters:addGroup(i .. ". Currency Pair ")
        Add(i)
    end		
	
	
	indicator.parameters:addGroup("Style")
	indicator.parameters:addInteger("Size", "Font Size", "", 10)
 
end

function Add(id)
    local List = {
        "10USNote",
        "DIA.us",
        "SPX500",
        "VOLX",
        "AAPL.us",
        "QQQ.us"
    }

 
    indicator.parameters:addString("Pair" .. id, "Pair", "", List[id])
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end


function getRainbowColour(ratio)
	-- Using HSV colour system, where Hue is changed in proportion to ratio

	ratio = math.max(0, math.min(1, ratio))

	-- NOTE: hue is an angular value and can be 0..360, but it wraps around back to 'red' again
	-- which looks a bit weird so I limit to 300 degrees
	local hue = 300 * (1 - ratio)

	-- Convert back to RGB
	return convertHSVtoRGB(hue, 1, 1)
end

function convertHSVtoRGB(hue, saturation, value)
	-- http://en.wikipedia.org/wiki/HSL_and_HSV
	-- Hue is an angle (0..360), Saturation and Value are both in the range 0..1

	local hi = (math.floor(hue / 60)) % 6
	local f = hue / 60 - math.floor(hue / 60)

	value = value * 255
	local v = math.floor(value)
	local p = math.floor(value * (1 - saturation))
	local q = math.floor(value * (1 - f * saturation))
	local t = math.floor(value * (1 - (1 - f) * saturation))

	if hi == 0 then
		return core.rgb(v, t, p)
	elseif hi == 1 then
		return core.rgb(q, v, p)
	elseif hi == 2 then
		return core.rgb(p, v, t)
	elseif hi == 3 then
		return core.rgb(p, q, v)
	elseif hi == 4 then
		return core.rgb(t, p, v)
	else
		return core.rgb(v, p, q)
	end
end
 
local Count=6;
local first
local source = nil
local Period;
 
local Init = true
local db

 
local Date1={};
local Date2={};	
local Level1={};
local Level2={};
local Correlation={};
local Reset;
local Source={};
local loading={};
local Pair={};
local TF;


function Prepare(nameOnly)

	Period=instance.parameters.Period;
	Size=instance.parameters.Size;
	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	
	db = LoadParameters("Trans instrument correlation-based price targets")

	core.host:execute("addCommand", 100, "Add Target to this Instrument", "")
	core.host:execute("addCommand", 101, "Delete This Instrument Target", "") 
	 
    Reset=true;
    InstrumentList={}; 
	Date1={};
	Date2={};	
	Level1={};
	Level2={};	
    Correlation={};	 
			
	instance:ownerDrawn(true)

    core.host:execute ("setTimer", 103 , 5);	
	

	
 
  
    for i = 1, Count, 1 do
    Pair[i]=instance.parameters:getString("Pair" .. i)
         
	Source[i] = core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(), 0 , 2000 +  i , 1000 + i);
	loading[i] = true;  	
    end	
end



function ReleaseInstance()
core.host:execute ("killTimer", 103 );
end 

function LoadParameters(Name)
	require("storagedb")
	local db = storagedb.get_db(Name)
	--db:put(tostring("Selected"), tostring(1))
	return db
end

function Update(period)
end

function Draw(stage, context)
	if stage ~= 0 then
		return
	end

    context:createFont (1, "wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0)

	context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
 
   for i = 1, 6, 1 do
 

		Date1 = tonumber(db:get(tostring(Pair[i] .. "Date1"), 0))
		Level1 = tonumber(db:get(tostring(Pair[i] .. "Level1"), 0))
		Date2 = tonumber(db:get(tostring(Pair[i] .. "Date2"), 0))
		Level2 = tonumber(db:get(tostring(Pair[i] .. "Level2"), 0))		 
		Instrument = tostring(db:get(tostring(Pair[i] .. "Instrument"), 0))
		
		
		p1 = core.findDate(source, Date1, false)
		p2 = core.findDate(source, Date2, false)
		
		if p1~= -1 and p2~= -1 then
					local x, x1, x  = context:positionOfBar(p1)
					local x, x, x2  = context:positionOfBar(p2)	
					
					
					 
					
					if Correlation[i] ~= nil   then
                    Price= source.open[p1]+ ((source.open[p1]/100) *(Level2-Level1)/(Level1/100))*Correlation[i]					
					visible, y2 = context:pointOfPrice(Price)		
					else
					 Price= source.open[p1]+ (source.open[p1]/100) *(Level2-Level1)/(Level1/100) 	
					visible, y2 = context:pointOfPrice(Price)				
					end
					
					width, height= context:measureText (1, "\174", 0)
					
					context:drawText (1, "\174",getRainbowColour(i/6), -1, x2, y2-height/2, x2+width, y2+height/2, 0, 0)		
		
		
		end
		
		
		
	end	
		
 
end

local pattern = "([^;]*);([^;]*)"

function Parse(message)
	if message == nil then
		return 0, 0
	end
	local level, date
	level, date = string.match(message, pattern, 0)

	if level == nil or date == nil then
		return 0, 0
	end
	return tonumber(date), tonumber(level)
end


function AsyncOperationFinished(cookie, success, message)

	local i,j;
    for i = 1, Count, 1 do
		
		    
			  if cookie == (1000 + i) then
			  loading[i] = true;
		      elseif  cookie == (2000 + i) then
			  loading[i] = false;               
			  end
		       
        
	end    
	
	  
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	

	
	if FLAG then	
	core.host:execute ("setStatus", "  Loading "..((Count) - Number) .. " / " .. (Count) );	
	else
	
	core.host:execute ("setStatus", "")	
    instance:updateFrom(0);	
	end
   
        

	

	local Instrument= source:instrument ();
	 
	if cookie == 101 then 
			db:put(tostring(Instrument .. "Instrument"), tostring(0))	
			db:put(tostring(Instrument .. "Level1"), tostring(0))
			db:put(tostring(Instrument .. "Date2"), tostring(0))
			db:put(tostring(Instrument .. "Level2"), tostring(0))
			db:put(tostring(Instrument .. "Date2"), tostring(0))
            Reset=true;			
			 
	end
	
	if cookie == 100 then 	

	   local Date, Level = Parse(message);
	   
		db:put(tostring(Instrument .. "Instrument"), tostring(Instrument))
		db:put(tostring(Instrument .. "Level1"), tostring(source.open[source:size()-1]))
		db:put(tostring(Instrument .. "Date1"), tostring(source:date(source:size()-1)))   
		
		db:put(tostring(Instrument .. "Level2"), tostring(Level))
		db:put(tostring(Instrument .. "Date2"), tostring(Date)) 
        Reset=true; 
	   
	end

	 
    if cookie == 103 and Reset then		
    Reset=false; 	
  
 
 

			
	        Date1={};
            Date2={};	
            Level1={};
            Level2={};		
			
							for i= 1 , Count, 1 do
							
										local level1 = tostring(db:get(tostring(Pair[i] .. "Level1"), 0))
										local level2 = tostring(db:get(tostring(Pair[i] .. "Level2"), 0))        
										local date1 = tostring(db:get(tostring(Pair[i] .. "Date1"), 0))
										local date2 = tostring(db:get(tostring(Pair[i] .. "Date2"), 0))
										
											if level1~=0 then
											Level1[i]=Level1;				
											end
											if level2~=0 then
											Level2[i]=Level2;					
											end
											if date1~=0 then
											Date1[i]=date1;				
											end
											if date2~=0 then
											Date2[i]=date2;
											end
											
								 
								if source:size()-1  > Period 
                                and Source[i]:size()-1  > Period 
                                then								
								Correlation[i] = mathex.correl(source.close, Source[i].close, source:size()-1-Period+1, source:size()-1, Source[i]:size()-1-Period+1, Source[i]:size()-1);
								else
								Correlation[i]=nil;
                                end								
											 		 
													 
							
							end
			end
	        

	
     return core.ASYNC_REDRAW ;
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+