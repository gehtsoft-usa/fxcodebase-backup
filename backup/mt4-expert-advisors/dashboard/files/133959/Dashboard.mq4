// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69860

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

#property indicator_chart_window
//---- input parameters
input int Periods = 64;
input string TimeFrame = "D1";
input string Symbols = "EURUSD,GBPUSD,USDJPY,USDCHF,USDCAD,AUDUSD,NZDUSD,EURGBP,EURJPY,EURCHF,GBPJPY,GBPCHF";
input int StartX = 5, StartY = 5;
input bool CompactMode = false;

//Signaler v 1.7
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
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
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

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
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

//----general vars
string gsaSymbols[], gsaMmlName[] = {"-2/8", "-1/8", "0/8", "1/8", "2/8", "3/8", "4/8", "5/8", "6/8", "7/8", "8/8", "+1/8", "+2/8"};
bool showAlert[] = { false, false, false, false, false, false, false, false, false, false, false, false, false };

int giTf = PERIOD_D1; //default, in case user set TimeFrame  = EMPTY
int giNumRow = 13;

color gsaMmlClr[] = {White, Magenta, DeepSkyBlue, Gold, Tomato, Lime, White, Lime, Tomato, Gold, DeepSkyBlue, Magenta, White};

double gdaSymMM[][13 /*mmline*/];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int _start_x;
Signaler* signaler;

int init()
{
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   IndicatorObjPrefix = GenerateIndicatorPrefix("dshbrd");
   IndicatorShortName("Dashboard");
   strToStrArray(Symbols, gsaSymbols);

   if (StringLen(TimeFrame) > 0)
   {
      giTf = getTFByName(TimeFrame);
   }

   ArrayResize(gdaSymMM, ArraySize(gsaSymbols));

   _start_y = StartY;
   if (CompactMode)
   {
      giNumRow = 2;
      _start_x = MathMax(StartX, 8);
   }

   layout();

   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (!secondDiff())
      return (0);

   int i, j;
   //----
   double mm[13], hh, ll;
   string sym;

   for (i = 0; i < ArraySize(gsaSymbols); i++)
   {
      sym = gsaSymbols[i];
      ArrayInitialize(mm, 0.0);

      hh = iHigh(sym, giTf, iHighest(sym, giTf, MODE_HIGH, Periods, 0));
      ll = iLow(sym, giTf, iLowest(sym, giTf, MODE_LOW, Periods, 0));

      calcMM(ll, hh, mm);

      for (j = 0; j < 13; j++)
         gdaSymMM[i][j] = mm[j];
   }

   display();

   return (0);
}
/*---------------------------------------------------------------------*
 *Murrey Math Calculation                                              *
 *v1 = low; v2 = high                                                  *
 *---------------------------------------------------------------------*
 */
void calcMM(double v1, double v2, double &mm[])
{
   //private vars
   int shift = 0, i2 = 0, WorkTime = 0, Periods = 0;
   double sum = 0, /*v1=0,v2=0,*/ fractal = 0;

   double range = 0, octave = 0, mn = 0, mx = 0, price = 0;
   double finalH = 0, finalL = 0, v45 = 0;
   double x1 = 0, x2 = 0, x3 = 0, x4 = 0, x5 = 0, x6 = 0, y1 = 0, y2 = 0, y3 = 0, y4 = 0, y5 = 0, y6 = 0;

   //+------------------------------------------------------------------+
   //| Determine which Fractal to use.....                              |
   //+------------------------------------------------------------------+
   if (v2 <= 250000 && v2 > 25000)
      fractal = 100000;
   if (v2 <= 25000 && v2 > 2500)
      fractal = 10000;
   if (v2 <= 2500 && v2 > 250)
      fractal = 1000;
   if (v2 <= 250 && v2 > 25)
      fractal = 100;
   if (v2 <= 25 && v2 > 12.5)
      fractal = 12.5;
   if (v2 <= 12.5 && v2 > 6.25)
      fractal = 12.5;
   if (v2 <= 6.25 && v2 > 3.125)
      fractal = 6.25;
   if (v2 <= 3.125 && v2 > 1.5625)
      fractal = 3.125;
   if (v2 <= 1.5625 && v2 > 0.390625)
      fractal = 1.5625;
   if (v2 <= 0.390625 && v2 > 0)
      fractal = 0.1953125;

   // calculating our octave....
   range = (v2 - v1);
   sum = range == 0 ? 0 : MathFloor(MathLog(fractal / range) / MathLog(2));
   octave = fractal * (MathPow(0.5, sum));
   mn = octave == 0 ? 0 : MathFloor(v1 / octave) * octave;
   if ((mn + octave) > v2)
      mx = mn + octave;
   mx = mn + (2 * octave);
   // calculating xx
   //x2
   if ((v1 >= (3 * (mx - mn) / 16 + mn)) && (v2 <= (9 * (mx - mn) / 16 + mn)))
      x2 = mn + (mx - mn) / 2;
   else
      x2 = 0;
   //x1
   if ((v1 >= (mn - (mx - mn) / 8)) && (v2 <= (5 * (mx - mn) / 8 + mn)) && (x2 == 0))
      x1 = mn + (mx - mn) / 2;
   else
      x1 = 0;
   //x4
   if ((v1 >= (mn + 7 * (mx - mn) / 16)) && (v2 <= (13 * (mx - mn) / 16 + mn)))
      x4 = mn + 3 * (mx - mn) / 4;
   else
      x4 = 0;
   //x5
   if ((v1 >= (mn + 3 * (mx - mn) / 8)) && (v2 <= (9 * (mx - mn) / 8 + mn)) && (x4 == 0))
      x5 = mx;
   else
      x5 = 0;
   //x3
   if ((v1 >= (mn + (mx - mn) / 8)) && (v2 <= (7 * (mx - mn) / 8 + mn)) && (x1 == 0) && (x2 == 0) && (x4 == 0) && (x5 == 0))
      x3 = mn + 3 * (mx - mn) / 4;
   else
      x3 = 0;
   //x6 when we have no sbj, du {}
   if ((x1 + x2 + x3 + x4 + x5) == 0)
      x6 = mx;
   else
      x6 = 0;

   finalH = x1 + x2 + x3 + x4 + x5 + x6;
   // calculating yy
   //y1
   if (x1 > 0)
      y1 = mn;
   else
      y1 = 0;
   //y2
   if (x2 > 0)
      y2 = mn + (mx - mn) / 4;
   else
      y2 = 0;
   //y3
   if (x3 > 0)
      y3 = mn + (mx - mn) / 4;
   else
      y3 = 0;
   //y4
   if (x4 > 0)
      y4 = mn + (mx - mn) / 2;
   else
      y4 = 0;
   //y5
   if (x5 > 0)
      y5 = mn + (mx - mn) / 2;
   else
      y5 = 0;
   //y6
   if ((finalH > 0) && ((y1 + y2 + y3 + y4 + y5) == 0))
      y6 = mn;
   else
      y6 = 0;

   finalL = y1 + y2 + y3 + y4 + y5 + y6;

   v45 = (finalH - finalL) / 8;

   mm[0] = (finalL - v45 * 2);
   mm[1] = (finalL - v45);
   mm[2] = (finalL);
   mm[3] = (finalL + v45);
   mm[4] = (finalL + 2 * v45);
   mm[5] = (finalL + 3 * v45);
   mm[6] = (finalL + 4 * v45);
   mm[7] = (finalL + 5 * v45);
   mm[8] = (finalL + 6 * v45);
   mm[9] = (finalL + 7 * v45);
   mm[10] = (finalL + 8 * v45);
   mm[11] = (finalL + 9 * v45);
   mm[12] = (finalL + 10 * v45);
}

//+------------------------------------------------------------------+
//| display                                                          |
//+------------------------------------------------------------------+
void display()
{
   int i, j, k, mmidx;
   double cp, cpprev, fix_point, fix_digits;
   string sym, mmn, mmn1, objmmprice1, objmmprice2, objmmarrow, objsymprice, objsympricebg;
   for (i = 0; i < ArraySize(gsaSymbols); i++)
   {
      sym = gsaSymbols[i];

      cp = iClose(sym, giTf, 0);

      fix_point = MarketInfo(sym, MODE_POINT);
      fix_digits = MarketInfo(sym, MODE_DIGITS);

      if (fix_point == 0.001 || fix_point == 0.00001)
      {
         fix_point *= 10;
         fix_digits -= 1;
      }

      objsymprice = IndicatorObjPrefix + "0.1." + sym + ".price";
      objsympricebg = IndicatorObjPrefix + "0.0." + sym + ".pricebg";
      objmmarrow = IndicatorObjPrefix + "0.1." + sym + ".pricedir";

      for (j = 0; j < 13; j++)
      {
         if (j >= 0 && j < 12 && cp > gdaSymMM[i][j] && cp <= gdaSymMM[i][j + 1])
         {
            mmidx = j;
            break;
         }
         if (j == 0 && cp < gdaSymMM[i][j])
         {
            mmidx = -1;
            break;
         }
         if (j == 12 && cp > gdaSymMM[i][j])
         {
            mmidx = 13;
            break;
         }
      } //eo j

      if (CompactMode)
      {
         mmn = "lvl0";
         mmn1 = "lvl1";
         objmmprice1 = IndicatorObjPrefix + "0.1." + mmn + "." + sym + ".price";
         objmmprice2 = IndicatorObjPrefix + "0.1." + mmn1 + "." + sym + ".price";

         //---mml name
         ObjectSet(IndicatorObjPrefix + sym + ".mml0", OBJPROP_COLOR, gsaMmlClr[mmidx]);
         ObjectSetText(IndicatorObjPrefix + sym + ".mml0", addChar(gsaMmlName[mmidx], " ", 6));

         ObjectSet(IndicatorObjPrefix + sym + ".mml1", OBJPROP_COLOR, gsaMmlClr[mmidx + 1]);
         ObjectSetText(IndicatorObjPrefix + sym + ".mml1", addChar(gsaMmlName[mmidx + 1], " ", 6));
      }

      for (j = 0; j < giNumRow; j++)
      {

         if (CompactMode)
         {
            mmn = "lvl" + j;
            mmn1 = "lvl" + (j + 1);
         }
         else
         {
            mmn = gsaMmlName[j];
            mmn1 = gsaMmlName[j + 1];
         }

         objmmprice1 = IndicatorObjPrefix + "0.1." + mmn + "." + sym + ".price";
         objmmprice2 = IndicatorObjPrefix + "0.1." + mmn1 + "." + sym + ".price";

         if (CompactMode)
         {
            ObjectSetText(objmmprice1, addChar(DoubleToStr(gdaSymMM[i][j + mmidx], fix_digits), " ", 6));
            ObjectSet(IndicatorObjPrefix + "0.0." + mmn + "." + sym + ".pricebg", OBJPROP_COLOR, gsaMmlClr[j + mmidx]);

            if (j == 0)
               ObjectSet(objsymprice, OBJPROP_YDISTANCE, ObjectGet(objmmprice1, OBJPROP_YDISTANCE) - 19);
         }
         else //mm price for level gsaMmlName[j]
         {
            ObjectSetText(objmmprice1, addChar(DoubleToStr(gdaSymMM[i][j], fix_digits), " ", 6));

            //----obj current price location per symbol...
            if (j == 0 && mmidx < 0)
               ObjectSet(objsymprice, OBJPROP_YDISTANCE, ObjectGet(objmmprice1, OBJPROP_YDISTANCE) - 19);

            if (j == 12 && mmidx > 12)
               ObjectSet(objsymprice, OBJPROP_YDISTANCE, ObjectGet(objmmprice1, OBJPROP_YDISTANCE) + 19);

            if (j >= 0 && j < 12 && mmidx == j && mmidx >= 0 && mmidx < 12)
               ObjectSet(objsymprice, OBJPROP_YDISTANCE, ObjectGet(objmmprice2, OBJPROP_YDISTANCE) + 19);
         }
      } //eo j

      ObjectSetText(objsymprice, addChar(DoubleToStr(cp, fix_digits), " ", 6));
      ObjectSetText(objsymprice + "2", addChar(DoubleToStr(cp, fix_digits), " ", 6));

      ObjectSet(objsymprice + "2", OBJPROP_XDISTANCE, ObjectGet(objsymprice, OBJPROP_XDISTANCE) + 1);
      ObjectSet(objsymprice + "2", OBJPROP_YDISTANCE, ObjectGet(objsymprice, OBJPROP_YDISTANCE));

      ObjectSet(objsympricebg, OBJPROP_YDISTANCE, ObjectGet(objsymprice, OBJPROP_YDISTANCE) - 4);
      ObjectSet(IndicatorObjPrefix + "0.1." + sym + ".price.lbullet", OBJPROP_YDISTANCE, ObjectGet(objsympricebg, OBJPROP_YDISTANCE) - 1);
      ObjectSet(IndicatorObjPrefix + "0.1." + sym + ".price.rbullet", OBJPROP_YDISTANCE, ObjectGet(objsympricebg, OBJPROP_YDISTANCE) - 1);

      ObjectSetText(objsymprice, addChar(DoubleToStr(cp, fix_digits), " ", 6));
      ObjectSetText(objsymprice + "2", addChar(DoubleToStr(cp, fix_digits), " ", 6));

      ObjectSet(objsymprice + "2", OBJPROP_XDISTANCE, ObjectGet(objsymprice, OBJPROP_XDISTANCE) + 1);
      ObjectSet(objsymprice + "2", OBJPROP_YDISTANCE, ObjectGet(objsymprice, OBJPROP_YDISTANCE));

      ObjectSet(objsympricebg, OBJPROP_YDISTANCE, ObjectGet(objsymprice, OBJPROP_YDISTANCE) - 5);

      //----previous broken mm level - price direciton
      for (k = 1; k < Periods; k++)
      {
         cpprev = iClose(sym, giTf, k);

         if (cpprev > gdaSymMM[i][mmidx + 1]) //--- down dir
         {
            ObjectSet(objsympricebg, OBJPROP_COLOR, gsaMmlClr[mmidx]);
            ObjectSetText(objmmarrow, "�");
            ObjectSet(objmmarrow, OBJPROP_YDISTANCE, ObjectGet(objsympricebg, OBJPROP_YDISTANCE) - 15);
            ObjectSet(objmmarrow, OBJPROP_COLOR, gsaMmlClr[mmidx + 1]);
            if (showAlert[mmidx])
            {
               signaler.SendNotifications("Down");
            }
            break;
         }

         if (cpprev < gdaSymMM[i][mmidx]) //--- up dir
         {
            ObjectSet(objsympricebg, OBJPROP_COLOR, gsaMmlClr[mmidx + 1]);
            ObjectSetText(objmmarrow, "�");
            ObjectSet(objmmarrow, OBJPROP_YDISTANCE, ObjectGet(objsympricebg, OBJPROP_YDISTANCE) + 15);
            ObjectSet(objmmarrow, OBJPROP_COLOR, gsaMmlClr[mmidx]);
            if (showAlert[mmidx])
            {
               signaler.SendNotifications("Up");
            }
            break;
         }
      } //eo k

   } //eo i
}
int _start_y;
//+------------------------------------------------------------------+
//| layout                                                           |
//+------------------------------------------------------------------+
void layout()
{
   int i, j, x, y;
   int symcolwidth = 65, mmcolwidth = 50, mmlineheight = 38, rowheight = 15, mmrowpadding = 0, startytbl;

   string title, sym, mmn;

   if (CompactMode)
      title = "MML(" + Periods + "," + TimeFrame + ")";
   else
      title = "MURREY MATH LINES DASHBOARD (" + Periods + "," + TimeFrame + ")";

   lblCreate("title", _start_x, _start_y, title, 12, "Lucida Console", Lime);

   if (CompactMode)
   {
      mmcolwidth = 0;
      _start_y += 18;
   }
   else
   {
      _start_y += 33;
   }

   startytbl = _start_y + rowheight;
   x = _start_x + mmcolwidth;
   y = _start_y;

   //----symbol
   for (i = 0; i < ArraySize(gsaSymbols); i++)
   {
      sym = gsaSymbols[i];
      lblCreate(sym, x + (i * symcolwidth), _start_y, sym, 9, "Lucida Console", White);
      //----MML name for compact mode
      if (CompactMode)
      {
         lblCreate(sym + ".mml1", x + (i * symcolwidth) + 5, _start_y + (1.1 * rowheight), addChar("0/0", " ", 6), 8, "Lucida Console", gsaMmlClr[0]);
         lblCreate(sym + ".mml0", x + (i * symcolwidth) + 5, _start_y + (0.8 * rowheight) + (2 * mmlineheight), addChar("0/0", " ", 6), 8, "Lucida Console", gsaMmlClr[0]);
      }
   }

   x = _start_x;
   if (CompactMode)
      y = _start_y + (2.0 * rowheight);
   else
      y = _start_y + (2.5 * rowheight);

   for (i = giNumRow - 1; i >= 0; i--)
   {
      mmn = gsaMmlName[i];
      if (CompactMode)
         mmn = "lvl" + i;
      //----MML name  for !compact mode
      if (!CompactMode)
         lblCreate("0.0." + mmn, x, y, addChar(mmn, " ", 4), 9, "Lucida Console", gsaMmlClr[i]);

      x += mmcolwidth;
      for (j = 0; j < ArraySize(gsaSymbols); j++)
      {
         sym = gsaSymbols[j];
         lblCreate("0.0." + mmn + "." + sym + ".pricebg", x + (j * symcolwidth), y - 2, addChar("", "g", 4), 9, "Webdings", gsaMmlClr[i]);
         lblCreate("0.1." + mmn + "." + sym + ".price", x + (j * symcolwidth) + 5, y + 2, addChar("", "0", 6), 8, "Lucida Console", Black);

         if (i == 0)
         {
            //TODO: alert
            lblCreate("0.1." + sym + ".pricedir", x + (j * symcolwidth) + 42, y, "�", 14, "Wingdings", White);
            lblCreate("0.1." + sym + ".price", x + (j * symcolwidth) + 5, y + rowheight, addChar("", "0", 6), 8, "Lucida Console", C'32,32,32');
            lblCreate("0.1." + sym + ".price2", x + (j * symcolwidth) + 5, y + rowheight, addChar("", "0", 6), 8, "Lucida Console", Black);
            lblCreate("0.0." + sym + ".pricebg", x + (j * symcolwidth) - 8, y + rowheight, addChar("", "g", 4), 12, "Webdings", Blue);
         }
      }

      x = _start_x;
      y += mmlineheight;
   }
}
//+------------------------------------------------------------------+
//| lblCreate                                                        |
//+------------------------------------------------------------------+
void lblCreate(string name, int x, int y, string text = "-", int size = 42,
               string font = "Arial", color c = CLR_NONE, bool back = false)
{
   name = IndicatorObjPrefix + name;
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_CORNER, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSet(name, OBJPROP_BACK, back);
   ObjectSetText(name, text, size, font, c);
}
//+------------------------------------------------------------------+
//| strToStrArray                                                    |
//+------------------------------------------------------------------+
void strToStrArray(string s, string &a[], string delim = ",")
{
   int idx, count_idx, last_idx;
   string str;
   for (;;)
   {
      idx = StringFind(s, delim, last_idx);

      if (idx >= 0)
      {
         str = StringTrimRight(StringTrimLeft(StringSubstr(s, last_idx, idx - last_idx)));
         last_idx = idx + 1;
      }
      else
         str = StringTrimRight(StringTrimLeft(StringSubstr(s, last_idx, StringLen(s) - last_idx)));

      count_idx += 1;
      ArrayResize(a, count_idx);
      a[count_idx - 1] = str;

      if (idx < 0)
         break;
   }
}
//+------------------------------------------------------------------+
//| addChar                                                          |
//+------------------------------------------------------------------+
string addChar(string str, string tchar, int maxlength, bool atbeginning = true)
{
   int l = maxlength - StringLen(str);
   for (int i = 0; i < l; i++)
   {
      if (atbeginning)
         str = tchar + str;
      else
         str = str + tchar;
   }

   return (str);
}
//+------------------------------------------------------------------+
//| secondDiff                                                       |
//+------------------------------------------------------------------+
bool secondDiff(int sec = 10)
{
   static datetime lasttime;
   int diff = TimeCurrent() - lasttime;

   if (diff > sec)
   {
      lasttime = TimeCurrent();
      return (true);
   }

   return (false);
}
//+------------------------------------------------------------------+
//| getTFByName function                                             |
//+------------------------------------------------------------------+
int getTFByName(string TFName)
{
   int m;
   if (TFName == "MN1")
      m = PERIOD_MN1;
   else if (TFName == "W1")
      m = PERIOD_W1;
   else if (TFName == "D1")
      m = PERIOD_D1;
   else if (TFName == "H4")
      m = PERIOD_H4;
   else if (TFName == "H1")
      m = PERIOD_H1;
   else if (TFName == "M30")
      m = PERIOD_M30;
   else if (TFName == "M15")
      m = PERIOD_M15;
   else if (TFName == "M5")
      m = PERIOD_M5;
   else if (TFName == "M1")
      m = PERIOD_M1;
   else
      m = Period();

   return (m);
}