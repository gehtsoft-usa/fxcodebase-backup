//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76015

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrNONE
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red

enum alert
  {
   Off = 0, // Off
   Current = 1,  // At current bar
   Previous = 2   // At previous closed bar
  };

int Gi_76 = 10;
extern double Sensitivity = 15.0;
extern int TrendStrength = 5;
extern int SignalMode = 2;
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = false;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
extern double GapThreshold = 300.0;
extern int MaxBarsToAnalyze = 8000;
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
extern string HomePage = "www.BeForexGuru.com";
int PriceCalculationMethod = 0;
int ShiftBars = 0;
double PreviousTrendValue = 0.0;
double TrendThresholdPips = 0.0;
input bool UseTrailingStop = FALSE;


double Gd_152;
double Gda_160[];
double G_ibuf_164[];
double G_ibuf_168[];
double G_ibuf_172[];
double G_ibuf_176[];
double G_ibuf_180[];
double G_ibuf_184[];
double G_ibuf_188[];
double G_time_192;
double Gd_208 = 0.0;
double Gd_216 = 0.0;
double Gd_224 = -100000.0;
double Gd_232 = 1000000.0;
int Gi_240;

// BB63D4283583708E94A566ACAD581B18
double f0_0(int Ai_0, double Ad_4, int Ai_12, int Ai_16)
  {
   double Ld_ret_20;
   double Ld_28;
   double Ld_36;
   double Ld_48;
   if(Ai_12 == 0)
     {
      Ld_28 = 0;
      Ld_36 = 0;
      for(int Li_44 = Ai_0 - 1; Li_44 >= 0; Li_44--)
        {
         if(PriceCalculationMethod == 0)
            Ld_48 = 1.0;
         else
            Ld_48 = 1.0 * (Ai_0 - Li_44) / Ai_0;
         Ld_28 += Ld_48 * (High[Ai_16 + Li_44] - (Low[Ai_16 + Li_44]));
         Ld_36 += Ld_48;
        }
      Gd_216 = Ld_28 / Ld_36;
      if(Gd_216 > Gd_224)
         Gd_224 = Gd_216;
      if(Gd_216 < Gd_232)
         Gd_232 = Gd_216;
      Ld_ret_20 = MathRound(Ad_4 / 2.0 * (Gd_224 + Gd_232) / Point);
     }
   else
      Ld_ret_20 = Ad_4 * TrendStrength;
   return (Ld_ret_20);
  }

// D7B59FC1FF468B9BCD57E69E1EA40FBF
double f0_1(bool Ai_0, double A_pips_4, int Ai_12)
  {
   double Ld_ret_20;
   int ind_counted_16 = IndicatorCounted();
   if(Ai_0)
     {
      G_ibuf_184[Ai_12] = Low[Ai_12] + 2.0 * A_pips_4 * Point;
      G_ibuf_180[Ai_12] = High[Ai_12] - 2.0 * A_pips_4 * Point;
     }
   else
     {
      G_ibuf_184[Ai_12] = Close[Ai_12] + 2.0 * A_pips_4 * Point;
      G_ibuf_180[Ai_12] = Close[Ai_12] - 2.0 * A_pips_4 * Point;
     }
   if(ind_counted_16 == 0)
     {
      G_ibuf_184[Gi_240 + 1] = G_ibuf_184[Gi_240];
      G_ibuf_180[Gi_240 + 1] = G_ibuf_180[Gi_240];
      G_ibuf_188[Gi_240 + 1] = 0;
     }
   G_ibuf_188[Ai_12] = G_ibuf_188[Ai_12 + 1];
   if(Close[Ai_12] > G_ibuf_184[Ai_12 + 1])
      G_ibuf_188[Ai_12] = 1;
   if(Close[Ai_12] < G_ibuf_180[Ai_12 + 1])
      G_ibuf_188[Ai_12] = -1;
   if(G_ibuf_188[Ai_12] > 0.0)
     {
      if(G_ibuf_180[Ai_12] < G_ibuf_180[Ai_12 + 1])
         G_ibuf_180[Ai_12] = G_ibuf_180[Ai_12 + 1];
      Ld_ret_20 = G_ibuf_180[Ai_12] + A_pips_4 * Point;
     }
   else
     {
      if(G_ibuf_184[Ai_12] > G_ibuf_184[Ai_12 + 1])
         G_ibuf_184[Ai_12] = G_ibuf_184[Ai_12 + 1];
      Ld_ret_20 = G_ibuf_184[Ai_12] - A_pips_4 * Point;
     }
   return (Ld_ret_20);
  }

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   IndicatorBuffers(8);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(1, 159);
   SetIndexArrow(2, 159);
   SetIndexArrow(3, 115);
   SetIndexArrow(4, 115);
   SetIndexBuffer(1, G_ibuf_164);
   SetIndexBuffer(2, G_ibuf_168);
   SetIndexShift(1, ShiftBars);
   SetIndexShift(2, ShiftBars);
   SetIndexBuffer(3, G_ibuf_172);
   SetIndexBuffer(4, G_ibuf_176);
   SetIndexBuffer(5, G_ibuf_188);
   SetIndexBuffer(6, G_ibuf_180);
   SetIndexBuffer(7, G_ibuf_184);
   string Ls_0 = "Medium-Term Scalper";
   IndicatorShortName(Ls_0);
   SetIndexLabel(0, Ls_0);
   SetIndexLabel(1, "UpTrend");
   SetIndexLabel(2, "DownTrend");
   SetIndexDrawBegin(0, Gi_76);
   SetIndexDrawBegin(1, Gi_76);
   SetIndexDrawBegin(2, Gi_76);
   SetIndexDrawBegin(3, Gi_76);
   SetIndexDrawBegin(4, Gi_76);
   SetIndexDrawBegin(6, Gi_76);
   SetIndexDrawBegin(7, Gi_76);
   return (0);
  }

// 52D46093050F38C27267BCE42543EF60
int deinit()
  {
   return (0);
  }

// EA2B2676C28C0DB26D39331A336C6B92
int start()
  {
   int bars_8;
   int Li_12;
   int ind_counted_4 = IndicatorCounted();
   Gd_152 = Sensitivity;
   if(MaxBarsToAnalyze > 0)
      bars_8 = MaxBarsToAnalyze;
   else
      bars_8 = Bars;
   if(ind_counted_4 > 0)
      Gi_240 = Bars - ind_counted_4;
   if(ind_counted_4 < 0)
      return (0);
   if(ind_counted_4 == 0)
      Gi_240 = bars_8 - Gi_76 - 1;
   for(int Li_0 = Bars - ind_counted_4; Li_0 >= 0; Li_0--)
     {
      G_ibuf_164[Li_0] = EMPTY_VALUE;
      G_ibuf_172[Li_0] = EMPTY_VALUE;
      G_ibuf_168[Li_0] = EMPTY_VALUE;
      G_ibuf_176[Li_0] = EMPTY_VALUE;
     }
   for(Li_0 = Gi_240; Li_0 >= 0; Li_0--)
     {
      Li_12 = f0_0(Gi_76, Gd_152, TrendStrength, Li_0);
      Gd_208 = f0_1(UseTrailingStop, Li_12, Li_0) + PreviousTrendValue / 100.0 * Li_12 * Point;
      if(SignalMode == 2)
        {
         if(G_ibuf_188[Li_0] > 0.0)
           {
            G_ibuf_164[Li_0] = Gd_208 + TrendThresholdPips * Point;
            if(G_ibuf_188[Li_0 + 1] < 0.0)
              {
               G_ibuf_164[Li_0 + 1] = G_ibuf_168[Li_0 + 1];
               G_ibuf_172[Li_0] = G_ibuf_168[Li_0 + 1] - GapThreshold * Point;
              }
            Gda_160[Li_0] = G_ibuf_164[Li_0];
            if(Li_0 < 3 && G_ibuf_168[Li_0] == G_ibuf_164[Li_0] && G_time_192 != Time[0])
              {
               G_time_192 = Time[0];
              }
            G_ibuf_168[Li_0] = EMPTY_VALUE;
           }
         if(G_ibuf_188[Li_0] < 0.0)
           {
            G_ibuf_168[Li_0] = Gd_208 - TrendThresholdPips * Point;
            if(G_ibuf_188[Li_0 + 1] > 0.0)
              {
               G_ibuf_168[Li_0 + 1] = G_ibuf_164[Li_0 + 1];
               G_ibuf_176[Li_0] = G_ibuf_164[Li_0 + 1] + GapThreshold * Point;
              }
            Gda_160[Li_0] = G_ibuf_168[Li_0];
            if(Li_0 < 3 && G_ibuf_168[Li_0] == G_ibuf_164[Li_0] && G_time_192 != Time[0])
              {
               G_time_192 = Time[0];
              }
            G_ibuf_164[Li_0] = EMPTY_VALUE;
           }
        }
      else
        {
         Gda_160[Li_0] = Gd_208;
         G_ibuf_164[Li_0] = EMPTY_VALUE;
         G_ibuf_168[Li_0] = EMPTY_VALUE;
         G_ibuf_172[Li_0] = -1;
         G_ibuf_176[Li_0] = -1;
        }
     }
   /*

   SetIndexBuffer(3, G_ibuf_172);
   SetIndexBuffer(4, G_ibuf_176);

   */
   if(notificationsOn > 0)
     {
      bool nb =  IsNewBar();
      if(nb)
        {
         alerted = false;
        }
      if(notificationsOn == 1 && !alerted)
        {
         if(G_ibuf_172[0] > 0 && G_ibuf_172[0] != EMPTY_VALUE)
           {
            Notify(1);
            alerted = true;
           }
         if(G_ibuf_176[0]  > 0 && G_ibuf_176[0] != EMPTY_VALUE)
           {
            Notify(2);
            alerted = true;
           }
        }
      if(notificationsOn == 2 && nb)
        {
         if(G_ibuf_172[1] > 0 && G_ibuf_172[1] != EMPTY_VALUE)
            Notify(11);
         if(G_ibuf_176[1] > 0 && G_ibuf_176[1] != EMPTY_VALUE)
            Notify(22);
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
bool alerted;
void Notify(int type)
  {
   string text = "Be-forex-guru: ";
   switch(type)
     {
      case 1:
         text += " Buy signal before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Sell signal before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Buy signal after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Sell signal after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
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

//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76015

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 