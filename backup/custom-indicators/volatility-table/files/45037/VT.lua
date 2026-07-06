-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26238
-- Id: 7906

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility Table");
    indicator:description("Volatility Table");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addString("TF",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addInteger("NOL", "Lot Number", "", 1);
	
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
local Period;

local first;
local source = nil;
local loading={};
local  List, Count, Size;
local TF;
local Label;
local SourceData={};
local Shift, FSize;
local host;
local offset;
local weekoffset;
local SUM={};

local HSize;
local Cost;
local NOL;
local Bid, Ask;
local LabelText={ "Pair","$", "PIP",  "%", "Value"};
local CountX=5;
local CountY;  

-- Routine
function Prepare(nameOnly)
    TF = instance.parameters.TF;
	NOL = instance.parameters.NOL;
	Shift = instance.parameters.Shift;
	FSize = instance.parameters.FSize;
	Label = instance.parameters.Label;
	LabelSize = instance.parameters.LabelSize;
	HSize = instance.parameters.HSize;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	List, Count=getInstrumentList();
	CountY=Count+1;
	
	Size=getPointSize(); 
	Cost=getPipCost();
	Bid, Ask = getBidAskList()
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local i;
	for i = 1, Count, 1 do
		SourceData[i] = core.host:execute("getSyncHistory", List[i], TF, source:isBid(), math.min(300,Period*2), 200+i, 100+i);
		loading[i]= true;
		end
	 core.host:execute ("setTimer", 1, 1);
	
	instance:ownerDrawn(true);

   
end

 local init = false;
 local SUM={};

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
	
 
	
		
        for j= 1, CountY,1 do   
			 for i= 1, CountX,1 do 
         			 
			 DrawLabel (context,i, j); 
			 end
         end
	
	
 

end

function DrawLabel(context,i, j)

	
	top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
   
    xGap= (( (right-left)/100)*HSize)/(CountX);	 
    yGap=  (bottom-top)/(CountY+2);
	
	
       y1=top +(j)*yGap; 
		
 
		
		x1=left +(i-1)*xGap;
		--x2=left +(j )*xGap; 
		
		
		iwidth = ((xGap/10)/100)*LabelSize ;
		iheight=  (yGap/100)*LabelSize;
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
 
		
		if j== 1 then 
		width, height = context:measureText (7, LabelText[i], context.CENTER  ); 
		context:drawText (7, LabelText[i], Label, -1, x1, y1+Shift-height , x1+width, y1+Shift, context.CENTER, 0);
		end
		
	 
		if j == 1 then
		return;
		end
		
		
		
		  if i== 1 then
		  Text= List[j-1]; 
		  elseif i== 2 then
		  Text = string.format("%." .. 4 .. "f", SUM[j-1]);	
		  elseif i== 3 then
		  Text = string.format("%." .. 2 .. "f", (SUM[j-1] / Size[j-1]));	
          elseif i== 4 then  		  
		  Text =string.format("%." .. 2 .. "f", (SUM[j-1]/ (Bid[j-1]/100)));	 
		  elseif i== 5 then
		  Text =string.format("%." .. 2 .. "f", (SUM[j-1]/ Size[j-1])*Cost[j-1]*NOL);	
		  end
		  
         width, height = context:measureText (7, Text, context.CENTER  ); 
		  context:drawText (7, Text, Label, -1, x1, y1+Shift-height , x1+width, y1+Shift, context.CENTER, 0);
	 
		
end--pair
 

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
		for j = 1, Count, 1 do
	        SUM[j]= Calculate(j);	 
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
