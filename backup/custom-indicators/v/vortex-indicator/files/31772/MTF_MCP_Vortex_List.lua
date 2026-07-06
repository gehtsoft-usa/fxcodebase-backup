-- Id: 6455
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=277

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
    indicator:name("Multi Time Frame, Multi Currency Pairs Vortex List");
    indicator:description("Multi Time Frame, Multi Currency Pairs Vortex List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m30"  );
	Parameters (2 , "H1"  );
	Parameters (3 , "H4" );
	Parameters (4 , "H8"   );
	Parameters (5 , "D1"  );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". Time Frame Calculation");
	
     indicator.parameters:addInteger("N"..id, "Length of the vortex", "", 14);
	
	indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end


local font, Wingdings, Bold;
local Type={};
local  Size;
local source;
local Vortex={};
local loading={};
local Source={};
 
local stream;
local FRAME={};
local host;
local first;
local TEMP={};
 
local Count;
local Up, Down, No, LabelColor;
local N={};
local INSTRUMENT;
local Shift;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Shift=instance.parameters.Shift; 
    source = instance.source;
	first= source:first();
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    
	
	local i;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;

	
	for i = 1 , 5 , 1 do   
	   FRAME[i]=  instance.parameters:getString ("B"..i);
	    N[i]=instance.parameters:getInteger ("N"..i); 
	end	
	
		assert(core.indicators:findIndicator("VORTEX") ~= nil, "Please, download and install VORTEX.LUA indicator");   
	
 
	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
 
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	 INSTRUMENT, Count = getInstrumentList();
	 
	 	 
	local Id=0;
	for j = 1, Count, 1 do
	Source[j]={};
	Vortex[j]={};
	loading[j]={};
		for i = 1, 5 , 1 do	 
		
	      Id=Id+1;
			
 
			Source[j][i] = core.host:execute("getSyncHistory",  INSTRUMENT[j],  FRAME[i], source:isBid(),math.min(300,N[i]*2), 2000 + Id , 1000 +Id);	
			Vortex[j][i] = core.indicators:create("VORTEX", Source[j][i],N[i]);
			loading[j][i]=true;
			 
		end
	end
	
 
  

	
	 core.host:execute("setTimer", 1, 1);
end
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Count, 1 do
	  for i = 1, 5 , 1 do	 
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j][i]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j][i]  = false;
			  end
		 
		       
                 if loading[j][i] then
				 FLAG= true;
				 Num=Num+1;
				 end
		end		 
	end    
   
    
   if not FLAG and cookie== 1 then
		for j= 1, Count , 1 do
		 
		     for i = 1, 5 , 1 do	
			  Vortex[j][i]:update(core.UpdateLast );
			  end
		end
		
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*5) - Num) .. " / " .. (Count*5) );	 
	else
	core.host:execute ("setStatus", "Loaded");	 
    instance:updateFrom(0);    
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
	
	
end

function Update(period, mode)

 if period < source:size()-1 then
 return
 end
 
 
 

local FLAG=false; 
    for j = 1, Count, 1 do
	  for i = 1, 5 , 1 do	 		
		       
                 if loading[j][i] then
				 FLAG= true;				
				 end
		end		 
	end    

	if FLAG then
	return;
	end
	
	local i,j;
	local id =0;
	

  for i = 1, 5 , 1 do
  
  core.host:execute("drawLabel1", id,  5*Size*1.1+(i)*5*Size*1.1 ,  core.CR_LEFT, Size*3*1.1  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  FRAME[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 5*Size*1.1 ,  core.CR_LEFT, Size*4*1.1+(j-1)*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  INSTRUMENT[j]);			  
  id = id+1;	
				
	for i = 1, 5, 1  do

	 
				if Vortex[j][i].DATA:hasData(Vortex[j][i].DATA:size()-1) then					

				local Color =nil;			
				local Style = nil;				

                 if Vortex[j][i].VIP[Vortex[j][i].VIP:size()-1] >  Vortex[j][i].VIM[Vortex[j][i].VIM:size()-1] then
								
									
									Color = Up;
									Style= "\225";
				else
									
	                                  Color = Down;									
										Style= "\226";	
				
				 end 				
                
				
				if Style ~= nil then
				core.host:execute("drawLabel1", id, 5*Size*1.1+(i)*5*Size*1.1,  core.CR_LEFT, Size*4*1.1+(j-1)*Size*1.1 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,   Style );			  
		        id = id+1;
				end

				
				
				end
        end
    end
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

 