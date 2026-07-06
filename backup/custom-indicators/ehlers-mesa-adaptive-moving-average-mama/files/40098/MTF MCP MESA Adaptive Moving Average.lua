-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=23283


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
    indicator:name("MTF MCP MESA Adaptive Moving Average");
    indicator:description("MTF MCP MESA Adaptive Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1" ,false );
	Parameters (2 , "m15",false   );
	Parameters (3 , "m30" ,false );
	Parameters (4 , "H1" ,true  );
	Parameters (5 , "H2" ,false );
	Parameters (6 , "H3",false   );
	Parameters (7 , "H4",false   );
	Parameters (8 , "H8",false   );
	Parameters (9 , "D1",true    );
	Parameters (10 , "W1",true   );	
	Parameters (11 , "M1",false    );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , OnOrOff)
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "",  OnOrOff);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	  indicator.parameters:addDouble("FastLimit"..id, "FastLimit", "FastLimit", 0.5, 0, 1);
    indicator.parameters:addDouble("SlowLimit"..id, "SlowLimit", "SlowLimit", 0.05, 0, 1); 
	
	
	
end
local Inverse;
local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test={};
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local SC={};
local Type={};
local Lock={};
local FastLimit={};
local SlowLimit={};
function ReleaseInstance()
         core.host:execute("deleteFont", font);
	     core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

function Prepare(nameOnly)     
	Shift=instance.parameters.Shift; 
	Inverse=instance.parameters.Inverse;
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	Num=0;
	
	assert(core.indicators:findIndicator("MAMA") ~= nil, "Please, download and install MAMA.LUA indicator");
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	  
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	    
	   SlowLimit[Num]=  instance.parameters:getDouble ("SlowLimit"..i);
	   FastLimit[Num]=  instance.parameters:getDouble ("FastLimit"..i);
	 
	          		  
			
	  
                 
	
	  end
	end	
	
	
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	
	

	
	
	local ID =0;	
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};			
			 Indicator[j] = {};
			 
		 for i = 1, Num, 1 do	
		       ID=ID+1;
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), 300 ,20000 + ID , 10000 + ID);
			   loading[j][i] = true;  
			  
			  Indicator[j][i] = core.indicators:create("MAMA", SourceData[j][i].close,FastLimit[i], SlowLimit[i]);

		end
	end
    
 
	 core.host:execute ("setTimer", 1, 1);
end




function Update(period, mode)

 


 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local i,j,k;
	local id =1;
	local X;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;				
				 end
		 
         end  	
    end
	
	if FLAG then 
	return;
	end
	
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, 150+(i-1)*Size*10 ,  core.CR_LEFT, 40  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 80 ,  core.CR_LEFT, 60+(j-1)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
--close
				
					local Color =No;			
						local Style = "\158" 
			
				
				
				if   Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1)
				and Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-1)
				and Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-2)
				and Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-2)
				then					

					
					 
						
					 
					     
                            if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] > Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] then
							Style= "\233";
							elseif Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] < Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] then
							Style =  "\234";
							else
							Style =  "\158";
							end			

                            if Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] > Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2] then
							Color=Up;
							elseif  Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-1] < Indicator[j][i]:getStream(1)[Indicator[j][i]:getStream(1):size()-2]  then
							Color = Down;
							else
							Color= No;
							end									
			
				 end		
						
					 				
						
						core.host:execute("drawLabel1", id, 150+(i-1)*Size*10,  core.CR_LEFT, 60+(j-1)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,   Style );			  
						id = id+1;
					 

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




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 local ID =0;	
 local i,j;
 
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		  
		     ID=ID+1;     
			  if cookie == ( 10000 +  ID) then
			  loading[j][i] = true;
		      elseif  cookie == (20000+ ID) then
			  loading[j][i] = false;   			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if 	not FLAG and cookie== 1 then
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
	Indicator[j][i]:update(core.UpdateLast);
	end
	end
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
	core.host:execute ("setStatus", "Loaded")
	  instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end




