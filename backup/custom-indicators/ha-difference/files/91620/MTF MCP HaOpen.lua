-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60133

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

function AddCurrencyPair(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"				  
			  };
	
	if id < 5 then
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		  
	else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		  
	end
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end


function Init()
    indicator:name("Multi Time Frame, Multi Currency HaOpen");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

   	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" ,  "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");

	AddCurrencyPair (i );
	
	end
	
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

	Parameters (1 , "m1"   );
	Parameters (2 , "m5"  );
	Parameters (3 , "m15"   );
	Parameters (4 , "m30"   );
	Parameters (5 , "H1"     );
	Parameters (6 , "H2"     );
	Parameters (7 , "H3"     );
	Parameters (8 , "H4"     );
	Parameters (9 , "H6"    );
    Parameters (10 , "H8"  );
	Parameters (11 , "D1"   );
	Parameters (12 , "W1"   );
	Parameters (13 , "M1"    );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 25, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME  )
    indicator.parameters:addGroup(id ..". Time Frame");
	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
end
local Dodaj={};
local loading={};
local SourceData={};
local HAOPEN={};
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local  SIZE ;
local Type; 
local Id,id; 
local Use={};
  
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  
 
function Prepare(nameOnly)  
    Type=instance.parameters.Type;   
	Shift=instance.parameters.Shift; 
	Level=instance.parameters.Level; 
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
	
	
	Pair={};
	
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					  
					 end
				 
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count  = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			    
			   Count=1;
	end

	Num=0;
	
	
	
	
	for i = 1 , 13 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	    
         
	    end	
	end 

	
		
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
 assert(core.indicators:findIndicator("HAOPEN") ~= nil, "Please, download and install HAOPEN.LUA indicator");

for i = 1, Num, 1 do	
		first[i]=1; 
		 
		      Test = core.indicators:create("HAOPEN", source );   			  
	          first[i]= math.max (first[i], Test.DATA:first()+1 );	
			 
end	

 
Id=0;	
	for j = 1, Count, 1 do	
	
	         SourceData[j] = {};			  
			 HAOPEN[j] = {};
             loading[j] = {};
			 
		 for i = 1, Num, 1 do	
		       
              
	         
		       Id = Id+1;
		 				 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300, first[i]*2), 2000 +Id , 1000 + Id);
			   loading[j][i] = true;  
			  		 
			   HAOPEN[j][i] = core.indicators:create("HAOPEN", SourceData[j][i]   );
			  
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
  
  core.host:execute("drawLabel1", id, 100+Size*4+(i-1)*Size*5 ,  core.CR_LEFT,  Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 100 ,  core.CR_LEFT,  (j-1)*Size+Shift+Size  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	           for i = 1, Num, 1  do

				
			  
			   Logic(j,i, mode)
			
				end
        end
    
end

function Logic (j,i, mode)

				
				if  
				   loading[j][i]
				then				
				
				     	core.host:execute("drawLabel1", id, 100+Size*4+(i-1)*Size*5,  core.CR_LEFT,  (j-1)*Size +Shift+Size  , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				 
				
               	if not HAOPEN[j][i].open:hasData(HAOPEN[j][i].open:size()-1)	
                or not HAOPEN[j][i].close:hasData(HAOPEN[j][i].close:size()-1)				
				or (HAOPEN[j][i].close:size()-1)<= HAOPEN[j][i].close:first()+1
				or (HAOPEN[j][i].open:size()-1)<= HAOPEN[j][i].open:first()
                then
              return;
                end				
				
				if   HAOPEN[j][i].close[HAOPEN[j][i].close:size()-1]> HAOPEN[j][i].close[HAOPEN[j][i].close:size()-2] 
				then
				Close = 1;
				elseif    HAOPEN[j][i].close[HAOPEN[j][i].close:size()-1]< HAOPEN[j][i].close[HAOPEN[j][i].close:size()-2] 
				then
				Close = -1;
				else
				Close = 0;
				end 
				
				
				if   HAOPEN[j][i].close[HAOPEN[j][i].close:size()-1]> HAOPEN[j][i].open[HAOPEN[j][i].open:size()-1] 
				then
				Open = 1;
				elseif    HAOPEN[j][i].close[HAOPEN[j][i].close:size()-1]< HAOPEN[j][i].open[HAOPEN[j][i].open:size()-1] 
				then
				Open = -1;
				else
				Open = 0;
				end 
				
				
			 
						
                    --    font = Font;
						
               		   

						 if Close == 1 then										
											
										Color = Up;									 
										 font = Wingdings;
										 Style= "\225";		
										
						elseif Close == -1 then
											
											  Color = Down;	                                        
										 font = Wingdings;
										 Style= "\226";									 																		
						 else				
                                           					 
											 Color = No;
										 font = Wingdings;
										 Style= "\167";
						 end 		
						 
						  
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, 100+Size*4+(i-1)*Size*5,  core.CR_LEFT, (j-1)*Size +Shift+Size  , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
						id = id+1;
						end
						
						
						 if Open == 1 then										
											
										Color = Up;									 
										 font = Wingdings;
										 Style= "\225";		
										
						elseif Open == -1 then
											
											  Color = Down;	                                        
										 font = Wingdings;
										 Style= "\226";									 																		
						 else				
                                           					 
											 Color = No;
										 font = Wingdings;
										 Style= "\167";
						 end 		
						 
						  
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, 100+Size*4+(i-1)*Size*5+Size,  core.CR_LEFT,  (j-1)*Size +Shift+Size  , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
						id = id+1;
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
	
	if not FLAG and cookie== 1 then
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
	HAOPEN[j][i]:update(core.UpdateLast );
	end
	end
    end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	 else
	  core.host:execute ("setStatus", "  Loaded" );	 
	  instance:updateFrom(0);
	  
	end
   
        
    return core.ASYNC_REDRAW ;
end
 
