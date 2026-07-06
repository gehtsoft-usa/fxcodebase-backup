//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 Lime
#property indicator_color6 Red

input bool ALERTS = true;
input bool SoundAlerts = true;
input string SoundAlertFile = "alert.wave";
input bool eMailAlerts = true;
int G_bars_96;
int Gi_100 = 21;
double G_ibuf_104[];
double G_ibuf_108[];
double G_ibuf_112[];
double G_ibuf_116[];
double G_ibuf_120[];
double G_ibuf_124[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
{
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE, EMPTY, 3);
   SetIndexStyle(2, DRAW_LINE, EMPTY, 3);
   SetIndexStyle(3, DRAW_LINE, EMPTY, 3);
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(4, 225);
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 2);
   SetIndexArrow(5, 226);
   IndicatorDigits(Digits + 0);
   SetIndexBuffer(0, G_ibuf_104);
   SetIndexBuffer(1, G_ibuf_108);
   SetIndexBuffer(2, G_ibuf_112);
   SetIndexBuffer(3, G_ibuf_116);
   SetIndexBuffer(4, G_ibuf_120);
   SetIndexBuffer(5, G_ibuf_124);
   IndicatorShortName("MEGAFXPROFIT � www.megafxprofit.com");
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, NULL);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start()
{
   double Ld_0;
   double Ld_8;
   double Ld_16;
   string Ls_104;
   string Ls_112;
   string Ls_120;
   int Li_24 = IndicatorCounted();
   double Ld_28 = 0;
   double Ld_36 = 0;
   double Ld_60 = 0;
   double low_76 = 0;
   double high_84 = 0;
   if (Li_24 > 0)
      Li_24--;
   int Li_92 = Bars - Li_24;
   for (int Li_96 = 0; Li_96 < Li_92; Li_96++)
   {
      high_84 = High[iHighest(NULL, 0, MODE_HIGH, Gi_100, Li_96)];
      low_76 = Low[iLowest(NULL, 0, MODE_LOW, Gi_100, Li_96)];
      Ld_16 = (High[Li_96] + Low[Li_96]) / 2.0;
      double hlDiff = high_84 - low_76;
      Ld_28 = (hlDiff == 0 ? 0 : 0.66 * ((Ld_16 - low_76) / hlDiff - 0.5)) + 0.67 * Ld_36;
      Ld_28 = MathMin(MathMax(Ld_28, -0.999), 0.999);
      G_ibuf_104[Li_96] = MathLog((Ld_28 + 1.0) / (1 - Ld_28)) / 2.0 + Ld_60 / 2.0;
      Ld_36 = Ld_28;
      Ld_60 = G_ibuf_104[Li_96];
   }
   bool Li_100 = true;
   for (Li_96 = Li_92 - 2; Li_96 >= 0; Li_96--)
   {
      G_ibuf_116[Li_96] = 0;
      Ld_8 = G_ibuf_104[Li_96 + 1];
      Ld_0 = G_ibuf_104[Li_96 + 2];
      if ((Ld_8 < 0.0 && Ld_0 > 0.0) || Ld_8 < 0.0)
      {
         Li_100 = false;
         if (Ld_8 < 0.0 && Ld_0 > 0.0)
         {
            Ls_104 = Symbol() + ", TF:" + f0_0(Period());
            Ls_112 = Ls_104 + ", MEGAFXPROFIT SELL SIGNAL for Level: " + Ld_8;
            Ls_120 = Ls_112 + " @ " + TimeToStr(TimeLocal(), TIME_SECONDS);
            if (Bars > G_bars_96)
            {
               G_bars_96 = Bars;
               f0_1(Ls_120, Ls_112);
            }
         }
      }
      if ((Ld_8 > 0.0 && Ld_0 < 0.0) || Ld_8 > 0.0)
      {
         Li_100 = true;
         if (Ld_8 > 0.0 && Ld_0 < 0.0)
         {
            Ls_104 = Symbol() + ", TF:" + f0_0(Period());
            Ls_112 = Ls_104 + ", MEGAFXPROFIT BUY SIGNAL for Level: " + Ld_8;
            Ls_120 = Ls_112 + " @ " + TimeToStr(TimeLocal(), TIME_SECONDS);
            if (Bars > G_bars_96)
            {
               G_bars_96 = Bars;
               f0_1(Ls_120, Ls_112);
            }
         }
      }
      if (!Li_100)
      {
         G_ibuf_112[Li_96] = Ld_8;
         G_ibuf_108[Li_96] = 0.0;
      }
      else
      {
         G_ibuf_108[Li_96] = Ld_8;
         G_ibuf_112[Li_96] = 0.0;
      }
   }
   for (Li_96 = 0; Li_96 < Li_92; Li_96++)
   {
      if (G_ibuf_108[Li_96] > 0.0 && G_ibuf_108[Li_96 + 1] == 0.0)
         G_ibuf_120[Li_96] = G_ibuf_108[Li_96];
      if (G_ibuf_112[Li_96] < 0.0 && G_ibuf_112[Li_96 + 1] == 0.0)
         G_ibuf_124[Li_96] = G_ibuf_112[Li_96];
   }
   return (0);
}

// FF3DED0DF4360E36577F1A7C4D36796A
void f0_1(string As_0, string As_8)
{
   if (ALERTS)
      Alert(As_0);
   if (SoundAlerts)
      PlaySound(SoundAlertFile);
   if (eMailAlerts)
      SendMail(As_8, As_0);
}

// A9BA851E539886467D4ECFDDCA93F414
string f0_0(int Ai_0)
{
   switch (Ai_0)
   {
   case 1:
      return ("M1");
   case 5:
      return ("M5");
   case 15:
      return ("M15");
   case 30:
      return ("M30");
   case 60:
      return ("H1");
   case 240:
      return ("H4");
   case 1440:
      return ("D1");
   case 10080:
      return ("W1");
   case 43200:
      return ("MN1");
   }
   WindowRedraw();
   return (Period());
}
