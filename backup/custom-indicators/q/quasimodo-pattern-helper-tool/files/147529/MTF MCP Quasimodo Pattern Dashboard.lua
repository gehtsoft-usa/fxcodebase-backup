-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72717 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters

function Init()
    indicator:name("MTF MCP Quasimodo Pattern Dashboard");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 
    indicator.parameters:addInteger("Frame", "Number of fractals)", "Number of fractals", 2, 1,99);
    indicator.parameters:addInteger("Sample", "Sample", "Sample", 100, 1,1000);	
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
	
    Parameters (1 , "m1", false  );	
	Parameters (2 , "m5", false   );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false   );	
	Parameters (5 , "H1", true  );
	Parameters (6 , "H2", false   );
	Parameters (7 , "H3", false   );	
	Parameters (8 , "H4", false   );
	Parameters (9 , "H6", false   );
	Parameters (10 , "H8", true  );	
	Parameters (11 , "D1", true  );
	Parameters (12 , "W1", true  );
   Parameters (13 , "M1", true  );	
   
   
   
   
    for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	 

	
	indicator.parameters:addGroup( "Style");
	indicator.parameters:addInteger("Size", "Size", "", 90);
    indicator.parameters:addColor("Color", "Label Color", "Label Color", core.COLOR_LABEL ); 
    indicator.parameters:addColor("TextColorUp", "Up Signal,", "Label Color", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("TextColorDown", "Down Signal,", "Label Color", core.rgb(255, 0, 0));	
 
	
	
end


 
function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
   
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end


 
function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;
local first;
local source = nil;
local Color, Up, Down,Neutral;
 

 
local Indicator={}; 

local Num;
local loading={};
local SourceData={};
local Point={};
local Pair={};
local Count;
local TF={};

local id;
local Dodaj={};
 
local Value={};
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    source = instance.source;
    first = source:first();
	Size=instance.parameters.Size;
	Color=instance.parameters.Color;
 
 
    Type= instance.parameters.Type;

	Num=0;	
	
	for i = 1 , 13 , 1 do   
	   
	   if  instance.parameters:getBoolean ("On"..i) then
	   	   	   
	   Num = Num+1;	   
	 
	   
	   TF[Num]=  instance.parameters:getString ("TF"..i); 	    
	   
	  end
	end	
	
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 end
				 
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;
	end
	
    assert(core.indicators:findIndicator("QUASIMODO PATTERN HELPER TOOL") ~= nil, "Please, download and install QUASIMODO PATTERN HELPER TOOL.LUA indicator");
	
	
	Id=0;
	local Test;
	
	for j = 1, Count, 1 do
	
		
	         SourceData[j] = {};
			 Value[j] = {}; 				 
             Indicator[j] = {};	
	         loading[j] = {};	
	   
		 for i = 1, Num, 1 do	
		 
		  
		 
		 	   Id=Id+1;			
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), 300 , 2000 +  Id , 1000 + Id);
			   loading[j][i] = true;  
			  
                Indicator[j][i] =core.indicators:create("QUASIMODO PATTERN HELPER TOOL", SourceData[j][i], instance.parameters.Frame, instance.parameters.Sample, true)
                   
            
		end
	end
    
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    
	
	 core.host:execute ("setTimer", 1, 1);
	 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    

 
 
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
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
	
	if cookie== 1 and  not FLAG then
		for j = 1, Count, 1 do
			 for i = 1, Num, 1 do	
					Indicator[j][i]:update(core.UpdateLast); 	
                    FindLast(j,i)		 					
			  end
		end    
	end
	
	if FLAG then	
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	
	 core.host:execute ("setStatus", "")	
    instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

function FindLast(j,i)
 
        if loading[j][i] then
		return;
		end
			
		local IndexOfLast= Indicator[j][i].Direction:size()-1
		
			      for k = Indicator[j][i].Direction:size()-1, 0, - 1 do
				   
				   
							if  Indicator[j][i].Direction[k] ==1  then
							 Value[j][i] =   IndexOfLast -  k +1 
							 break;  
							end
							
							if    Indicator[j][i].Direction[k] ==-1   then
							 Value[j][i] =  ( k-IndexOfLast ) -1 ;  
							  break; 
							end					
				 end
				
 
 	

end




local initDraw = false;

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
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
	return;
	end
	
	
	
	

	
	 core.host:execute ("setStatus", " Loaded ");
	 

	 
	  
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right();
    

    
    xGap=  (right-left)/(Num+1);	 
    yGap=  (bottom-top)/(Count+1);
	
	if yGap> (bottom-top)/5 then
    yGap= (bottom-top)/5 ;
    end
	
	iwidth = ((xGap/10)/100)*Size ;
	iheight=  (yGap/100)*Size;
		
		

           	
	
		context:createFont (7, "Arial",iwidth, iheight , 0); 
		
		
		
 
	 
		        for i = 1, Count, 1 do
						 for j = 1, Num, 1 do	

                         
                            y1=bottom -(i+1)*yGap;	
							x1=right -(j+1)*xGap;
							x2=right -(j )*xGap;
							
							
						 if j== Num then 
							width, height = context:measureText (7, Pair[i], context.CENTER  ); 
							context:drawText (7, Pair[i], Color, -1, x1, y1-height+yGap*2, x2, y1+yGap*2, context.CENTER, 0);
							end
							
							
						  
							if i== Count then 
							width, height = context:measureText (7, TF[j], 0); 
							context:drawText (7,  TF[j], Color, -1, x1+xGap  , y1-height+yGap ,x2+xGap ,  y1+yGap , context.CENTER   );	
							end				

		 
 
                              
                         
						 
					         if Value[i][j]~= nil then
								
								       Text= tostring(math.abs(Value[i][j])) 
									 
				 
										 if Value[i][j] > 0 then 
										 width, height = context:measureText (7, Text, 0);	
										 context:drawText (7, Text, instance.parameters.TextColorUp, -1, x1+xGap  , y1-height+yGap*2 ,x2+xGap ,  y1+yGap*2 , context.CENTER   );	
										  else
										  width, height = context:measureText (7, Text, 0);	
										 context:drawText (7, Text, instance.parameters.TextColorDown, -1, x1+xGap  , y1-height+yGap*2 ,x2+xGap ,  y1+yGap*2 , context.CENTER   );	
										 end 
								 end
						 	   
						   end
						 
					 
	 
                   
                 
				 
				 end
		 
	
 
	
end

 
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+
 