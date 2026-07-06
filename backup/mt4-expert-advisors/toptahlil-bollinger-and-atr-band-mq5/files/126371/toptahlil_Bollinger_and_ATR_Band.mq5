// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68471

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+
input double ATRMult=2;
input int ATR_Period=10;
input int Band_Period=20;
input double  Band_Diviations=3;
input int Band_Shift=0;
input ENUM_APPLIED_PRICE Band_ApplyPrice=PRICE_MEDIAN;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+
int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];
double ExtHistoBuffer3[];
double ExtHistoBuffer4[];
int _bbhandle;
int _atrhandle;

int OnInit()
{
   SetIndexBuffer(0, ExtHistoBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, indicator_style1);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, indicator_color1);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(1, ExtHistoBuffer2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, indicator_style2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, indicator_color2);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);

   SetIndexBuffer(2, ExtHistoBuffer3, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, indicator_style3);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, indicator_color3);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
   
   SetIndexBuffer(3, ExtHistoBuffer4, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, indicator_style4);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, indicator_color4);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);

   _bbhandle = iBands(_Symbol, Period(), Band_Period, Band_Shift, Band_Diviations, Band_ApplyPrice); 
   _atrhandle = iATR(_Symbol, Period(), ATR_Period); 

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(_bbhandle);
   IndicatorRelease(_atrhandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
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
   if (prev_calculated == 0)
   {
      ArrayInitialize(ExtHistoBuffer, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer2, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer3, EMPTY_VALUE);
      ArrayInitialize(ExtHistoBuffer4, EMPTY_VALUE);
   }
   int start = MathMax(0, rates_total - 1 - prev_calculated);
   for (int shift = start; shift >= 0; shift--)
   {
      double up[1];
      if (CopyBuffer(_bbhandle, UPPER_BAND, shift, 1, up) != 1 && up[0] != EMPTY_VALUE)
         continue;
      double down[1];
      if (CopyBuffer(_bbhandle, LOWER_BAND, shift, 1, down) != 1 && down[0] != EMPTY_VALUE)
         continue;

      double atr[1];
      if (CopyBuffer(_atrhandle, 0, shift, 1, atr) != 1 && atr[0] != EMPTY_VALUE)
         continue;

      double KU = up[0] + ATRMult * atr[0];
      double KL = down[0] - ATRMult * atr[0];
      ExtHistoBuffer[rates_total - 1 - shift] = KU;
      ExtHistoBuffer2[rates_total - 1 - shift] = KL;
      ExtHistoBuffer3[rates_total - 1 - shift] = up[0];
      ExtHistoBuffer4[rates_total - 1 - shift] = down[0];
   }
   Print(ExtHistoBuffer3[rates_total - 1]);
      
   return rates_total;
}
//+------------------------------------------------------------------+
