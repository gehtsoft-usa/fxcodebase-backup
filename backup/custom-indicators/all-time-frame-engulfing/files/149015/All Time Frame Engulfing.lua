-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73169

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
function Init()
    indicator:name("All Time Frame Engulfing");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

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
	
	 indicator.parameters:addGroup("Arrow Style");	
 
	 indicator.parameters:addInteger("Size", "Arrow Size", "",10); 	
	 indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0)); 
end

function AddParam(id, frame )

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local SourceData={};
local loading={};  	
local Indicator={};
local Signal={};
local TF={};
local Count=13;
local Number;
local Up, Down;
-- Routine
 function Prepare(nameOnly)   
 
    
	Up=instance.parameters.Up;
    Down=instance.parameters.Down;	
	Size=instance.parameters.Size;
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	 
	
	first=source:first() ; 
	
	Number=0;
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	
	 
    for i = 1, Count, 1 do
	
	  
 
		
		
	   	s2, e2 = core.getcandle(instance.parameters:getString("TF" .. i), 0, 0, 0);
		
	     if instance.parameters:getBoolean("USE" .. i) and  (e2-s2)>=(e1-s1) then
		 Number=Number+1;  
			  TF[Number]= instance.parameters:getString("TF" .. i);	 
		 end   
		   
	  
    end
   
	assert(core.indicators:findIndicator("ENGULFING SIGNAL") ~= nil, "Please, download and install ENGULFING SIGNAL.LUA indicator");    	
	
 for i = 1, Number, 1 do	 
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  0 , 200+i, 100+i);	   
		loading[i]= true;	 
        Indicator[i] = core.indicators:create("ENGULFING SIGNAL", SourceData[i]  )
		Signal[i] = instance:addInternalStream(0, 0);
    end
	
	core.host:execute ("setTimer", 1, 5);	
    instance:ownerDrawn(true);	
end


function Update(period, mode)

	 

	
end



 local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	local Flag=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] 
				 then
				 Flag= true;
				 end
				 
	end    
    
	
		
	if Flag then
	return;	 
	end
	
	

	 
	 
	
    for i = 1, Number, 1 do 
	context:createFont(i, "Wingdings", Size*i,Size*i, 0);
	 
	Add(i, context);
	end 
	

end	

function Add(i, context)

     
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
		
		for period= first, last, 1 do	 

		
		
		   
		    p=Initialization(i,period);
			
			if p~= false and Indicator[i].DATA:hasData(p)  then
					local StartDate, EndDate  = core.getcandle(TF[i], SourceData[i]:date(p), offset, weekoffset);
					
					x, x1, x = context:positionOfDate (StartDate)
					--x, x, x2 = context:positionOfDate (EndDate)	

                    Signal[i][period]=0;					

					if  Indicator[i].DATA[p]==1 and Indicator[i].DATA[p] ~= Indicator[i].DATA[p-1] and Indicator[i].DATA[p]~= Signal[i][period] then 
					width, height = context:measureText (i,  "\225" , 0)
                    visible, y =  context:pointOfPrice (SourceData[i].low[p])					
                    context:drawText(i,  "\225" , Up, -1, x1 , y   , x1+width,y+height, 0);		
                    Signal[i][period]=1;					
					 
					elseif  Indicator[i].DATA[p]==-1 and Indicator[i].DATA[p] ~= Indicator[i].DATA[p-1]and Indicator[i].DATA[p]~= Signal[i][period] then  
                    visible, y =  context:pointOfPrice (SourceData[i].high[p])						
					width, height = context:measureText (i,  "\226" , 0)						
                    context:drawText(i,  "\226" , Down, -1, x1 , y-height   , x1+width,y, 0);	 
                    Signal[i][period]=-1;	
                    else
                    Signal[i][period]=Signal[i][period-1];					
					end	
            end			
        end

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
	
	 
	
   
   
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded "); 
		instance:updateFrom(0);
		end
		
		
	   if not Flag and cookie== 1 then
			for i= 1, Number , 1 do
				  Indicator[i]:update(core.UpdateLast );
			end
			
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