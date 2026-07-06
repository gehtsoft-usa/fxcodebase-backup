
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31923

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



function Init()
    indicator:name("Multi Time Frame, Multi Currency Pair, RSI List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m5", true  );
	Parameters (2 , "m15", false   );
	Parameters (3 , "m30", false  );
	Parameters (4 , "H1", false    );
    Parameters (5 , "H8", false  );
	Parameters (6 , "D1", false   );
	Parameters (7 , "W1", false  );
	Parameters (8 , "M1", false    );
	
	indicator.parameters:addGroup("Common Parameters");		
	indicator.parameters:addString("Type", "Pip/Value", "", "PIP");
    indicator.parameters:addStringAlternative("Type", "Value", "", "VALUE");
    indicator.parameters:addStringAlternative("Type", "Pip", "", "PIP"); 
	indicator.parameters:addInteger("ArrowSize", "Font Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
   indicator.parameters:addInteger("N"..id, "Period", "", 14);
	
	
end

local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local  SIZE ;
local Type;

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
	
	
    Type=instance.parameters.Type;   
	Shift=instance.parameters.Shift; 
	Level=instance.parameters.Level;
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
  
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;
	
	
	
	for i = 1 , 8 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	    N[Num]=  instance.parameters:getInteger ("N"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   

	 
	 

	  
	
	  end
	end	
	
	 
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	 
	
	
		
	local ID=0;
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 Indicator[j] = {};	
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		      ID=ID+1;
		 
		 		Test = core.indicators:create("ATR", source ,N[i]);   
	            first= Test.DATA:first() ;	
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(2*first,300) , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("ATR", SourceData[j][i],N[i]);

             			  
			  
		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 1);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


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
 


  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*5+(i)*Size*5*1.1 ,  core.CR_LEFT, Size*1.1*3  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT,  Size*1.1*4+(j-1)*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

				
				--Indicator[j][i]:update(core.UpdateLast);
				
				
				if  Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-1) and Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-2) then					
                       
						local Color =nil;			
						local Style = nil 
						
						if Type == "PIP" then
						Style = Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1]/SIZE[j];	
						else
						Style = Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1];	
                        end		
						
               		   

						 if Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] >  Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2] then
										
											
											Color = Up;
										
						elseif Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] <  Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2] then
											
											  Color = Down;									
											
												
						 else				
                                           					 
											 Color = No;
						 end 				
						
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id,  Size*5+(i)*Size*5*1.1,  core.CR_LEFT,  Size*1.1*4+(j-1)*Size*1.1 +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,   string.format("%." .. 5 .. "f", Style) );			  
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

	local ID=0;
	local i,j;

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
	
	if not FLAG and cookie== 1 then
	
	         for j = 1, Count, 1 do  
	         for i = 1, Num, 1  do

				
				Indicator[j][i]:update(core.UpdateLast);
				
			end
            end			
				
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
	          core.host:execute ("setStatus", "  " );	 
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

