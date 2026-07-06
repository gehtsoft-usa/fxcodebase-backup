-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74958

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Delta-RSI Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 1, 2000);   
    indicator.parameters:addInteger("Degree", "Polynomial Order", "", 2, 1, 2000); 
    indicator.parameters:addInteger("Window", "Frame Length (must be greater than Order)", "", 18, 2, 2000);	
    indicator.parameters:addInteger("SignalLength", "D-RSI Signal Length", "", 9, 2, 2000);	 
    indicator.parameters:addBoolean("IsSignal", "Show D-RSI Signal Line", "", true);
    indicator.parameters:addBoolean("IsRSIFittingError", "Show RSIFittingError Line", "", false);

	
    indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Trend Bar Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Bar in Up Trend Color", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("color3", "Up Bar in Down Trend Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color4", "Down Trend Bar Color", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("color5", "Signal Line Color", "", core.rgb(0, 0, 255));	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period, Degree,  Window, SignalLength, IsSignal; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Degree=instance.parameters.Degree;
	Window=instance.parameters.Window;
	SignalLength=instance.parameters.SignalLength;
	IsSignal=instance.parameters.IsSignal;
	IsRSIFittingError=instance.parameters.IsRSIFittingError;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period   .. "," .. Degree .. "," .. Window .. "," .. SignalLength  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


	
	RSI= core.indicators:create("RSI", source, Period);
	first=RSI.DATA:first() ; 
	 

  
    PolynomialDifferentiator = instance:addStream("PolynomialDifferentiator", core.Bar, name, "PolynomialDifferentiator", instance.parameters.color1, first );
    PolynomialDifferentiator:setPrecision(math.max(2, instance.source:getPrecision())); 
    PolynomialDifferentiator:addLevel(0);	
	
	EMA= core.indicators:create("EMA", PolynomialDifferentiator, SignalLength);	
	
	if IsSignal then
    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color5, first+SignalLength );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
 	else
    Signal = instance:addInternalStream(0, 0);	
	end
	
	
	
 	if IsRSIFittingError then
    RSIFittingError = instance:addStream("RSIFittingError", core.Line, name, "RSIFittingError", instance.parameters.color5, first+SignalLength );
    RSIFittingError:setPrecision(math.max(2, instance.source:getPrecision()));
    RSIFittingError:setWidth(instance.parameters.width);
    RSIFittingError:setStyle(instance.parameters.style);
 	else
    RSIFittingError = instance:addInternalStream(0, 0);	
	end
end


function Update(period, mode)

	RSI:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
    local Value1, Value2 = Differentiator(RSI.DATA, Window, Degree, period)  
	
	PolynomialDifferentiator[period]=Value1;
	RSIFittingError[period]=Value2;	
	
	if PolynomialDifferentiator[period] > 0 then
	    if PolynomialDifferentiator[period]>PolynomialDifferentiator[period-1] then
		PolynomialDifferentiator:setColor(period, instance.parameters.color1);	
        else		
		PolynomialDifferentiator:setColor(period, instance.parameters.color2);
		end
	else				
        if PolynomialDifferentiator[period]>PolynomialDifferentiator[period-1] then	
		PolynomialDifferentiator:setColor(period, instance.parameters.color3);
		else
		PolynomialDifferentiator:setColor(period, instance.parameters.color4);
		end
    end	
	
 
	
	EMA:update(mode); 
	
	if period <= first+SignalLength
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	Signal[period]=EMA.DATA[period];
	
end

--[[
src = rsi(close,rsi_l)
[drsi,nrmse] = diff(src,window,degree)
signalline = ema(drsi, signalLength)

// Conditions and filters
filter_rmse = usenrmse?nrmse<rmse_thrs:true
dirchangeup = (drsi>drsi[1]) and (drsi[1]<drsi[2]) and drsi[1]<0.0
dirchangedw = (drsi<drsi[1]) and (drsi[1]>drsi[2]) and drsi[1]>0.0
crossup = crossover(drsi,0.0)
crossdw = crossunder(drsi,0.0)
crosssignalup = crossover(drsi,signalline)
crosssignaldw = crossunder(drsi,signalline)

//Signals
golong = (buycond=="Direction Change"?dirchangeup:(buycond=="Zero-Crossing"?crossup:crosssignalup)) and  filter_rmse
goshort= (sellcond=="Direction Change"?dirchangedw:(sellcond=="Zero-Crossing"?crossdw:crosssignaldw)) and  filter_rmse
endlong = (endcond=="Direction Change"?dirchangedw:(endcond=="Zero-Crossing"?crossdw:crosssignaldw)) and filter_rmse
endshort= (endcond=="Direction Change"?dirchangeup:(endcond=="Zero-Crossing"?crossup:crosssignalup)) and filter_rmse
plotshape((golong and islong)  ? low : na, location=location.belowbar, style=shape.labelup,   color=#2E7C13,  size=size.small, title='Buy')
plotshape((goshort and isshort) ? high: na, location=location.abovebar, style=shape.labeldown, color=#BF217C, size=size.small, title='Sell')
plotshape((showendlabels and endlong and islong)  ? high: na, location=location.abovebar, style=shape.xcross,   color=#2E7C13,  size=size.tiny, title='Exit Long')
plotshape((showendlabels and endshort and isshort) ? low : na, location=location.belowbar, style=shape.xcross, color=#BF217C, size=size.tiny, title='Exit Short')

alertcondition(golong, title='Long Signal', message='D-RSI: Long Signal')
alertcondition(goshort, title='Short Signal', message='D-RSI: Short Signal')
alertcondition(endlong, title='Exit Long Signal', message='D-RSI: Exit Long')
alertcondition(endshort, title='Exit Short Signal', message='D-RSI: Exit Short')





]]

-- Subroutines
function matrix_get(_A,_i,_j,_nrows)
    return _A[_i+_nrows*_j]
end

function matrix_set(_A,_value,_i,_j,_nrows)
    _A[_i+_nrows*_j] = _value
end
 

function transpose(_A,_nrows,_ncolumns)
    local _AT = {}
	for i= 1, _nrows*_ncolumns  do
	_AT[i]=0;
	end	
	
    for i = 0, _nrows-1 do
        for j = 0, _ncolumns-1 do
            matrix_set(_AT, matrix_get(_A,i,j,_nrows),j,i,_ncolumns)
        end
    end
    return _AT
end


function multiply(_A,_B,_nrowsA,_ncolumnsA,_ncolumnsB)
    local _C = {}
	for i= 1, _nrowsA*_ncolumnsB  do
	_C[i]=0;
	end		
	
    local _nrowsB = _ncolumnsA
    local elementC = 0.0
    for i = 0, _nrowsA-1 do
        for j = 0, _ncolumnsB-1 do
            elementC = 0
            for k = 0, _ncolumnsA-1 do
                elementC = elementC + matrix_get(_A,i,k,_nrowsA)*matrix_get(_B,k,j,_nrowsB)
            end
            matrix_set(_C,elementC,i,j,_nrowsA)
        end
    end
    return _C
end


 
-- Square norm of vector _X with size _n
function vnorm(_X, _n)
    local _norm = 0.0
    for i = 0, _n-1 do
        _norm = _norm + math.pow( _X[i], 2)
    end
    return math.sqrt(_norm)
end

function qr_diag(_A, _nrows, _ncolumns)
    local _Q = {}
	for i= 1, _nrows*_ncolumns do
	_Q[i]=0;
	end
	
    local _R = {}
	for i= 1, _nrows*_ncolumns do
	_R[i]=0;
	end
	
    local _a = {}
	for i= 1, _nrows  do
	_a[i]=0;
	end	
    local _q = {}
	for i= 1, _nrows  do
	_q[i]=0;
	end
    local _r = 0.0
    local _aux = 0.0

    for i = 0, _nrows-1 do
        _a[i] = matrix_get(_A, i, 0, _nrows)
    end
    _r = vnorm(_a, _nrows)

    matrix_set(_R, _r, 0, 0, _ncolumns)
    for i = 0, _nrows-1 do
        matrix_set(_Q, _a[i]/_r, i, 0, _nrows)
    end

    if _ncolumns ~= 1 then
        for k = 1, _ncolumns-1 do
            for i = 0, _nrows-1 do
                _a[i] = matrix_get(_A, i, k, _nrows)
            end
            for j = 0, k-1 do
                _r = 0
                for i = 0, _nrows-1 do
                    _r = _r + matrix_get(_Q, i, j, _nrows)*_a[i]
                end
                matrix_set(_R, _r, j, k, _ncolumns)
                for i = 0, _nrows-1 do
                    _aux = _a[i] - _r*matrix_get(_Q, i, j, _nrows)
                    _a[i] = _aux
                end
            end
            _r = vnorm(_a, _nrows)
            matrix_set(_R, _r, k, k, _ncolumns)
            for i = 0, _nrows-1 do
                matrix_set(_Q, _a[i]/_r, i, k, _nrows)
            end
        end
    end

    return _Q, _R
 
end
 

function pinv(_A, _nrows, _ncolumns)
    -- Pseudoinverse of matrix _A calculated using QR decomposition
    -- Input: 
    -- _A: array: implied as a (_nrows x _ncolumns) matrix _A = [[column_0],[column_1],...,[column_(_ncolumns-1) 
    -- Output: 
    -- _Ainv: array implied as a (_ncolumns x _nrows) matrix _A = [[row_0],[row_1],...,[row_(_nrows-1) 
    -- ----
    -- First find the QR factorization of A: A = QR,
    -- where R is upper triangular matrix.
    -- Then _Ainv = R^-1*Q^T.
    -- ----

    _Q, _R = qr_diag(_A, _nrows, _ncolumns)
    _QT = transpose(_Q, _nrows, _ncolumns)

    -- Calculate Rinv:
    _Rinv = {}
	for i= 1, _ncolumns*_ncolumns do
	_Rinv[i]=0;
	end	
	
    _r = 0.0
    matrix_set(_Rinv, 1/matrix_get(_R, 0, 0, _ncolumns), 0, 0, _ncolumns)
    if _ncolumns ~= 1 then
        for j = 1, _ncolumns-1 do
            for i = 0, j-1 do
                _r = 0.0
                for k = i, j-1 do
                    _r = _r + matrix_get(_Rinv, i, k, _ncolumns) * matrix_get(_R, k, j, _ncolumns)
                end
                matrix_set(_Rinv, _r, i, j, _ncolumns)
            end
            for k = 0, j-1 do
                matrix_set(_Rinv, -matrix_get(_Rinv, k, j, _ncolumns) / matrix_get(_R, j, j, _ncolumns), k, j, _ncolumns)
            end
            matrix_set(_Rinv, 1/matrix_get(_R, j, j, _ncolumns), j, j, _ncolumns)
        end
    end

    _Ainv = multiply(_Rinv, _QT, _ncolumns, _ncolumns, _nrows)
    return _Ainv
end


function norm_rmse(_x, _xhat)  
    -- Root Mean Square Error normalized to the sample mean
    -- _x.   :: array float, original data
    -- _xhat :: array float, model estimate
    -- output
    -- _nrmse:: float
 
        local  _N = #_x--table.getn(_x);
        local _mse = 0.0
        for i = 0 ,  _N-1 do
            _mse = _mse + math.pow( _x[i] -  _xhat[i],2)/_N
		end	
        _xmean = sum_array(_x)/_N
        _nrmse = math.sqrt(_mse) /_xmean
	 
    return _nrmse
end 	

function sum_array(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end

    return sum
end

function Differentiator(_src, _window, _degree, period) 	

    -- Polynomial differentiator
    -- input:
    -- _src: input series
    -- _window: integer: width of the moving lookback window
    -- _degree: integer: degree of fitting polynomial
    -- output:
    -- _diff: series: time derivative

    -- Vandermonde matrix with implied dimensions (window x degree+1)
    -- Linear form: J = [ [z]^0, [z]^1, ... [z]^degree], with z = [ (1-window)/2 to (window-1)/2 ] 
    _J = {}
	for i= 1, _window*(_degree+1) do
	_J[i]=0;
	end		
	
    for i = 0, _window-1 do
        
        for j = 0, _degree do
             matrix_set(_J,math.pow(i,j),i,j,_window)
			--            
        end
    end

    -- Vector of raw datapoints:
    _Y_raw = {}
    for j = 0, _window-1 do
        _Y_raw[j] = _src[period-_window+1+j]
    end

    -- Calculate polynomial coefficients which minimize the loss function
    -- Note: Lua does not have a built-in function for pseudo-inverse or matrix multiplication.
    -- You would need to use a library or implement these functions yourself.
    _C = pinv(_J, _window, _degree+1)
    _a_coef = multiply(_C, _Y_raw, _degree+1, _window, 1)

    -- For smoothing, approximate the last point (i.e. z=window-1) by a0
    _diff = 0.0
    for i = 1, _degree do
        _diff = _diff + i * _a_coef[i] * math.pow(_window-1, i-1)
    end
    -- Calculates data estimate (needed for rmse)
    _Y_hat = multiply(_J,_a_coef,_window,_degree+1,1)
    local  _nrmse = norm_rmse(_Y_raw,_Y_hat)
    return _diff,_nrmse;
end

--[[
/// --- main ---
degree = input(title="Polynomial Order", group = "Model Parameters:",
              inline = "linepar1", type = input.integer, defval=2, minval = 1)
rsi_l = input(title = "RSI Length", group = "Model Parameters:",
              inline = "linepar1", type = input.integer, defval = 21, minval = 1,
              tooltip="The period length of RSI that is used as input.")
window = input(title="Length ( > Order)", group = "Model Parameters:",
              inline = "linepar2", type = input.integer, defval=21, minval = 2)
signalLength = input(title="Signal Length", group = "Model Parameters:",
              inline = "linepar2", type=input.integer, defval=9,
              tooltip="The signal line is a EMA of the D-RSI time series.")
islong = input(title = "Buy", group = "Show Signals:",
              inline = "lineent",type = input.bool, defval = true)
isshort = input(title = "Sell", group = "Show Signals:",
              inline = "lineent", type = input.bool, defval= true)
showendlabels = input(title = "Exit", group = "Show Signals:",
              inline = "lineent", type = input.bool, defval= true)
buycond = input(title="Buy", group = "Entry and Exit Conditions:",
              inline = "linecond",type = input.string, defval="Zero-Crossing",
              options=["Zero-Crossing", "Signal Line Crossing","Direction Change"])
sellcond = input(title="Sell", group = "Entry and Exit Conditions:",
              inline = "linecond",type = input.string, defval="Zero-Crossing",
              options=["Zero-Crossing", "Signal Line Crossing","Direction Change"])
endcond = input(title="Exit", group = "Entry and Exit Conditions:",
              inline = "linecond",type = input.string, defval="Zero-Crossing",
              options=["Zero-Crossing", "Signal Line Crossing","Direction Change"])
usenrmse = input(title = "", group = "Filter by Means of Root-Mean-Square Error of RSI Fitting:",
              inline = "linermse",type = input.bool, defval = false)
rmse_thrs = input(title = "RSI fitting Error Threshold, %", type = input.float,
              group = "Filter by Means of Root-Mean-Square Error of RSI Fitting:",
              inline = "linermse", defval = 10, minval = 0.0) /100


src = rsi(close,rsi_l)
[drsi,nrmse] = diff(src,window,degree)
signalline = ema(drsi, signalLength)

// Conditions and filters
filter_rmse = usenrmse?nrmse<rmse_thrs:true
dirchangeup = (drsi>drsi[1]) and (drsi[1]<drsi[2]) and drsi[1]<0.0
dirchangedw = (drsi<drsi[1]) and (drsi[1]>drsi[2]) and drsi[1]>0.0
crossup = crossover(drsi,0.0)
crossdw = crossunder(drsi,0.0)
crosssignalup = crossover(drsi,signalline)
crosssignaldw = crossunder(drsi,signalline)

//Signals
golong = (buycond=="Direction Change"?dirchangeup:(buycond=="Zero-Crossing"?crossup:crosssignalup)) and  filter_rmse
goshort= (sellcond=="Direction Change"?dirchangedw:(sellcond=="Zero-Crossing"?crossdw:crosssignaldw)) and  filter_rmse
endlong = (endcond=="Direction Change"?dirchangedw:(endcond=="Zero-Crossing"?crossdw:crosssignaldw)) and filter_rmse
endshort= (endcond=="Direction Change"?dirchangeup:(endcond=="Zero-Crossing"?crossup:crosssignalup)) and filter_rmse
plotshape((golong and islong)  ? low : na, location=location.belowbar, style=shape.labelup,   color=#2E7C13,  size=size.small, title='Buy')
plotshape((goshort and isshort) ? high: na, location=location.abovebar, style=shape.labeldown, color=#BF217C, size=size.small, title='Sell')
plotshape((showendlabels and endlong and islong)  ? high: na, location=location.abovebar, style=shape.xcross,   color=#2E7C13,  size=size.tiny, title='Exit Long')
plotshape((showendlabels and endshort and isshort) ? low : na, location=location.belowbar, style=shape.xcross, color=#BF217C, size=size.tiny, title='Exit Short')

alertcondition(golong, title='Long Signal', message='D-RSI: Long Signal')
alertcondition(goshort, title='Short Signal', message='D-RSI: Short Signal')
alertcondition(endlong, title='Exit Long Signal', message='D-RSI: Exit Long')
alertcondition(endshort, title='Exit Short Signal', message='D-RSI: Exit Short')

]]

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
 