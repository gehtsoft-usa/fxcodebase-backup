
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59406

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
    indicator:name("MTF MCP Extreme TMA line Slope List");
    indicator:description("MTF MCP Extreme TMA line Slope List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1" , false );
	Parameters (2 , "m15" , false  );
	Parameters (3 , "m30" , false);
	Parameters (4 , "H1" , true  );
	Parameters (5 , "H2" , false );
	Parameters (6 , "H3" , false );
	Parameters (7 , "H4", false   );
	Parameters (8 , "H8", true );
	Parameters (9 , "D1" , true   );
	Parameters (10 , "W1", true   );	
	Parameters (11 , "M1", false   );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	 indicator.parameters:addBoolean("Inverse", "Inverse pair", "", false);	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , Flag )
    indicator.parameters:addGroup(id ..". Time Frame"); 
	
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", Flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	indicator.parameters:addInteger("TMA_Period"..id, "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period"..id, "ATR period", "", 100);  
    indicator.parameters:addDouble("TrendThreshold"..id, "TrendThreshold", "", 0.5);
    indicator.parameters:addBoolean("Redraw"..id, "Redraw", "", true);
		
	indicator.parameters:addString("Type"..id, "Indicaton Type", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Numeric", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Trend", "", "Trend");
		
end

local TMA_Period={};
local ATR_Period={};
local TrendThreshold={};
local Redraw={};

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

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
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
	  assert(core.indicators:findIndicator("EXTREME_TMA_SLOPE") ~= nil, "Please, download and install EXTREME_TMA_SLOPE.LUA indicator");	

	Num=0;
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	  
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Type[Num]=  instance.parameters:getString ("Type"..i);
	   
		TMA_Period[Num]=  instance.parameters:getInteger ("TMA_Period"..i);
		ATR_Period[Num]=  instance.parameters:getInteger ("ATR_Period"..i);
		TrendThreshold[Num]=  instance.parameters:getDouble("TrendThreshold"..i);
		Redraw[Num]=  instance.parameters:getBoolean ("Redraw"..i);
	 
	          		  
			   Test[Num] = core.indicators:create("EXTREME_TMA_SLOPE",source,  TMA_Period[Num], ATR_Period[Num], TrendThreshold[Num], Redraw[Num], No, Up, Down); 
			  
	           first[Num]= Test[Num]:getStream(0):first() ;	
	  
                
	
	  end
	end	
	
	
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	
	

	
	
     ID=0;
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};			
			 Indicator[j] = {};
			 
		 for i = 1, Num, 1 do	
		 
		       ID=ID+1;
		 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first[i]) , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			   
			   Indicator[j][i] =  core.indicators:create("EXTREME_TMA_SLOPE",SourceData[j][i],  TMA_Period[Num], ATR_Period[Num], TrendThreshold[Num], Redraw[Num]); 
			  

		end
	end
    
	
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local i,j;
	local id =1;
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
	return;
	end
	
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, 150+(i-1)*100 ,  core.CR_LEFT, 40  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 80 ,  core.CR_LEFT, 60+(j-1)*15+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
--close
				
				Indicator[j][i]:update(core.UpdateLast);
				
				
				if  Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1)  then					

						local Color =nil;			
						local Style = nil 
						local Font=nil;
						
						Style = Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1];			

						 if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] >  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then										
										
											Style= "\225";
						elseif Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] <  Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2] then
																			
												Style= "\226";	
												
						 else				
                                              Style= "\158";							 
											
                        end
                        if Type[i]~= "Trend" then
						Font= font;	
						Style= string.format("%." .. 5 .. "f", Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] );   
						else
						Font= Wingdings;						
                        end						
						
						
						Color=Indicator[j][i]:getStream(0):colorI(Indicator[j][i]:getStream(0):size()-1)
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, 150+(i-1)*100,  core.CR_LEFT, 60+(j-1)*15 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Font, Color,   Style );			  
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


  ID=0;
  
  
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
	local i,j; 
	 
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true; 
				 end
		 
         end  	
    end
	
	if not  FLAG then
	instance:updateFrom(0);
	end
   
 
end



