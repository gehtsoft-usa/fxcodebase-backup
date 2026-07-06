-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8257

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


	
function Init()
    indicator:name("Curency  Strength");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

	

	indicator.parameters:addGroup(  "Mojors");	 
	indicator.parameters:addString("Major", "Major", "", "USD");			
    indicator.parameters:addStringAlternative("Major", "USD" , "", "USD");	
	indicator.parameters:addStringAlternative("Major", "EUR" , "", "EUR");
	indicator.parameters:addStringAlternative("Major", "JPY" , "", "JPY");
	indicator.parameters:addStringAlternative("Major", "GBP" , "", "GBP");
	indicator.parameters:addStringAlternative("Major", "CHF" , "", "CHF");
	indicator.parameters:addStringAlternative("Major", "AUD" , "", "AUD");
	indicator.parameters:addStringAlternative("Major", "NOK" , "", "NOK"); 
	indicator.parameters:addStringAlternative("Major", "SEK" , "", "SEK"); 
	indicator.parameters:addStringAlternative("Major", "NZD" , "", "NZD"); 
	
	 indicator.parameters:addBoolean("Inverse", "Inverse", "Inverse" ,  true);
	
	indicator.parameters:addString("TF", "Time Frame", "", "H1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addInteger("Size", "Font Size", "", 8);
	indicator.parameters:addInteger("Decimal", "Number of decimals", "", 4);
	 indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 0, 0));
	 indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
end

local first;
local source = nil;
local Major;
local Pattern =  "(%a%a%a)/(%a%a%a)";
local ID;
local TF;
local Bold;
local Decimal;
local day_offset, week_offset;
local dummy;
local host;
local Initialize;
local color;
local Inverse;
local Up, Down;
local Position;
local Stream = {};
local Pairs = {};
local Pip ={};
local Percentage={};
local Index;
local font;
local Size;
local Last;
local loading;
local streams = {};
local INV={};
local PointSize={};

-- Routine
function Prepare(nameOnly) 
    Position=instance.parameters.Position;
	Decimal=instance.parameters.Decimal;
    Inverse=instance.parameters.Inverse;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
    color=instance.parameters.color;
    Size=instance.parameters.Size;
    Major=instance.parameters.Major;
	TF=instance.parameters.TF;
	source = instance.source;
    first = source:first();
	
	local name = profile:id() ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	host=   core.host;    
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	dummy = instance:addInternalStream (first, 0);
	
	Initialize= true;

    
		
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);
	loading=true;
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

	if period ~= source:size() -1  then
	return;
	end  
	
	if Initialize then
	Find ();
	Initialize= false;
	end
	
	if loading then
	return;
	end
	
	Calculate();
	Sort(Percentage);	
	Draw ();
	
end

function Draw()

local i;

       core.host:execute("drawLabel1", 1 ,Size*5, core.CR_LEFT, Size + (1 + 0) *Size, core.CR_TOP, core.H_Center, core.V_Center, Bold, color, "Pairs" );  
	    core.host:execute("drawLabel1", 2 , Size*5+Size*10 ,core.CR_LEFT, Size + (1 + 0) *Size, core.CR_TOP, core.H_Center, core.V_Center, Bold, color, "Percentage" );  
		 core.host:execute("drawLabel1", 3 , Size*5+Size*15  ,core.CR_LEFT, Size + (1 + 0) *Size, core.CR_TOP, core.H_Center, core.V_Center, Bold, color, "Pip" );  
	for i = 1, ID , 1 do
		if Percentage[Index [i]] ~= nil then
		core.host:execute("drawLabel1", i+100,Size*5, core.CR_LEFT, Size + (i+1) *Size, core.CR_TOP, core.H_Center, core.V_Center, Bold, color, Pairs[Index [i]] );
		
		local C;		
		if Percentage[Index [i]] > 0 then 
		C = Up;
		else
		C = Down;
		end
		
		core.host:execute("drawLabel1", i+200,Size*5+Size*10, core.CR_LEFT, Size + (i+1) *Size, core.CR_TOP, core.H_Center, core.V_Center, font, C, string.format("%." .. Decimal .. "f", Percentage[Index [i]]));
		
		
		if Pip[Index [i]] > 0 then 
		C = Up;
		else
		C = Down;
		end
		
		core.host:execute("drawLabel1", i+300,Size*5+Size*15, core.CR_LEFT, Size + (i+1) *Size, core.CR_TOP, core.H_Center, core.V_Center, font, C, string.format("%." .. Decimal .. "f", Pip[Index [i]]));
		end
	end

end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Bold);
 end  

function Sort(DATA)

local i;

    Index={};

	for i = 1, ID, 1 do
	Index[i] = Miximum ( DATA);	
	end

end

function Miximum (DATA)
    
    local i, Max, index;
	
    Max = nil;	
	
	
	for i =1 , ID, 1 do
	    if DATA[i]~= nil then
	   
		   if  TEST (i) then
		       if Max == nil then
		       Max = DATA[i]; 
			   end
			   
			   if DATA[i] >= Max  then
			   Max = DATA[i]; 
			   index = i;
			   end
		   end
		 end  
     end   	
	
	
	return index;
    	
	
     
end

function TEST (j)

   if j == nil then
   return false;
   end
  
   local RETURN= true;
   local i;
   
   for  i = 1, ID, 1 do
	   if Index[i] == j then
	   RETURN = false;
	   end
   end
   
   return  RETURN;
    
  
end

function Calculate ()

local i;

	for i = 1, ID, 1 do
		   if Stream[i]~= nil then 
				 if Stream[i].close:size()-1 >= Stream[i].close:first() then
				 
				        if Inverse  and  INV[i]  then
						Pip[i] =     (  1/Stream[i].close[Stream[i].close:size()-1]  - 1/Stream[i].open[Stream[i].close:size()-1] 	)/PointSize[i] ;
						 Percentage[i] =   (  1/Stream[i].close[Stream[i].close:size()-1] - 1/Stream[i].open[Stream[i].close:size()-1]  ) /  (1/(Stream[i].open[Stream[i].open:size()-1] )) /100;				
						elseif not Inverse or  Inverse  and  not INV[i]  then 
						 Pip[i] =  ((Stream[i].close[Stream[i].close:size()-1] - Stream[i].open[Stream[i].close:size()-1]) )/PointSize[i] ;
						 Percentage[i] = (Stream[i].close[Stream[i].close:size()-1]  - Stream[i].open[Stream[i].close:size()-1]) / (Stream[i].open[Stream[i].open:size()-1] /100);
                        end						
				end 
		  end	
	end

end

function Find ()

	local Table=core.host:findTable("offers");
	local enum = Table:enumerator();	
	ID=1;
	 
	 while true do
		
	    local row = enum:next();	
	    
		if row == nil then
		break;
		end   
				
		local instrument = row.Instrument;	
	

		
       local One, Two;
    	One, Two   = string.match(instrument, Pattern);
	   
	   if One == Major or  Two == Major  then	
			   
			  
			   
			   
			           if Inverse and   One == Major then
						Pairs[ID] = Two .. "/" ..  One  
						INV[ID]= true;						
					  
						 
						else
						 Pairs[ID]= instrument; 	
						 INV[ID]	= false;			
						end
					   
			   	PointSize[ID] = row.PointSize;
			   
			   Stream[ID]=registerStream(ID, TF, 0, instrument); 
			  ID= ID+1;  	
			   		  
	   end
		
		
	end
	
  

end

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required extent (number of periods to look the back)
-- @return the stream reference
function registerStream(id, barSize, extent, instrument )
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, 0, 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    stream.data = nil;
    stream.barSize = barSize;
    stream.length = length;
    stream.loading = false;
    stream.extent = extent;
    local from, dataFrom
    from, dataFrom = getFrom(barSize, length, extent);
    if (source:isAlive()) then
        to = 0;
    else
        t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
    end
    stream.loading = true;
    stream.loadingFrom = from;
    stream.dataFrom = from;
    stream.data = host:execute("getHistory", id, instrument, barSize, from, to, source:isBid());
    setBookmark(0);

    streams[id] = stream;
    return stream.data;
end


function setBookmark(period)
    local bm;
    bm = dummy:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    dummy:setBookmark(1, bm);
end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - length * extent + 0.5) / 86400;
    end
    return loadFrom, from;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;
    local stream = streams[cookie];
    if stream == nil then
        return ;
    end
    stream.loading = false;
    period = dummy:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end   
   