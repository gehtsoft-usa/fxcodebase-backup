// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71213


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

// based on rvm_fam@fromru.com
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Black
//---- input parameters
input int Range = 3;
//Signaler v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, "", "");
   }
};

//---- buffers
double Up[];
double Dn[];
double ur1[];
double ur2[];
double h1[];
double l1[];
//-----
int cb;
Signaler* signaler;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   signaler = new Signaler();
   signaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");
   //---- indicators
   IndicatorBuffers(6);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   SetIndexBuffer(0, Up);
   SetIndexBuffer(1, Dn);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexLabel(0, "HL_Act_Up");
   SetIndexLabel(1, "HL_Act_Dn");
   SetIndexBuffer(2, ur1);
   SetIndexBuffer(3, ur2);
   SetIndexBuffer(4, h1);
   SetIndexBuffer(5, l1);
   //----
   return (0);
}

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
   }
   return "";
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
datetime last_signal;
int start()
{
   //------ ���������� ��������� ����������
   int counted_bars = IndicatorCounted();
   int NumBars = 1000, n = 0, Nbar = 0, k = 0, hh = 0, ll = 0, mm = 0;
   double MaH = 0.0, MaL = 0.0;
   //-----
   if (Bars < Range * 12 - 10)
      return (0);
   if (counted_bars >= Bars - 1)
   {
      NumBars = 0;
   }
   else
   {
      NumBars = MathMax(Bars - 1 - counted_bars - (Range * 12 - 10), Range * 12 - 10);
   }
   //
   for (cb = NumBars; cb >= 0; cb--)
   {
      Nbar = -1;
      k = 1;
      mm = 0;
      Dn[cb] = 0.0;
      Up[cb] = 0.0;
      ur1[cb] = 0.0;
      ur2[cb] = 0.0;
      h1[cb] = 0.0;
      l1[cb] = 0.0;
      //-----------------------------------------------------------------------------
      if (Period() == 5) //���� ������ - �5
      {
         //Print("������� ������ "+cb+" ���� "+TimeToStr(Time[cb]) );
         //Print("----   Dn[cb]= "+Dn[cb]+" Up[cb]= "+Up[cb] );
         if (TimeHour(Time[cb + 1]) != TimeHour(Time[cb]))
         {
            //Print("----   Nbar= "+Nbar+" k= "+k+" mm= "+mm );
            n = cb - 15;
            //Print("----   n= "+n );
            while (n <= cb + Range * 12 + 5)
            {
               if (n < 0)
               {
                  Nbar = 0;
                  n = 1;
                  //Print("----   n= "+n+" Nbar= "+Nbar );
               }
               if (TimeHour(Time[n + 1]) != TimeHour(Time[n]))
               {
                  if (Nbar == -1)
                  {
                     Nbar = n;
                     mm = n;
                     n++;
                     //Print("----   n= "+n+" Nbar= "+Nbar+" mm= "+mm );
                     continue;
                  }
                  else
                  {
                     h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                     l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                     //Print("----   k= "+k+" Nbar= "+Nbar+" n= "+n+" h1["+k+"]= "+h1[k]+" l1["+k+"]= "+l1[k]+" "+(Low[Lowest(NULL,0,MODE_LOW,(n-Nbar),n)])+" "+(High[Lowest(NULL,0,MODE_HIGH,(n-Nbar),n)]) );
                     k++;
                     Nbar = n;
                  }
               }
               n++;
            }
            MaH = 0;
            MaL = 0;
            for (n = 1; n <= Range; n++)
            {
               MaH = MaH + h1[n];
               MaL = MaL + l1[n];
            }
            MaH = MaH / Range;
            MaL = MaL / Range;
            ur1[cb] = MaH;
            ur2[cb] = MaL;
            //Print("----   MaH= "+MaH+" MaL= "+MaL+" ur1["+cb+"]= "+ur1[cb]+" ur2["+cb+"]= "+ur2[cb] );
            if (Close[mm + 1] >= MaH)
            {
               ll = 1;
               hh = 0;
               //Print("----   Close["+(mm+1)+"]"+Close[mm+1]+">="+"MaH"+MaH+"  ="+(Close[mm+1]>=MaH) );
            }
            if (Close[mm + 1] <= MaL)
            {
               hh = 1;
               ll = 0;
               //Print("----   Close["+(mm+1)+"]"+Close[mm+1]+"<="+"MaL"+MaL+"  ="+(Close[mm+1]<=MaL) );
            }
            //Print("----   ll= "+ll+" hh= "+hh );
         }
         if (ur1[cb] == 0.0)
         {
            ur1[cb] = ur1[cb + 1];
            ur2[cb] = ur2[cb + 1];
            //Print("----  ur1["+cb+"]= "+ur1[cb]+" ur2["+cb+"]= "+ur2[cb] );
         }
         if (ll == 1)
         {
            Up[cb] = ur2[cb];
            //Print("----  Dn["+cb+"]= "+Dn[cb]+" Up["+cb+"]= "+Up[cb] );
            //Print("----  1 Up["+cb+"]= "+Up[cb]+" ur2[cb]="+ur2[cb] );
         }
         else
         {
            if (hh == 1)
            {
               Dn[cb] = ur1[cb];
               //Print("----  Dn["+cb+"]= "+Dn[cb]+" Up["+cb+"]= "+Up[cb] );
               //Print("----                                        2 Up["+cb+"]= "+Up[cb] );
            }
            else
            {
               Dn[cb] = Dn[cb + 1];
               Up[cb] = Up[cb + 1];
            }
         }
      }
      else
      {
         //-----------------------------------------------------------------------------
         if (Period() == 15) //���� ������ - �15
         {
            if (TimeHour(Time[cb + 1]) != TimeHour(Time[cb])) //���� �������� ����� ���
            {
               n = cb - 5;
               while (n <= cb + Range * 4 + 2)
               {
                  if (n < 0)
                  {
                     Nbar = 0;
                     n = 1;
                  }
                  if (TimeHour(Time[n + 1]) != TimeHour(Time[n])) //���� ����� �15 �� ��������� � �1
                  {
                     if (Nbar == -1) //���� �������������� ������ ��������
                     {
                        Nbar = n;
                        mm = n;
                        n++;
                        continue;
                     }
                     else
                     {
                        h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                        l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                        k++;
                        Nbar = n;
                     }
                  }
                  n++;
               }
               MaH = 0;
               MaL = 0;
               for (n = 1; n <= Range; n++)
               {
                  MaH = MaH + h1[n];
                  MaL = MaL + l1[n];
               }
               MaH = MaH / Range;
               MaL = MaL / Range;
               ur1[cb] = MaH;
               ur2[cb] = MaL;
               if (Close[mm + 1] >= MaH)
               {
                  ll = 1;
                  hh = 0;
               }
               if (Close[mm + 1] <= MaL)
               {
                  hh = 1;
                  ll = 0;
               }
            }
            if (ur1[cb] == 0.0)
            {
               ur1[cb] = ur1[cb + 1];
               ur2[cb] = ur2[cb + 1];
            }
            if (ll == 1)
            {
               Up[cb] = ur2[cb];
            }
            else
            {
               if (hh == 1)
               {
                  Dn[cb] = ur1[cb];
               }
            }
         }
         else
         {
            //-----------------------------------------------------------------------------
            if (Period() == 30) //���� ������ - �30
            {
               if ((TimeMinute(Time[cb]) == 0 && (TimeHour(Time[cb]) == 0 || TimeHour(Time[cb]) == 4 || TimeHour(Time[cb]) == 8 ||
                                                  TimeHour(Time[cb]) == 12 || TimeHour(Time[cb]) == 16 || TimeHour(Time[cb]) == 20)))
               {
                  n = cb - 10;
                  while (n <= cb + Range * 8 + 5)
                  {
                     if (n < 0)
                     {
                        Nbar = 0;
                        n = 1;
                     }
                     if ((TimeMinute(Time[n]) == 0 && (TimeHour(Time[n]) == 0 || TimeHour(Time[n]) == 4 || TimeHour(Time[n]) == 8 | TimeHour(Time[n]) == 12 || TimeHour(Time[n]) == 16 || TimeHour(Time[n]) == 20)))
                     {
                        if (Nbar == -1)
                        {
                           Nbar = n;
                           mm = n;
                           n++;
                           continue;
                        }
                        else
                        {
                           h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                           l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                           k++;
                           Nbar = n;
                        }
                     }
                     n++;
                  }
                  MaH = 0;
                  MaL = 0;
                  for (n = 1; n <= Range; n++)
                  {
                     MaH = MaH + h1[n];
                     MaL = MaL + l1[n];
                  }
                  MaH = MaH / Range;
                  MaL = MaL / Range;
                  ur1[cb] = MaH;
                  ur2[cb] = MaL;
                  if (Close[mm + 1] >= MaH)
                  {
                     ll = 1;
                     hh = 0;
                  }
                  if (Close[mm + 1] <= MaL)
                  {
                     hh = 1;
                     ll = 0;
                  }
               }
               if (ur1[cb] == 0)
               {
                  ur1[cb] = ur1[cb + 1];
                  ur2[cb] = ur2[cb + 1];
               }
               if (ll == 1)
               {
                  Up[cb] = ur2[cb];
               }
               else
               {
                  if (hh == 1)
                  {
                     Dn[cb] = ur1[cb];
                  }
               }
            }
            else
            {
               //-----------------------------------------------------------------------------
               if (Period() == 60) //���� ������ - H1
               {
                  if ((TimeMinute(Time[cb]) == 0 && (TimeHour(Time[cb]) == 0 || TimeHour(Time[cb]) == 4 || TimeHour(Time[cb]) == 8 ||
                                                     TimeHour(Time[cb]) == 12 || TimeHour(Time[cb]) == 16 || TimeHour(Time[cb]) == 20)))
                  {
                     n = cb - 6;
                     while (n <= cb + Range * 4 + 3)
                     {
                        if (n < 0)
                        {
                           Nbar = 0;
                           n = 1;
                        }
                        if ((TimeMinute(Time[n]) == 0 && (TimeHour(Time[n]) == 0 || TimeHour(Time[n]) == 4 || TimeHour(Time[n]) == 8 | TimeHour(Time[n]) == 12 || TimeHour(Time[n]) == 16 || TimeHour(Time[n]) == 20)))
                        {
                           if (Nbar == -1)
                           {
                              Nbar = n;
                              mm = n;
                              n++;
                              continue;
                           }
                           else
                           {
                              h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                              l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                              k++;
                              Nbar = n;
                           }
                        }
                        n++;
                     }
                     MaH = 0;
                     MaL = 0;
                     for (n = 1; n <= Range; n++)
                     {
                        MaH = MaH + h1[n];
                        MaL = MaL + l1[n];
                     }
                     MaH = MaH / Range;
                     MaL = MaL / Range;
                     ur1[cb] = MaH;
                     ur2[cb] = MaL;
                     if (Close[mm + 1] >= MaH)
                     {
                        ll = 1;
                        hh = 0;
                     }
                     if (Close[mm + 1] <= MaL)
                     {
                        hh = 1;
                        ll = 0;
                     }
                  }
                  if (ur1[cb] == 0)
                  {
                     ur1[cb] = ur1[cb + 1];
                     ur2[cb] = ur2[cb + 1];
                  }
                  if (ll == 1)
                  {
                     Up[cb] = ur2[cb];
                  }
                  else
                  {
                     if (hh == 1)
                     {
                        Dn[cb] = ur1[cb];
                     }
                  }
               }
               else
               {
                  //-----------------------------------------------------------------------------
                  if (Period() == 240) //���� ������ - H4
                  {
                     if (TimeDay(Time[cb + 1]) != TimeDay(Time[cb]))
                     {
                        n = cb - 8;
                        while (n <= cb + Range * 8 + 4)
                        {
                           if (n < 0)
                           {
                              Nbar = 0;
                              n = 1;
                           }
                           if (TimeDay(Time[n + 1]) != TimeDay(Time[n]))
                           {
                              if (Nbar == -1)
                              {
                                 Nbar = n;
                                 mm = n;
                                 n++;
                                 continue;
                              }
                              else
                              {
                                 h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                                 l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                                 k++;
                                 Nbar = n;
                              }
                           }
                           n++;
                        }
                        MaH = 0;
                        MaL = 0;
                        for (n = 1; n <= Range; n++)
                        {
                           MaH = MaH + h1[n];
                           MaL = MaL + l1[n];
                        }
                        MaH = MaH / Range;
                        MaL = MaL / Range;
                        ur1[cb] = MaH;
                        ur2[cb] = MaL;
                        if (Close[mm + 1] >= MaH)
                        {
                           ll = 1;
                           hh = 0;
                        }
                        if (Close[mm + 1] <= MaL)
                        {
                           hh = 1;
                           ll = 0;
                        }
                     }
                     if (ur1[cb] == 0)
                     {
                        ur1[cb] = ur1[cb + 1];
                        ur2[cb] = ur2[cb + 1];
                     }
                     if (ll == 1)
                     {
                        Up[cb] = ur2[cb];
                     }
                     else
                     {
                        if (hh == 1)
                        {
                           Dn[cb] = ur1[cb];
                        }
                     }
                  }
                  else
                  {
                     //-----------------------------------------------------------------------------
                     if (Period() == 1440) //���� ������ - D1
                     {
                        if (TimeDayOfWeek(Time[cb + 1]) == 5 && TimeDayOfWeek(Time[cb]) == 1)
                        {
                           n = cb - 6;
                           while (n <= cb + Range * 5 + 3)
                           {
                              if (n < 0)
                              {
                                 Nbar = 0;
                                 n = 1;
                              }
                              if (TimeDayOfWeek(Time[n + 1]) == 6 || TimeDayOfWeek(Time[n]) == 2)
                              {
                                 if (Nbar == -1)
                                 {
                                    Nbar = n;
                                    mm = n;
                                    n++;
                                    continue;
                                 }
                                 else
                                 {
                                    h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                                    l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                                    k++;
                                    Nbar = n;
                                 }
                              }
                              n++;
                           }
                           MaH = 0;
                           MaL = 0;
                           for (n = 1; n <= Range; n++)
                           {
                              MaH = MaH + h1[n];
                              MaL = MaL + l1[n];
                           }
                           MaH = MaH / Range;
                           MaL = MaL / Range;
                           ur1[cb] = MaH;
                           ur2[cb] = MaL;
                           if (Close[mm + 1] >= MaH)
                           {
                              ll = 1;
                              hh = 0;
                           }
                           if (Close[mm + 1] <= MaL)
                           {
                              hh = 1;
                              ll = 0;
                           }
                        }
                        if (ur1[cb] == 0)
                        {
                           ur1[cb] = ur1[cb + 1];
                           ur2[cb] = ur2[cb + 1];
                        }
                        if (ll == 1)
                        {
                           Up[cb] = ur2[cb];
                        }
                        else
                        {
                           if (hh == 1)
                           {
                              Dn[cb] = ur1[cb];
                           }
                        }
                     }
                     else
                     {
                        //-----------------------------------------------------------------------------
                        if (Period() == 10080) //���� ������ - W1
                        {
                           if (TimeMonth(Time[cb + 1]) != TimeMonth(Time[cb]))
                           {
                              n = cb - 8;
                              while (n <= cb + Range * 8 + 4)
                              {
                                 if (n < 0)
                                 {
                                    Nbar = 0;
                                    n = 1;
                                 }
                                 if (TimeMonth(Time[n + 1]) != TimeMonth(Time[n]))
                                 {
                                    if (Nbar == -1)
                                    {
                                       Nbar = n;
                                       mm = n;
                                       n++;
                                       continue;
                                    }
                                    else
                                    {
                                       h1[k] = High[Highest(NULL, 0, MODE_HIGH, (n - Nbar), n)];
                                       l1[k] = Low[Lowest(NULL, 0, MODE_LOW, (n - Nbar), n)];
                                       k++;
                                       Nbar = n;
                                    }
                                 }
                                 n++;
                              }
                              MaH = 0;
                              MaL = 0;
                              for (n = 1; n <= Range; n++)
                              {
                                 MaH = MaH + h1[n];
                                 MaL = MaL + l1[n];
                              }
                              MaH = MaH / Range;
                              MaL = MaL / Range;
                              ur1[cb] = MaH;
                              ur2[cb] = MaL;
                              if (Close[mm + 1] >= MaH)
                              {
                                 ll = 1;
                                 hh = 0;
                              }
                              if (Close[mm + 1] <= MaL)
                              {
                                 hh = 1;
                                 ll = 0;
                              }
                           }
                           if (ur1[cb] == 0)
                           {
                              ur1[cb] = ur1[cb + 1];
                              ur2[cb] = ur2[cb + 1];
                           }
                           if (ll == 1)
                           {
                              Up[cb] = ur2[cb];
                           }
                           else
                           {
                              if (hh == 1)
                              {
                                 Dn[cb] = ur1[cb];
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      //-----------------------------------------------------------------------------
      if (Dn[cb + 1] == 0.0 && Dn[cb] != 0.0)
      {
         if (cb == 0)
            Alert("��� ���� �����!!!  :)  ���� ���������.");
         SetSymbol("sell_sig", cb, 0, Time[cb], High[cb] + 15 * Point, Black, 2, 218);
      }
      if (Up[cb + 1] == 0.0 && Up[cb] != 0.0)
      {
         if (cb == 0)
            Alert("��� ���� �����!!!  :)  ���� ��������.");
         SetSymbol("buy_sig", cb, 0, Time[cb], Low[cb] - 15 * Point, DeepSkyBlue, 2, 217);
      }
   }
   
   if (last_signal != Time[0])
   {
      if (Up[0] > 0)
      {
         signaler.SendNotifications("Buy");
         last_signal = Time[0];
      }
      else if (Dn[0] > 0)
      {
         signaler.SendNotifications("Sell");
         last_signal = Time[0];
      }
   }
   return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSymbol(string txt, int _cb, int win, datetime stime, double sprice, int scol, int swidth, int scode)
{
   //----
   if (ObjectFind(txt + " " + (string)_cb) == -1)
   {
      ObjectCreate(txt + " " + (string)_cb, OBJ_ARROW, win, stime, sprice);
      ObjectSet(txt + " " + (string)_cb, OBJPROP_COLOR, scol);
      ObjectSet(txt + " " + (string)_cb, OBJPROP_WIDTH, swidth);
      ObjectSet(txt + " " + (string)_cb, OBJPROP_ARROWCODE, scode);
   }
   else
   {
      ObjectMove(txt + " " + (string)_cb, 0, stime, sprice);
   }
   //----
   return;
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   delete signaler;
   //---- TODO: add your code here
   int _cb;
   for (_cb = Bars - 1 - Range; _cb >= 0; _cb--)
   {
      if (ObjectFind("buy_sig " + (string)_cb) != -1)
      {
         ObjectDelete("buy_sig " + (string)_cb);
      }
      else
      {
         if (ObjectFind("sell_sig " + (string)_cb) != -1)
         {
            ObjectDelete("sell_sig " + (string)_cb);
         }
      }
   }
   //----
   return (0);
}
//+------------------------------------------------------------------+