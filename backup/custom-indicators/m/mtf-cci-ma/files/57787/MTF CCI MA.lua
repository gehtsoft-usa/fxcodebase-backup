-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34000
-- Id: 8853

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF CCI MA");
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
    Add(i, 100, 100);
	end
	
	indicator.parameters:addGroup("Style"); 
     indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));	
	 indicator.parameters:addInteger("FSize", "Font Size", "", 10);
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
	
	indicator.parameters:addInteger("Period1"..id, "MA Period", "Period" , x);
	
 
	indicator.parameters:addInteger("Period2"..id, "CCI Period", "Period" , y);
	indicator.parameters:addDouble("BUY"..id, "CCI Buy Level", " Buy Level" , 0);
	indicator.parameters:addDouble("SELL"..id, "CCI Sell Level", " Sell Level" , 0);
 
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
 
	local Method1={};
	local Period2={};
	local Period1={}; 
	local Type1={};
   local Indicator1={};
   local Indicator2={};
   local Up, Down, UpDown, DownUp;
   local Wingdings;
   local BUY={};
   local SELL={};
 
-- Routine
function Prepare(nameOnly)
  
    Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source;
    first = source:first();
    Color = instance.parameters.Color;
	FSize = instance.parameters.FSize;
	Shift= instance.parameters.Shift;
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    local name = profile:id() .. ", " .. source:name()  ;
    instance:name(name);
	 
	Wingdings  = core.host:execute("createFont", "Wingdings", FSize +1, false, false);
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
     BUY[Num]= instance.parameters:getDouble ("BUY"..i);
     SELL[Num]= instance.parameters:getDouble ("SELL"..i);
	 Method1[Num]= instance.parameters:getString ("Method1"..i);	
 
	 
    assert(core.indicators:findIndicator(Method1[Num]) ~= nil, Method1[Num] .. " indicator must be installed");
	Temp1= core.indicators:create(Method1[Num], source[Type1[Num]], Period1[Num]);	
    Temp2= core.indicators:create("CCI", source , Period2[Num]);	
	
	 
	 
	 FIRST[Num]= math.max(Temp1.DATA:first(), Temp2.DATA:first());	 
	 
	 
	 SourceData[Num] = core.host:execute("getSyncHistory", source:instrument (), TF[Num], source:isBid(),  FIRST[Num] , 200+Num , 100+Num);
	 loading[Num] = true;   
	 
	 
	Indicator1[Num]= core.indicators:create(Method1[Num], SourceData[Num][Type1[Num]], Period1[Num]);		 
	Indicator2[Num]= core.indicators:create("CCI" , SourceData[Num] , Period2[Num]);	
 

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
	
	
	  core.host:execute("drawLabel1", id,  100+(Num+1)*FSize*5  ,  core.CR_LEFT, 25+FSize*5  +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Color, tostring("PRICE/MA")    );			  
  id = id+1;
  
    core.host:execute("drawLabel1", id,  100+(Num+1)*FSize*5   ,  core.CR_LEFT, 25+FSize*8  +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Color, tostring("CCI")    );			  
  id = id+1;
	
	
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
               
	 instance:updateFrom(0);
			  	
	end
   
   
        
     return core.ASYNC_REDRAW;
end

function Draw (i)

 
  local One, Two;
  
  if SourceData[i].close[SourceData[i].close:size()-1] > SourceData[i].open[SourceData[i].open:size()-1] then
  One = true;   
  else
  One = false;  
  end
  
  if Indicator2[i].DATA[Indicator2[i].DATA:size()-1] > Indicator2[i].DATA[Indicator2[i].DATA:size()-2] then
  Two = true;   
  else
  Two = false;  
  end
  
  core.host:execute("drawLabel1", id,  100+(i-1)*  FSize*5,  core.CR_LEFT, 25+FSize*2  +Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Color, tostring(TF[i])    );			  
  id = id+1;
  
  
  
  local label1, label2, color1, color2;
  
  if One  then
   
	color1= Up;
  else
    
	color1= Down;	  
  end
 
    if Two  then    
	color2= Up;
  else  
	color2= Down;	  
  end
  
  
   if  SourceData[i].close[SourceData[i].close:size()-1] > Indicator1[i].DATA[Indicator1[i].DATA:size()-1] then
  label1 = "\225";   
  else
  label1 = "\226";  
  end
  
  if Signal(i) == true then
  label2 =  "\225";     
  elseif Signal(i) == false then
  label2 = "\226";  
  else
  label2 = "\160";  
  end
  
  
  
 
  core.host:execute("drawLabel1", id,  100+(i-1)*  FSize*5 ,  core.CR_LEFT, 25+FSize*8   +Shift  , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, color2, tostring(label2)    );			  
  id = id+1;
   
   
  
  core.host:execute("drawLabel1", id,  100+(i-1)*  FSize*5 ,  core.CR_LEFT, 25+FSize*5   +Shift  , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, color1, tostring(label1)    );			  
  id = id+1;
  
     
end

function ReleaseInstance()
       core.host:execute("deleteFont", font); 
	    core.host:execute("deleteFont", Wingdings);
end

function Signal (i)
  
  local SIGNAL="Neutral";
  
  local period;
  for period= Indicator2[i].DATA:size()-1 , Indicator2[i].DATA:first()+1, -1 do  
  
		  if Indicator2[i].DATA[period] > BUY[i] and Indicator2[i].DATA[period-1] < BUY[i] and SIGNAL=="Neutral" then
		  SIGNAL= true; 
		  elseif Indicator2[i].DATA[period] < SELL[i] and Indicator2[i].DATA[period-1] > SELL[i]   and SIGNAL=="Neutral"then
		  SIGNAL= false;  
		  end
		  
		  if SIGNAL~="Neutral" then
		  break;
		  end
  
  end
  
  
  return SIGNAL;
  

end


