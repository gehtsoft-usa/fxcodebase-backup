-- More information about this indicator can be found at:
-- http://fxcodebase.com 
 
--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Average Daily Range List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "Period", 1);
	indicator.parameters:addDouble("Multiplier1", "1. Multiplier", "", 0.5);

	
	indicator.parameters:addInteger("Period2", "2. Period", "Period", 5);
	indicator.parameters:addDouble("Multiplier2", "2. Multiplier", "", 0.5);
	
	indicator.parameters:addInteger("Period3", "3. Period", "Period", 20);
	indicator.parameters:addDouble("Multiplier3", "3. Multiplier", "", 0.5);
	
	indicator.parameters:addInteger("Period4", "4. Period", "Period", 60);
	indicator.parameters:addDouble("Multiplier4", "4. Multiplier", "", 0.5);
	
	indicator.parameters:addString("TF",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("LabelSize", "Font Size (As % of Cell)", "", 80, 0, 100);
	indicator.parameters:addInteger("HSize", "Horizontal Output Size (As % of Screen)", "", 50, 0, 100);
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 50, 0 , 10000);
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;
local loading={};
local  List, Count, Size;
local TF;
local Label;
local SourceData={};
local Integer={};
local Shift, FSize;
local host;
local offset;
local weekoffset;
local SUM={};

local HSize;
local Cost;

local Bid, Ask;
local LabelText={  };
local CountX=5;
 

local Period={};
local Multiplier={};
local Indicator={};
-- Routine
function Prepare(nameOnly)
	
	 local name = profile:id() .. "(" ..  instance:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end
	
    TF = instance.parameters.TF;
	Shift = instance.parameters.Shift;
	FSize = instance.parameters.FSize;
	Label = instance.parameters.Label;
	LabelSize = instance.parameters.LabelSize;
	HSize = instance.parameters.HSize;    
    source = instance.source;
    first = source:first();
	
	local PeriodMax=0;
	for j= 1, 4, 1 do
	Period[j] = instance.parameters:getInteger ("Period"..j);
	Multiplier[j] = instance.parameters:getDouble ("Multiplier"..j);
	PeriodMax=math.max(PeriodMax,Period[j]  );
	LabelText[j]=tostring(Period[j]);
	end
	
	LabelText[5]="Average";
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	List, Count=getInstrumentList();
	CountY=Count;
	
	Size=getPointSize(); 
	Cost=getPipCost();
	Bid, Ask = getBidAskList()
	
	local i;
	
	assert(core.indicators:findIndicator("AVERAGE DAILY RANGE CHART TIME FRAME OSCILLATOR") ~= nil, "Please, download and install AVERAGE DAILY RANGE CHART TIME FRAME OSCILLATOR.LUA indicator");
	for i = 1, Count, 1 do
	SourceData[i] = core.host:execute("getSyncHistory", List[i], TF, true, math.min(300,PeriodMax*2), 200+i, 100+i);
	Indicator[i]={};
	loading[i]= true;
		for j=1, 4, 1 do
		Indicator[i][j] = core.indicators:create("AVERAGE DAILY RANGE CHART TIME FRAME OSCILLATOR", SourceData[i], Period[j], Multiplier[j]);
		end
	end

  
	
	 core.host:execute ("setTimer", 1, 1);
	
	instance:ownerDrawn(true);

   
end

 local init = false;
 local Average={};

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	

end
function Draw(stage, context)

   if stage  ~= 2 then
	return;
	end
	

         if not init then
		 transparency = context:convertTransparency(instance.parameters.transparency); 
		   init = true;
         end

	local i, j;
	
	local FLAG=false;
	
	for i = 1, Count, 1 do
	   if loading[i] then
	   FLAG= true;
	   end
	end
	
	
	  
	
	if FLAG   then	
	return;	
	end
	
 
	
		
        
			
			 
		  for i= 1, CountY,1 do   
		        for j= 1, CountX,1 do 
							 
					   DrawLabel (context,i, j); 
					   end
		     end
       
	
	
 

end

function DrawLabel(context,i, j)

	
	top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
   
    xGap= (( (right-left)/100)*HSize)/(CountX);	 
    yGap=  (bottom-(top+Shift))/(CountY+2);
	
	
       y1=top +(i)*yGap;  
	   x1=left +(j-1)*xGap; 
		
		iwidth = ((xGap/10)/100)*LabelSize ;
		iheight=  (yGap/100)*LabelSize;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
 
		
		 
		 
		if i== 1 then  
		    Text = LabelText[j]
			
			width, height = context:measureText (7, Text, context.CENTER  ); 
			context:drawText (7, Text, Label, -1, x1+xGap  , y1+Shift-height , x1+xGap+width, y1+Shift, context.CENTER, 0);
        end
		
 
		
		
		 if j== 1  then 
		width, height = context:measureText (7, List[i], context.CENTER  ); 
		context:drawText (7, List[i], Label, -1, x1  , y1+yGap+Shift-height , x1+width, y1+yGap+Shift, context.CENTER, 0);
		end 
 
 
        if   (Indicator[i][j] == nil or not Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-1)) and j~= 5 then
		return;
		end
		

		
		    if j<= 4 then
           	Text= string.format("%." .. 2 .. "f", Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1]);	
			else
			Text=string.format("%." .. 2 .. "f", 	SUM[i]); 
			end 
	 
			 
			-- Text=i.." - " .. j
			 width, height = context:measureText (7, Text, context.CENTER  ); 
			 context:drawText (7, Text, Label, -1, x1+xGap  , y1+yGap+Shift-height , x1+xGap+width, y1+yGap+Shift, context.CENTER, 0);
		 
		
 end
 
 
 

function Calculate(i)

local j;
local Num =0;
local Sum =0;
		 for j = SourceData[i].close:size()-1 - Period, SourceData[i].close:size()-1 , 1 do
		 
			if  SourceData[i].close:hasData(j) then
			Sum=Sum +  ( SourceData[i].high[j] -SourceData[i].low[j])
			Num = Num +1;
			end
			
		end
		
		return Sum / Num;

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


function getPointSize()
    local SIZE = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        SIZE[count] = row.PointSize;		
		
        row = enum:next();
    end

    return  SIZE;
end



function AsyncOperationFinished(cookie)

   local i;
   local ItIs=false;
   local Num=0;
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  Num=Num+1;
			  ItIs=true;
		      elseif  cookie == 200+i then
			  loading[i] = false;  
			  end
		  
	end    
	

	 
   if cookie== 1 and  not ItIs then
   
        for i = 1, Count, 1 do
			for j=1, 4, 1 do
			Indicator[i][j]:update(core.UpdateLast);
			end
	    end
		
		
       for i = 1, Count, 1 do
	     SUM[i]=0;
		for j = 1, Count, 1 do
		
		    if  Indicator[i][j] ~= nil and Indicator[i][j].DATA:hasData(Indicator[i][j].DATA:size()-1) then
	        SUM[i]=  SUM[i] + Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1];	 
			end
		end  
		
		  SUM[i]=SUM[i]/4;		
       end

       
	end
	
   
   if not ItIs then
   instance:updateFrom(0);
   core.host:execute ("setStatus", "");
   else
    core.host:execute ("setStatus", "  Loading "..((Count) - Num) .. " / " .. (Count) );	 
   end
   
  
   
        
     return core.ASYNC_REDRAW;
end


function getPipCost()
    local PipCost = {};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
		
        PipCost[count] = row.PipCost;		
		
        row = enum:next();
    end

    return  PipCost;
end

function getBidAskList()
    local BID = {};
   local ASK  = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        BID[count] = row.Bid;
      ASK[count] = row.Ask;
      
        row = enum:next();
    end

    return BID, ASK;
end
