-- Id: 4790
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7412

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
    indicator:name("Oscillator Overlay");
    indicator:description("Oscillator Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
		
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_ONLYOSCILLATORS);


     indicator.parameters:addString("Position", "Position", "", "Central");
    indicator.parameters:addStringAlternative("Position", "Central", "", "Central");
    indicator.parameters:addStringAlternative("Position", "Top", "", "Top");	
	indicator.parameters:addStringAlternative("Position", "Bottom", "", "Bottom");	
	
	 indicator.parameters:addColor("Line", "Zero Line Color", "", core.rgb(0, 0, 0));
end




local INDICATOR;
local out={};
local final={};
local source;
local Indicator= nil;
--local day_offset, week_offset;
--local dummy;
--local stream=nil;
local host;
local first;
--local  loading;
local FLAG = false;
local INSTRUMENT={};
local Count; 
  local TEMP;  
local first= 1;
local source = nil;
local INDEX={};
local Position;
local Line;

function Prepare(nameOnly)
    INDICATOR=instance.parameters.INDICATOR;
	Position=instance.parameters.Position;
    source = instance.source;   
    host = core.host;	
	
	Line=instance.parameters.Line;
	
	  local name =  profile:id()  ;
	
	local i;
  
     name = name..", ("  ..  INDICATOR .. ")";      
	
	
	instance:name(name);
	if nameOnly then
		return;
	end
	
  -- day_offset = host:execute("getTradingDayOffset");
   -- week_offset = host:execute("getTradingWeekOffset"); 
	

   -- dummy = instance:addInternalStream(0, 0);	
	
	
	
	       local tmpiprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		   local tmpiparams = instance.parameters:getCustomParameters("INDICATOR");
			   
  
	if  tmpiprofile:requiredSource() == core.Tick then
    assert(core.indicators:findIndicator(INDICATOR) ~= nil, INDICATOR .. " indicator must be installed");
	TEMP= core.indicators:create(INDICATOR, source.close, tmpiparams);	
    else
	TEMP= core.indicators:create(INDICATOR, source, tmpiparams);	
    end	
	
	 Count= TEMP:getStreamCount ();


				for i = 0, Count-1 , 1  do
						if i <= Count  then
						INDEX[i]=  TEMP:getStream (i);	
						 out[i] = instance:addInternalStream(0, 0);
						
						final[i] = instance:addStream("out" .. i , core.Line,  i , i,  core.rgb(0, 0, 0), INDEX[i]:first());
						final[i]:setPrecision(2);	
						
						first = math.max(first, INDEX[i]:first());						
						
						end	
	             end	
   
end


function Update(period, mode)
    
	local i;
	
	TEMP:update(mode);
	local Color;
	
	
	if period == source:size()-1 then
	
	local Zero= nil;
	local MIN, MAX;
	local  min,  max, tmin, tmax;
	MIN, MAX= mathex.minmax (source, first, source:size()-1 );
    local MID = (MAX+MIN)/2;	
	local PriceSpread=  MAX-MIN;
			for i = 0, Count -1, 1  do
			tmin,  tmax = mathex.minmax (INDEX[i] , INDEX[i]:first(), INDEX[i]:size()-1 );
					
					
					    local IndexSpread= (tmax - tmin)/100;
				
					     for j = first, source:size()-1 , 1 do
						 
						 if Position == "Top" then
						  final[i][j] = MID+PriceSpread + (INDEX[i][j]/IndexSpread  ) * (PriceSpread/100);
						  Zero= MID+PriceSpread;
						 elseif   Position == "Bottom"  then
						  final[i][j] = MID -  PriceSpread + (INDEX[i][j]/IndexSpread  ) * (PriceSpread/100);	
						  Zero= MID-PriceSpread; 
						 else
						 final[i][j] = MID+  (INDEX[i][j]/IndexSpread  ) * (PriceSpread/100);	
                           Zero= MID;						 
						  end 
						 
						   Color= INDEX[i]:colorI(j);
						   final[i]:setColor(j, Color);		
						  end
	        
			end	
	      if  tmin < 0 and tmax > 0  and Zero ~= nil then
          core.host:execute ("drawLine", 1, source:date(first), Zero, source:date(source:size()-1), Zero, Line);
	      end
	end
	
	
end
