-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69959

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Market Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
    
	
	
	indicator.parameters:addGroup("Selector");
 
	indicator.parameters:addBoolean("S1", "Show Percentage Change", "", true);
	indicator.parameters:addBoolean("S2", "Bias", "", true);
	indicator.parameters:addBoolean("S3", "Histogram", "", true);
	 indicator.parameters:addBoolean("S4", "Patterns", "", true);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Sort_Method", "Sort By", "", "Percentage");
    indicator.parameters:addStringAlternative("Sort_Method", "Percentage", "", "Percentage");
    indicator.parameters:addStringAlternative("Sort_Method", "Bias", "", "Bias");
	
	indicator.parameters:addInteger("Bias_Period", "Bias Period", "Bias Period", 5);
	indicator.parameters:addInteger("BaseSize", "BaseSize (in pips)", "BaseSize", 10);
	indicator.parameters:addDouble("Log_Multiplier", "Log Multiplier", "BaseSize", 1.1);
	
	indicator.parameters:addString("Histogram", "Histogram", "", "Numerical");
    indicator.parameters:addStringAlternative("Histogram", "Graphical", "", "Graphical");
    indicator.parameters:addStringAlternative("Histogram", "Numerical", "", "Numerical");
	 indicator.parameters:addStringAlternative("Histogram", "Both", "", "Both");
	
	
	indicator.parameters:addString("Base", "Base Pair", "", "USD");
    indicator.parameters:addStringAlternative("Base", "USD", "", "USD");
    indicator.parameters:addStringAlternative("Base", "EUR", "", "EUR");
    indicator.parameters:addStringAlternative("Base", "JPY", "", "JPY");
    indicator.parameters:addStringAlternative("Base","CHF", "", "CHF");
    indicator.parameters:addStringAlternative("Base", "GBP", "", "GBP");
	indicator.parameters:addStringAlternative("Base", "CAD", "", "CAD");
    indicator.parameters:addStringAlternative("Base", "AUD", "", "AUD");
    indicator.parameters:addStringAlternative("Base", "NZD", "", "NZD");	
	
    indicator.parameters:addBoolean("Base_Pair", "Base Pair", "Base Pair", true);
    indicator.parameters:addBoolean("Major", "Major Only", "Major Only", true);
	indicator.parameters:addBoolean("Short", "Short List", "Short List", true);
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);

 
 
 
	indicator.parameters:addInteger("Size", "Font Size", "", 10 , 0, 100);
    indicator.parameters:addInteger("Histogram_Size", "Histogram Font Size", "", 15 , 0, 100);
	
	indicator.parameters:addColor("bg_color", "Background color", "", core.COLOR_BACKGROUND);

end
 

  

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local S1,S2,S3,S4;
local Bias_Period;
local Base;
local Major; 
local Base_Pair; 
local pauto = "(%a%a%a)/(%a%a%a)"
local Color;
local Source={};
local BiasArray={};
local Sort_Method;
local transparency; 
local loading={}; 
local source;
local Size;
local Up,  Down,Neutral ;
local minusX, minusY;  
local HISTORY_LOADING_ID = 1000;
local InstrumentList , InstrumentCount,Point;
local Change={};
local ChangeKey; 
local ShortList={};
local Inverse={};
local Short;
local Histogram_Size;
local BaseSize;
local Log_Multiplier;
local Histogram;


local Pattern={};
local Number_Of_Signals= 2; 
local Pattern_Name={ "REV", "LOG" };
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--assert(core.indicators:findIndicator("BIAS") ~= nil, "Please, download and install BIAS.LUA indicator");
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	S4= instance.parameters.S4;
	
	Log_Multiplier= instance.parameters.Log_Multiplier;
 
	
	Base= instance.parameters.Base;
	BaseSize= instance.parameters.BaseSize;
	Base_Pair= instance.parameters.Base_Pair;
	Major= instance.parameters.Major;
	Short= instance.parameters.Short;
	Bias_Period= instance.parameters.Bias_Period;
	Sort_Method= instance.parameters.Sort_Method;
	Histogram= instance.parameters.Histogram;
  
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;  
	Histogram_Size= instance.parameters.Histogram_Size;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	 
	 
	InstrumentList , InstrumentCount, Point , ShortList, Inverse= getInstrumentList();
 
    	source = instance.source; 
 
    local ID=0;
     
        for i = 1, InstrumentCount, 1 do
            
			 
        
                ID = ID + 1;  
                Source[i] = core.host:execute("getHistory", HISTORY_LOADING_ID + ID, InstrumentList[i], "D1", 0, 0, true);					
                loading[i] = true; 
				
				Pattern[i]={}
				--Pattern[i][1]=1;
              --  Pattern[i][2]=2;
        end
   
    
    
    instance:ownerDrawn(true); 
    core.host:execute("subscribeTradeEvents", 999, "offers");
    instance:initView("Dashboard", 0, 1, true, true);
 
 
    
    --open =   instance:addInternalStream(0, 0);
	open = instance:addStream("open", core.Dot, "open", "open", 0, 0, 0);
    open:setVisible(false);
	
 
--	core.host:execute ("setTimer", 1, 10);
end

function getInstrumentList()
    local list={};
	local point={};
	local short={};
    local count = 0;
    local inverse={};	
    local row, enum;	
	
	

	local crncy1, crncy2;
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	
	   	crncy1, crncy2 = string.match(row.Instrument, pauto)
		
		if ((crncy1== Base or  crncy2== Base) and Base_Pair or not Base_Pair)
        and (ItIsMajor(crncy1, crncy2) and Major or not Major)
		then
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;   
			if crncy1== Base then
			short[count]=crncy2;	
			inverse[count]=0;
			elseif crncy2== Base then
			short[count]=crncy1;
            inverse[count]=1;			
			end
		end
		
		 row = enum:next();
    end
	
	 
    return list, count,point,short, inverse;
end

local Majors={"USD" ,"EUR","JPY", "CHF" , "GBP" ,"AUD" ,"NZD", "CAD" };
function ItIsMajor(crncy1, crncy2)


local Flag1=false;
local Flag2=false;

if crncy1==nil
or crncy2==nil
then
return false;
end


        for i= 1, 8, 1 do

		
             if crncy1== Majors[i] then
			  Flag1=true;
			 end
			 
			 if crncy2== Majors[i] then
			  Flag2=true;
			 end
	 
		end
	
    local Return =false;

	
	if 	Flag1 and Flag2 then
	Return=true;
	end
	
	return Return;

end
--function ReleaseInstance()
--core.host:execute ("killTimer", 1);
--end 


 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 
   if cookie >= HISTORY_LOADING_ID then
        local i,j;
        local ID = 0;

        for i = 1, InstrumentCount, 1 do
            
                ID = ID + 1;
                if cookie == (HISTORY_LOADING_ID + ID) then
                    loading[i]  = false;
                end
				
				
				if i== 1 then
				
					--for j = 0, Source[i]:size() - 1 , 1 do
					j= Source[i]:size() - 1;
					if j>=0 then
					instance:addViewBar(Source[i]:date(j));				   
				    end
				
				end
             
        end

        local FLAG=false; 
        local Number=0;
        
        for i = 1, InstrumentCount, 1 do
           
                if loading[i]  then
                    FLAG = true;
                    Number=Number+1;
                end
            
        end
        
        if FLAG then
            core.host:execute ("setStatus", "Loading ".. (InstrumentCount- Number) .. " / " ..  InstrumentCount );	 
        else
            core.host:execute ("setStatus", "Loaded") 
             
        end
       
      
    elseif cookie == 999 then
        local Loading = false; 
        for i = 1, InstrumentCount, 1 do 
             
                if loading[i] then
                    Loading = true; 
                end
            end 
    end
	
	 if Loading then
	 return;
	 end
	 
	 
	 
 
	  
	     for i= 1, InstrumentCount,1 do  
		 Change[i]= CalculatePercentageChange (i,1);
         BiasArray[i]= CalculatePercentageChange (i,2); 
         CalculatePercentageChange (i,3); 			 
		 end
		 
		
		 
		if Sort_Method== "Percentage" then       		
	    ChangeKey= BubbleSortKey(Change, InstrumentCount );	 
		elseif Sort_Method== "Bias" then   
		 BubbleSortKey(BiasArray, InstrumentCount );	 
		end

	 
    
	    return core.ASYNC_REDRAW;
end

function CalculatePercentageChange (i, id)
 
     if Source[i].close:size()-1<=2 then
	return 0;
	end
 
 
    if id == 1 or id == 2 then

  
	
	
			
			local Value;
			local Positive_Bias =0;
			
			
			if Base_Pair and Short then
			
			
			   for j = Bias_Period, 1, -1 do
			  Value=  (Source[i].close[Source[i].close:size()-1-j+1]-Source[i].open[Source[i].open:size()-1-j+1])/ (Source[i].open[Source[i].open:size()-1-j+1]/100);
			  
			 
			  
			   if Inverse[i] == 1 then
			   Value=-Value;
			   end
			   
			   
			  if Value > 0 then
			  Positive_Bias=Positive_Bias+1;
			  end
			   
			   
			  end
			else
				 for j = Bias_Period, 1, -1 do
				 Value=  (Source[i].close[Source[i].close:size()-1-j+1]-Source[i].open[Source[i].open:size()-1-j+1])/ (Source[i].open[Source[i].open:size()-1-j+1]/100);
				
				
					  if Value > 0 then
					  Positive_Bias=Positive_Bias+1;
					  end
				  
				  end
			   
			   
			end
		 
		 
			 
		   
			if id == 1 then
			return Value ;
			elseif id ==2 then
			return (Positive_Bias/(Bias_Period/100)); 
			end
			
	
	end
	
	
	
	
	if  id ==3 then
	 
     ArraySize=0;
	 Pattern[i]={};
	 
     if Source[i].close[Source[i].close:size()-1  ] > Source[i].open[Source[i].open:size()-1  ]
	 and Source[i].close[Source[i].close:size()-2  ] < Source[i].open[Source[i].open:size()-2  ]
	 then
	 
	 ArraySize=ArraySize+1;
	 Pattern[i][ ArraySize ]= 1 ;   
	 
	 
	 if Base_Pair and Short and Inverse[i] == 1 then
	 Pattern[i][ ArraySize ]= -Pattern[i][ ArraySize ];   		 
	 end		 
	 

             
			   
	 elseif Source[i].close[Source[i].close:size()-1  ] > Source[i].open[Source[i].open:size()-1  ]
	 and Source[i].close[Source[i].close:size()-2  ] < Source[i].open[Source[i].open:size()-2  ]
	 then
	 ArraySize=ArraySize+1;
	 Pattern[i][ArraySize ]= -1 ;  

     if Base_Pair and Short and Inverse[i] == 1 then
	 Pattern[i][ ArraySize ]= -Pattern[i][ ArraySize ];   		 
	 end
	 
	 end
	 
	  local Delta1=   Source[i].close[Source[i].close:size()-1  ] - Source[i].open[Source[i].open:size()-1  ]; 
	  local Delta2=  Source[i].close[Source[i].close:size()-2  ] - Source[i].open[Source[i].open:size()-2  ]; 
	  local Delta3=  Source[i].close[Source[i].close:size()-3  ] - Source[i].open[Source[i].open:size()-3  ]; 
	  
	  if Delta1 > 0  and Delta2>0 and Delta3>0	  
	  and Delta2 >  Log_Multiplier* Delta1 and Delta3 >  Log_Multiplier* Delta2	  
	  then
	   ArraySize=ArraySize+1;
	  Pattern[i][ ArraySize ]= 1 ; 
	  
	   if Base_Pair and Short and Inverse[i] == 1 then
	 Pattern[i][ ArraySize ]= -Pattern[i][ ArraySize ];   		 
	 end
			   
	  elseif Delta1 < 0  and Delta2<0 and Delta3<0	
       and math.abs(Delta2) >  Log_Multiplier* math.abs(Delta1) and math.abs(Delta3) >  Log_Multiplier* math.abs(Delta2)	  
	  then
	  
	   ArraySize=ArraySize+1;
	 Pattern[i][ ArraySize ]= -1 ;  
               
		if Base_Pair and Short and Inverse[i] == 1 then
	 Pattern[i][ ArraySize ]= -Pattern[i][ ArraySize ];   		 
	 end	   
	   end
	end
	
	
end





function BubbleSortKey(Data, Index)
 
 local Key={};
 local Temp;
 local Repeat_The_Loop=true;
 
   
   for i=1, Index, 1 do
   Key[i]=i;
   end
   
   

     while Repeat_The_Loop do
    Repeat_The_Loop=false;
   
            for i = 2, Index , 1 do
                  
                    if Data[Key[i]] >  Data[Key[i-1]] then
                     Repeat_The_Loop=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                      
                    end
          
          end
   
    end
 
  return Key;
end

local top, bottom;
local left, right;
 
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
    --shoudn't be called
end

local init = false; 

local BG = 3;
local BG_PEN = 4;
function Draw(stage, context)
	if stage ~= 2 then
        return;
	end
	
	
   context:setClipRectangle(0, 0, 5000, 5000);
   context:drawRectangle(BG_PEN, BG, 0, 0, 5000, 5000);

	local Loading=false;
	
	for i = 1, InstrumentCount, 1 do 
	   
            if loading [i] then
            Loading=true;      
            end
		
    end
	
	if Loading then
	return;
	end
	

    if not init then
 
		
		transparency = context:convertTransparency(instance.parameters.transparency);
		
		context:createFont (1, "Arial",Size, Size , 0);
		context:createFont (2, "Wingdings",Histogram_Size, Histogram_Size , 0);
		context:createFont (3, "Arial",Histogram_Size, Histogram_Size , 0);
		
		context:createSolidBrush(BG, instance.parameters.bg_color);
		context:createPen(BG_PEN, context.SOLID, 1, instance.parameters.bg_color);
                        
        init = true;
    end
 
	    
    
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
 
   
    local column=0;
	local tab =Size*14;
    
    local Text;
       for i= 1, InstrumentCount,1 do 	
	   
	             
 
					column=1; 
					if Short and Base_Pair then
					 Text= tostring(ShortList[ChangeKey[i]]);
					else
					Text= tostring(InstrumentList[ChangeKey[i]]);
					end
					width, height = context:measureText (1, Text, context.CENTER  ); 
					context:drawText (1,Text, Color, -1, left+(column-1)*tab  , top+(i+1)*height,   left+column*tab + width,  top+(i+2)*height, context.CENTER   );	
					
					
					if S1 then
						column=column+1; 	
						
						local color;
						if Change[ChangeKey[i]] > 0 then
						color=Up;
						elseif Change[ChangeKey[i]] < 0 then
						color=Down;
						else
						color=Neutral;
						end
						Text= string.format("%." .. 2 .. "f", Change[ChangeKey[i]]);  
						width, height = context:measureText (1, Text, context.CENTER  ); 
						context:drawText (1,Text, color, -1, left+(column-1)*tab  , top+(i+1)*height,   left+column*tab + width,  top+(i+2)*height, context.CENTER   );	
						
						
						
					 
						if  Base_Pair and Short and i == InstrumentCount then
						Text= tostring(Base);  
						width, height = context:measureText (1, Text, context.CENTER  ); 
						context:drawText (1,Text, Color, -1, left+(column-1)*tab  , top+(i+2)*height,   left+column*tab + width,  top+(i+3)*height, context.CENTER   );
						end
						
						if   i == 1 then
						Text= tostring("%");  
						width, height = context:measureText (1, Text, context.CENTER  ); 
						context:drawText (1,Text, Color, -1, left+(column-1)*tab  , top+(i)*height,   left+column*tab + width,  top+(i+1 )*height, context.CENTER   );
						end
						
					end
					
					if S2 then
								column=column+1; 
							
							if   i == 1 then
							Text= tostring("Bias");  
							width, height = context:measureText (1, Text, context.CENTER  ); 
							context:drawText (1,Text, Color, -1, left+(column-1)*tab  , top+(i)*height,   left+column*tab + width,  top+(i+1 )*height, context.CENTER   );
							end
							
							
							local color;
							if BiasArray[ChangeKey[i]] > 50 then
							color=Up;
							elseif BiasArray[ChangeKey[i]] < 50 then
							color=Down;
							else
							color=Neutral;
							end
							
							Text= string.format("%." .. 0 .. "f", BiasArray[ChangeKey[i]]/10);  
							width, height = context:measureText (1, Text, context.CENTER  ); 
							context:drawText (1,Text, color, -1, left+(column-1)*tab  , top+(i+1)*height,   left+column*tab + width,  top+(i+2)*height, context.CENTER   );	
							
					end
					
					
					LineHeight=height;
					
					if S3 then
					        
					       	column=column+1; 
					
							if   i == 1 then
							Text= tostring("Histogram");  
							width, height = context:measureText (1, Text, context.CENTER  ); 
							context:drawText (1,Text, Color, -1, left+(column-1)*tab  , top+(i)*height,   left+column*tab + width,  top+(i+1 )*height, context.CENTER   );
							end
							
							local period= Source[ChangeKey[i]].close:size()-1;
							
							
								for j = 1, 10, 1 do
								if Source[ChangeKey[i]].close[period-j+1] > Source[ChangeKey[i]].open[period-j+1] then
								color=1;
								elseif Source[ChangeKey[i]].close[period-j+1] < Source[ChangeKey[i]].open[period-j+1] then
								color=2;
								else
								color=0;
								end
								
								
								if  Base_Pair and Short and Inverse[ChangeKey[i]] then  
								 
								 
				 
									 if color== 1 then
									 color= 2;
									 elseif color== 2 then
									 color= 1;
									 end
									 
								
								end
								
								
								if color==1 then
								color=Up;
								elseif color==2 then
								color=Down;
								else
								color=Neutral;
								end
								
								 if Histogram~="Numerical" then
								 Text= "\110";  
								width, height = context:measureText (2, Text, context.CENTER  ); 
								context:drawText (2,Text, color, -1, left+ width*10 +(column-1)*tab - j*width    , top+(i+1  )*LineHeight,   left+ width*10+column*tab- (j-1)*width,  top+(i+2 )*LineHeight+ height, context.CENTER   );	
								 end
							
								if Histogram~="Graphical" then
								
								Value = math.abs(Source[ChangeKey[i]].close[period-j+1] - Source[ChangeKey[i]].open[period-j+1])/Point[ChangeKey[i]];
								Value= Value/BaseSize;
								
								if Value>9 then
								Value=9;
								end
								
								Value= string.format("%." .. 0 .. "f",Value);  
								
								
						 
								
								width, height = context:measureText (1, Value, context.CENTER +context.VCENTER  ); 
								
								
								  if Histogram== "Both" then	
								  color=Color;
								  end  						  
								  context:drawText (1,Value, color, -1, left+ width*10+(column-1)*tab -j*width    , top+(i+1  )*LineHeight,   left+ width*10+column*tab-(j-1)*width,  top+(i+2 )*LineHeight+ height, context.CENTER +context.VCENTER  ) ;	
										
								end
							end
							
					
				    end
				 
							 if S4
							 and Pattern [ChangeKey[i]]~=nil 
							 then
							 column=column+2;
                              

                               for j= 1, Number_Of_Signals, 1 do	

							   
										
										 if Pattern [ChangeKey[i]][j] ~= nil then
										 
										  Value = tostring(Pattern_Name[math.abs(Pattern [ChangeKey[i]][j] )]);
									 
											 if Pattern[ChangeKey[i]][j] >0 then
											 Color=Up;
											 elseif Pattern[ChangeKey[i]][j] < 0 then
											 Color=Down;
											 end
											 
										 
										  
										 
										 width, height = context:measureText (1, Value, context.CENTER +context.VCENTER  ); 
										 context:drawText (1,Value, Color, -1, left +(column-1)*tab +(j-1)*width*5    , top+(i+1  )*LineHeight,   left +(column-1)*tab+j*width*5,  top+(i+2 )*LineHeight+ height, context.CENTER +context.VCENTER  ) ;
										 
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