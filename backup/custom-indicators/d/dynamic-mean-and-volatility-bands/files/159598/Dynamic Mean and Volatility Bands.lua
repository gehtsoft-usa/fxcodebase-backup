-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76032

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 
function Init()
    indicator:name("Dynamic Mean and Volatility Bands")
    indicator:description("Dynamic Mean and Volatility Bands")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("decay_factor", "decay_factor", "decay_factor", 0.99, 0.01, 1)
    indicator.parameters:addInteger("corr_length", "Autocorrelation Length (θ)", "Autocorrelation Length (θ)", 100, 2, 2000)	
    indicator.parameters:addDouble("threshold", "Threshold (σ)", "Threshold (σ)", 2, 0.1)	
--[[
 
 
threshold = input.float(title="Threshold (σ)", defval=2.0, minval=0.1, tooltip=tooltip_treshold)
dev_length = input.int(title="Max Gradient Length (γ)", defval=400, minval=2, tooltip=tooltip_dev_length)
]]

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color", "Color of the line", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
	
 
	
end
local first;
local Period, Method;

function Prepare(nameOnly)
    -- Get input parameters
    decay_factor = instance.parameters.decay_factor;
	corr_length = instance.parameters.corr_length;
	threshold = instance.parameters.threshold;
    source = instance.source;
    
    -- Indicator name
    local name =  profile:id() .. " (".. decay_factor .. ", " .. corr_length .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end	
	
	
 
	--ma = core.indicators:create(Method, source, Period);		
	first=source:first()+1;
	
    returns = instance:addInternalStream(0, 0); 	
    consecutive_bars = instance:addInternalStream(0, 0);  	
	
    ewma_mu = instance:addStream("Mean", core.Line, name, "Mean", instance.parameters.color, first)
    ewma_mu:setWidth(instance.parameters.width)
    ewma_mu:setStyle(instance.parameters.style)
    ewma_mu:setPrecision(math.max(2, instance.source:getPrecision()));	
 
    upper_band = instance:addStream("upper_band", core.Line, name, "upper_band", instance.parameters.color, first)
    upper_band:setWidth(instance.parameters.width)
    upper_band:setStyle(instance.parameters.style)
    upper_band:setPrecision(math.max(2, instance.source:getPrecision()));
 
    lower_band = instance:addStream("lower_band", core.Line, name, "lower_band", instance.parameters.color, first)
    lower_band:setWidth(instance.parameters.width)
    lower_band:setStyle(instance.parameters.style)
    lower_band:setPrecision(math.max(2, instance.source:getPrecision()));
	
    core.host:execute ("attachOuputToChart", "Mean")
    core.host:execute ("attachOuputToChart", "upper_band")
    core.host:execute ("attachOuputToChart",  "lower_band")	

    deviation = instance:addStream("deviation", core.Line, name, "deviation", instance.parameters.color, first)
    deviation:setWidth(instance.parameters.width)
    deviation:setStyle(instance.parameters.style)
    deviation:setPrecision(math.max(2, instance.source:getPrecision()));	
end

function Update(period)

 
    -- Make sure there is enough data to calculate all required moving averages
    if period < first then
        return
    end
   --  Calculate Returns
   returns[period]=math.log(source[period] / source[period-1]);
   
    -- Calculate Long-Term Mean (μ) using EWMA over the entire dataset
    ewma_mu[period] = nil -- Initialize ewma_mu as 'na'
	
	if ewma_mu[period-1]== nil then
    ewma_mu[period]=  source[period];
    else	
	ewma_mu[period]=decay_factor * ewma_mu[period-1] + (1 - decay_factor) * source[period]
    end
	
	
	if period <  corr_length then
	return;
	end
	
	-- Calculate Autocorrelation at Lag 1
	rho1 = mathex.correl(returns, returns, period- corr_length+1, period, period-1 - corr_length+1, period-1 )

	-- Ensure rho1 is within valid range to avoid errors
	if rho1 <= 0 then
	rho1= 0.0001
	end

	-- Calculate Speed of Mean Reversion (θ)
	theta = -math.log(rho1)

	-- Calculate Volatility (σ)
	sigma = mathex.stdev(source, period- corr_length+1, period)
	
    --Calculate Upper and Lower Bands	
	upper_band[period] = ewma_mu[period] + threshold * sigma
	lower_band[period] = ewma_mu[period] - threshold * sigma
	
    -- Calculate deviation from mean
   deviation[period] = (source[period] - ewma_mu[period]) / sigma	
	
	
end
 
-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76032

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 