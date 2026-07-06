
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1589

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF Cloud");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
		
	local i;
	 local TF={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8" ,"D1","W1","M1"};
	 local Flag={true,true,true,true,true,true,true,true,true,true ,true,true,true};
	indicator.parameters:addGroup("Selector"); 
	
	for i= 1, 13 , 1 do
	indicator.parameters:addBoolean("Show" .. i , i .. ". Show " .. TF[i], "", Flag[i]);
	end
	
	for i= 1, 13 , 1 do
    Add(i, 20, 100);
	end
	
	indicator.parameters:addGroup("Style"); 
     indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));	
	 indicator.parameters:addInteger("FSize", "Font Size", "", 8);
	 indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
 
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));

end

function Add (id, x, y)

   
    local TF={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8" ,"D1","W1","M1"};
	
	  indicator.parameters:addGroup( id .. ". Time Frame Parameters" );
	
	
	indicator.parameters:addString("Type1"..id, "First Averege Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1"..id, "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addString("Method1"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period1"..id, "Period", "Period" , x);
	
	
	
	indicator.parameters:addString("Type2"..id, "Second Averege Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2"..id, "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addString("Method2"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2"..id, "Period", "Period" , y);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local Shift;
	local first;
	local FIRST={};
	local source = nil;
	local Start={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8" ,"D1","W1","M1"};
	local TF={};
	local host;
	local offset;
	local weekoffset;
	local SourceData ={};
	local loading ={};   
    local Count= 13; 
    local font;
	local Max={ };
	 local  Show={ }; 
	 local Num;
	local Color;
	local FSize;
	 local id;
	local Method2={};
	local Method1={};
	local Period2={};
	local Period1={};
	local Type2={};
	local Type1={};
   local Indicator1={};
   local Indicator2={};
   local Up, Down, UpDown, DownUp;
 
-- Routine
function Prepare(nameOnly) 
  
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
    first = source:first();
	
	
	
	local name = profile:id() .. ", " .. source:name()  ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Color = instance.parameters.Color;
	FSize = instance.parameters.FSize;
	Shift= instance.parameters.Shift;
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	 
	
	font = core.host:execute("createFont", "Arial", FSize , false, false);
     
	local s, e , i , Temp1, Temp2;
	Num = 0; 
	 
	for i = 1, Count, 1 do		
	 Show[i]= instance.parameters:getBoolean ("Show"..i);	
	 
			 if  Show[i]  then 
			 Num= Num+1;
			 Calculate(i, Num);
			 end
			
			 end 
	
   
	 

end

function Calculate (i, Num)
     TF[Num]= Start[i];
    Period1[Num]= instance.parameters:getInteger ("Period1"..i);
	 Period2[Num]= instance.parameters:getInteger ("Period2"..i);	
	 Type1[Num]= instance.parameters:getString ("Type1"..i);	
	 Type2[Num]= instance.parameters:getString ("Type2"..i);	
	 Method2[Num]= instance.parameters:getString ("Method2"..i);	
	 Method1[Num]= instance.parameters:getString ("Method1"..i);	
	 
	 
	  if (Period2[Num]<= Period1[Num]) then
       error("The First MA period must be smaller than Second MA period");
    end
	 
	 assert(core.indicators:findIndicator(Method1[Num]) ~= nil, "Please, download and install "..Method1[Num]..  " indicator");
	assert(core.indicators:findIndicator(Method2[Num]) ~= nil, "Please, download and install "..Method2[Num]..  " indicator");
	
	if Method1[Num] == "VAMA" then
	Temp1= core.indicators:create(Method1[Num], source, Period1[Num]);	
	else
	Temp1= core.indicators:create(Method1[Num], source[Type1[Num]], Period1[Num]);	
	end
	
	if Method2[Num] == "VAMA" then
	Temp2= core.indicators:create(Method2[Num], source, Period2[Num]);	
	else
	Temp2= core.indicators:create(Method2[Num], source[Type2[Num]], Period2[Num]);	
	end
	 
	 FIRST[i]= math.max(Temp1.DATA:first(), Temp2.DATA:first());	 
	 
	 
	 SourceData[Num] = core.host:execute("getSyncHistory", source:instrument (), TF[Num], source:isBid(),  math.min(300,FIRST[i]) , 200+Num , 100+Num);
	 loading[Num] = true;   
	 
	 if Method1[Num] == "VAMA" then
	Indicator1[Num]= core.indicators:create(Method1[Num], SourceData[Num], Period1[Num]);	
	else
	Indicator1[Num]= core.indicators:create(Method1[Num], SourceData[Num][Type1[Num]], Period1[Num]);	
	end
	
	if Method2[Num] == "VAMA" then
	Indicator2[Num]= core.indicators:create(Method2[Num], SourceData[Num], Period2[Num]);	
	else
	Indicator2[Num]= core.indicators:create(Method2[Num], SourceData[Num][Type2[Num]], Period2[Num]);	
	end

end

 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

if period < source:size()-1 then
return;
end


core.host:execute ("setStatus", "")

    local FLAG= false;
	
	local i;
	
	for i= 1, Num, 1 do
	  if loading[i] then
	  FLAG=true;
	  end
	end
	
	if FLAG then
	core.host:execute ("setStatus", "Loading")
	return;
	end
    id = 1;
	
	
    for i= 1, Num, 1 do
	Indicator1[i]:update(mode);
	Indicator2[i]:update(mode);
	end
	
    for i= 1, Num, 1 do 
	Draw(i ); 
    end
end
 

 

function AsyncOperationFinished(cookie)

   local i;
   
   
    for i = 1, Num, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
		      elseif  cookie == 200+i then
			  loading[i] = false;  
			  
			  end
		  
	end    
	
	 local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
   
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. (Num) );	
    else
      core.host:execute ("setStatus", "" );	        
	instance:updateFrom(0);	
	end
   
   
        
     return core.ASYNC_REDRAW;
end

function Draw (i)

 
  local One, Two;
  
  if Indicator1[i].DATA[Indicator1[i].DATA:size()-1] > Indicator1[i].DATA[Indicator1[i].DATA:size()-2] then
  One = true;   
  else
  One = false;  
  end
  
  if Indicator2[i].DATA[Indicator2[i].DATA:size()-1] > Indicator2[i].DATA[Indicator2[i].DATA:size()-2] then
  Two = true;   
  else
  Two = false;  
  end
  
  core.host:execute("drawLabel1", id,  50+(i-1)*  FSize*8,  core.CR_LEFT, 25+FSize*2  +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Color, tostring(TF[i])    );			  
  id = id+1;
  
  local label1, label2, color1, color2;
  
  if Two  then
    label2= "Up Slope"
	color2= Up;
  else
   label2= "Down Slope"
	color2= Down;	  
  end
 
    if One  then
    label1= "Up Swing"
	color1= Up;
  else
   label1= "Down Swing"
	color1= Down;	  
  end
  
  
  
 
  core.host:execute("drawLabel1", id,  50+(i-1)*  FSize*8 ,  core.CR_LEFT, 25+FSize*5   +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, color2, tostring(label2)    );			  
  id = id+1;
   
   
  
  core.host:execute("drawLabel1", id,  50+(i-1)*  FSize*8 ,  core.CR_LEFT, 25+FSize*8   +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, color1, tostring(label1)    );			  
  id = id+1;
   
end

function ReleaseInstance()
       core.host:execute("deleteFont", font); 
end

