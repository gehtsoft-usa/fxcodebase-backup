 

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65209

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
    indicator:name("Multi Time Frame, Multi Currency Pair ZIG ZAG Dashboard");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Time Frame Selector");
	indicator.parameters:addBoolean("On".. 1 , "Show (m1) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 2 , "Show (m5) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 3 , "Show (m15) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 4 , "Show (m30) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 5 , "Show (H1) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 6 , "Show (H2) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 7 , "Show (H3) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 8 , "Show (H4) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 9 , "Show (H6)Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 10 , "Show (H8) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 11 , "Show (D1) Time Frame", "", true);	
	indicator.parameters:addBoolean("On".. 12 , "Show (W1) Time Frame", "", true);	
	indicator.parameters:addBoolean("On".. 13 , "Show (M1) Time Frame", "", true);	

	Parameters (1 , "m1", false  );
	Parameters (2 , "m5", false  );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false  );
	Parameters (5 , "H1", false    );
	Parameters (6 , "H2", false    );
	Parameters (7 , "H3", false    );
	Parameters (8 , "H4", false    );
	Parameters (9 , "H6", false    );
    Parameters (10 , "H8", false  );
	Parameters (11 , "D1", true   );
	Parameters (12 , "W1", true  );
	Parameters (13 , "M1", true    );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 8);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	
	indicator.parameters:addInteger("HShift", "Horizontal Shift", "", 0, 0 , 10000);
	
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
 
		
	 indicator.parameters:addInteger("Depth".. id, "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation".. id, "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep".. id, "Backstep", "The minimal amount of bars between maximums/minimums", 3);

 
	
end

local loading={};
local SourceData={};
 
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
 
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift,HShift;
local On={};
local Num;
local  SIZE ;
local Type;
local Price={}; 
local Id,id;

 local Indicator={}; 
 local Depth={};
 local Deviation={};
 local Backstep={};
 
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 
		 core.host:execute ("killTimer", 1);
 end  
 
function Prepare(nameOnly) 
    Type=instance.parameters.Type;   
	Shift=instance.parameters.Shift; 
	HShift=instance.parameters.HShift;
	Level=instance.parameters.Level;
	 
	 
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
	 getPointSize();    

	Num=0;
	
	
	
	
	for i = 1 , 13 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	    
		
		 Depth[Num]= instance.parameters:getInteger("Depth" .. i);
		 Deviation[Num]= instance.parameters:getInteger("Deviation" .. i);
		 Backstep[Num]= instance.parameters:getInteger("Backstep" .. i);
	   
	 
	
	  end
	end	
	
	
		
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
 
 

 
Id=0;	
local first;

	for j = 1, Count, 1 do
	
	
	
	         SourceData[j] = {};
			 Indicator[j] = {};
			 
			 
             loading[j] = {};	
			 
 
	   
	   
		 for i = 1, Num, 1 do	
		    
          
	         
		       Id = Id+1;
			   
			   
		
			  
		 				 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(),300, 2000 +Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			 
			    Indicator[j][i]= core.indicators:create("ZIGZAG", SourceData[j][i],   Depth[i], Deviation[i],Backstep[i], Up, Down);   
                 
			   
			    
			  
			  
		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 10);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1 then
 return
 end
 
	local i,j;
	 id =1;
	local FLAG=false; 
	local Number=0;
	local font;
 	
	
	

	
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
 
  

  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, HShift+Size*5+(i)*Size*5 ,  core.CR_LEFT, Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, HShift+Size*5 ,  core.CR_LEFT, Size*2+(j)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	           for i = 1, Num, 1  do

				
			  
			   Logic(j,i )
			
				end
        end
    
end

function Logic (j,i )


   
						local Color =nil;			
						local Style = nil 
						
					 
						
                        font = Font;
						
               		  
					    
						
						            local Signal= FindLast(j,i); 

									 if Signal == 1 then
													
														
														Color = Up;
														
												 
													 font = Wingdings;
													 Style= "\225";
													 
														
													
									elseif  Signal == -1  then
														
														  Color = Down;	

													
													 font = Wingdings;
													 Style= "\226";
																					  
														
															
									 else				
																		 
														 Color = No;
													 
													 font = Wingdings;
													 Style= "\167";
															
									 end 		
					 
						 

						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, HShift+Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
						id = id+1;
						end
                
				 

end

function FindLast(j,i) 
   
   local Return=0;
   
   for  p=  Indicator[j][i].DATA:size()-1, Indicator[j][i].DATA:first(), -1   do
   
   
       if Indicator[j][i].DATA:hasData(p)  and  Indicator[j][i].DATA:color(p) == Up  then
	   Return=1;
	   break;
	   end
	   
	   
	   if  Indicator[j][i].DATA:hasData(p)  and  Indicator[j][i].DATA:color(p) == Down then
       Return=-1;
	   break;
	   end
	   
   end
 
  return Return;
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
    Id=0;
	
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
	          Id=Id+1;	 
		 
			  if cookie == (1000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + Id) then
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
	
	
	
	  if not FLAG and cookie==1 then
  
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		  
		   Indicator [j][i]:update(core.UpdateAll);	
		  
         end
   end 
  end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

function getPointSize()
    SIZE = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        SIZE[count] = row.PointSize;      
      
        row = enum:next();
    end

end

