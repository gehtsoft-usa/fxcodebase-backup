//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75679

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime

extern int Risk = 0;
extern double ArrowsGap = 1.0;
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                  // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications
//
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexBuffer(1, G_ibuf_92);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexBuffer(2, G_ibuf_96);
   return (0);
  }

// EA2B2676C28C0DB26D39331A336C6B92
int start()
  {
   int period_28;
   double Ld_32;
   bool Li_44;
   bool Li_48;
   int Li_0 = IndicatorCounted();
   if(Li_0 < 0)
      return (-1);
   if(Li_0 > 0)
      Li_0--;
   int Li_4 = MathMin(Bars - Li_0, Bars - 1);
   double Ld_8 = Risk + 67.0;
   double Ld_16 = 33.0 - Risk;
   for(int Li_24 = Li_4; Li_24 >= 0; Li_24--)
     {
      period_28 = Risk * 2 + 3;
      Ld_32 = 0;
      for(int count_40 = 0; count_40 < 10; count_40++)
         Ld_32 += High[Li_24 + count_40] - (Low[Li_24 + count_40]);
      Ld_32 /= 10.0;
      Li_44 = FALSE;
      for(count_40 = 0; count_40 < 6 && !Li_44; count_40++)
         Li_44 = MathAbs(Open[Li_24 + count_40] - (Close[Li_24 + count_40 + 1])) >= 2.0 * Ld_32;
      Li_48 = FALSE;
      for(count_40 = 0; count_40 < 9 && !Li_48; count_40++)
         Li_48 = MathAbs(Close[Li_24 + count_40 + 3] - (Close[Li_24 + count_40])) >= 4.6 * Ld_32;
      if(Li_44)
         period_28 = 3;
      if(Li_48)
         period_28 = 4;
      G_ibuf_96[Li_24] = iWPR(NULL, 0, period_28, Li_24) + 100.0;
      G_ibuf_88[Li_24] = EMPTY_VALUE;
      G_ibuf_92[Li_24] = EMPTY_VALUE;
      if(G_ibuf_96[Li_24] < Ld_16)
        {
         for(count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++)
           {
           }
         if(G_ibuf_96[Li_24 + count_40] > Ld_8)
            G_ibuf_88[Li_24] = High[Li_24] + Ld_32 * ArrowsGap;
        }
      if(G_ibuf_96[Li_24] > Ld_8)
        {
         for(count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++)
           {
           }
         if(G_ibuf_96[Li_24 + count_40] < Ld_16)
            G_ibuf_92[Li_24] = Low[Li_24] - Ld_32 * ArrowsGap;
        }
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return (0);
  }


bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(G_ibuf_88[0]>0 && G_ibuf_88[0]!=EMPTY_VALUE)
        {
         Notify(1);
         alerted = true;
        }
      if(G_ibuf_92[0]>0 && G_ibuf_92[0]!=EMPTY_VALUE)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(G_ibuf_88[1]>0 && G_ibuf_88[1]!=EMPTY_VALUE)
        {
         Notify(11);
        }
      if(G_ibuf_92[1]>0 && G_ibuf_92[1]!=EMPTY_VALUE)
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "RBCI: ";
   switch(type)
     {
      case 1:
         text += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75679

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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