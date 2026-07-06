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
    indicator:name("Multi Time Frame Ichimoku Components" );
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
local indicator={};
local day_offset, week_offset;
local Size;
local Number=5;
local loading={};
local Source={};
local host;
local first;

local font1, font2;
local Position;
local X={};
local Y={};
local Z={};
local Order={};
local ID;
local Color={};

function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	  
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
		
	local i;
	
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
		
	 
	
	   font1 = core.host:execute("createFont", "Arial", 15, true, false);
       font2 = core.host:execute("createFont", "Wingdings", 15, false, false);
	 
end


function Update(period, mode)

   
	if    period<source:size() - 1 then	
	return;
	end
	
	
	core.host:execute ("removeAll");
	ID=0;
            
			
		 core.host:execute("drawLabel1", NewID(), -6*Size*5, core.CR_RIGHT,Position+Size+1*Size, core.CR_TOP, core.H_Left, core.V_Bottom,
                font1, Label, "TS vs KS");
		core.host:execute("drawLabel1", NewID(),-6*Size*5, core.CR_RIGHT,Position+Size+2*Size, core.CR_TOP, core.H_Left, core.V_Bottom,
                font1, Label, "SA vs SB (*)");
         core.host:execute("drawLabel1", NewID(), -6*Size*5, core.CR_RIGHT,Position+Size+3*Size, core.CR_TOP, core.H_Left, core.V_Bottom,
                font1, Label, "Price vs Cloud");
         core.host:execute("drawLabel1", NewID(), -6*Size*5, core.CR_RIGHT,Position+Size+4*Size, core.CR_TOP, core.H_Left, core.V_Bottom,
                font1, Label, "CS vs Cloud");
		 core.host:execute("drawLabel1", NewID(), -6*Size*5, core.CR_RIGHT,Position+Size+5*Size, core.CR_TOP, core.H_Left, core.V_Bottom,
                font1, Label, "CS vs Price");
				
	
			for i = 1, 5, 1  do
			indicator[i]:update(mode);
			Draw(i,period);	
	      end
end

function Draw(i,period)
              
			
			
			   
						
                 core.host:execute("drawLabel1", NewID(), -i*Size*5, core.CR_RIGHT,Position+Size, core.CR_TOP, core.H_Right, core.V_Bottom,
                font1, Label, instance.parameters:getString ("TF"..i));
				
		if  not indicator[i].SL:hasData(indicator[i].SL:size()-1)
		or not  indicator[i].CS:hasData(indicator[i].CS:size()-1) 
		or not  indicator[i].SA:hasData(indicator[i].SA:size()-1) 
		then	
		return;
		end
      
     local  period =  Initialization(period,i);
    
     if period== false then
     return;
     end	 
				
				
				
						
						if indicator[i].SL[indicator[i].SL:size()-1] > indicator[i].TL[indicator[i].TL:size()-1] then
						core.host:execute("drawLabel1", NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Up, "\225"  );	
						elseif  indicator[i].SL[indicator[i].SL:size()-1] < indicator[i].TL[indicator[i].TL:size()-1] then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Down, "\226"  );
						else						
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+1*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Neutral, "\223"  );
						end
						
						if indicator[i].SA[indicator[i].SA:size()-1] > indicator[i].SB[indicator[i].SB:size()-1] then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Up, "\225"  );	
						elseif  indicator[i].SA[indicator[i].SA:size()-1] < indicator[i].SB[indicator[i].SB:size()-1] then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Down, "\226"  );
						else						
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+2*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Neutral, "\223"  );
						end
						
						  
                        if Source[i].close[Source[i].close:size()-1] > math.max(indicator[i].SA[period], indicator[i].SB[period] )  then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+3*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Up, "\225"  );	
						elseif Source[i].close[Source[i].close:size()-1] < math.min(indicator[i].SA[period], indicator[i].SB[period] ) then
						core.host:execute("drawLabel1",  NewID(),-i*Size*5,core.CR_RIGHT, Position+Size+3*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Down, "\226"  );
						else						
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+3*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Neutral, "\223"  );
						end						
						
						if indicator[i].CS[indicator[i].CS:size()-1] > math.max(indicator[i].SA[indicator[i].CS:size()-1], indicator[i].SB[indicator[i].CS:size()-1] )  then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+4*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Up, "\225"  );	
						elseif indicator[i].CS[indicator[i].CS:size()-1] < math.min(indicator[i].SA[indicator[i].CS:size()-1], indicator[i].SB[indicator[i].CS:size()-1] ) then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+4*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Down, "\226"  );
						else						
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+4*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Neutral, "\223"  );
						end			

                       if indicator[i].CS[indicator[i].CS:size()-1] > Source[i].close[Source[i].close:size()-1]  then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+5*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Up, "\225"  );	
						elseif indicator[i].CS[indicator[i].CS:size()-1] < Source[i].close[Source[i].close:size()-1] then
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+5*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Down, "\226"  );
						else						
						core.host:execute("drawLabel1",  NewID(), -i*Size*5,core.CR_RIGHT, Position+Size+5*Size, core.CR_TOP, core.H_Right, core.V_Bottom,
						font2, Neutral, "\223"  );
						end					

end

function  NewID()
ID =ID+1;
return ID;
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
 