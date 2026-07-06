-- Id: 2533
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2717

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
function Init()
    indicator:name("Multi Time Frame Overview Oscillator");
    indicator:description("Multi Time Frame Overview Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
	
	Parameters (1 , "m5" );
	Parameters (2 , "H1" );
	Parameters (3 , "H4" );
	Parameters (4 , "D1" );
 
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90);
	indicator.parameters:addDouble("HSize", "Horizontal indicator size as % of screen", "", 50, 50, 100);
	
	indicator.parameters:addInteger("VShift", "Vertical Shift", "", 0);
	
	
end



function Parameters (id , FRAME )

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

 
 
local source;
local MA={};
local OUT={};
local day_offset, week_offset;
 
local stream={};
local loading={};
local host;
local first;
 

local Number=4;


local UP, DN, NO;
local Label;
local Size;
local HSize;
local VShift;

local LabelText={"MA", "Price", "MA/Price"}
	
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

     
 

    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

	 UP=instance.parameters.UP;
	 DN=instance.parameters.DN;
	 NO=instance.parameters.NO;
	 Label=instance.parameters.Label;
	 Size=instance.parameters.Size;
	 HSize=instance.parameters.HSize;
	 VShift=instance.parameters.VShift;
 
    
		for i = 1, 4 , 1 do	 
		
		    assert (core.indicators:findIndicator(instance.parameters:getString ("MA"..i) )~= nil , "Please download " .. instance.parameters:getString ("MA"..i).. " from the FxCodeBase.com");
					
			stream[i] =    core.host:execute("getSyncHistory",  source:instrument(),   instance.parameters:getString ("B"..i), source:isBid(), math.min(300,instance.parameters:getInteger ("N"..i)), 2000 + i , 1000 +i);	
            loading[i]=true;			
			 
			assert(core.indicators:findIndicator(instance.parameters:getString ("MA"..i)) ~= nil, instance.parameters:getString ("MA"..i) .. " indicator must be installed");
			if instance.parameters.MA ~= "VAMA" then
    		MA[i] = core.indicators:create(instance.parameters:getString ("MA"..i), stream[i][instance.parameters:getString ("S"..i)], instance.parameters:getInteger ("N"..i));
			else
			MA[i] = core.indicators:create(instance.parameters:getString ("MA"..i), stream[i], instance.parameters:getInteger ("N"..i));
			end
		end
 

		instance:ownerDrawn(true);
	      core.host:execute ("setTimer", 1, 1);
end





function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

function Update(period)

		    
 end

 
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true; 
		end	 
 
	end    
	
	
	
     	if Flag then
		return;
		end
		
		for j = 1, 3, 1 do 
		for i = 1, Number, 1 do 	
		Add(context, i,j );
		end
		end       		 
 
		
end

function Add(context, i,j )

        if not  MA[i].DATA:hasData(MA[i].DATA:size()-1) then
		return;
		end
		
		
		local Symbol="\149";
      
	    local xCell =( (context:right () -context:left ())/100 )* (HSize/Number);		
        local yCell = (context:bottom () -context:top ())/6;	

		 context:createFont (2, "Arial", (xCell/10)*(Size/100), yCell*(Size/100), 0);	
        context:createFont (1, "Wingdings", (xCell/10)*(Size/100)*2, yCell*(Size/100), 0);	
	  
		

			local Color;
			
			
			if j == 1 then
					if MA[i].DATA[ MA[i].DATA:size()-1] >	 MA[i].DATA[ MA[i].DATA:size()-2] then
					Color=UP;
					Symbol="\217";
					elseif MA[i].DATA[ MA[i].DATA:size()-1]<	 MA[i].DATA[ MA[i].DATA:size()-2] then
					Color=DN;
					Symbol="\218";
					else
					Symbol="\160";
					Color=NO;
					end			
					 
		     elseif j == 2 then
			
			        if stream[i].close[ stream[i].close:size()-1] >	 stream[i].close[ stream[i].close:size()-2] then
					Color=UP;
					Symbol="\217";
					elseif stream[i].close[ stream[i].close:size()-1]<	stream[i].close[ stream[i].close:size()-2] then
					Color=DN;
					Symbol="\218";
					else
					Symbol="\160";
					Color=NO;
					end		 
			
			
			else
			       if  stream[i].close[ stream[i].close:size()-1] >	 MA[i].DATA[ MA[i].DATA:size()-1] then
					Color=UP;
					Symbol="\217";
					elseif  stream[i].close[ stream[i].close:size()-1] <	MA[i].DATA[ MA[i].DATA:size()-1] then
					Color=DN;
					Symbol="\218";
					else
					Symbol="\160";
					Color=NO;
					end		
			
			end
			
	         
           
			 width, height = context:measureText (1, tostring(Symbol), 0)			
			 context:drawText (1,  tostring(Symbol), Color, -1, context:right ()-(i)*xCell    , context:top ()+ VShift+yCell*(j+1), context:right ()-(i-1)*xCell + width, context:top ()+ VShift+yCell*(j+1) + height, 0);
			 
			 
		     if j== 1 then
			  width, height = context:measureText (2, tostring( instance.parameters:getString ("B"..i)), 0)				
		    context:drawText (2, tostring( instance.parameters:getString ("B"..i)), Label, -1, context:right ()-(i)*xCell    , context:top ()+VShift+yCell, context:right ()-(i-1)*xCell + width, context:top ()+VShift+yCell + height, 0);
	        end
			
			 if i== 4 then
			width, height = context:measureText (2, LabelText[j], 0)	
	         context:drawText (2,  LabelText[j],Label, -1, context:right ()-(i+0.5)*xCell-width    , context:top ()+ VShift+yCell*(j+1),  context:right ()-(i+0.5)*xCell, context:top ()+ VShift+yCell*(j+1) + height,0);
			 end
			 
			
end


	
function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or stream[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(stream[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
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
			  MA[i]:update(core.UpdateLast );
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