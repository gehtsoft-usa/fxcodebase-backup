-- Id: 10388
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59804

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams



function checkReady(table)
    return core.host:execute("isTableFilled", table);
end




function Init()
    indicator:name("Strong Vs Weak");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Currency Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);
	
		
	indicator.parameters:addGroup("Time Frame Selector");	 
	
	indicator.parameters:addBoolean("TFOn".. 1 , "Show (m1) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 2 , "Show (m5) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 3 , "Show (m15) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 4 , "Show (m30) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 5 , "Show (H1) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 6 , "Show (H2) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 7 , "Show (H3) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 8 , "Show (H4) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 9 , "Show (H6) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 10 , "Show (H8) This Time Frame", "", false);	
	indicator.parameters:addBoolean("TFOn".. 11 , "Show (D1) This Time Frame", "", true);	
	indicator.parameters:addBoolean("TFOn".. 12 , "Show (W1) This Time Frame", "", false);	
	
	
	
	indicator.parameters:addGroup("Common parameters");
	indicator.parameters:addBoolean("Show"  , "Show Values", "", true);
	
	indicator.parameters:addString("Type", "Type", "", "Simple");
    indicator.parameters:addStringAlternative("Type", "Simple", "Count", "Simple");
    indicator.parameters:addStringAlternative("Type", "Advanced", "In Pips", "Advanced");
	
	indicator.parameters:addString("Algorithm", "Calculation Method", "Method" , "Price");
    indicator.parameters:addStringAlternative("Algorithm", "Price Change", "Price" , "Price");
    indicator.parameters:addStringAlternative("Algorithm", "Price/ Fast MA Position", "Price/MA" , "Price/MA");
    indicator.parameters:addStringAlternative("Algorithm", "Fast MA/ Slow MA Position", "Fast MA/ Slow MA Position" , "MA/MA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
    indicator.parameters:addColor("Color", "Label Color", " " , core.COLOR_LABEL );
    indicator.parameters:addInteger("Size", "Font Size", " " , 10);
	indicator.parameters:addBoolean("Rainbow"  , "Use Rainbow Coloring", "", true);
	
	
	
	
	
	
	Parameters (1 , "m1" );
	Parameters (2 , "m5"  );
	Parameters (3 , "m15"  );
	Parameters (4 , "m30"    );
    Parameters (5 , "H1"  );
	Parameters (6 , "H2"   );
	Parameters (7 , "H3"  );
	Parameters (8 , "H4"    );
    Parameters (9 , "H6"    );
    Parameters (10 , "H8"  );
	Parameters (11 , "D1"   );
	Parameters (12 , "W1"  );
	
	
	
	
	

end



function Parameters (id , TF )
	 
	 
	indicator.parameters:addGroup(id ..". Time Frame Parameters");
	

	indicator.parameters:addString("TF"..id, "Time frame", "", TF);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS); 
	 
	indicator.parameters:addString("Price1"..id , "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method1"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period1"..id, "Period", " " , 50);
	
	
	indicator.parameters:addString("Price2"..id , "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2"..id, "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method2"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2"..id, "Period", " " , 200);
	end


function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local Type;
local Algorithm;
local first;
local source = nil;
local Method1={};
local  Price1={};
local Period1={};
local Method2={};
local  Price2={};
local Period2={};
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
local FastIndicator={};
local SlowIndicator={};
local Bold, Size;
local id;
local Final={};
	local host;
	local offset;
	local weekoffset;
local Show;	 
    local Point={};
	local Mode; 
--local Use;
local MA={};

local TF={};
local TFOn={};
local TfCount;
local Sorted;
local Rainbow;
-- Routine
local Row;
local Pips={};
function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	
    Show = instance.parameters.Show;
	Algorithm = instance.parameters.Algorithm;
	Type = instance.parameters.Type;
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
	Shift = instance.parameters.Shift;
	Rainbow = instance.parameters.Rainbow;
	
	local i,j;
	
	TfCount=0;
	
	
	for i= 1, 12, 1 do
	TFOn[i] = instance.parameters:getBoolean("TFOn" .. i);	
	if TFOn[i] then
	TfCount=TfCount+1;
	TF[TfCount]= instance.parameters:getString("TF" .. i);
	Method1[TfCount]= instance.parameters:getString("Method1" .. i);
	Price1[TfCount] = instance.parameters:getString("Price1" .. i);
	Period1[TfCount]= instance.parameters:getInteger("Period1" .. i);
	Method2[TfCount]= instance.parameters:getString("Method2" .. i);
	Price2[TfCount] = instance.parameters:getString("Price2" .. i);
	Period2[TfCount]= instance.parameters:getInteger("Period2" .. i);
	end
	
	end

    Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	Mode = instance.parameters.Mode;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
  
	
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
	
		   
			 if  ( (Check(crncy1) and (Check(crncy2)) ) )			 
			 then
			 FLAG= true;
			 end
		 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end
	local Temp1, Temp2;
    local index=0;
	for j= 1 , TfCount, 1 do
	SourceData[j]={};
	FastIndicator[j]={};
	SlowIndicator[j]={};
	Pips[j]={};
	loading[j]={};
    assert(core.indicators:findIndicator(Method1[j]) ~= nil, Method1[j] .. " indicator must be installed");
	 Temp1= core.indicators:create(Method1[j], source, Period1[j]);	
    assert(core.indicators:findIndicator(Method2[j]) ~= nil, Method2[j] .. " indicator must be installed");
      Temp2= core.indicators:create(Method2[j], source, Period2[j]);	 	 
     first = math.max(Temp1.DATA:first(), Temp2.DATA:first());
		 
	   for i = 1, Count, 1 do		
		 index=index+1;
		 SourceData[j][i] = core.host:execute("getSyncHistory", List[i], TF[j], source:isBid(), math.min(300,first) , 200+index , 100+index);
		 loading[j][i] = true;  	 
		 Pips[j][i]= core.host:findTable("offers"):find("Instrument", List[i]).PointSize;	
	    FastIndicator[j][i] = core.indicators:create(Method1[j], SourceData[j][i][Price1[j]], Period1[j]);
		SlowIndicator[j][i] = core.indicators:create(Method2[j], SourceData[j][i][Price2[j]], Period2[j]);
	   end
	end
	
	core.host:execute ("setTimer", 1, 5);
	
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
   

	   
end	


function Sort(old, index, raw, columns)
 
 local new=old;
 local i,j,k, temp;
local SortFlag=true;
 
 
    while SortFlag do
    SortFlag=false;

   
        for j = 2, columns , 1 do
                
                  if new[index][j] >  new[index][j-1] then
                           SortFlag=true;             
                           
                           for k = 1, raw, 1 do
                           temp= new[k][j-1];
                           new[k][j-1]= new[k][j];
                           new[k][j]= temp;
                           end
                      
                  end
            
        end		
      
    end
  
  return new;
end


function Draw(j)

local i;
local iCount=0;
    if Show then	
    Row=j*2; 
	else
	Row=j;
	end
	for i = 1, 8, 1 do
		if On[i] then
		
		iCount=iCount+1;
			
			
		 if Rainbow then		
	 	core.host:execute("drawLabel1", id, Size*5+(iCount-1)*Size*5 ,  core.CR_LEFT,  (Row)*Size +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold,  Coloring (( 100/8)*i, 50),  Sorted[1][i]);	
        id = id+1;	
		else
		core.host:execute("drawLabel1", id, Size*5+(iCount-1)*Size*5 ,  core.CR_LEFT,   (Row)*Size +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
        id = id+1;	
		end
	  	
		local Value;
		if  Sorted[2][i]== nil then
		Value = "No Data";
		else
		Value= string.format("%." .. 0 .. "f", Sorted[2][i]);
		end
		
	    if Show then
		core.host:execute("drawLabel1", id, Size*5+(iCount-1)*Size*5,  core.CR_LEFT,   (Row+1)*Size +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,Value  );	
        id = id+1;	
		end
		
			core.host:execute("drawLabel1", id, Size*2  ,  core.CR_LEFT,  (Row)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  TF[j]);	
			id = id+1;	
		
		end
	end
	
end
		
		
function Calculate(j,i )

 

if not FastIndicator[j][i].DATA:hasData(FastIndicator[j][i].DATA:size()-1) 
or not SlowIndicator[j][i].DATA:hasData(SlowIndicator[j][i].DATA:size()-1) 
then
 return;
end


local k;
local crncy1, crncy2;
local Value;
local Flag;
for k= 1, 8 , 1 do  
	 
	 
     
        if On[k] and SourceData[j][i].close:hasData(SourceData[j][i].close:size()-1) then
		
		                  if  Algorithm == "Price" then
						   Flag = (SourceData[j][i].close[SourceData[j][i].close:size()-1] > SourceData[j][i].open[SourceData[j][i].close:size()-1]);
						  elseif  Algorithm == "Price/MA" then
						   Flag = (SourceData[j][i].close[SourceData[j][i].close:size()-1] > FastIndicator[j][i].DATA[FastIndicator[j][i].DATA:size()-1]);
						  elseif  Algorithm == "MA/MA" then
						   Flag = (FastIndicator[j][i].DATA[FastIndicator[j][i].DATA:size()-1] > SlowIndicator[j][i].DATA[SlowIndicator[j][i].DATA:size()-1]);
		                  end
						  
						 
						 if Type == "Simple" then
	                    	Value=1;
						   else	
						   
						          if  Algorithm == "Price" then
								   Value=math.abs(SourceData[j][i].close[SourceData[j][i].close:size()-1] - SourceData[j][i].open[SourceData[j][i].close:size()-1])/Pips[j][i];
								  elseif  Algorithm == "Price/MA" then
								   Value=math.abs(SourceData[j][i].close[SourceData[j][i].close:size()-1] - FastIndicator[j][i].DATA[FastIndicator[j][i].DATA:size()-1])/Pips[j][i];
								  elseif  Algorithm == "MA/MA" then
								   Value=math.abs( FastIndicator[j][i].DATA[FastIndicator[j][i].DATA:size()-1] - SlowIndicator[j][i].DATA[SlowIndicator[j][i].DATA:size()-1])/Pips[j][i];
		                         end
						  
						  
							
		                   end
						   
						   
						   
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Pair[k] then
					
					        
					
							if Flag then	
							Plus(k, Value);							 
							else						
							Plus(k, -Value);
							end
			 
					end
					
					if crncy2 == Pair[k] then
					   
					
					        if  Flag  then							
							Plus(k, -Value);
							else
							Plus(k, Value);
                      		end		
					   
					end
	    end		
		 
	 end	 
	 
	 
	  
		
end		
		
 function Plus(k, value)

 Num[2][k] = Num[2][k] + value;
 end
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i, j;
 
   
    local FLAG=false; 
	local Number=0;
	local index=0;
  for j= 1 , TfCount, 1 do 
  
    for i = 1, Count, 1 do
              index=index+1;
			  if cookie == 100+index then
			  loading[j][i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+index then
			  loading[j][i] = false; 
			  end
		  
	end    
	
	end
	
	
	if not FLAG and cookie== 1 then
	
	
	    	core.host:execute ("setStatus",    "" );
	 
	local p;
	id=0;
	Row=0;
	for j= 1 , TfCount, 1 do
	
	  Num[1]={"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"};
	  Num[2]={0,0,0,0,0,0,0,0};
	--	Num[3]={0,0,0,0,0,0,0,0};
		
		
		for i = 1, Count, 1 do	
		
		
		   
		   
					   FastIndicator[j][i]:update(core.UpdateLast ); 	
                       SlowIndicator[j][i]:update(core.UpdateLast );  					   
						Calculate(j, i);
				         
					 	
		end
	   	Sorted=Sort(Num, 2, 2, 8)
		
	    Draw(j);	
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

 
 
