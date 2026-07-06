-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4127

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
    indicator:name("Multi Time Frame Ichimoku");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
  
	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	 
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Arrow Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	
end


function Parameters (id , FRAME )
    indicator.parameters:addGroup(id ..". Ichimoku Calculation");
  
    indicator.parameters:addInteger("X"..id, "Tenkan-sen period", "", 9, 1, 10000);
    indicator.parameters:addInteger("Y"..id, "Kijun-sen period", "", 26, 1, 10000);
    indicator.parameters:addInteger("Z"..id, "Senkou Span B period", "", 52, 1, 10000);   
	
    indicator.parameters:addString("TF"..id, "Ichimoku Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end

local Label;
local Up, Down, Neutral;
local source;
local day_offset, week_offset;
local Source={};
local host;
local first;

local font1, font2;
local Position;
local X={};
local Y={};
local Z={};
local Order={};
local indicator={};
local Color={};
local Size;
local Number=5;
local loading={};
function ReleaseInstance()
 core.host:execute("deleteFont", font1);
end

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	Size=instance.parameters.Size;
    Neutral=instance.parameters.Neutral;
    Label=instance.parameters.Label;
	Up=instance.parameters.Up;
    Down=instance.parameters.Down;
    Position=instance.parameters.Position;   
    
  
    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	font1 = core.host:execute("createFont", "Arial", Size, true, false);
		
	local i;	     
			
		for i = 1, Number , 1 do	
			X[i]=instance.parameters:getInteger ("X"..i);
			Y[i]=instance.parameters:getInteger ("Y"..i);
			Z[i]=instance.parameters:getInteger ("Z"..i);
			 
            Test = core.indicators:create("ICH", source, X[i], Y[i],  Z[i]);  
	        first=(Test.SA:first()*2)+1;		
			Source[i] = core.host:execute("getSyncHistory",source:instrument(), instance.parameters:getString ("TF"..i), source:isBid(), math.min(first,300), 200+i, 100+i);
		    indicator[i] = core.indicators:create("ICH", Source[i], X[i], Y[i],  Z[i]);
			loading[i]= true;
		end 
	 
end


function Update(period, mode)
 
	
	if   period < source:size() - 1 then	
	return;
	end
	
	
	core.host:execute ("removeAll")
	
            local Loop;
	
			for i = 1, 5, 1  do
		  
				indicator[i]:update(mode);
						
			
                      		
				SORT(i, period);		
			 
	       end
	 
end

function SORT(id, period)

  
  
    	if  not indicator[id].SL:hasData(indicator[id].SL:size()-1)
		or not  indicator[id].CS:hasData(indicator[id].CS:size()-1) 
		or not  indicator[id].SA:hasData(indicator[id].SA:size()-1) 
		then	
		return;
		end
      
     local  period =  Initialization(period,id);
    
     if period== false then
     return;
     end	 
	 
   
      local TS= indicator[id].SL[period];
	  local KS= indicator[id].TL[period]; 
       local SA= indicator[id].SA[period];
	  local SB= indicator[id].SB[period];
	  local PRICE=Source[id].close[period];
	  
	  if indicator[id].SL[period] > indicator[id].SL[period-1] then
	  Color["TS"] =Up;
	  elseif indicator[id].SL[period] < indicator[id].SL[period-1] then
	   Color["TS"] =Down;
	  else
	   Color["TS"] =Neutral;
	  end
	  
	   if indicator[id].TL[period] > indicator[id].TL[period-1] then
	  Color["KS"] =Up;
	  elseif indicator[id].TL[period] < indicator[id].TL[period-1] then
	   Color["KS"] =Down;
	  else
	   Color["KS"] =Neutral;
	  end
	  
	     if indicator[id].SA[period] > indicator[id].SA[period-1] then
	  Color["SA"] =Up;
	  elseif indicator[id].SA[period] < indicator[id].SA[period-1] then
	   Color["SA"] =Down;
	  else
	   Color["SA"] =Neutral;
	  end
	  
	  
	     if indicator[id].SB[period] > indicator[id].SB[period-1] then
	  Color["SB"] =Up;
	  elseif indicator[id].SB[period] < indicator[id].SB[period-1] then
	   Color["SB"] =Down;
	  else
	   Color["SB"] =Neutral;
	  end
	  
	    if Source[id].close[period] > Source[id].close[period-1] then
	  Color["PRICE"] =Up;
	  elseif Source[id].close[period] < Source[id].close[period-1] then
	   Color["PRICE"] =Down;
	  else
	   Color["PRICE"] =Neutral;
	  end
	  
    
      local TEMP={};
	  TEMP[1]=TS;
	  TEMP[2]=KS; 
	  TEMP[3]=SA;
	  TEMP[4]=SB;
	  TEMP[5]=PRICE;
	  
	 
	  
      table.sort(TEMP); 
	  
	  if TEMP[1] == TS then
	  Order[1]="TS";
	  elseif TEMP[1] == KS then
	   Order[1]="KS"; 
	  elseif TEMP[1] == SA then
	   Order[1]="SA";
	  elseif TEMP[1] == SB then
	   Order[1]="SB";
	   elseif TEMP[1] == PRICE then
	   Order[1]="PRICE";
	  end				
	 
	 
	   if TEMP[2] == TS then
	  Order[2]="TS";
	  elseif TEMP[2] == KS then
	   Order[2]="KS"; 
	  elseif TEMP[2] == SA then
	   Order[2]="SA";
	  elseif TEMP[2] == SB then
	   Order[2]="SB";
	  elseif TEMP[2] == PRICE then
	   Order[2]="PRICE"; 
	  end		
	
	   if TEMP[3] == TS then
	  Order[3]="TS";
	  elseif TEMP[3] == KS then
	   Order[3]="KS"; 
	  elseif TEMP[3] == SA then
	   Order[3]="SA";
	  elseif TEMP[3] == SB then
	   Order[3]="SB";
	  elseif TEMP[3] == PRICE then
	   Order[3]="PRICE"; 
	  end	
	
	  if TEMP[4] == TS then
	  Order[4]="TS";
	  elseif TEMP[4] == KS then
	   Order[4]="KS"; 
	  elseif TEMP[4] == SA then
	   Order[4]="SA";
	  elseif TEMP[4] == SB then
	   Order[4]="SB";
	   elseif TEMP[4] == PRICE then
	   Order[4]="PRICE";
	  end	
	  
	  if TEMP[5] == TS then
	  Order[5]="TS";
	  elseif TEMP[5] == KS then
	   Order[5]="KS"; 
	  elseif TEMP[5] == SA then
	   Order[5]="SA";
	  elseif TEMP[5] == SB then
	   Order[5]="SB";
	   elseif TEMP[5] == PRICE then
	   Order[5]="PRICE";
	  end	 

    
	
	             core.host:execute("drawLabel1", id, -id*Size*5, core.CR_RIGHT,Size +Position, core.CR_TOP, core.H_Right, core.V_Bottom,
                font1, Label, instance.parameters:getString ("TF"..id));
				
						for Loop = 5 , 1, -1 do
						
						core.host:execute("drawLabel1", Loop+id*5, -id*Size*5,core.CR_RIGHT, 2*Size +Position  +Loop*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font1, Color[Order[6-Loop]], Order[6-Loop]  );	
						
						
						end				
				
	      
end 




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
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

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
 