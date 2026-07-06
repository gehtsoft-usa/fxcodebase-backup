-- Id: 10243
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59670

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
    indicator:name("MTF Krivo Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Use", "Use Percentage", "", true);
	indicator.parameters:addBoolean("Both", "Majors Only", "", true); 
	
	indicator.parameters:addGroup("Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
	indicator.parameters:addGroup("Time Frame Selector");	 
	Parameters (1 , "m1", false  );
	Parameters (2 , "m5", false   );
	Parameters (3 , "m15", false  );
	Parameters (4 , "m30", false    );
    Parameters (5 , "H1", true  );
	Parameters (6 , "H2", false   );
	Parameters (7 , "H3", false  );
	Parameters (8 , "H4", false    );
    Parameters (9 , "H6", false    );
    Parameters (10 , "H8", true  );
	Parameters (11 , "D1", true   );
	Parameters (12 , "W1", false  );
	 
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
    indicator.parameters:addColor("Color", "Label Color", " " ,  core.COLOR_LABEL);
    indicator.parameters:addInteger("Size", "Font Size", " " , 10);
end



function Parameters (id , TF, flag )
	 
	 
	indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("TFOn"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", TF);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS); 
	 
	indicator.parameters:addString("Price"..id , "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period"..id, "Period", " " , 50);
	end


function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
 end  

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 

local first;
local source = nil;
local Method={};
local  Price={};
local Period={};
-- Streams block
local Out={};
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Num={};
local Shift;
local Color;
local Indicator={};
local Bold, Size;
local id;
local Final={};
	local host;
	local offset;
	local weekoffset;
	 
    local Point={};
	local Mode; 
local Use;
local MA={};
local iNum={};
local Both;

local TF={};
local TFOn={};
local TfCount;
-- Routine
function Prepare(nameOnly) 
 
	
	Both = instance.parameters.Both;
	Use = instance.parameters.Use;
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
	Shift = instance.parameters.Shift;
	
	local i,j;
	
	TfCount=0;
	
	
	for i= 1, 12, 1 do
	TFOn[i] = instance.parameters:getBoolean("TFOn" .. i);	
	if TFOn[i] then
	TfCount=TfCount+1;
	TF[TfCount]= instance.parameters:getString("TF" .. i);
	Method[TfCount]= instance.parameters:getString("Method" .. i);
	Price[TfCount] = instance.parameters:getString("Price" .. i);
	Period[TfCount]= instance.parameters:getInteger("Period" .. i);
	end
	
	end

  
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	  Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	 

	local FLAG= false;
	Count=0;
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j);	 
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   for j = 1, 8 , 1 do
			 if  ( (Check(crncy1) or (Check(crncy2)) ) and not Both)
			 or ( (Check(crncy1) and (Check(crncy2)) ) and Both)			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end
	local Temp;
	local k=0;	 
	for j= 1 , TfCount, 1 do
	SourceData[j]={};
	Indicator[j]={};
	loading[j]={};
    assert(core.indicators:findIndicator(Method[j]) ~= nil, Method[j] .. " indicator must be installed");
	 Temp= core.indicators:create(Method[j], source, Period[j]);		 
     first = Temp.DATA:first();
		 
	   for i = 1, Count, 1 do		
		 k=k+1;
		 SourceData[j][i] = core.host:execute("getSyncHistory", List[i], TF[j], source:isBid(), math.min(first) , 200+k , 100+k);
		 loading[j][i] = true;  	 
	    Indicator[j][i] = core.indicators:create(Method[j], SourceData[j][i][Price[j]], Period[j]);
	   end
	end
	
	
end

function Check(Find)
 local FLAG= false;
            for j = 1, 8 , 1 do
			 if  (Find==Pair[j] and On[j])then
			 FLAG= true;
			 end
		   end 
return FLAG;		   
end
function getInstrumentList()
    local list={};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < source:size()-1 or not source:hasData(period) then
	return;
	end
	
	
	
    local FLAG=false; 
	local Number=0;
	local i;
	
	for j= 1 , TfCount, 1 do

	   for i = 1, Count, 1 do
	             if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
				 
		end		 
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );
	 
	local p;
	id=0;
	
	for j= 1 , TfCount, 1 do
	
	Num={0,0,0,0,0,0,0,0};
	iNum={0,0,0,0,0,0,0,0};
	
		for i = 1, Count, 1 do	
		
		   
		   
					   Indicator[j][i]:update(mode); 					 
						Calculate(j, i);
				         
					 	
		end
	
	    Draw(j);	
	end	
	   
end	

function Draw(j)

local i;
local iCount=0;


	for i = 1, 8, 1 do
		if On[i] then
		
		iCount=iCount+1;
			
	 	core.host:execute("drawLabel1", id, Size*10+(iCount-1)*Size*10 ,  core.CR_LEFT, Size*1  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Pair[i]);	
        
			id = id+1;	
	  	
		
	
		
		
       local Data;
	   
      	if Use then			
		Data= Num[i]/(iNum[i]/100);	 
		else
		Data= Num[i];	
		end
		
				if iNum[i]== 0  then
				core.host:execute("drawLabel1", id,  Size*10+(iCount-1)*Size*10 ,  core.CR_LEFT,  Size*3 + (j-1)*Size +Size +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  "No Data"	);			  
			    id = id+1;	
				else
			 
			core.host:execute("drawLabel1", id,  Size*10+ (iCount-1)*Size*10 ,  core.CR_LEFT,  Size*3 +(j-1)* Size+Size  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  	string.format("%." .. 2 .. "f", Data)	);			  
			id = id+1;	
			 end
		end	
	end	
		
			core.host:execute("drawLabel1", id,  Size*3 ,  core.CR_LEFT,  Shift+Size*3 + (j-1)*Size +Size  , core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  TF[j]);	
			id = id+1;	
		
end
		
		
function Calculate(j,i )

 

if not Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-1) then
 return;
end


local k;
local crncy1, crncy2;
for k= 1, 8 , 1 do  
	 
	 
     
        if On[k] then
		
		 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Pair[k] then
					
					    
					
							if SourceData[j][i].close[SourceData[j][i].close:size()-1] > Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] then
							Num[k] = Num[k] + 1;
							else
							Num[k] =  Num[k] - 1;
							end
					 	   
						iNum[k]=iNum[k]+1;
                    					
					end
					
					if crncy2 == Pair[k] then
					   
					 
					        if SourceData[j][i].close[SourceData[j][i].close:size()-1] > Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] then
							Num[k] = Num[k] - 1;
							else
							Num[k] =  Num[k] + 1;
                      		end		
					    iNum[k]=iNum[k]+1
					end
	    end		
		 
	 end	 
	 
	 
	  
		
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i, j;
   local l =0;
   
    local FLAG=false; 
	local Number=0;
  for j= 1 , TfCount, 1 do 
  
    for i = 1, Count, 1 do
		 l=l+1;
			  if cookie == 100+l then
			  loading[j][i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+l then
			  loading[j][i] = false;  			  
			  end
		  
	end    
	
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading ".. ( Count*TfCount -Number) .. " / " .. Count*TfCount );
    else
	 core.host:execute ("setStatus",    "Loaded" );
	   instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end

 
 
