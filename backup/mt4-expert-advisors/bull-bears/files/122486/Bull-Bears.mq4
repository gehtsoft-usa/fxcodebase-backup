// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67044

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Violet

extern int Period = 12;
double out1[];
double out2[];
double out3[];
string message = "";
string indicator_name = "Bull-Bear";

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

int init() {
   IndicatorName = GenerateIndicatorName(indicator_name);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, out1);
   SetIndexBuffer(1, out2);
   SetIndexBuffer(2, out3);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   
   return (0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start() {
   double ld_0;
   double ld_8;
   double highLowMiddle;
   int counted = IndicatorCounted();
   if (counted < 0) return (-1);
   if (counted > 0) counted--;
   double temp = 0;
   double prevTemp = 0;
   double prevOut = 0;
   double lowest = 0;
   double highest = 0;
   creataalltext();
   int li_112 = 16777215;
   if (counted > 0) counted--;
   int limit = Bars - counted;
   for (int period = 0; period < limit; period++)
   {
      highest = High[iHighest(NULL, 0, MODE_HIGH, period, Period)];
      lowest = Low[iLowest(NULL, 0, MODE_LOW, period, Period)];
      highLowMiddle = (High[period] + Low[period]) / 2.0;
      if (highest - lowest != 0)
      {
         temp = 0.66 * ((highLowMiddle - lowest) / (highest - lowest) - 0.5) + 0.67 * prevTemp;
         temp = MathMin(MathMax(temp, -0.999), 0.999);
         out1[period] = MathLog((temp + 1.0) / (1 - temp)) / 2.0 + prevOut / 2.0;
         prevTemp = temp;
         prevOut = out1[period];
      }
   }
   bool bear = TRUE;
   for (period = limit - 2; period >= 0; period--) {
      ld_8 = out1[period];
      ld_0 = out1[period + 1];
      if ((ld_8 < 0.0 && ld_0 > 0.0) || ld_8 < 0.0) bear = FALSE;
      if ((ld_8 > 0.0 && ld_0 < 0.0) || ld_8 > 0.0) bear = TRUE;
      if (!bear) {
         out3[period] = ld_8;
         out2[period] = 0.0;
         message = "Bear";
         li_112 = 65535;
      } else {
         out2[period] = ld_8;
         out3[period] = 0.0;
         message = "Bull";
         li_112 = 65280;
      }
   }
   settext("Text Label", message, 12, li_112, 10, 15);
   return (0);
}

void creataalltext() {
   createtext("Text Label");
   settext("Text Label", "", 12, White, 10, 15);
}

void createtext(string a_name_0) {
   ObjectCreate(IndicatorObjPrefix + a_name_0, OBJ_LABEL, WindowFind(indicator_name), 0, 0);
}

void settext(string a_name_0, string a_text_8, int a_fontsize_16, color a_color_20, int a_x_24, int a_y_28) {
   ObjectSet(IndicatorObjPrefix + a_name_0, OBJPROP_XDISTANCE, a_x_24);
   ObjectSet(IndicatorObjPrefix + a_name_0, OBJPROP_YDISTANCE, a_y_28);
   ObjectSetText(IndicatorObjPrefix + a_name_0, a_text_8, a_fontsize_16, "Arial", a_color_20);
}

