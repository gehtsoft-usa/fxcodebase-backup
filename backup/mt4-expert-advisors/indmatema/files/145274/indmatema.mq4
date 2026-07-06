// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71947

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 11
#property indicator_plots   3
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_color2  clrRed
#property indicator_color3  clrGray
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_label1  "MATEMA"
#property indicator_label2  "MATEMA"
#property indicator_label3  "MATEMA"
//#property indicator_style1  STYLE_SOLID
#property indicator_level1  0.0

//--- input parameters
//--- 1 MA
input int            InpMA1Period = 10;      // Period MA Close
input ENUM_MA_METHOD InpMA1Method = MODE_SMMA; // Method MA Close
int                  InpMA1Shift = 0;        // Shift  MA Close
ENUM_APPLIED_PRICE   InpMA1Price = PRICE_CLOSE; // PriceClose MA Close
//--- 2 MA
input int            InpMA2Period = 10;      // Period MA Open
input ENUM_MA_METHOD InpMA2Method = MODE_SMMA; // Method MA Open
int                  InpMA2Shift = 0;        // Shift  MA Open
ENUM_APPLIED_PRICE   InpMA2Price = PRICE_OPEN; // PriceOpen MA Open

input double         delta = 0.0002;         // Delta

//--- 1 TEMA
input int            InpTEMA1Period = 20;    // Period TEMA Close
int                  InpTEMA1Shift = 0;      // Shift TEMA Close
ENUM_APPLIED_PRICE   InpTEMA1Price = PRICE_CLOSE; // PriceClose TEMA Close
//--- 2 TEMA
input int            InpTEMA2Period = 20;    // Period TEMA Open
int                  InpTEMA2Shift = 0;      // Shift  TEMA Open
ENUM_APPLIED_PRICE   InpTEMA2Price = PRICE_OPEN; // PriceOpen TEMA Open

//--- indicator buffers
double ExtBuffer1[], ExtBuffer2[], ExtBuffer3[];
double ExtColorBuffer[];
//--- MA Buffers
double ExtMAOpenBuffer[];
double ExtMACloseBuffer[];
double ExtMABuffer[];
//--- TEMA Buffers
double ExtTEMAOpenBuffer[];
double ExtTEMACloseBuffer[];
double ExtTEMABuffer[];

double Ema1xO[], Ema2xO[], Ema3xO[], TEmaO[];
double Ema1xC[], Ema2xC[], Ema3xC[], TEmaC[];

int DATA_LIMIT;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
    {
//--- indicator buffers mapping
     SetIndexBuffer(0, ExtBuffer1, INDICATOR_DATA);
     SetIndexStyle(0, DRAW_HISTOGRAM);
     SetIndexBuffer(1, ExtBuffer2, INDICATOR_DATA);
     SetIndexStyle(1, DRAW_HISTOGRAM);
     SetIndexBuffer(2, ExtBuffer3, INDICATOR_DATA);
     SetIndexStyle(2, DRAW_HISTOGRAM);
     SetIndexBuffer(3, Ema1xO);
     SetIndexStyle(3, DRAW_NONE);
     SetIndexLabel(3, "");
     SetIndexBuffer(4, Ema2xO);
     SetIndexStyle(4, DRAW_NONE);
     SetIndexLabel(4, "");
     SetIndexBuffer(5, Ema3xO);
     SetIndexStyle(5, DRAW_NONE);
     SetIndexLabel(5, "");
     SetIndexBuffer(6, TEmaO);
     SetIndexStyle(6, DRAW_NONE);
     SetIndexLabel(6, "");
     SetIndexBuffer(7, Ema1xC);
     SetIndexStyle(7, DRAW_NONE);
     SetIndexLabel(7, "");
     SetIndexBuffer(8, Ema2xC);
     SetIndexStyle(8, DRAW_NONE);
     SetIndexLabel(8, "");
     SetIndexBuffer(9, Ema3xC);
     SetIndexStyle(9, DRAW_NONE);
     SetIndexLabel(9, "");
     SetIndexBuffer(10, TEmaC);
     SetIndexStyle(10, DRAW_NONE);
     SetIndexLabel(10, "");
//--- set accuracy
     IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
//--- sets first bar from what index will be drawn
     PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, DATA_LIMIT);
//--- name for DataWindow
     IndicatorSetString(INDICATOR_SHORTNAME, "MATEMA (" + string(InpMA1Period) + " - " + string(InpMA2Period) + " : " + string(InpTEMA1Period) + " - " + string(InpTEMA2Period) + ")");
//--- get handles
     int per1 = MathMax(InpMA1Period, InpMA2Period);
     int per2 = MathMax(InpTEMA1Period, InpTEMA2Period);
     DATA_LIMIT = MathMax(per1, per2);
//---
     return(0);
    }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
    {
     int i, limit;
     double MAOpenBuffer, MACloseBuffer, MABuffer, TEMABuffer, Buffer;
     int limit1, limit2, limit3;
     if(IsNewBar() || ArrayMaximum(ExtBuffer1) == NULL || ArrayMinimum(ExtBuffer2) == NULL)
         {
          ArrayInitialize(ExtBuffer1, NULL);
          ArrayInitialize(ExtBuffer2, NULL);
          ArrayInitialize(ExtBuffer3, NULL);
          limit1 = rates_total - 1 - DATA_LIMIT;
          limit2 = limit1 - InpTEMA1Period;
          limit3 = limit2 - InpTEMA1Period;
         }
     else
         {
          limit1 = 1;
          limit2 = limit1;
          limit3 = limit2;
         }
     for(i = 0; i <= limit1; i++)
          Ema1xO[i] = iMA(NULL, 0, InpTEMA1Period, InpTEMA1Shift, MODE_EMA, InpTEMA1Price, i);
     for(i = 0; i <= limit2; i++)
          Ema2xO[i] = iMAOnArray(Ema1xO, 0, InpTEMA1Period, 0, MODE_EMA, i);
     for(i = 0; i <= limit3; i++)
          Ema3xO[i] = iMAOnArray(Ema2xO, 0, InpTEMA1Period, 0, MODE_EMA, i);
     for(i = 0; i <= limit3; i++)
          TEmaO[i] = 3 * Ema1xO[i] - 3 * Ema2xO[i] + Ema3xO[i];
     for(i = 0; i <= limit1; i++)
          Ema1xC[i] = iMA(NULL, 0, InpTEMA2Period, InpTEMA2Shift, MODE_EMA, InpTEMA2Price, i);
     for(i = 0; i <= limit2; i++)
          Ema2xC[i] = iMAOnArray(Ema1xC, 0, InpTEMA2Period, 0, MODE_EMA, i);
     for(i = 0; i <= limit3; i++)
          Ema3xC[i] = iMAOnArray(Ema2xC, 0, InpTEMA2Period, 0, MODE_EMA, i);
     for(i = 0; i <= limit3; i++)
          TEmaC[i] = 3 * Ema1xC[i] - 3 * Ema2xC[i] + Ema3xC[i];
     for(i = 0; i < limit1 && !IsStopped(); i++)
         {
          MAOpenBuffer = iMA(_Symbol, _Period, InpMA1Period, InpMA1Shift, InpMA1Method, InpMA1Price, i);
          MACloseBuffer = iMA(_Symbol, _Period, InpMA2Period, InpMA2Shift, InpMA2Method, InpMA2Price, i);
          MABuffer = MAOpenBuffer - MACloseBuffer;
          TEMABuffer = TEmaO[i] - TEmaC[i];
          Buffer = MABuffer + TEMABuffer;
          if(MathAbs(Buffer) < delta)
               ExtBuffer3[i] = Buffer;
          else
              {
               if(Buffer >= 0)
                    ExtBuffer1[i] = Buffer;
               else
                    ExtBuffer2[i] = Buffer;
              }
         }
//--- return value of prev_calculated for next call
     return(rates_total);
    }
//+------------------------------------------------------------------+
bool IsNewBar()
    {
     static datetime lastbar;
     datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
     if(lastbar != curbar)
         {
          lastbar = curbar;
          return true;
         }
     return false;
    }
//+------------------------------------------------------------------+
