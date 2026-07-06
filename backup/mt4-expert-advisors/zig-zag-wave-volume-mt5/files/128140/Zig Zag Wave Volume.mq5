// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68835

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
#property indicator_buffers 2
#property indicator_plots 2

input int      ExtDepth=12;
input int      ExtDeviation=5;
input int      ExtBackstep=3;
input color clr = Red; // Label color

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

double p_arr[], p_arr2[];
int zigzag_handle;

void OnInit()
{
   IndicatorName = GenerateIndicatorName("Zig Zag Wave Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   zigzag_handle = iCustom(_Symbol, _Period, "Examples\\ZigZag", ExtDepth, ExtDeviation, ExtBackstep);
   int id = 0;
   SetIndexBuffer(id + 0, p_arr, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_ZIGZAG);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetDouble(id + 0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   ++id;
   
   SetIndexBuffer(id + 0, p_arr2, INDICATOR_DATA);
   PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_ZIGZAG);
   PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetDouble(id + 0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(zigzag_handle);
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
   if (prev_calculated == 0)
      ArrayInitialize(p_arr, EMPTY_VALUE);

   for (int pos = prev_calculated - 1; pos < rates_total; ++pos)
   {
      int pos1 = -1;
      int pos2 = -1;
      for (int i = pos; i > 0; --i)
      {
         double buffer[1];
         if (CopyBuffer(zigzag_handle, 0, rates_total - 1 - i, 1, buffer) != 1)
         {
            break;
         }
         if (buffer[0] == 0)
         {
            p_arr[i] = EMPTY_VALUE;
            string id = IndicatorObjPrefix + "textId" + TimeToString(time[i]);
            ObjectDelete(0, id);
         }
         else
         {
            p_arr[i] = buffer[0];
            pos2 = pos1;
            pos1 = i;
         }
         p_arr2[i] = p_arr[i];
         if (pos2 != -1)
         {
            break;
         }
      }
      if (pos2 != -1)
      {
         DrawLabel(time, tick_volume, pos1, pos2);
      }
   }
   return rates_total;
}

void DrawLabel(const datetime& time[], const long &volume[], int last_pos, int pos)
{
   if (last_pos == -1)
      return;
   long total = 0;
   for (int i = last_pos; i < pos; ++i)
   {
      total += volume[i];
   }
   string id = IndicatorObjPrefix + "textId" + TimeToString(time[pos]);
   if (ObjectFind(0, id) == -1)
   {
      if (ObjectCreate(0, id, OBJ_TEXT, 0, time[pos], p_arr[pos]))
      {
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      }
   }
   ObjectSetString(0, id, OBJPROP_TEXT, IntegerToString(total));
}