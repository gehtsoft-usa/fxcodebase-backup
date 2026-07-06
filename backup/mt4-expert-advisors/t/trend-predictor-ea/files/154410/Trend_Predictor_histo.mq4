//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74280 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_label1 "Bar Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Bar Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double LineUp[];
double LineDn[];
double histo[];

// ------------------------------------------------------------------
input ENUM_TIMEFRAMES tf1 = PERIOD_M15; // TF 1:
input ENUM_TIMEFRAMES tf2 = PERIOD_H1;  // TF 2:
input ENUM_TIMEFRAMES tf3 = PERIOD_H4;  // TF 3:

input string Tindi                     = "== Indicator Setup =="; // ————————————
input int    inp_zone_period           = 10;                      // zone period
input int    inp_amplitude_period      = 25;                      // zone amplitude
input double inp_amplitude_coefficient = 3;                       // zone coefficient
// ------------------------------------------------------------------
input string T2                    = "== Set Histo ==";     // ————————————
input bool acumMode = false; // Acumulation Mode:
input int    candlesBack           = 1000;                  // Candles Back
input color  LineUpClr             = clrBlue;               // Line Up Color:
input color  LineDnClr             = clrRed;                // Line Down Color:

// ------------------------------------------------------------------

class CNewCandle
{
  private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

  public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol         = Symbol();
        _tf             = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if (_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

string file_custom_indicator = "TrendPredictor_v1.0";
int    bufferToBuy           = 0;
int    bufferToSell          = 1;

double Indi(int buffer, int candle, ENUM_TIMEFRAMES tf = 0)
{
    return iCustom(NULL, tf, file_custom_indicator,
                   inp_zone_period, inp_amplitude_period, inp_amplitude_coefficient,
                   buffer, candle);
}

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 1, LineUpClr);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 1, LineDnClr);
    SetIndexBuffer(2, histo);
    SetIndexStyle(2, DRAW_NONE);
    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = candlesBack;          
    } else {
        start = rates_total - (prev_calculated - 1);
    }



    for (i = start; i >= 0; i--) {


            if(i == start) histo[i] = 0;
            else { histo[i] = histo[i+1];}

        datetime tm = time[i];
        
        int i_tf1=  iBarShift(_Symbol, tf1, tm, true);
        int i_tf2=  iBarShift(_Symbol, tf2, tm, true);
        int i_tf3=  iBarShift(_Symbol, tf3, tm, true);
    
        double trend1 =0;
        double trend2 =0;
        double trend3 =0;
        
        if(i_tf1 >0){ 
            double in1 = Indi(6, i_tf1, tf1);
            if(in1 != EMPTY_VALUE) trend1 = in1;        
        }
        if(i_tf2 >0){ 
            double in2 = Indi(6, i_tf2, tf2);
            if(in2 != EMPTY_VALUE) trend2 = in2;        
        }
        if(i_tf2 >0){ 
            double in3 = Indi(6, i_tf3, tf3);
            if(in3 != EMPTY_VALUE) trend3 = in3;        
        }

        if(acumMode){
            histo[i] += trend1;
            histo[i] += trend2;
            histo[i] += trend3;
        } else 
        {
            histo[i] = trend1 + trend2 + trend3;
        }

        
        if (histo[i] > 0) { LineUp[i] = histo[i]; LineDn[i]=0; }
        if (histo[i] < 0) { LineDn[i] = histo[i]; LineUp[i]=0; }
        

    }
    return (rates_total);
}

// ------------------------------------------------------------------

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+
