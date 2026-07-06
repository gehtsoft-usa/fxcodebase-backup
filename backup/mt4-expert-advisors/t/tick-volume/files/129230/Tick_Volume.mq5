// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69019

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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3

enum Method
{
   Cumulative,
   Separated,
   Absolute
};

input Method method = Cumulative;

double prevAsk, prevBid;
double Up[], Down[], output[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

void OnInit()
{
   IndicatorName = GenerateIndicatorName("Tick Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   prevAsk = 0;
   prevBid = 0;

   int id = 0;
   if (method == Cumulative)
   {
      SetIndexBuffer(id + 0, output, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      PlotIndexSetString(id, PLOT_LABEL, "Cumulative");
      ++id;
      SetIndexBuffer(id + 0, Up, INDICATOR_CALCULATIONS);
      ++id;
      SetIndexBuffer(id + 0, Down, INDICATOR_CALCULATIONS);
   }
   else if (method == Absolute)
   {
      SetIndexBuffer(id + 0, output, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      PlotIndexSetString(id, PLOT_LABEL, "Absolute");
      ++id;
      SetIndexBuffer(id + 0, Up, INDICATOR_CALCULATIONS);
      ++id;
      SetIndexBuffer(id + 0, Down, INDICATOR_CALCULATIONS);
   }
   else
   {
      SetIndexBuffer(id + 0, Up, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      PlotIndexSetString(id, PLOT_LABEL, "Up");
      ++id;
      SetIndexBuffer(id + 0, Down, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      PlotIndexSetString(id, PLOT_LABEL, "Down");
   }
}

void OnDeinit(const int reason)
{
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
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if (Up[rates_total - 1] == EMPTY_VALUE)
   {
      Up[rates_total - 1] = 0;
      Down[rates_total - 1] = 0;

      if (ask != prevAsk)
      {
         if (ask > prevAsk)
            Up[rates_total - 1] = Up[rates_total - 1] + 1;
         else
            Down[rates_total - 1] = Down[rates_total - 1] + 1;
            
         prevAsk = ask;
      }

      if (bid != prevBid)
      {
         if (bid > prevBid)
            Up[rates_total - 1] = Up[rates_total - 1] + 1;
         else
            Down[rates_total - 1] = Down[rates_total - 1] + 1;
         prevBid = bid;
      }
   }
   else
   {
      if (ask != prevAsk)
      {
         if (ask > prevAsk)
            Up[rates_total - 1] = Up[rates_total - 1] + 1;
         else
            Down[rates_total - 1] = Down[rates_total - 1] - 1;
            
         prevAsk = ask;
      }

      if (bid != prevBid)
      {
         if (bid > prevBid)
            Up[rates_total - 1] = Up[rates_total - 1] + 1;
         else
            Down[rates_total - 1] = Down[rates_total - 1] - 1;
         prevBid = bid;
      }
   }
   if (method == Cumulative)
   {
      output[rates_total - 1] = Up[rates_total - 1] + Down[rates_total - 1];
   }
   else if (method == Separated)
   {
      output[rates_total - 1] = Up[rates_total - 1] + MathAbs(Down[rates_total - 1]);
   }
   return rates_total;
}
   