-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=70412

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("MCP Cosine wave");
    indicator:description("MCP Cosine wave");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("WaveId", "Wave Id", "Id", 1);
     indicator.parameters:addInteger("Extension", "Extension", "Extension", 100);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "1. Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color2", "2. Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color3", "3. Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style3", core.FLAG_LINE_STYLE);
	
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;
local WaveId;
-- Streams block
local StartDate={};
local EndDate={};
local StartLevel={};
local EndLevel={};
 local StartPeriod, EndPeriod;
local pattern = "([^;]*);([^;]*)";
local db; 
local Extension;
local Line={};
-- Routine

local Width={};
local Style={};
local Color={};
function Prepare(nameOnly)
    
    source = instance.source;
	WaveId=instance.parameters.WaveId;
 
    first = source:first() ;

    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
	Start=instance.parameters.Start;
	End=instance.parameters.End;
	
	Width[1]=instance.parameters.Width1;
	Style[1]=instance.parameters.Style1;
	Color [1]=instance.parameters.Color1;	
	
	Width[2]=instance.parameters.Width2;
	Style[2]=instance.parameters.Style2;
	Color[2]=instance.parameters.Color2;
	
	Width[3]=instance.parameters.Width3;
	Style[3]=instance.parameters.Style3;
	Color[3]=instance.parameters.Color3;
	
	Extension=instance.parameters.Extension;
	
	EndDate={nil,nil,nil};
	StartData={nil,nil,nil};
	
	StartPeriod=nil;
	EndPeriod=nil;
	
	for i= 1, 3, 1 do
        Line[i] = instance:addStream("Line", core.Line, name, "Line", Color[i], first,Extension);
        Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		Line[i]:setWidth(Width[i]);
        Line[i]:setStyle(Style[i]);
		Line[i]:addLevel(0);
   end
	
	    core.host:execute("addCommand", 1, "Start Point");
 		core.host:execute("addCommand", 2, "End Point");
		
		
		 
	require("storagedb");
    db = storagedb.get_db(profile:id());	
	
 
	
	 core.host:execute("setTimer", 10, 1);
end

function ReleaseInstance()
    core.host:execute("killTimer", 10);
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < source:size()-1 then
	return;
	end
	
 for i= 1, 3, 1 do
 DrawLine(i, period)
 end
 
end

function DrawLine(i, period)
   if StartDate[i]== nil
   or EndDate[i]== nil
   then
   return;
   end
   
 
	StartPeriod = core.findDate (source, StartDate[i], false); 
	EndPeriod = core.findDate (source, EndDate[i], false);
	 
	if StartPeriod < first
	or EndPeriod < first
	or StartPeriod > source:size()-1
	or EndPeriod > source:size()-1
	then
	return;
	end
		
    if EndDate[i]== nil or StartPeriod== nil or period < StartPeriod then 
	return;
	end
	
	Period=(EndPeriod-StartPeriod)/2;
	
	for j= StartPeriod-1, source:size()-1+Extension ,1 do	
	 
        Line[i][j] = math.cos(math.pi * ((j-StartPeriod)/Period) );
		
    end
end

function AsyncOperationFinished(cookie, success, message)


    if cookie== 1 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("StartDate".. tostring(WaveId) , tostring(Date));  	
	db:put("StartLevel".. tostring(WaveId) , tostring(Level));  	
	end
	
	
	if cookie== 2 then
	local Level, Date = string.match(message, pattern, 0);	
	db:put("EndDate".. tostring(WaveId) , tostring(Date));  	
	db:put("EndLevel".. tostring(WaveId) , tostring(Level));  	
	end
	
	if cookie == 10   then
 
 
            for i=1, 3, 1 do
			StartDate[i]= db:get ("StartDate".. tostring(i), 0); 
			StartLevel[i]= db:get ("StartLevel".. tostring(i), 0); 			
			EndDate[i]= db:get ("EndDate".. tostring(i), 0); 
			EndLevel[i]= db:get ("EndLevel".. tostring(i), 0); 
			end
			
 
	 instance:updateFrom(0);
	 
   end
   
   
   
     return core.ASYNC_REDRAW ;
   
	
end	

 
  
