
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59338

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
    indicator:name("MTF MCP Change");
    indicator:description("MTF MCP Change");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1" , "MVA", false );
	Parameters (2 , "m15", "MVA" , false  );
	Parameters (3 , "m30", "MVA", false  );
	Parameters (4 , "H1" , "MVA", true   );
	Parameters (5 , "H2", "MVA", false   );
	Parameters (6 , "H3" , "MVA", false  );
	Parameters (7 , "H4", "MVA", false   );
	Parameters (8 , "H8", "MVA" , false );
	Parameters (9 , "D1" , "MVA", true   );
	Parameters (10 , "W1", "MVA" , true  );	
	Parameters (11 , "M1", "MVA", true  );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, Method ,ItIs)
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", ItIs);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	indicator.parameters:addInteger("Period"..id, "Period",  "", 1, 1, 1000);
	indicator.parameters:addInteger("APeriod"..id, "Average Period",  "", 14, 1, 1000);

	
	indicator.parameters:addString("Type"..id, "Absolute/Relativ", "", "Absolute");
    indicator.parameters:addStringAlternative("Type"..id, "Absolute", "", "Absolute");
    indicator.parameters:addStringAlternative("Type"..id, "Relativ", "", "Relativ");
	indicator.parameters:addStringAlternative("Type"..id, "ATR", "", "ATR");
	indicator.parameters:addStringAlternative("Type"..id, "Standard Deviation", "", "Standard Deviation");
	indicator.parameters:addStringAlternative("Type"..id, "Average Candle", "", "Average");
	  
	
	
	
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
local Period={};
local APeriod={};
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
	Num=0;
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	  
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Type[Num]=  instance.parameters:getString ("Type"..i);
	   Period[Num]=  instance.parameters:getInteger ("Period"..i);
	   APeriod[Num]=  instance.parameters:getInteger ("APeriod"..i);

			   first[Num]= Period[Num] +APeriod[Num];
	  
 
	
	  end
	end	
	

		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	
	

	local ID=0;
	
		
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};			
			 Indicator[j] = {};
			 
		 for i = 1, Num, 1 do	
		  
		       ID=ID+1;
		 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first[i]*2,300) ,20000 + ID , 10000 + ID);
			   loading[j][i] = true;  
			  
			  Indicator[j][i] = core.indicators:create("ATR", SourceData[j][i],Period[i]);

		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 1);
	 
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
  
  core.host:execute("drawLabel1", id, Size*5+(i)*Size*5 ,  core.CR_LEFT, Size*3 *1.1 +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, Size*4 *1.1+(j-1 )*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
--close
			
				
				
				if   SourceData[j][i].close:hasData(SourceData[j][i].close:size()-1) and SourceData[j][i].close:hasData(SourceData[j][i].close:size()-1- Period[i]) 
				and Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-1)
				then					

						local Color =nil;			
						local Style = nil 
						local Font=nil;
						
						local C = SourceData[j][i].close[SourceData[j][i].close:size()-1] -SourceData[j][i].close[SourceData[j][i].close:size()-1- Period[i]];			

					
                       if Type[i]== "Absolute" then				
                           if C > 0 then
							Color=Up;
							elseif C < 0 then
							Color = Down;
							else
							Color= No;
							end					   
					   Style= string.format("%." .. 4 .. "f", C );
					   
					   elseif Type[i]== "Relativ" then	
					   
					    X=C/(SourceData[j][i].close[SourceData[j][i].close:size()-1- Period[i]]/100)
					   
					       if X > 0 then
							Color=Up;
							elseif X < 0 then
							Color = Down;
							else
							Color= No;
							end
							
					   Style= string.format("%." .. 2 .. "f", X );
					   
					   elseif Type[i]== "ATR" then
					   
					     X=C/Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1];
					   
					       if X > 0 then
							Color=Up;
							elseif X < 0 then
							Color = Down;
							else
							Color= No;
							end
							
					   Style= string.format("%." .. 2 .. "f", X );	

                       elseif Type[i]== "Average" then
					   
					    local Sum=0;
					   
					     for k= Indicator[j][i].DATA:size()-1- APeriod[i]+1, Indicator[j][i].DATA:size()-1, 1 do
						 Sum= Sum +SourceData[j][i].close[k] -SourceData[j][i].close[k- Period[i]];
						 end
						 
					     X=Sum/APeriod[i];
					   
					        if X > 0 then
							Color=Up;
							elseif X < 0 then
							Color = Down;
							else
							Color= No;
							end
							
					   Style= string.format("%." .. 4 .. "f", X );		 					   
					   else
					   
					   X=C/mathex.stdev (SourceData[j][i].close, SourceData[j][i].close:size()-1- Period[i], SourceData[j][i].close:size()-1);
					   
					       if X > 0 then
							Color=Up;
							elseif X < 0 then
							Color = Down;
							else
							Color= No;
							end
							
					   Style= string.format("%." .. 2 .. "f", X );	
					   
					   
					   end
 
                       Font= font;							  
					--	Font= Wingdings;						
                       					
						
						
						
						if Style ~= nil then					
						
						core.host:execute("drawLabel1", id, Size*5+(i )*Size*5,  core.CR_LEFT, Size*3 *1.1+(j)*Size*1.1 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Font, Color,   Style );			  
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
			  if cookie == ( 10000 + ID) then
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
	
	if not FLAG and  cookie== 1 then 
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
				Indicator[j][i]:update(core.UpdateLast);
		 end
    end		 
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	else
	core.host:execute ("setStatus", "Loaded");	           
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end




