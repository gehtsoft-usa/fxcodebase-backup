-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2723

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


function Init()
    indicator:name("Multi Time Frame, Multi Currency Pairs ATR");
    indicator:description("Multi Time Frame, Multi Currency Pairs ATR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   
	
	 indicator.parameters:addBoolean("Lock", "Lock", "", false);
	 
	 indicator.parameters:addString("Type", "Lock Type", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Time Frame", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Instrument", "", "Instrument");
   
	
	Parameters (1 , "m30"  );
	Parameters (2 , "H1"  );
	Parameters (3 , "H4" );
	Parameters (4 , "H8"   );
	Parameters (5 , "D1"  );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". ATR Calculation");
    indicator.parameters:addInteger("N"..id, "ATR Periods", "", 14);
	
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
    indicator.parameters:addString("B"..id, "MA Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end

local font, Wingdings, Bold;
local Lock;
local Type;
local  Size;
local source;
 
local day_offset, week_offset;
local stream={};
local loading={};
local ATR={};

local host;
--local alive;
local first;
local INSTRUMENT={};
local Label={};
local FRAME={};
local  FrameLabel={};
local TEMP={};
local timer;
local Up, Down, No, LabelColor;

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

function Prepare(nameOnly) 
    Lock=instance.parameters.Lock;
	Type=instance.parameters.Type;
    source = instance.source;
	first= source:first();
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  profile:id()  ;
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	local i;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;

	
	for i = 1 , 5 , 1 do    
	
	   if instance.parameters:getString ("INSTRUMENT"..i) == "" then
	      INSTRUMENT[i]= source:instrument();
	  else
	  INSTRUMENT[i] = instance.parameters:getString ("INSTRUMENT"..i);
	  end
	
	   if Lock and  Type=="Instrument" then
	   INSTRUMENT[i] = INSTRUMENT[1];
	   else
	   INSTRUMENT[i] = INSTRUMENT[i];
	   end
	   
	    if Lock and  Type=="Instrument" and i ~= 1 then
	    Label[i]="";		  
		else
		 Label[i]=INSTRUMENT[i];
		end

        	
	  
	   FRAME[i]=  instance.parameters:getString ("B"..i);
	  
	  if Lock and  Type=="Frame" then
      FRAME[i]	= FRAME[1];		   
	  end
	  
	   if Lock and  Type=="Frame" and i ~= 1 then
	    FrameLabel[i]="";		  
		else
		 FrameLabel[i]=FRAME[i];
		end 	
	 
	  
       
	end	
	

	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
	
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
		local Id=0;
		
	for i= 1, 5, 1 do
	Id=Id+1;
	 stream[i]  = core.host:execute("getSyncHistory",  INSTRUMENT[i],  FRAME[i], source:isBid(), math.min(300, instance.parameters:getInteger ("N"..i)*2), 2000 + Id , 1000 +Id);	 	 
	loading[i]  = true;  
      ATR[i] = core.indicators:create("ATR", stream[i] ,  instance.parameters:getInteger ("N"..i)); 		
	 end
     
	
	 core.host:execute ("setTimer", 1, 1);
end

 



function Update(period, mode)

         if  period~= source:size() - 1 then	
		return;
		end
 

	 local FLAG=false; 
 
    for j = 1, 5, 1 do
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
 
   if FLAG then
   return;
   end
   
   
	local i;
	local id =0;
	
 		

	for i = 1, 5, 1  do

				--ATR[i]:update(mode);
				if ATR[i].DATA:hasData(ATR[i].DATA:size()-1)  and ATR[i].DATA:hasData(ATR[i].DATA:size()-2)then					

								
                    local Color =nil;			
					local Style = nil;	
						core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*7,  core.CR_RIGHT, Size*3  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,   "ATR "..tostring(round(ATR[i].DATA[ATR[i].DATA:size()-1], 4)));			  
		                           id = id+1;
								   
						core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*7,  core.CR_RIGHT, Size*2  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,   FrameLabel[i]);			  
		                           id = id+1;
                         core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*7,  core.CR_RIGHT, Size*1 , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,   Label[i]);			  
		                           id = id+1;								   
												
						           if ATR[i].DATA[ATR[i].DATA:size()-1] > ATR[i].DATA[ATR[i].DATA:size()-2] then
								
									
									Color = Up;
									Style= "\225";
					                elseif ATR[i].DATA[ATR[i].DATA:size()-1] < ATR[i].DATA[ATR[i].DATA:size()-2] then
									
	                                  Color = Down;									
										Style= "\226";	
						 			else
								
 									 	Color = No;
										Style= "\223";
								    end 		
									           if Style ~= nil then
												   core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*7,  core.CR_RIGHT, Size*4   , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,   Style );			  
		                                         id = id+1;
												end

				end
			end
		
 
	 
	  
 
end
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, 5, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;         
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
   if not FLAG and cookie== 1 then
		for i= 1, 5 , 1 do
			   ATR[i]:update(core.UpdateLast );
		end
		
		
   end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((5) - Num) .. " / " .. (5) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end


function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

