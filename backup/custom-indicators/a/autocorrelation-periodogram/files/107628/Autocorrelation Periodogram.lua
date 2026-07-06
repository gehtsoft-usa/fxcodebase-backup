-- Id: 16510
--From “Past Market Cycles” by John F. Ehlers
--September 2016 issue of Technical Analysis of STOCKS & COMMODITIES magazine.


-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63766

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


--[[TASC Aug 2016
Article: MHL MA
By: Vitali Apirine
]]
function Init()
    indicator:name("Autocorrelation Periodogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AvgLength", "Avg Length", "AvgLength", 3);
	indicator.parameters:addBoolean("EnhanceResolution", "Enhance Resolution", "", false);
 
 
     indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "DominantCycle Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local source;
local first;
local AvgLength,EnhanceResolution;
local 	alpha1, a1, b1, c2, c3, c1;
local HP, Filt;
local DominantCycle;
local   Pwr={};
--local   Color={};
local Corr={};
local CosinePart={};
local SinePart={};
local SqSum={};
local R1={};
local R2={};

function Prepare(nameOnly)
    source = instance.source;
    first=source:first()+48;
   
   AvgLength=instance.parameters.AvgLength;
   EnhanceResolution=instance.parameters.EnhanceResolution;
   
   
   HP= instance:addInternalStream(0, 0);
   Filt= instance:addInternalStream(0, 0);
   
  
    local name = profile:id() .. " ( " .. AvgLength.. " )";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	

--Highpass Filter and SuperSmoother Filter together form a Roofing Filter
--Highpass Filter
alpha1 = (1 - math.sin (360 / 48)) / math.cos(360 / 48);

--Smooth with a SuperSmoother Filter 
a1 = math.exp(-1.414*3.14159 / 8);
b1 = 2*a1*math.cos(1.414*180 / 8);
c2 = b1;
c3 = -a1*a1;
c1 = 1 - c2 - c3;
	
 
DominantCycle = instance:addStream("DominantCycle", core.Line, name, "DominantCycle", instance.parameters.color, first);
    DominantCycle:setPrecision(math.max(2, instance.source:getPrecision()));
DominantCycle:setWidth(instance.parameters.width);
DominantCycle:setStyle(instance.parameters.style);

--for  Period = 8, 48, 1  do
--Color[Period]= instance:addInternalStream(0, 0);
--end


--instance:ownerDrawn(true);

end


--[[
function Draw(stage, context)
    if stage~= 0 then
	return;
	end
	 
	local i;	
	
	local First= math.max(first, context:firstBar ());
	local Last= math.min(source:size()-1, context:lastBar ());
	
	
	
-- Plot as a Heatmap

local yCell = (context:bottom () -context:top ()) /(48-8)



	
	for period= First, Last, 1 do 
	 x, x1, x2 = context:positionOfBar (period);
			for  Period = 8, 48, 1  do

		 
			y1= context:bottom () -(Period-8)*yCell;
			y2= context:bottom () -(Period-1-8)*yCell;
		
	
					
			context:drawGradientRectangle (x1, y1, Color[Period][period], x2, y1, Color[Period][period], x2, y2, Color[Period][period], x1, y2, Color[Period][period]);
			end

       end 
	
end
 
]]

function Update(period, mode)

 
if period < 1 then
return;
end 

HP[period] = 0.5*(1 + alpha1)*(source[period] - source[period-1]) + alpha1*HP[period-1];
 
if period < 2 then
return;
end
 
Filt[period] = c1*(HP[period] + HP[period-1]) / 2 + c2*Filt[period-1] + c3*Filt[period-2];

if period < AvgLength+48 then
return;
end


--Pearson correlation for each value of lag
for Lag = 0, 48, 1 do
	--//Set the averaging length as M
	M = AvgLength;
	if AvgLength == 0 then M = Lag end;
	Sx = 0;
	Sy = 0;
	Sxx = 0;
	Syy = 0;
	Sxy = 0;	
	for count = 0, M - 1, 1 do
		X = Filt[period-count];
		Y = Filt[period-Lag - count];
		Sx = Sx + X;
		Sy = Sy + Y;
		Sxx = Sxx + X*X;
		Sxy = Sxy + X*Y;
		Syy = Syy + Y*Y;
	end
	
	
	if (M*Sxx - Sx*Sx)*(M*Syy - Sy*Sy) > 0 then Corr[Lag] = (M*Sxy - Sx*Sy)/math.sqrt((M*Sxx - Sx*Sx)*(M*Syy - Sy*Sy));end
	
	
end



--Compute the Fourier Transform for each Correlation
for Period= 8, 48, 1 do
	CosinePart[Period] = 0;
	SinePart[Period] = 0;
	for N = 3, 48, 1 do
		CosinePart[Period] = CosinePart[Period] + Corr[N]*math.cos(360*N / Period);
		SinePart[Period] = SinePart[Period] + Corr[N]*math.sin(360*N / Period);
	 end
	SqSum[Period] = CosinePart[Period]*CosinePart[Period] + SinePart[Period]*SinePart[Period];
end


for Period = 8,  48, 1 do
	
	if R1[Period]~= nil then
	R2[Period] = R1[Period];
	else
	R2[Period]=0;
	end
	 
	R1[Period] = 0.2*SqSum[Period]*SqSum[Period] + 0.8*R2[Period]; 
	 
	
end


-- Find Maximum Power Level for Normalization
MaxPwr = 0;
for Period = 8,  48, 1 do
	if R1[Period] > MaxPwr then MaxPwr = R1[Period]; end
end
for Period = 8,  48, 1 do
	Pwr[Period] = R1[Period] / MaxPwr;
end


--Optionally increase Display Resolution by raising the NormPwr to a higher mathematically power (since the maximum amplitude is unity, cubing all amplitudes further reduces the smaller ones).
if EnhanceResolution then
	for Period = 8, 48, 1 do
		Pwr[Period] = math.pow (Pwr[Period], 3);
	end
end



--Compute the dominant cycle using the CG of the spectrum
DominantCycle[period] = 0;
PeakPwr = 0;
for Period = 8 , 48, 1 do
	if Pwr[Period] > PeakPwr then PeakPwr = Pwr[Period]; end
end

Spx = 0;
Sp = 0;
for Period = 8 , 48, 1 do
	if PeakPwr >= 0.25 and Pwr[Period] >= 0.25 then
		Spx = Spx + Period*Pwr[Period];
		Sp = Sp + Pwr[Period];
	end	
end

if Sp ~= 0 then DominantCycle[period] = Spx / Sp; end
if Sp < 0.25 then DominantCycle[period] = DominantCycle[period-1]; end

--[[
for Period = 8 , 48, 1 do
local  Color3 = 0;
	
	if Pwr[Period] > 0.5  then
		Color1 = 255;
		Color2 = 255*(2*Pwr[Period] - 1);
	else
		Color1 = 2*255*Pwr[Period];
		Color2 = 0;
	end
	Color[Period][period]=  core.rgb(Color1, Color2, Color3);
	
end	]]
	
	
end
 
 