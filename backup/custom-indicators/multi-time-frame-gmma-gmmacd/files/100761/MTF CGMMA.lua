-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62289

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


local Period ={3,5,8,10,12,15,30,35,40,45,50,60};

function Init()
    indicator:name("Customizable Guppy's Multiple Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	local i;
	
	indicator.parameters:addGroup("Time Frame Selector");
	indicator.parameters:addString("Short", "Short EMA Time frame", "", "H1");
    indicator.parameters:setFlag("Short", core.FLAG_PERIODS);
	
	indicator.parameters:addString("Long", "Long EMA Time frame", "", "H1");
    indicator.parameters:setFlag("Long", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Calculation");
	for i =1, 12, 1 do 	
		indicator.parameters:addInteger("Period"..i, i.. ". EMA Period", "", Period[i]);
	end

    indicator.parameters:addGroup("Style ");	
	for i =1, 12, 1 do 
    indicator.parameters:addInteger("widtd"..i, "Line ".. i.. ". Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line "..i..". Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
	end
	
	indicator.parameters:addColor("S_COLOR", "Color for the short EMA group", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("L_COLOR", "Color for the long EMA group", "", core.rgb(255, 0, 0));

end
local dayoffset, weekoffset;
local source = nil;
local Source={};
local EMAs = {};    -- an array of outputs
local Number=2;
local EMA={};
local loading={};
local Max={};
local TF={};
function CreateEMA(index, N,  color, name, width,style)
    local label;
    	-- line label
  
	label = "EMA" .. N;
    -- create the line
	
	if index<=6 then
	EMA[index]= core.indicators:create("EMA", Source[1].close , N );  
	else
	EMA[index]= core.indicators:create("EMA", Source[2].close , N );  
	end
	
    EMAs[index] = instance:addStream(label, core.Line, name .. label, label,
                                     color, source:first() );
									 
	EMAs[index]:setWidth(width);
	EMAs[index]:setStyle(style);								 
end


local Long, Short;
function Prepare(nameOnly)   
    source = instance.source;
    local name;
	
	TF[1]= instance.parameters.Short;
	TF[2]= instance.parameters.Long;
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	

    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	Max[1]=0;
	Max[2]=0;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF[1], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame for short group must be equal to or bigger than the chart time frame!");
	
	
	s2, e2 = core.getcandle(TF[2], 0, 0, 0);
    assert ((e1 - s1)<= (e2 - s2), "The chosen time frame for long group must be equal to or bigger than the chart time frame!");
	
	for i = 1 , 12, 1 do
		if i<=6 then
		Max[1]=math.max(Max[1],instance.parameters:getInteger("Period" .. i) );
		else
		Max[2]=math.max(Max[2],instance.parameters:getInteger("Period" .. i) );
		end
	end
	
	for i=1, Number,1 do 
		Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(300,Max[i]), 200+i, 100+i); 
		loading[i]=true;	  
    end
    CreateEMA(1, instance.parameters:getInteger("Period" .. 1), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 1),instance.parameters:getInteger("style" .. 1));
    CreateEMA(2, instance.parameters:getInteger("Period" .. 2), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 2),instance.parameters:getInteger("style" .. 2));
    CreateEMA(3, instance.parameters:getInteger("Period" .. 3), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 3),instance.parameters:getInteger("style" .. 3));
    CreateEMA(4, instance.parameters:getInteger("Period" .. 4), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 4 ),instance.parameters:getInteger("style" .. 4));
    CreateEMA(5, instance.parameters:getInteger("Period" .. 5), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 5 ),instance.parameters:getInteger("style" .. 5));
    CreateEMA(6, instance.parameters:getInteger("Period" .. 6), instance.parameters.S_COLOR, name,instance.parameters:getInteger("widtd" .. 6 ),instance.parameters:getInteger("style" .. 6));

    CreateEMA(7, instance.parameters:getInteger("Period" .. 7), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 7),instance.parameters:getInteger("style" .. 7));
    CreateEMA(8, instance.parameters:getInteger("Period" .. 8), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 8 ),instance.parameters:getInteger("style" .. 8));
    CreateEMA(9, instance.parameters:getInteger("Period" .. 9), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 9),instance.parameters:getInteger("style" .. 9));
    CreateEMA(10, instance.parameters:getInteger("Period" .. 10), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 10),instance.parameters:getInteger("style" .. 10));
    CreateEMA(11, instance.parameters:getInteger("Period" .. 11), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 11),instance.parameters:getInteger("style" .. 11));
    CreateEMA(12, instance.parameters:getInteger("Period" .. 12), instance.parameters.L_COLOR, name,instance.parameters:getInteger("widtd" .. 12 ),instance.parameters:getInteger("style" .. 12));
end

 
 

function Update(period,mode)
 
    local p;
	local Flag=false;
	
 	for i= 1, Number, 1 do 	  
		if loading[i] then		
		Flag=true;
		end
		 
	end
		
	
	if Flag   then
	return;
	end	
	
 
  
	 for i= 1 , 12 , 1 do
	 EMA[i]:update(mode);  
	 
	     if i<=6 then
		 p = Initialization(period,1);
		 else
		 p = Initialization(period,2);
		 end
	 
		 if p~= false and  p~= -1  and EMA[i].DATA:hasData(p) then
		 EMAs[i][period]= EMA[i].DATA[p];  
		 end
	 end
 
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source [id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  			  
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		
			  
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ");
		 instance:updateFrom(0);	
		end
		
   
        
		return core.ASYNC_REDRAW ;
end
 



