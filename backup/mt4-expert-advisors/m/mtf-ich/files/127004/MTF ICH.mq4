// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68588

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
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 SandyBrown
#property indicator_color4 Thistle
#property indicator_color5 Lime
#property indicator_color6 SandyBrown
#property indicator_color7 Thistle
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style3 2
#property indicator_style4 2
#property indicator_style6 1
#property indicator_style7 1

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Timeframe
extern int  tenkan_sen                = 9; // Tenkan sen
extern int  kijun_sen                 = 26; // Kijun sen
extern int  senkoi_span_b             = 52; // Senkou span b

double Tenkan_Buffer[];
double Kijun_Buffer[];
double SpanA_Buffer[];
double SpanB_Buffer[];
double Chinkou_Buffer[];
double SpanA2_Buffer[];
double SpanB2_Buffer[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
int a_begin;
int rate;
ENUM_TIMEFRAMES TF;
int init()
{
   IndicatorName = GenerateIndicatorName("MTF ICH");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Tenkan_Buffer);
   SetIndexDrawBegin(0, tenkan_sen - 1);
   SetIndexLabel(0, "Tenkan Sen");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Kijun_Buffer);
   SetIndexDrawBegin(1, kijun_sen - 1);
   SetIndexLabel(1, "Kijun Sen");
   a_begin = MathMax(kijun_sen, tenkan_sen);

   TF = TimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)Period() : TimeFrame;
   rate = TF / Period();

   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, SpanA_Buffer);
   SetIndexDrawBegin(2, kijun_sen + a_begin - 1);
   SetIndexShift(2, kijun_sen * rate);
   SetIndexLabel(2, NULL);

   SetIndexStyle(5, DRAW_LINE);
   SetIndexBuffer(5, SpanA2_Buffer);
   SetIndexDrawBegin(5, kijun_sen + a_begin - 1);
   SetIndexShift(5, kijun_sen * rate);
   SetIndexLabel(5, "Senkou Span A");

   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, SpanB_Buffer);
   SetIndexDrawBegin(3, kijun_sen + senkoi_span_b - 1);
   SetIndexShift(3, kijun_sen * rate);
   SetIndexLabel(3, NULL);

   SetIndexStyle(6, DRAW_LINE);
   SetIndexBuffer(6, SpanB2_Buffer);
   SetIndexDrawBegin(6, kijun_sen + senkoi_span_b - 1);
   SetIndexShift(6, kijun_sen * rate);
   SetIndexLabel(6, "Senkou Span B");

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, Chinkou_Buffer);
   SetIndexShift(4, -kijun_sen * rate);
   SetIndexLabel(4, "Chinkou Span");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 - kijun_sen * rate : Bars - 1 - kijun_sen * rate;
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = iBarShift(_Symbol, TimeFrame, Time[pos]);
      if (index < 0)
         continue;

      double tenkanSenValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_TENKANSEN, index);
      double kijunSenValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_KIJUNSEN, index);
      double senkouSpanAValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANA, index);
      double senkouSpanBValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANB, index);
      double chikouSpanValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_CHIKOUSPAN, index);
      
      Tenkan_Buffer[pos] = tenkanSenValue;
      Kijun_Buffer[pos] = kijunSenValue;
      SpanA_Buffer[pos + kijun_sen * rate] = senkouSpanAValue;
      SpanB_Buffer[pos + kijun_sen * rate] = senkouSpanBValue;
      Chinkou_Buffer[pos] = chikouSpanValue;
      SpanA2_Buffer[pos + kijun_sen * rate] = senkouSpanAValue;
      SpanB2_Buffer[pos + kijun_sen * rate] = senkouSpanBValue;
   }
   for (int pos = -1; pos > -kijun_sen * rate; --pos)
   {
      int index = (int)MathCeil(pos / (double)rate);

      double senkouSpanAValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANA, index);
      double senkouSpanBValue = iIchimoku(_Symbol, TimeFrame, tenkan_sen, kijun_sen, senkoi_span_b, MODE_SENKOUSPANB, index);
      
      SpanA_Buffer[pos + kijun_sen * rate] = senkouSpanAValue;
      SpanB_Buffer[pos + kijun_sen * rate] = senkouSpanBValue;
      SpanA2_Buffer[pos + kijun_sen * rate] = senkouSpanAValue;
      SpanB2_Buffer[pos + kijun_sen * rate] = senkouSpanBValue;
   }
   return 0;
}