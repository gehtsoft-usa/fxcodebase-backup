// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70455
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
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window

int Normal_TL_Period;
bool Three_Touch;
input bool Auto_Refresh = TRUE;
input int _Normal_TL_Period = 500;
input bool _Three_Touch = TRUE;
input bool M1_Fast_Analysis = TRUE;
input bool M5_Fast_Analysis = TRUE;
input bool Mark_Highest_and_Lowest_TL = TRUE;
input int Expiration_Day_Alert = 5;
input color Normal_TL_Color = Gainsboro;
input color Long_TL_Color = Goldenrod;
input int Three_Touch_TL_Widht = 2;
input color Three_Touch_TL_Color = White;
int gi_120;
int gi_124;
//Signaler v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
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


// Abstract condition v1.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

#ifndef AConditionBase_IMP
#define AConditionBase_IMP

class AConditionBase : public ICondition
{
   int _references;
   string _conditionName;
public:
   AConditionBase(string name = "")
   {
      _conditionName = name;
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      if (_conditionName == "" || _conditionName == NULL)
      {
         return "";
      }
      return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
   }
};

#endif

// Line cross condition v1.0

#ifndef LineCrossCondition_IMP
#define LineCrossCondition_IMP

class LineCrossCondition : public AConditionBase
{
   string _lineId;
public:
   LineCrossCondition(string lineId)
      :AConditionBase("Line cross")
   {
      _lineId = lineId;
   }

   bool IsPass(const int period, const datetime date)
   {
      double val0 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period);
      double val1 = iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, period + 1);
      double y0 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 0);
      double y1 = ObjectGetDouble(0, _lineId, OBJPROP_PRICE, 1);
      double x0 = ObjectGetInteger(0, _lineId, OBJPROP_TIME, 0);
      double x1 = ObjectGetInteger(0, _lineId, OBJPROP_TIME, 1);
      if (y0 > 0 && y1 > 0 && x0 > 0 && x1 > 0)
      {
         double d1 = (y0 - y1) * iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period) + (x1 - x0) * val0 + (x0 * y1 - x1 * y0);
         double d2 = (y0 - y1) * iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, period + 1) + (x1 - x0) * val1 + (x0 * y1 - x1 * y0);
         double d = d1 * d2;
         return d < 0 || d1 == 0;
      }
      return false;
   }
};

#endif
LineCrossCondition* conditions[];
Signaler signaler;

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
   case PERIOD_M1:
      return "M1";
   case PERIOD_M5:
      return "M5";
   case PERIOD_D1:
      return "D1";
   case PERIOD_H1:
      return "H1";
   case PERIOD_H4:
      return "H4";
   case PERIOD_M15:
      return "M15";
   case PERIOD_M30:
      return "M30";
   case PERIOD_MN1:
      return "MN1";
   case PERIOD_W1:
      return "W1";
   }
   return "";
}
int init()
{
   Three_Touch = _Three_Touch;
   Normal_TL_Period = _Normal_TL_Period;
   signaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");
   ObjectCreate("calctl", OBJ_HLINE, 0, 0, 0);
   ObjectCreate("visibletl", OBJ_HLINE, 0, 0, 0);
   ObjectCreate("downmax", OBJ_TREND, 0, 0, 0, 0, 0);
   ObjectCreate("upmax", OBJ_TREND, 0, 0, 0, 0, 0);
   return (0);
}

int deinit()
{
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
   ArrayResize(conditions, 0);
   for (int li_0 = 0; li_0 <= 100; li_0++)
   {
      ObjectDelete("downtrendline" + li_0);
      ObjectDelete("uptrendline" + li_0);
      ObjectDelete("downtrendline" + li_0 + "tt");
      ObjectDelete("uptrendline" + li_0 + "tt");
   }
   ObjectDelete("calctl");
   ObjectDelete("timeleft");
   ObjectDelete("invacc");
   ObjectDelete("visibletl");
   ObjectDelete("downmax");
   ObjectDelete("upmax");
   ObjectDelete("downmax");
   ObjectDelete("upmax");
   return (0);
}

int start()
{
   for (int i = ArraySize(conditions) - 1; i >= 0; --i)
   {
      if (conditions[i] != NULL && conditions[i].IsPass(0, Time[0]))
      {
         signaler.SendNotifications("Line cross");
         delete conditions[i];
         conditions[i] = NULL;
      }
   }
   double ld_20;
   double ld_28;
   double ld_36;
   double ld_44;
   double ld_52;
   double ld_60;
   double ld_68;
   double ld_76;
   double ld_84;
   double ld_100;
   double ld_108;
   double ld_116;
   double ld_124;
   double ld_132;
   double ld_140;
   double ld_148;
   double ld_156;
   double ld_164;
   double ld_172;
   double ld_180;
   double ld_188;
   double ld_232;
   double ld_240;
   int li_248;
   int li_252;
   if (Normal_TL_Period > 1000 || Normal_TL_Period < 100)
      Normal_TL_Period = 500;
   string ls_0 = AccountNumber();
   gi_124++;
   string ls_8 = AccountNumber();
   int li_16 = 1;
   int li_196 = MathMax(0, WindowFirstVisibleBar() - WindowBarsPerChart());
   double ld_224 = Bars;
   if (gi_120 == 0)
      gi_120 = ld_224;
   if (ld_224 > gi_120)
   {
      gi_120 = ld_224;
      if (Auto_Refresh == TRUE && li_196 == 0)
         ObjectSet("calctl", OBJPROP_PRICE1, -1);
   }
   if (Auto_Refresh == TRUE && IndicatorCounted() == 0)
      ObjectSet("calctl", OBJPROP_PRICE1, -1);
   if (ObjectGet("visibletl", OBJPROP_PRICE1) == -1.0)
   {
      for (int li_208 = 0; li_208 <= 100; li_208++)
      {
         ObjectDelete("downtrendline" + li_208);
         ObjectDelete("uptrendline" + li_208);
         ObjectDelete("downtrendline" + li_208 + "tt");
         ObjectDelete("uptrendline" + li_208 + "tt");
      }
   }
   if (ObjectGet("calctl", OBJPROP_PRICE1) == -1.0 && ObjectGet("visibletl", OBJPROP_PRICE1) == 0.0 && StringFind(ls_8, ls_0, 0) >= 0 && li_16 > 0)
   {
      for (li_208 = 0; li_208 <= 100; li_208++)
      {
         ObjectDelete("downtrendline" + li_208);
         ObjectDelete("uptrendline" + li_208);
         ObjectDelete("downtrendline" + li_208 + "tt");
         ObjectDelete("uptrendline" + li_208 + "tt");
      }
      ld_20 = 150000;
      if (Period() == PERIOD_M1 && M1_Fast_Analysis == TRUE)
         ld_20 = 8000;
      if (Period() == PERIOD_M5 && M5_Fast_Analysis == TRUE)
         ld_20 = 2400;
      if (Period() == PERIOD_MN1)
      {
         ld_20 = 150;
         Three_Touch = FALSE;
         Normal_TL_Period = 150;
      }
      ld_28 = li_196 + MathMin(Bars - li_196 - 10, ld_20);
      ld_36 = iHigh(NULL, 0, ld_28);
      ld_52 = li_196 + MathMin(Bars - li_196 - 10, ld_20);
      ld_60 = iHigh(NULL, 0, ld_52);
      for (int li_200 = 1; li_200 < 50; li_200++)
      {
         if ((iFractals(NULL, 0, MODE_UPPER, li_196 + li_200) > 0.0 && li_200 > 2) || (Close[li_196 + li_200 + 1] > Open[li_196 + li_200 + 1] && Close[li_196 + li_200 + 1] - (Low[li_196 + li_200 + 1]) < 0.6 * (High[li_196 + li_200 + 1] - (Low[li_196 + li_200 + 1])) && Close[li_196 + li_200] < Open[li_196 + li_200]) || (Close[li_196 + li_200 + 1] <= Open[li_196 + li_200 + 1] && Close[li_196 + li_200] < Open[li_196 + li_200]) || (Close[li_196 + li_200] < Open[li_196 + li_200] && Close[li_196 + li_200] < Low[li_196 + li_200 + 1]))
         {
            ld_44 = li_196 + li_200;
            break;
         }
      }
      for (int li_204 = 1; li_204 <= 30; li_204++)
      {
         if (ld_28 > ld_44 + 6.0)
         {
            if (ObjectCreate("downtrendline" + li_204, OBJ_TREND, 0, iTime(NULL, 0, ld_28), ld_36, iTime(NULL, 0, ld_28), ld_36))
            {
               int size = ArraySize(conditions);
               ArrayResize(conditions, size + 1);
               conditions[size] = new LineCrossCondition("downtrendline" + li_204);
            }
            for (li_200 = ld_28; li_200 >= ld_44; li_200--)
            {
               if (ObjectGet("downtrendline" + li_204, OBJPROP_PRICE1) == ObjectGet("downtrendline" + li_204, OBJPROP_PRICE2))
               {
                  ObjectMove("downtrendline" + li_204, 1, iTime(NULL, 0, li_200 - 1), iHigh(NULL, 0, li_200 - 1));
                  ld_28 = li_200 - 1;
                  ld_36 = iHigh(NULL, 0, li_200 - 1);
               }
               ld_76 = ObjectGetValueByShift("downtrendline" + li_204, li_200);
               if (ld_76 < iHigh(NULL, 0, li_200))
               {
                  ObjectMove("downtrendline" + li_204, 1, iTime(NULL, 0, li_200), iHigh(NULL, 0, li_200));
                  ld_28 = li_200;
                  ld_36 = iHigh(NULL, 0, li_200);
               }
            }
         }
         if (ObjectGet("downtrendline" + li_204, OBJPROP_PRICE1) < ObjectGet("downtrendline" + li_204, OBJPROP_PRICE2))
            ObjectDelete("downtrendline" + li_204);
         if (iBarShift(NULL, 0, ObjectGet("downtrendline" + li_204, OBJPROP_TIME1)) - li_196 >= Normal_TL_Period)
         {
            ObjectSet("downtrendline" + li_204, OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText("downtrendline" + li_204, "Long");
         }
         else
         {
            ObjectSet("downtrendline" + li_204, OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText("downtrendline" + li_204, "Normal");
         }
      }
      for (li_200 = 1; li_200 < 50; li_200++)
      {
         if ((iFractals(NULL, 0, MODE_LOWER, li_196 + li_200) > 0.0 && li_200 > 2) || (Close[li_196 + li_200 + 1] < Open[li_196 + li_200 + 1] && High[li_196 + li_200 + 1] - (Close[li_196 + li_200 + 1]) < 0.6 * (High[li_196 + li_200 + 1] - (Low[li_196 + li_200 + 1])) && Close[li_196 + li_200] > Open[li_196 + li_200]) || (Close[li_196 + li_200 + 1] >= Open[li_196 + li_200 + 1] && Close[li_196 + li_200] > Open[li_196 + li_200]) || (Close[li_196 + li_200] > Open[li_196 + li_200] && Close[li_196 + li_200] > High[li_196 + li_200 + 1]))
         {
            ld_68 = li_196 + li_200;
            break;
         }
      }
      for (li_204 = 1; li_204 <= 30; li_204++)
      {
         if (ld_52 > ld_68 + 6.0)
         {
            if (ObjectCreate("uptrendline" + li_204, OBJ_TREND, 0, iTime(NULL, 0, ld_52), ld_60, iTime(NULL, 0, ld_52), ld_60))
            {
               size = ArraySize(conditions);
               ArrayResize(conditions, size + 1);
               conditions[size] = new LineCrossCondition("uptrendline" + li_204);
            }
            for (li_200 = ld_52; li_200 >= ld_68; li_200--)
            {
               if (ObjectGet("uptrendline" + li_204, OBJPROP_TIME1) == ObjectGet("uptrendline" + li_204, OBJPROP_TIME2))
               {
                  ObjectMove("uptrendline" + li_204, 1, iTime(NULL, 0, li_200 - 1), iLow(NULL, 0, li_200 - 1));
                  ld_52 = li_200 - 1;
                  ld_60 = iLow(NULL, 0, li_200 - 1);
               }
               ld_76 = ObjectGetValueByShift("uptrendline" + li_204, li_200);
               if (iLow(NULL, 0, li_200) < ld_76)
               {
                  ObjectMove("uptrendline" + li_204, 1, iTime(NULL, 0, li_200), iLow(NULL, 0, li_200));
                  ld_52 = li_200;
                  ld_60 = iLow(NULL, 0, li_200);
               }
            }
         }
         if (ObjectGet("uptrendline" + li_204, OBJPROP_PRICE1) > ObjectGet("uptrendline" + li_204, OBJPROP_PRICE2))
            ObjectDelete("uptrendline" + li_204);
         if (iBarShift(NULL, 0, ObjectGet("uptrendline" + li_204, OBJPROP_TIME1)) - li_196 >= Normal_TL_Period)
         {
            ObjectSet("uptrendline" + li_204, OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText("uptrendline" + li_204, "Long");
         }
         else
         {
            ObjectSet("uptrendline" + li_204, OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText("uptrendline" + li_204, "Normal");
         }
      }
      if (Three_Touch == TRUE && Bars > 1000)
      {
         for (li_204 = 1; li_204 <= 30; li_204++)
         {
            ld_100 = ObjectGet("downtrendline" + li_204, OBJPROP_TIME1);
            ld_108 = iBarShift(NULL, 0, ld_100);
            ld_84 = ld_44;
            ld_116 = ld_108 - ld_84;
            if (ld_116 < MathMin(Normal_TL_Period, 1000) && ld_116 > 6.0)
            {
               if (ObjectCreate("downtrendline" + li_204 + "tt", OBJ_TREND, 0, iTime(NULL, 0, ld_108), iHigh(NULL, 0, ld_108), iTime(NULL, 0, ld_84), iHigh(NULL, 0, ld_84)))
               {
                  size = ArraySize(conditions);
                  ArrayResize(conditions, size + 1);
                  conditions[size] = new LineCrossCondition("downtrendline" + li_204 + "tt");
               }
               ObjectSet("downtrendline" + li_204 + "tt", OBJPROP_WIDTH, 2);
               ld_180 = iATR(NULL, 0, ld_116, li_196) / Point / 10.0;
               ld_188 = 8.0 * ld_180;
               ld_124 = 0;
               ld_132 = 0;
               ld_140 = 0;
               for (int li_212 = ld_84; li_212 <= ld_108; li_212++)
               {
                  if (ld_132 == 0.0 && ld_140 >= 3.0 && li_212 > ld_84)
                  {
                     ld_164 = 0;
                     ld_172 = ObjectGet("downtrendline" + li_204 + "tt", OBJPROP_PRICE2);
                     for (int li_216 = 1; li_216 <= 5; li_216++)
                     {
                        if (ld_164 >= 3.0)
                           ld_124 = 1;
                        if (ld_124 == 0.0)
                        {
                           ObjectSet("downtrendline" + li_204 + "tt", OBJPROP_PRICE2, ld_172 + (li_216 - 3) * Point);
                           ld_164 = 0;
                           for (int li_220 = ld_84; li_220 <= ld_108; li_220++)
                           {
                              ld_76 = ObjectGetValueByShift("downtrendline" + li_204 + "tt", li_220);
                              if (ld_76 + ld_180 * Point > iHigh(NULL, 0, li_220) && ld_76 - ld_180 * Point < iHigh(NULL, 0, li_220))
                              {
                                 ld_164++;
                                 li_220++;
                              }
                           }
                        }
                     }
                  }
                  if (ld_124 == 0.0 && li_212 == ld_108)
                     ObjectDelete("downtrendline" + li_204 + "tt");
                  if (ld_124 == 1.0 && li_212 == ld_108)
                  {
                     ld_148 = ObjectGetValueByShift("downtrendline" + li_204, ld_84);
                     ld_156 = ObjectGetValueByShift("downtrendline" + li_204 + "tt", ld_84);
                     if (MathAbs(ld_148 - ld_156) > ld_188 * Point)
                        ObjectDelete("downtrendline" + li_204 + "tt");
                  }
                  if (ld_124 == 0.0 && li_212 <= ld_108)
                     ObjectMove("downtrendline" + li_204 + "tt", 1, iTime(NULL, 0, li_212), iHigh(NULL, 0, li_212));
                  if (ld_124 == 0.0)
                  {
                     ld_132 = 0;
                     ld_140 = 0;
                     for (li_200 = ld_84; li_200 <= ld_108; li_200++)
                     {
                        ld_76 = ObjectGetValueByShift("downtrendline" + li_204 + "tt", li_200);
                        if (iClose(NULL, 0, li_200) > ObjectGetValueByShift("downtrendline" + li_204 + "tt", li_200))
                           ld_132++;
                        if (ld_76 + 2.0 * ld_180 * Point > iHigh(NULL, 0, li_200) && ld_76 - 2.0 * ld_180 * Point < iHigh(NULL, 0, li_200))
                        {
                           ld_140++;
                           li_200++;
                        }
                     }
                  }
               }
            }
         }
         for (li_204 = 1; li_204 <= 30; li_204++)
         {
            ld_100 = ObjectGet("uptrendline" + li_204, OBJPROP_TIME1);
            ld_108 = iBarShift(NULL, 0, ld_100);
            ld_84 = ld_68;
            ld_116 = ld_108 - ld_84;
            if (ld_116 < MathMin(Normal_TL_Period, 1000) && ld_116 > 6.0)
            {
               if (ObjectCreate("uptrendline" + li_204 + "tt", OBJ_TREND, 0, iTime(NULL, 0, ld_108), iLow(NULL, 0, ld_108), iTime(NULL, 0, ld_108), iLow(NULL, 0, ld_108)))
               {
                  size = ArraySize(conditions);
                  ArrayResize(conditions, size + 1);
                  conditions[size] = new LineCrossCondition("uptrendline" + li_204 + "tt");
               }
               ObjectSet("uptrendline" + li_204 + "tt", OBJPROP_WIDTH, 2);
               ld_180 = iATR(NULL, 0, ld_116, li_196) / Point / 10.0;
               ld_188 = 8.0 * ld_180;
               ld_124 = 0;
               ld_140 = 0;
               for (li_212 = ld_84; li_212 <= ld_108; li_212++)
               {
                  if (ld_132 == 0.0 && ld_140 >= 3.0 && li_212 > ld_84 && ld_124 == 0.0)
                  {
                     ld_164 = 0;
                     ld_172 = ObjectGet("uptrendline" + li_204 + "tt", OBJPROP_PRICE2);
                     for (li_216 = 1; li_216 <= 5; li_216++)
                     {
                        if (ld_164 >= 3.0)
                           ld_124 = 1;
                        if (ld_124 == 0.0)
                        {
                           ObjectSet("uptrendline" + li_204 + "tt", OBJPROP_PRICE2, ld_172 + (li_216 - 3) * Point);
                           ld_164 = 0;
                           for (li_220 = ld_84; li_220 <= ld_108; li_220++)
                           {
                              ld_76 = ObjectGetValueByShift("uptrendline" + li_204 + "tt", li_220);
                              if (ld_76 + ld_180 * Point > iLow(NULL, 0, li_220) && ld_76 - ld_180 * Point < iLow(NULL, 0, li_220))
                              {
                                 ld_164++;
                                 li_220++;
                              }
                           }
                        }
                     }
                  }
                  if (ld_124 == 0.0 && li_212 == ld_108)
                     ObjectDelete("uptrendline" + li_204 + "tt");
                  if (ld_124 == 1.0 && li_212 == ld_108)
                  {
                     ld_148 = ObjectGetValueByShift("uptrendline" + li_204, ld_84);
                     ld_156 = ObjectGetValueByShift("uptrendline" + li_204 + "tt", ld_84);
                     if (MathAbs(ld_148 - ld_156) > ld_188 * Point)
                        ObjectDelete("uptrendline" + li_204 + "tt");
                  }
                  if (ld_124 == 0.0 && li_212 < ld_108)
                     ObjectMove("uptrendline" + li_204 + "tt", 1, iTime(NULL, 0, li_212), iLow(NULL, 0, li_212));
                  if (ld_124 == 0.0)
                  {
                     ld_132 = 0;
                     ld_140 = 0;
                     for (li_200 = ld_84; li_200 <= ld_108; li_200++)
                     {
                        ld_76 = ObjectGetValueByShift("uptrendline" + li_204 + "tt", li_200);
                        if (iClose(NULL, 0, li_200) < ObjectGetValueByShift("uptrendline" + li_204 + "tt", li_200))
                           ld_132++;
                        if (ld_76 + 2.0 * ld_180 * Point > iLow(NULL, 0, li_200) && ld_76 - 2.0 * ld_180 * Point < iLow(NULL, 0, li_200))
                        {
                           ld_140++;
                           li_200++;
                        }
                     }
                  }
               }
            }
         }
         for (li_200 = 0; li_200 <= 30; li_200++)
         {
            if (ObjectGetValueByShift("uptrendline" + li_200 + "tt", li_196 + 1) > 0.0)
            {
               ObjectSet("uptrendline" + li_200, OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet("uptrendline" + li_200, OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText("uptrendline" + li_200, "3t");
               ObjectDelete("uptrendline" + li_200 + "tt");
            }
         }
         for (li_200 = 0; li_200 <= 30; li_200++)
         {
            if (ObjectGetValueByShift("downtrendline" + li_200 + "tt", li_196 + 1) > 0.0)
            {
               ObjectSet("downtrendline" + li_200, OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet("downtrendline" + li_200, OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText("downtrendline" + li_200, "3t");
               ObjectDelete("downtrendline" + li_200 + "tt");
            }
         }
      }
      for (li_204 = 0; li_204 <= 30; li_204++)
      {
         if (ObjectGet("downtrendline" + ((li_204 - 1)), OBJPROP_PRICE1) == 0.0 && ObjectGet("downtrendline" + li_204, OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE)
         {
            ObjectSet("downmax", OBJPROP_TIME1, iTime(NULL, 0, li_196 + 6));
            ObjectSet("downmax", OBJPROP_PRICE1, ObjectGetValueByShift("downtrendline" + li_204, li_196 + 6));
            ObjectSet("downmax", OBJPROP_TIME2, iTime(NULL, 0, li_196 + 3));
            ObjectSet("downmax", OBJPROP_PRICE2, ObjectGetValueByShift("downtrendline" + li_204, li_196 + 3));
            ObjectSet("downmax", OBJPROP_COLOR, ObjectGet("downtrendline" + li_204, OBJPROP_COLOR));
            ObjectSet("downmax", OBJPROP_WIDTH, 5);
            ObjectSet("downmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("downmax", OBJPROP_RAY, FALSE);
            ObjectSet("downmax", OBJPROP_BACK, FALSE);
         }
         if (ObjectGet("uptrendline" + ((li_204 - 1)), OBJPROP_PRICE1) == 0.0 && ObjectGet("uptrendline" + li_204, OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE)
         {
            ObjectSet("upmax", OBJPROP_TIME1, iTime(NULL, 0, li_196 + 6));
            ObjectSet("upmax", OBJPROP_PRICE1, ObjectGetValueByShift("uptrendline" + li_204, li_196 + 6));
            ObjectSet("upmax", OBJPROP_TIME2, iTime(NULL, 0, li_196 + 3));
            ObjectSet("upmax", OBJPROP_PRICE2, ObjectGetValueByShift("uptrendline" + li_204, li_196 + 3));
            ObjectSet("upmax", OBJPROP_COLOR, ObjectGet("uptrendline" + li_204, OBJPROP_COLOR));
            ObjectSet("upmax", OBJPROP_WIDTH, 5);
            ObjectSet("upmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet("upmax", OBJPROP_RAY, FALSE);
            ObjectSet("upmax", OBJPROP_BACK, FALSE);
         }
      }
      ld_232 = 0;
      ld_240 = 0;
      for (li_204 = 1; li_204 <= 30; li_204++)
      {
         ld_232 += ObjectGet("downtrendline" + li_204, OBJPROP_PRICE1);
         ld_240 += ObjectGet("uptrendline" + li_204, OBJPROP_PRICE1);
      }
      if (ld_232 == 0.0)
      {
         ObjectSet("downmax", OBJPROP_TIME1, 0);
         ObjectSet("downmax", OBJPROP_PRICE1, 0);
         ObjectSet("downmax", OBJPROP_TIME2, 0);
         ObjectSet("downmax", OBJPROP_PRICE2, 0);
      }
      if (ld_240 == 0.0)
      {
         ObjectSet("upmax", OBJPROP_TIME1, 0);
         ObjectSet("upmax", OBJPROP_PRICE1, 0);
         ObjectSet("upmax", OBJPROP_TIME2, 0);
         ObjectSet("upmax", OBJPROP_PRICE2, 0);
      }
      ObjectSet("calctl", OBJPROP_PRICE1, 0);
   }
   if (Auto_Refresh == TRUE && IndicatorCounted() == 0)
   {
      ObjectSet("calctl", OBJPROP_PRICE1, -1);
   }
   return (0);
}