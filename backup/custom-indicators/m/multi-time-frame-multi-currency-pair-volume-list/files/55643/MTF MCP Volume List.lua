-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32684

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
    indicator:name("Multi Time Frame, Multi Currency Pair Volume List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	indicator.parameters:addGroup( "Time Frame Selector");
	Parameters (1 , "m1", true  );
	Parameters (2 , "m5", false  );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false  );
	Parameters (5 , "H1", true    );
	Parameters (6 , "H2", false    );
	Parameters (7 , "H3", false    );
	Parameters (8 , "H4", false    );
	Parameters (9 , "H6", false    );
    Parameters (10 , "H8", true  );
	Parameters (11 , "D1", true   );
	Parameters (12 , "W1", true  );
	Parameters (13 , "M1", true    );
	
	
	indicator.parameters:addGroup("Common Parameters");		
	 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    --indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show " .. FRAME, "", flag);	
	
	
end
 
local loading={};
local SourceData={};
--local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local RTF={"m1", "m5","m15", "m30", "H1","H2", "H3", "H4","H6", "H8", "D1","W1", "M1"};
local host;
local first;
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
 
 

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
 end  

function Prepare(nameOnly)   
   
	Shift=instance.parameters.Shift; 
 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
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
	-- getPointSize();    

	Num=0;
	
	
	
	for i = 1 , 13 , 1 do   
	
	   
	   
	   if (instance.parameters:getBoolean ("On"..i)) then  
	   
	   Num = Num+1;	  
       TF[Num]=  RTF[i];	   
	 	  
  


	  
	
	  end
	end	
	

	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	local    ID=0;	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do			 
		          ID=ID+1;
 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), 0 , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  			        			  
			  
		end
	end    	
	

	 
end



function Update(period, mode)




 if period < source:size()-1 then
 return
 end
 
	local i,j;
	local id =1;
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
	
	if FLAG then
	return;
	end
 
core.host:execute ("setStatus", "")

  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id,  Size*5+(i)* Size*5 ,  core.CR_LEFT, Size  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id,  Size*5 ,  core.CR_LEFT,  Size+(j)* Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

		
				
				if   SourceData[j][i].volume:hasData( SourceData[j][i].volume:size()-1) and SourceData[j][i].volume:hasData( SourceData[j][i].volume:size()-2) then					
                       
						local Color =nil;			
						local Style = nil 
						
						
						Style =SourceData[j][i].volume[SourceData[j][i].volume:size()-1];	
						
						
               		   

						 if  SourceData[j][i].volume[SourceData[j][i].volume:size()-1] > SourceData[j][i].volume[SourceData[j][i].volume:size()-2] then
										
											
											Color = Up;
										
						elseif  SourceData[j][i].volume[SourceData[j][i].volume:size()-1]<   SourceData[j][i].volume[SourceData[j][i].volume:size()-2]then
											
											  Color = Down;									
											
												
						 else				
                                           					 
											 Color = No;
						 end 				
						
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id,  Size*5+(i)* Size*5,  core.CR_LEFT,  Size+(j)* Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,   string.format("%." .. 0 .. "f", Style) );			  
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



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

	
	local i,j;
    local ID=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      ID=ID+1;
			  if cookie == (1000 + ID) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + ID) then
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
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
     core.host:execute ("setStatus", "  Loaded");	           
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end


