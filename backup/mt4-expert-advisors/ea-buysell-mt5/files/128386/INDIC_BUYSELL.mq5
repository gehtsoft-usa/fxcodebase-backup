// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68875

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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 2
#property indicator_color1 Blue
#property indicator_color2 Red

double arrow_up[];
double arrow_down[];
double buffer[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

int atr_handle;
double pointSize;

void OnInit()
{
   IndicatorName = GenerateIndicatorName("INDIC_BUYSELL");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   atr_handle = iATR(_Symbol, _Period, 10);

   int id = 0;
   SetIndexBuffer(id + 0, arrow_up, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 233);
   id++;

   SetIndexBuffer(id + 0, arrow_down, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, 234);

   SetIndexBuffer(id + 1, buffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 2, buffer2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 3, buffer3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 4, buffer4, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 5, buffer5, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 6, buffer6, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id + 7, buffer7, INDICATOR_CALCULATIONS);
   pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(atr_handle);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(arrow_up, EMPTY_VALUE);
      ArrayInitialize(arrow_down, EMPTY_VALUE);
   }
   for (int pos = MathMax(7, prev_calculated); pos < rates_total; ++pos)
   {
      double spreadRate = spread[pos] * pointSize;
      buffer[pos] = MathMax(MathAbs(low[pos] - close[pos - 1]), MathMax(MathAbs(spreadRate + high[pos] - close[pos - 1]), spreadRate + high[pos] - low[pos]));
      double ld_68 = 0;
      for (int i = 0; i < 7; i++) 
         ld_68 += buffer[pos - i] * (i + 1);
      ld_68 = 2.0 * ld_68 / (7 * (7 + 1.0));

      double ld_44 = 0.7 * ld_68;
      buffer2[pos] = buffer2[pos - 1];
      buffer3[pos] = buffer3[pos - 1];
      if (buffer2[pos] != -1 && low[pos] < buffer3[pos] - ld_44) 
      {
         buffer2[pos] = -1;
         buffer3[pos] = spreadRate + high[pos];
      }
      if (buffer2[pos] != 1 && spreadRate + high[pos] > buffer3[pos] + ld_44) 
      {
         buffer2[pos] = 1;
         buffer3[pos] = low[pos];
      }
      if (buffer2[pos] != -1 && low[pos] > buffer3[pos]) 
         buffer3[pos] = low[pos];
      if (buffer2[pos] != 1 && spreadRate + high[pos] < buffer3[pos]) 
         buffer3[pos] = spreadRate + high[pos];
      buffer4[pos] = buffer4[pos - 1];
      buffer5[pos] = buffer5[pos - 1];
      buffer6[pos] = buffer6[pos - 1];
      buffer7[pos] = buffer7[pos - 1];
      
      double atr[1];
      if (!CopyBuffer(atr_handle, 0, rates_total - 1 - pos, 1, atr) == 1)
         continue;
      if (buffer2[pos] != -1) 
      {
         if (buffer4[pos] != 1) 
            buffer5[pos] = low[pos] - atr[0] * 2 / 3.0;
         else if (buffer4[pos] == 1) 
            buffer5[pos] = -1.0;
         if (buffer5[pos] > 0.0) 
         {
            buffer6[pos] = buffer5[pos];
            buffer7[pos] = EMPTY_VALUE;
         } 
         else 
         {
            buffer6[pos] = EMPTY_VALUE;
            buffer7[pos] = EMPTY_VALUE;
         }
         arrow_up[pos] = buffer6[pos];
         buffer4[pos] = 1;
      } 
      else 
      {
         if (buffer4[pos] != 2) 
            buffer5[pos] = spreadRate + high[pos] + atr[0] * 2 / 3.0;
         else if (buffer4[pos] == 2) 
            buffer5[pos] = -1.0;
         if (buffer5[pos] > 0.0) 
         {
            buffer6[pos] = EMPTY_VALUE;
            buffer7[pos] = buffer5[pos];
         } 
         else 
         {
            buffer6[pos] = EMPTY_VALUE;
            buffer7[pos] = EMPTY_VALUE;
         }
         arrow_down[pos] = buffer7[pos];
         buffer4[pos] = 2;
      }
   }
   return rates_total;
}