-- Id: 4168
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=2717

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


function AddMvaParam(id, FRAME)
   
    indicator.parameters:addGroup(id ..". Line Calculation");
    indicator.parameters:addInteger("N"..id, "MA Periods", "", 14);
    indicator.parameters:addString("MA"..id, "MA Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA"..id, "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA"..id, "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA"..id, "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA"..id, "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA"..id, "Wilders*", "", "WMA");
	indicator.parameters:addStringAlternative("MA"..id, "VAMA (VWAP)", "", "VAMA");
    indicator.parameters:addString("B"..id, "MA Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
    indicator.parameters:addString("S"..id, "Price", "", "close");
    indicator.parameters:addStringAlternative("S"..id, "open", "", "open");
    indicator.parameters:addStringAlternative("S"..id, "high", "", "high");
    indicator.parameters:addStringAlternative("S"..id, "low", "", "low");
    indicator.parameters:addStringAlternative("S"..id, "close", "", "close");
    indicator.parameters:addStringAlternative("S"..id, "median", "", "median");
    indicator.parameters:addStringAlternative("S"..id, "typical", "", "typical");
    indicator.parameters:addStringAlternative("S"..id, "weighted", "", "weighted");
end

function Init()
    indicator:name("Heat_Map_Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("1.  Line" );
    AddMvaParam(1, "H1");
	indicator.parameters:addGroup("2.  Line" );
    AddMvaParam(2, "H2");
	indicator.parameters:addGroup("3. Line" );
    AddMvaParam(3, "H4");
	indicator.parameters:addGroup("4.  Line" );
    AddMvaParam(4, "H6");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up color Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Down color Down", "", core.rgb(255, 0, 0));		
    indicator.parameters:addColor("NO", "Neutral color", "", core.rgb(128, 128, 128));	
	indicator.parameters:addColor("Color", "Label color", "", core.COLOR_LABEL);
	
	  indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",0, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",0, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
end

-- list of streams
local streams = {}
-- the indicator source
local source;
local day_offset, week_offset; 
local host; 
local Indicator={};
local PRICE={}; 
local loading={};
local Label = {"MA", "Price", "MA/Price"};
local Number=4; 
local UP,DN, NO,Color;

local VSpace, HSpace,Size;

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	Color=instance.parameters.Color;
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
	
    source = instance.source;
    host = core.host;
	


    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    CheckBarSize(1);
    CheckBarSize(2);
    CheckBarSize(3);
    CheckBarSize(4);

    local i;
	
	for i = 1, 4 , 1 do	
	assert (core.indicators:findIndicator(instance.parameters:getString ("MA"..i) )~= nil , "Please download " .. instance.parameters:getString ("MA"..i).. " from the FxCodeBase.com");
	end
	
  
   
   	for i = 1, 4 , 1 do	 
					
			PRICE[i] =   core.host:execute("getSyncHistory",  source:instrument(),   instance.parameters:getString ("B"..i), source:isBid(), math.min(300,instance.parameters:getInteger ("N"..i)), 2000 + i , 1000 +i);	
            
             if instance.parameters.MA ~= "VAMA" then
    assert(core.indicators:findIndicator(instance.parameters:getString ("MA"..i)) ~= nil, instance.parameters:getString ("MA"..i) .. " indicator must be installed");
			Indicator[i] = core.indicators:create(instance.parameters:getString ("MA"..i), PRICE[i][instance.parameters:getString ("S"..i)], instance.parameters:getInteger ("N"..i));
			else
			Indicator[i] = core.indicators:create(instance.parameters:getString ("MA"..i), PRICE[i], instance.parameters:getInteger ("N"..i));
			end			
	end
	
	
		instance:ownerDrawn(true);
	      core.host:execute ("setTimer", 1, 10);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function CheckBarSize(id)
    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(instance.parameters:getString("B" .. id), core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
end


function Update(period, mode)
 
   end         

function Draw(stage, context)


 
    if stage ~= 2 then
	return;
	end
  

   	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] 
				 then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
   
   
	
	 
            context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
            context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, UP)       
			context:createSolidBrush(12, UP);
			
			context:createPen (21, context.SOLID, 3, DN)       
			context:createSolidBrush(22, DN);
			
			context:createPen (31, context.SOLID, 3, NO)       
			context:createSolidBrush(32, NO);
			
		local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
		X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number*3+5)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				
				  
				 
				  
				 
				  
				   for k=1, 3, 1 do
				  
				 
				   
				   
				   C1,C2=Signal (i,j,k );
				  
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize + (j-1)*VCellSize*4 + (k-1)*VCellSize+VCellSize* VSpace , x2-HCellSize, context:top()+VCellSize + (j-1)*VCellSize*4+ (k)*VCellSize-VCellSize* VSpace);
				    
					
					if i== last  then
				    Text = j.. ". " .. Label[k];
				     context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 
					width, height = context:measureText (3,  Text , 0);	 
					 context:drawText(3, Text , Color, -1, X2 +(X2-X1),context:top()+VCellSize + (j-1)*VCellSize*4 + (k-1)*VCellSize+VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize + (j-1)*VCellSize*4 + (k-1)*VCellSize+VCellSize* VSpace+width, 0);
				    end
				   end
				   
				   
				  
				end
               end
  
		 
end
function Signal (i,j,k )



    local  p1=Initialization(i,j);
    local  p2=Initialization((i-1),j); 
	
	  if p1== -1  or p1== false
	  or  p2== -1  or p2== false
	  then
	   return 31,32;
	  end
	   
  
     if not Indicator[j].DATA:hasData(p1)
     or not Indicator[j].DATA:hasData(p2)  	
	 then 
	 return 31,32;
	 end
	 
	 local R1=31;
	 local R2=32;
			      
							if k== 1 then
							if Indicator[j].DATA[p1] >  Indicator[j].DATA[p2]  then
							 R1=11;R2=12;				
							elseif Indicator[j].DATA[p1] <  Indicator[j].DATA[p2]  then
							 R1=21;R2=22;	     				  
							end 
		                   end
							
							
							if k==2 then
							if PRICE[j].close[p1] >  PRICE[j].close[p2]  then
							 R1=11;R2=12;	  			
							elseif PRICE[j].close[p1] <  PRICE[j].close[p2]  then
							 R1=21;R2=22;	 				  
							end 
                            end
	 
								
							 if k== 3 then	
							if PRICE[j].close[p1] >  Indicator[j].DATA[p1]  then
							 R1=11;R2=12;	  	
							elseif PRICE[j].close[p1] <  Indicator[j].DATA[p1]  then
							 R1=21;R2=22;		  
							end 
                             end
			 
		return R1, R2;		
 
end
 
 
	-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
 
    for j = 1, Number, 1 do
 
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;         
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
   if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
		
    end
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or PRICE[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(PRICE[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	
 