-- Id: 1986
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1319


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

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Multiple Bollinger Bands Deviation");
    indicator:description("Multiple Bollinger Bands Deviation");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods" , "The number of periods.", 20);
    indicator.parameters:addInteger("AD", "Number of deviations Line Shown", "" , 2,0, 100);
	indicator.parameters:addDouble("Dev", "Number of standard deviations between Lines", "Number of standard deviations between Lines.", 1);
	
	indicator.parameters:addString("M" , "Method for avegage", "Method for avegage", "MVA");
    indicator.parameters:addStringAlternative("M" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "LWMA", "", "LWMA");
	
	indicator.parameters:addGroup("Band Type");
	indicator.parameters:addString("Type", "Type " , "", "Multiplication");
    indicator.parameters:addStringAlternative("Type" , "MVA Multiplication", "", "Multiplication");
    indicator.parameters:addStringAlternative("Type", "MVA Shift", "", "Shift");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("HideAve", "Hide average line",  "Defines whether the BB average line is hidden.", false);   
	indicator.parameters:addInteger("CLwidth", "Central Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("CLstyle", "Central Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CLstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("LLwidth", "Outer Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LLstyle", "Outer Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LLstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("MLwidth", "Middle Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("MLstyle", "Middle Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MLstyle", core.FLAG_LINE_STYLE);
	
 end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;
local Type;

local Additional;
local UpR,UpG, UpB;
local DownR,DownG, DownB;
local step;

local firstPeriod;
local source = nil;
local Method;
local AVG;

-- Streams block
local DEV = {}; 

-- Routine
function Prepare(nameOnly) 
    Method = instance.parameters.M;
    Type = instance.parameters.Type;
    N = instance.parameters.N;
    D = instance.parameters.Dev;
	Additional=  instance.parameters.AD;
	
    source = instance.source;
    firstPeriod = source:first() + N - 1;
	
		
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. D .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
    
	local i;
	
	step = (255 / Additional) ;
	
	UpR =0;
	UpG= 0;
	UpB=255;
	
	DownR =0;
	DownG= 0; 
	DownB=255; 
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	AVG= core.indicators:create(Method, source, N);
	
	for i= 0 , Additional-1, 1 do 
	
	  UpR  = UpR+step ;  
	 -- UpG  =UpG+step; 
	  UpB	=UpB-step;
	 
	CreateDev(i, name, core.rgb(UpR, UpG, UpB));
	
	DownG  =DownG+step;    
	 DownB	=DownB-step; 
	
	CreateDev(i+Additional, name, core.rgb(DownR, DownG, DownB));
	end
	
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "0", core.rgb(0, 0, 255), firstPeriod)	
		AL:setWidth(instance.parameters.CLwidth);
        AL:setStyle(instance.parameters.CLstyle);
    end	
end

local FLAG= true;
local STANDARD;
-- Indicator calculation routine
function Update(period, mode)

    AVG:update(mode);

    if period >= firstPeriod and source:hasData(period) then
      
	    local p = core.rangeTo(period, N);
        local d = core.stdev(source, p);
		 d = d*D;
		 
		
         if Type == "Shift" and FLAG and d ~= nil then
	     FLAG=false;
		 STANDARD= d;
	     end		
		 
    
        if AVG.DATA:hasData(period)  then
            AL[period] = AVG.DATA[period];
        end
				
		local i;
	
		for i= 0 , Additional-1, 1 do 
		CalcDev(i,period, AVG.DATA[period],d)
		end		
		
    end
		
end


function CreateDev(index, names,color)
    local label;
    local note; 
	    
    if index < Additional then
    label = "DEV" .. index;
	note =index+1;
	else
	label = "DEV" .. index;
	note = "-"..(index+1-Additional);
	end
	
   if index ==	Additional -1  or index - Additional ==	Additional -1 then
   DEV[index] = instance:addStream(label, core.Line, names .. note , note, color, firstPeriod)
   DEV[index]:setWidth(instance.parameters.LLwidth);
   DEV[index]:setStyle(instance.parameters.LLstyle);   
   else
   DEV[index] = instance:addStream(label, core.Line, names .. note , note, color, firstPeriod)
   DEV[index]:setWidth(instance.parameters.MLwidth);
   DEV[index]:setStyle(instance.parameters.MLstyle);
   end
end

function CalcDev(index,period, ml,d)

       if Type == "Multiplication" then
       DEV[index][period] = ml + (index+1) * d;
	   DEV[index+Additional][period] = ml - (index+1) * d;
	   else
	   DEV[index][period] = ml + (index+1) * STANDARD;
	   DEV[index+Additional][period] = ml - (index+1) * STANDARD;
	   end
	  
end

