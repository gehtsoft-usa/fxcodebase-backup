-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60218
-- Id: 10967

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
    indicator:name("Edge Index");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	indicator.parameters:addGroup("On/Off Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);

	
 
	
indicator.parameters:addGroup("MA Parameters");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("FastMethod", " Fast MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("FastMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("FastMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("FastMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("FastMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("FastMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("FastPeriod", "Period", " " , 8);
	
	
	indicator.parameters:addString("MediumMethod", " Medium MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MediumMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MediumMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MediumMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MediumMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MediumMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MediumMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MediumMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MediumMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("MediumPeriod", "Period", " " , 21);
	
	
	
	indicator.parameters:addString("SlowMethod", " Slow MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("SlowMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("SlowMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("SlowMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("SlowPeriod", "Period", " " , 55);
	
   indicator.parameters:addGroup("ROC Parameters");
   
   indicator.parameters:addInteger("ROC", "ROC Period", " " , 8);
    indicator.parameters:addInteger("SIGNAL", "ROC Signal  Period", " " , 8);
	indicator.parameters:addString("ROCMethod", " Slow MA Method", "Method" , "EMA");
	 indicator.parameters:addStringAlternative("ROCMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("ROCMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("ROCMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("ROCMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("ROCMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("ROCMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("ROCMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("ROCMethod", "WMA", "WMA" , "WMA");
   
 
   
   indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Shift", "Vertical Shift", " " , 0);
    indicator.parameters:addColor("Color", "Label Color", " " ,  core.COLOR_LABEL);
    indicator.parameters:addInteger("Size", "Font Size", " " , 10);
	indicator.parameters:addBoolean("Rainbow"  , "Use Rainbow Coloring", "", true);
end


local ROCMethod, ROC, SIGNAL;

function AddStyle(id , Label, color)
indicator.parameters:addColor("color" ..id, Label ..  " Line Color","", color);
indicator.parameters:addInteger("width" .. id, "Line width", "", 1, 1, 5);
indicator.parameters:addInteger("style".. id, "Line style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style".. id, core.FLAG_LINE_STYLE);
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
 local roc={};
 local signal={};
local SlowMethod,SlowPeriod;
local MediumMethod,MediumPeriod;
local FastMethod,FastPeriod;
 local Sorted;
local slowMA={};
local mediumMA={};
local fastMA={} ;
local Out={};

local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local Show={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
 
 
local Bold;
local id;

	local host;
	local offset;
	local weekoffset;	 
local Rainbow, Size,Color,Shift;
 
function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
 end  

-- Routine
function Prepare(nameOnly)
    SlowMethod = instance.parameters.SlowMethod; 
	SlowPeriod = instance.parameters.SlowPeriod;  
	MediumMethod = instance.parameters.MediumMethod; 
	MediumPeriod = instance.parameters.MediumPeriod;  
    FastMethod = instance.parameters.FastMethod; 
	FastPeriod = instance.parameters.FastPeriod;  
	
	ROCMethod = instance.parameters.ROCMethod;
	ROC = instance.parameters.ROC;
	SIGNAL = instance.parameters.SIGNAL;
	
	Rainbow = instance.parameters.Rainbow
	Size = instance.parameters.Size
	Color = instance.parameters.Color
	Shift = instance.parameters.Shift
	
	Price = instance.parameters.Price;
	 
	local i,j;
	

	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;

    local name = profile:id() .. "  " .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true); 
	
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
		  
		   
			 if ( (Check(crncy1) and (Check(crncy2)) ))			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end

	
	local Temp1,Temp2,Temp3,Temp4,Temp5;
    assert(core.indicators:findIndicator(SlowMethod) ~= nil, SlowMethod .. " indicator must be installed");
	 Temp1= core.indicators:create(SlowMethod, source[Price], SlowPeriod);
    assert(core.indicators:findIndicator(MediumMethod) ~= nil, MediumMethod .. " indicator must be installed");
	  Temp2= core.indicators:create(MediumMethod, source[Price], MediumPeriod);
    assert(core.indicators:findIndicator(FastMethod) ~= nil, FastMethod .. " indicator must be installed");
	   Temp3= core.indicators:create(FastMethod, source[Price], FastPeriod);
	    Temp4= core.indicators:create("ROC", source[Price], ROC);  
    assert(core.indicators:findIndicator(ROCMethod) ~= nil, ROCMethod .. " indicator must be installed");
	    Temp5= core.indicators:create(ROCMethod, Temp4.DATA, SIGNAL);

	 first = math.max(Temp1.DATA:first(),Temp2.DATA:first(),Temp3.DATA:first(),Temp5.DATA:first());
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), first , 200+i , 100+i);
	 loading[i] = true;  
	 
	  slowMA[i] = core.indicators:create(SlowMethod, SourceData[i][Price], SlowPeriod);
	  mediumMA[i] = core.indicators:create(MediumMethod, SourceData[i][Price], MediumPeriod);
	  fastMA[i] = core.indicators:create(FastMethod, SourceData[i][Price], FastPeriod);
	  
	  roc[i]= core.indicators:create("ROC", SourceData[i][Price], ROC); 
	  signal[i]= core.indicators:create(ROCMethod, roc[i].DATA, SIGNAL);
	  
	end
	
	   instance:ownerDrawn(true);
	instance:setLabelColor(Color);
	 
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
function Update(period)
    if period < source:first() or not source:hasData(period) then
	return;
	end
	
	
	
    local FLAG=false; 
	local Number=0;
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );
	  
	  

	 
end	
local init = false;


function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end

function Draw(stage, context)
    if stage ~=2 then
	return;
	end
    
        if not init then
		init=true;
		end
		


     Out[1]={"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"};
	  Out[2]={0,0,0,0,0,0,0,0};
	

	for i = 1, Count, 1 do			   
	   
				     slowMA[i]:update( core.UpdateLast ); 		
                    mediumMA[i]:update( core.UpdateLast );
                    fastMA[i]:update( core.UpdateLast );	
                    roc[i]:update( core.UpdateLast );
                    signal[i]:update( core.UpdateLast );						
				   Calculate(i );				  
					
	end
	
	
	
Sorted=BubbleSort(Out, 2, 2, 8);

 id=1;
  iDraw()


end



function iDraw()

local i;
local iCount=0;


	for i = 1, 8, 1 do
	 
		
		iCount=iCount+1;
	 	core.host:execute("drawLabel1", id, 200+(iCount-1)*100 ,  core.CR_LEFT, 40  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  Sorted[1][i]);	
      
			id = id+1;	
			
		
       local Data=Sorted[2][i];	
		 
		
				 
			
					 if Rainbow then					 
					core.host:execute("drawLabel1", id, 200+(iCount-1)*100 ,  core.CR_LEFT, 40+ Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold,  Coloring (( 100/8)*i, 50),  	string.format("%." .. 2 .. "f", Data)	);			  
					id = id+1;	
					else 
					core.host:execute("drawLabel1", id, 200+(iCount-1)*100 ,  core.CR_LEFT, 40+ Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, Color,  	string.format("%." .. 2 .. "f", Data)	);			  
					id = id+1;	
					 end
				end
		 
	 
		
end

function BubbleSort(Data, index,raw, columns)
 
 local new=Data;
 local j,k, temp;
 local Sort=true;
 
   

     while Sort do
    Sort=false;
   
            for j = 2, columns , 1 do
                  
                    if new[index][j] <  new[index][j-1] then
                     Sort=true;                  
                           
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
		
		
		
function Calculate(i  )
 
local  period =SourceData[i].close:size()-1;
  
 

if not slowMA[i].DATA:hasData(period)  
or not mediumMA[i].DATA:hasData(period)
or not fastMA[i].DATA:hasData(period)
or not roc[i].DATA:hasData(period)
or not signal[i].DATA:hasData(period)
 then
 return;
end

 
local j;
local crncy1, crncy2;

	 for j= 1, 8 , 1 do  
 

     
       
	
		 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
							--1			
							if fastMA[i].DATA[period] > mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] > slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] + 3;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] - 3;
								end
							
							end
							
							
							if fastMA[i].DATA[period] < mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] < slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] - 3;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] + 3;
								end
							
							end
							
							--2
							if fastMA[i].DATA[period] < mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] > slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] + 2;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] - 1;
								end
							
							end
							
							
							if fastMA[i].DATA[period] > mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] < slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] - 1;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] + 2;
								end
							
							end
							
							
					
							
							if roc[i].DATA[period] > signal[i].DATA[period] 	
							and signal[i].DATA[period] > 0	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] + 3;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] - 3;
								end
							
							end
							
						
						   if roc[i].DATA[period]< signal[i].DATA[period] 	
							and signal[i].DATA[period] < 0	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] - 3;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] + 3;
								end
							
							end
							
							
					
							
							if roc[i].DATA[period] < signal[i].DATA[period] 	
							and signal[i].DATA[period] > 0	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] + 2;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] - 1;
								end
							
							end
							
						
						   if roc[i].DATA[period]>signal[i].DATA[period] 	
							and signal[i].DATA[period] < 0	
							then
								if crncy1 == Pair[j] then
								Out[2][j] = Out[2][j] - 1;
								elseif crncy2 == Pair[j] then
								Out[2][j] = Out[2][j] + 2;
								end
							
							end							
				 
	    end		
		
		
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
    local FLAG=false; 
	local Number=0;
   
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+i then
			  loading[i] = false; 			  
			  end
		  
	end    
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );
    else
	 core.host:execute ("setStatus",    "Loaded" );	            
	 instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end
 