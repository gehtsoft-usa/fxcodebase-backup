
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61102

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
			 
			 
	if id< 6 then		 
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		  
	else
		indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
	end
	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end


function Init()
    indicator:name("Multi Time Frame, Multi Currency Stochastic RSI");
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
	
	indicator.parameters:addGroup("Draw Parameters");		 
	indicator.parameters:addInteger("Size", "Size", "", 90);
	indicator.parameters:addInteger("VShift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addInteger("HShift", "Horizontal Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME  )
    indicator.parameters:addGroup(id ..". Time Frame");
	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	
   
	 indicator.parameters:addGroup(id ..". Time Frame STOCHASTIC RSI");	
	indicator.parameters:addInteger("SR1"..id, "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("SR2"..id, "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("SR3"..id, "%K Slowing Periods", "", 5, 1, 200);
	indicator.parameters:addInteger("SR6"..id, "%D Slowing Stochastic Periods", "", 3, 1, 200);
 
	indicator.parameters:addDouble("SR4"..id, "OVER BOUGHT Level", "", 90);
    indicator.parameters:addDouble("SR5"..id, "OVER SOLD Level", "", 10);
 
 
	
end
local Dodaj={};
local loading={};
local SourceData={};
local DMI={};
local Pair;
--local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test;
local Count;
local Up, Down, No, Label;
local N={};
local VShift;
local HShift;
local On={};
local Num;
local  SIZE ;
local Type;
local Price={}; 
local Id,id;


local Use={};
local SR1={};
local SR2={};
local SR3={};
local SR4={};
local SR5={};
local SR6={};
local  STOCHASTIC_RSI={};

local K={};
local D={};
local OBOS={};



function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

function Prepare(nameOnly)
    Type=instance.parameters.Type;   
	VShift=instance.parameters.VShift;
	HShift=instance.parameters.HShift; 	
	Level=instance.parameters.Level; 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.Size;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	Label = instance.parameters.Label;
	
	
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
	   Price[Num]=  instance.parameters:getString ("Price"..i);
        
	    SR1[Num]=instance.parameters:getInteger ("SR1"..i);
	    SR2[Num]=instance.parameters:getInteger ("SR2"..i); 
	    SR3[Num]=instance.parameters:getInteger ("SR3"..i); 
		SR4[Num]=instance.parameters:getDouble ("SR4"..i); 
	    SR5[Num]=instance.parameters:getDouble ("SR5"..i); 
		SR6[Num]=instance.parameters:getInteger ("SR6"..i); 
		 
 
      name = name..", ("  .. SR1[Num] .. ",  "  .. SR2[Num] .. ",  "  ..SR3[Num].. ",  "  .. SR6[Num]  .. ")";    
      
	end	
	end 
	instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
 
 assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "Please, download and install STOCHRSI.LUA indicator");

for i = 1, Num, 1 do	
		first[i]=1; 
		 
		      Test = core.indicators:create("STOCHRSI", source[Price[i]] ,  SR1[i],  SR2[i], SR3[i], SR6[i]);   			  
	          first[i]= math.max (first[i], Test.D:first()+1 );	
			 
end	

 
Id=0;	
	for j = 1, Count, 1 do	
	
	         SourceData[j] = {};			  
			 STOCHASTIC_RSI[j] = {};
             loading[j] = {};
			 
			K[j]={};
			D[j]={};
			OBOS[j]={};
			 
		 for i = 1, Num, 1 do	
		       
              
	         
		       Id = Id+1;
		 				 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first[i]+1, 2000 +Id , 1000 + Id);
			   loading[j][i] = true;  
			  		 
			   STOCHASTIC_RSI[j][i] = core.indicators:create("STOCHRSI", SourceData[j][i][Price[i]] ,  SR1[i],  SR2[i], SR3[i], SR6[i]   );
			  
		end
	end    
	
	
	 core.host:execute("setTimer", 1, 1);
	 
	 instance:ownerDrawn(true);  
	 
end



local initDraw = false;

 function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end
	
	
     local FLAG=false; 
	
	
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
	
	
	 top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right();
    

    
    xGap= ( (right-left)/4)/(Num+1);	 
    yGap=  (bottom-top)/(Count+2);
	
	if  yGap >   (bottom-top)/4 then
	yGap =   (bottom-top)/4;
	end
	
	iwidth = ((xGap/10)/100)*Size ;
	iheight=  (yGap/100)*Size;
		
	top=top+ yGap/2;
	
	

           	
	
		context:createFont (7, "Arial",iwidth, iheight , 0);
        context:createFont (8, "Wingdings",xGap/3, xGap/3 , 0);
		
	
		for j = 1, Count, 1 do
		
		
						 x=left;
						 y=top+(j+1)*yGap;	
							   
							   
						width, height = context:measureText (7, Pair[j], context.CENTER  ); 
						context:drawText (7, Pair[j], Label, -1, x+HShift, y-height+VShift, x+HShift+width , y+VShift, context.CENTER, 0);
											
											
											
			 for i = 1, Num, 1 do	
			

			
						 
							 if j== 1 then
							  
											 x=left +(i+1)*xGap+(i-1)*(xGap/3);
											 y=top+(j)*yGap;	
							   
							   
												width, height = context:measureText (7, TF[i], context.CENTER  ); 
												context:drawText (7, TF[i], Label, -1, x+HShift, y-height+VShift, x+HShift+width , y+VShift, context.CENTER, 0);   
									  
							 end
							 
							 
							
							 
							  if K[j][i] == 1 then										
											
										Color = Up;		
										 Style= "\225";		
										
						     elseif K[j][i]  == -1 then
											
										 Color = Down;	 
										 Style= "\226";									 																		
						     else				
                                            					 
										 Color = No;
										 Style= "\167";
						     end 		
						 
							 
							              	 x=left +(i+1)*xGap+(i-1)*(xGap/3);
								             y=top+(j+1)*yGap;	
							   
							   
											width, height = context:measureText (8, Style, context.CENTER  ); 
											context:drawText (8, Style, Color, -1, x+HShift+(0)*(xGap/3), y-height+VShift, x+HShift+(0)*(xGap/3)+width , y+VShift, context.CENTER, 0);
											
											
							  if D[j][i] == 1 then										
											
										Color = Up;		
										 Style= "\225";		
										
						     elseif D[j][i]  == -1 then
											
										 Color = Down;	 
										 Style= "\226";									 																		
						     else				
                                            					 
										 Color = No;
										 Style= "\167";
						     end 		
						 
							 
							              	 x=left +(i+1)*xGap+(i-1)*(xGap/3);
								             y=top+(j+1)*yGap;	
							   
							   
											width, height = context:measureText (8, Style, context.CENTER  ); 
											context:drawText (8, Style, Color, -1, x+HShift+(1)*(xGap/3), y-height+VShift, x+HShift+(1)*(xGap/3)+width , y+VShift, context.CENTER, 0);	


                           				
							  if OBOS[j][i] == 1 then										
											
										Color = Up;		
										 Style= "\108";		
										
						     elseif OBOS[j][i]  == -1 then
											
										 Color = Down;	 
										 Style= "\108";									 																		
						     else				
                                            					 
										 Color = No;
										 Style= "\167";
						     end 		
						 
							 
							              	 x=left +(i+1)*xGap+(i-1)*(xGap/3); 
								             y=top+(j+1)*yGap;	
							   
							   
											width, height = context:measureText (8, Style, context.CENTER  ); 
											context:drawText (8, Style, Color, -1, x+HShift+(2)*(xGap/3), y-height+VShift, x+HShift+(2)*(xGap/3)+width , y+VShift, context.CENTER, 0);				
							 											
							 
			 
			 end
			 
			 
			 
		 
		 end
	
	
end



function Update(period, mode)

 
end

function Logic (j,i )

				
				if  
				   loading[j][i]
				then				
				
				     	core.host:execute("drawLabel1", id, 100+Size*4+(i-1)*Size*5 + HShift,  core.CR_LEFT, 60+(j-1)*Size + VShift , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				 
				STOCHASTIC_RSI[j][i]:update(core.UpdateLast );

               	if not STOCHASTIC_RSI[j][i].D:hasData(STOCHASTIC_RSI[j][i].D:size()-1)
				or not  STOCHASTIC_RSI[j][i].K:hasData(STOCHASTIC_RSI[j][i].K:size()-2)
				or not STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]
				or (STOCHASTIC_RSI[j][i].D:size()-1)<= STOCHASTIC_RSI[j][i].D:first()
                then
              return;
                end				
				
				if   STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]> STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-2] 
				then
				K[j][i] = 1;
				elseif    STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]< STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-2] 
				then
				K[j][i] = -1;
				else
				K[j][i] = 0;
				end 
				
				
				if   STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]> STOCHASTIC_RSI[j][i].D[STOCHASTIC_RSI[j][i].D:size()-1] 
				then
				D[j][i] = 1;
				elseif    STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]< STOCHASTIC_RSI[j][i].D[STOCHASTIC_RSI[j][i].D:size()-1] 
				then
				D[j][i] = -1;
				else
				D[j][i] = 0;
				end 
				
				
				
				if   STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]>SR4[i] 
			 
				then
				OBOS[j][i] = 1;
				elseif    STOCHASTIC_RSI[j][i].K[STOCHASTIC_RSI[j][i].K:size()-1]< SR5[i] 
				 
				then
				OBOS[j][i] = -1;
				else
				OBOS[j][i] = 0;
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
			  instance:updateFrom(0);
			  
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
	 core.host:execute ("setStatus", "Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	elseif not FLAG and cookie == 1 then
	
	
	  core.host:execute ("setStatus", "Loaded" );	 
	             for j = 1, Count, 1 do
					
	                    for i = 1, Num, 1  do				
			  
			             Logic(j,i );
			
				        end
        end
    
	  
	end
   
        
    return core.ASYNC_REDRAW ;
end
 
