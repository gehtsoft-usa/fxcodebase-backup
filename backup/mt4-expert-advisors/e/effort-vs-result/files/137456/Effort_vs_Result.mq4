// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70406


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
//--- Signal line
#property indicator_label1  "Effort vs Result"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- indicator buffers
double         SignalBuffer[];
//--- input parameters
input int ma_period=30; // MA Reiod
input ENUM_MA_METHOD ma_method=MODE_SMA; // MA Method
input ENUM_APPLIED_PRICE ma_price=PRICE_CLOSE; // MA Price
input int atr_period=14; // ATR Reiod

string short_name;
int StartBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(1);
//--- indicator buffers mapping
   SetIndexBuffer(0,SignalBuffer);
   
   
   short_name="Effort vs Result("+string(ma_period)+","+
                                  string(atr_period)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//---
   return(INIT_SUCCEEDED);
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
int counted, i;    
    if(Bars <= StartBar)
        return (0);

    counted = IndicatorCounted();
    if(counted < 1)
        for(i = Bars - StartBar; i < Bars; i++)
        {
            SignalBuffer[i] = 0.0;
        }

  
    counted = Bars - counted - 1;
        
    for (i = counted; i >= 0; i--)
        SignalBuffer[i] = getAtrValue(i)/getMaValue(i);      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


double getAtrValue(int i)
{
   return iATR(NULL, NULL, atr_period, i);
}

double getMaValue(int i)
{
   double res = iMA(NULL,NULL,ma_period, 0 ,ma_method,ma_price,i);
   if(res == 0) res =1;
   return res;
}