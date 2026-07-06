-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=23005

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function AddParam(id, frame )

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);

end


function Init()
    indicator:name("MTF MCP Fractal_Channel Multimeter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Chart" , "Use Chart Price Source", "", true); 
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3,99);
	
    AddParam(1, "m1");	
    AddParam(2, "m5");	
    AddParam(3, "m15");	
    AddParam(4, "m30");
    AddParam(5, "H1");
	AddParam(6, "H2");	
    AddParam(7, "H3");	
    AddParam(8, "H4");	
    AddParam(9, "H6");
    AddParam(10, "H8");
	AddParam(11, "D1");	
    AddParam(12, "W1");
    AddParam(13, "M1");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("NO", "Color for Unclear Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addDouble("Size", "As % of Cell", "", 90, 25, 90);
	indicator.parameters:addInteger("VShift", "Vertical Shift ", "Shift", 25); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local UP, DN, NO,VShift;
	local source = nil;
	local TF={};
	local Pair={};
	local L={};	
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};  
	local Size;
	local USE={};
	local Count=13;
    local Number;
	local Chart ;
	local Label;
	local Frame;
    local Indicator={};
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    	
	Chart=instance.parameters.Chart;
	Frame=instance.parameters.Frame;
	
    source = instance.source;
    UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	NO=instance.parameters.NO;
	VShift=instance.parameters.VShift;
	
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	

    local i;
   
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		  
		 
		 		    
		    if  Chart   then		
		    Pair[Number]=source:name();	  
            else
            Pair[Number]= instance.parameters:getString("Pair" .. i);
		    end
	      
			  TF[Number]= instance.parameters:getString("TF" .. i);	 
		 end   
		   
	  
    end
   
   	
 	
   assert(core.indicators:findIndicator("FRACTAL_CHANNEL") ~= nil, "Please, download and install FRACTAL_CHANNEL.LUA indicator");	
	

    for i = 1, Number, 1 do	
	
	    	--local Test = core.indicators:create("CCI", source ,10);   
	        --first= Test.DATA:first()*2 ; 	
	  
	  	
	    if (TF[i] == source:barSize() and   Pair[i] == source:name())     then
		SourceData[i]=source;
		loading[i]= false;
		else 	
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(),  0 , 200+i, 100+i);	   
		loading[i]= true;		
		end
		
		
		Indicator[i] = core.indicators:create("FRACTAL_CHANNEL", SourceData[i], Frame, 0, 0, 0, 0, true  );
		
		
		 
    end
	
    core.host:execute ("setTimer", 10, 10);   
	instance:ownerDrawn(true);


end

function ReleaseInstance()
core.host:execute ("killTimer", 10);
end 


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), offset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

 
function Draw(stage, context)
    if stage ~= 2  
	then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] 
		then	
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		return;
		end
      
	    local xCell = (context:right () -context:left ())/(Number+1);		
        local yCell = (context:bottom () -context:top ())/15;		    
		
		for i = 1, Number, 1 do 
		     Color1=NO;   
		     Color2=NO; 
			 LabelText="";

				if  Indicator[i].Upper:hasData(Indicator[i].Upper:size()-1) then		   
							if  SourceData[i].close[SourceData[i].close:size()-1]  > Indicator[i].Upper[Indicator[i].Upper:size()-1] then
							Color1=UP;
							elseif  SourceData[i].close[SourceData[i].close:size()-1]  <   Indicator[i].Lower[Indicator[i].Lower:size()-1] then
							Color1=DN;
							else
							Color1=NO;
							end	
							
							if SourceData[i].close[SourceData[i].close:size()-1]  >  SourceData[i].open[SourceData[i].close:size()-1] then
							Color2=UP;
							elseif SourceData[i].close[SourceData[i].close:size()-1]  <  SourceData[i].open[SourceData[i].close:size()-1] then
							Color2=DN;
							else
							Color2=NO;
							end		
							
							LabelText= (SourceData[i].close[SourceData[i].close:size()-1]  - Indicator[i].Lower[Indicator[i].Lower:size()-1] )/((Indicator[i].Upper[Indicator[i].Upper:size()-1]-Indicator[i].Lower[Indicator[i].Lower:size()-1])/100)			
							LabelText=win32.formatNumber(LabelText, false, 2); 				
					 
		     
			    end

       		
			context:createFont (1, "Arial", (xCell/10/100)* Size , (yCell/100)*Size, 0);	
           
			 width, height = context:measureText (1, tostring(Pair[i]), 0)			
			 context:drawText (1, tostring(Pair[i]), Label, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell/4, context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell/4 + height, 0);
			 
			  width, height = context:measureText (1, tostring(TF[i]), 0)				
		    context:drawText (1, tostring(TF[i]), Color1, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell*(5/4), context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell*(5/4) + height, 0);
	
			  width, height = context:measureText (1, LabelText, 0)				
		    context:drawText (1, tostring(LabelText), Color2, -1, context:left ()+(i-1)*xCell    , context:top ()+VShift+yCell*(9/4), context:left ()+(i-1)*xCell + width, context:top ()+VShift+yCell*(9/4) + height, 0);	
		 end
	 
         		 
 
		
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
 
	end    
	
	local Flag = false;		
		for i = 1, Number, 1 do 
                 if loading [i] then
				 Flag= true; 
				 end
		 
     
       end
	
	
       if cookie== 10 and Flag == false  then
		
			    for j = 1, Number, 1 do
			 
					Indicator[j]:update(core.UpdateLast); 			
			 
		        end    
		
		end 
   
   
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded "); 
		 instance:updateFrom(0);
		end
		
		

        
		return core.ASYNC_REDRAW ;
   
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
