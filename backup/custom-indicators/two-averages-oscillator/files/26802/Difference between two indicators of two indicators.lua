-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Difference between two indicators of two indicators");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. Indicator Source Calculation"); 
	indicator.parameters:addString("Indicator3", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator3",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number3", "Data Stream Number", "", 1, 1 , 100);
	
	  indicator.parameters:addGroup("2. Indicator Source Calculation"); 
	indicator.parameters:addString("Indicator4", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator4",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number4", "Data Stream Number", "", 1, 1 , 100);

    indicator.parameters:addGroup("1. Indicator Calculation"); 
	indicator.parameters:addString("Indicator1", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
	  indicator.parameters:addGroup("2. Indicator Calculation"); 
	indicator.parameters:addString("Indicator2", "Indicator", "", "");
    indicator.parameters:setFlag("Indicator2",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number2", "Data Stream Number", "", 1, 1 , 100);
    
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local Difference;

local Number2, Number1;
local Indicator1,Indicator2; 
local Data2, Data1;


local Number3, Number4;
local Indicator3,Indicator4; 
local Data3, Data4;
-- Routine
function Prepare(nameOnly)

     Number2=instance.parameters.Number2-1;
	 Number1=instance.parameters.Number1-1;
	 Indicator1=instance.parameters.Indicator1;
	 Indicator2=instance.parameters.Indicator2;
	 
	 Number3=instance.parameters.Number3-1;
	 Number4=instance.parameters.Number4-1;
	 Indicator3=instance.parameters.Indicator3;
	 Indicator4=instance.parameters.Indicator4;
	 
	 source = instance.source;   

	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Indicator1).. ", " .. tostring(Indicator2).. ", " .. tostring(Indicator3).. ", " .. tostring(Indicator4) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		local profile3 = core.indicators:findIndicator(instance.parameters:getString("Indicator3"));
		local params3 = instance.parameters:getCustomParameters("Indicator3");

		if  profile3:requiredSource() == core.Tick then			
			Data3 = profile3:createInstance( source.close, params3);
		else
			Data3= profile3:createInstance(source, params3);
		end		
	
	
		Count3= Data3:getStreamCount ();
		
		local profile4 = core.indicators:findIndicator(instance.parameters:getString("Indicator4"));
			local params4 = instance.parameters:getCustomParameters("Indicator4");

			if  profile4:requiredSource() == core.Tick then			
				Data4 = profile4:createInstance( source.close, params4);
			else
				Data4 = profile4:createInstance(source, params4);
			end
			
			Count4= Data4:getStreamCount ();
			
			
		
		if Number3 >= Count3 then
		Number3 = Count3;
		assert( false, "Incorrect index of stream. The indicator has only ".. Count3  .. " stream(s).");
		end	
		
		
		if Number4 >= Count4 then
		Number4 = Count4;
		assert( false, "Incorrect index of stream. The indicator has only ".. Count4  .. " stream(s).");
		end	
		
		
		--***--
		
		
			local profile1 = core.indicators:findIndicator(instance.parameters:getString("Indicator1"));
			local params1 = instance.parameters:getCustomParameters("Indicator1");

			if  profile1:requiredSource() == core.Tick then			
				Data1 = profile1:createInstance( Data3.DATA, params1);
			else
				assert( false, "Indicator that use, Bar source are not supported.");
			end		
		
		
		Count1= Data1:getStreamCount ();
		
		local profile2 = core.indicators:findIndicator(instance.parameters:getString("Indicator2"));
		local params2 = instance.parameters:getCustomParameters("Indicator2");

		if  profile2:requiredSource() == core.Tick then			
			Data2 = profile1:createInstance( Data4.DATA, params2);
		else
				assert( false, "Indicator that use, Bar source are not supported.");
		end

		Count2= Data2:getStreamCount ();
		first = math.max(Data1.DATA:first(),  Data2.DATA:first(),Data3.DATA:first(),  Data4.DATA:first());
		
		if Number1 >= Count1 then
		Number1 = Count1;
		assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
		end	
		
		
		if Number2 >= Count2 then
			Number2 = Count2;
			assert( false, "Incorrect index of stream. The indicator has only ".. Count2  .. " stream(s).");
		end	
	    Difference = instance:addStream("DBTDF", core.Bar, name, "Difference", instance.parameters.UPUP, first);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	 Data3:update(mode);
	 Data4:update(mode);
     Data1:update(mode);
	 Data2:update(mode); 
	 
	 
    if period < first or not source:hasData(period) then
	return;
	end 
	
	Difference[period] =Data1:getStream (Number1)[period] - Data2:getStream (Number2)[period];
	
	if Difference[period] > 0 then
	    if  Difference[period] > Difference[period-1] then
		Difference:setColor(period, instance.parameters.UPUP);
		else
		Difference:setColor(period, instance.parameters.UPDN);
		end                	
	else
	    if  Difference[period] > Difference[period-1] then
		Difference:setColor(period, instance.parameters.DNUP);
		else
		Difference:setColor(period, instance.parameters.DNDN);
		end       
	end
	
    
end

