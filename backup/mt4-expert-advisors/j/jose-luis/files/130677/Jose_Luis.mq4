// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69306

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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
//#property indicator_separate_window
#property indicator_buffers 0

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

double masDM[], menosDM[], DX[];

int init()
{
   IndicatorName = GenerateIndicatorName("Jose Luis");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, masDM);

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, menosDM);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, DX);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - counted_bars - 1, Bars - 2);
   for (int i = limit; i >= 0; i--)
   {
      double Rge = iATR(_Symbol, _Period, 14, i);
      double aAdx0 = iATR(_Symbol, _Period, 14, i);
      double aAdx1 = iATR(_Symbol, _Period, 14, i + 1);
      double sto8 = iStochastic(_Symbol, _Period, 8, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      double sto8_3 = iStochastic(_Symbol, _Period, 8, 3, 3, MODE_SMA, 0, MODE_MAIN, i + 3);
      if (aAdx0 > aAdx1)
         Drawtext("B", i, Low[i] - 0.3 * Rge / 0.2, C'055,0,155');
      else if (aAdx0 < aAdx1)
         Drawtext("F", i, Low[i] - 0.3 * Rge / 0.2, C'155,0,0');
      if (aAdx0 >= 20 && aAdx1 < 20 && sto8 < sto8_3)
         Drawtext("TRADE", i, High[i] + 3 * Rge, C'100,100,255');
      else if (aAdx0 >= 20 && aAdx1 < 20 && sto8 > sto8_3)
         Drawtext("TRADE", i, Low[i] - 3 * Rge, C'100,100,255');
      if (aAdx0 <= 20 && aAdx1 > 20 && sto8 < sto8_3)
         Drawtext("DUDAS", i, High[i] + 2 * Rge, C'150,0,0');
      else if (aAdx0 <= 20 && aAdx1 && sto8 > sto8_3)
         Drawtext("DUDAS", i, Low[i] - 2 * Rge, C'150,0,0');
      if (aAdx0 >= 55 && aAdx1 < 55 && sto8 < sto8_3)
         Drawtext("DANGER", i, High[i] + 2 * Rge, C'0,0,0');
      else if (aAdx0 >= 55 && aAdx1 < 55 && sto8 > sto8_3)
         Drawtext("DANGER", i, Low[i] - 2 * Rge, C'0,0,0');
      if (aAdx0 >= 58 && aAdx1 < 58 && sto8 < sto8_3)
         Drawtext("BOOM", i, High[i] + 3 * Rge, C'0,0,0');
      else if (aAdx0 >= 58 && aAdx1 < 58 && sto8 > sto8_3)
         Drawtext("BOOM", i, Low[i] - 3 * Rge, C'0,0,0');
      if (aAdx0 >= 68 && aAdx1 < 68 && sto8 < sto8_3)
         Drawtext("MEGABOOM", i, High[i] + 3 * Rge, C'0,0,0');
      else if (aAdx0 >= 68 && aAdx1 < 68 && sto8 > sto8_3)
         Drawtext("MEGABOOM", i, Low[i] - 3 * Rge, C'0,0,0');
      if (aAdx0 >= 78 && aAdx1 < 78 && sto8 < sto8_3)
         Drawtext("DESASTRE", i, High[i] + 3 * Rge, C'0,0,0');
      else if (aAdx0 >= 78 && aAdx1 < 78 && sto8 > sto8_3)
         Drawtext("DESASTRE", i, Low[i] - 3 * Rge, C'0,0,0');
      if (aAdx0 >= 22 && aAdx1 < 22 && sto8 < sto8_3)
         Drawtext("F2", i, High[i] + 2 * Rge, C'100,100,255');
      else if (aAdx0 >= 22 && aAdx1 < 22 && sto8 > sto8_3)
         Drawtext("F2", i, Low[i] - 2 * Rge, C'100,100,255');
      if (aAdx0 >= 24 && aAdx1 < 24 && sto8 < sto8_3)
         Drawtext("F4", i, High[i] + 3 * Rge, C'100,100,255');
      else if (aAdx0 >= 24 && aAdx1 < 24 && sto8 > sto8_3)
         Drawtext("F4", i, Low[i] - 3 * Rge, C'100,100,255');
      if (aAdx0 >= 26 && aAdx1 < 26 && sto8 < sto8_3)
         Drawtext("F6", i,High[i] + 2 * Rge, C'100,100,255');
      else if (aAdx0 >= 26 && aAdx1 < 26 && sto8 > sto8_3)
         Drawtext("F6", i, Low[i] - 2 * Rge, C'100,100,255');
      if (aAdx0 >= 28 && aAdx1 < 28 && sto8 < sto8_3)
         Drawtext("F8", i, High[i] + 3 * Rge, C'100,100,255');
      else if (aAdx0 >= 28 && aAdx1 < 28 && sto8 > sto8_3 )
         Drawtext("F8", i, Low[i] - 3 * Rge, C'100,100,255');
      if (aAdx0 >= 30 && aAdx1 < 30 && sto8 < sto8_3)
         Drawtext("F30", i, High[i] + 2 * Rge, C'100,100,255');
      else if (aAdx0 >= 30 && aAdx1 < 30 && sto8 > sto8_3)
         Drawtext("F30", i, Low[i] - 2 * Rge, C'100,100,255');
      if (aAdx0 >= 35 && aAdx1 < 35 && sto8 < sto8_3)
         Drawtext("FF35", i, High[i] + 3 * Rge, C'100,100,255');
      else if (aAdx0 >= 35 && aAdx1 < 35 && sto8 > sto8_3)
         Drawtext("FF35", i, Low[i] - 3 * Rge, C'100,100,255');
      if (aAdx0 >= 40 && aAdx1 < 40 && sto8 < sto8_3)
         Drawtext("FF40", i, High[i] + 2 * Rge, C'100,100,255');
      else if (aAdx0 >= 40 && aAdx1 < 40 && sto8 > sto8_3)
         Drawtext("FF40", i, Low[i] - 2 * Rge, C'100,100,255');
      if (aAdx0 >= 50 && aAdx1 < 50 && sto8 < sto8_3)
         Drawtext("PELIGRO", i, High[i] + 3 * Rge, C'0,0,150');
      else if (aAdx0 >= 50 && aAdx1 < 50 && sto8 > sto8_3)
         Drawtext("PELIGRO", i, Low[i] - 3 * Rge, C'0,0,150');
      if (aAdx0 >= 17 && aAdx1 < 17 && sto8 < sto8_3)
         Drawtext("BUENCAM", i, High[i] + 2.5 * Rge, C'0,0,150');
      else if (aAdx0 >= 17 && aAdx1 < 17 && sto8 > sto8_3)
         Drawtext("BUENCAM", i, Low[i] - 2.5 * Rge, C'0,0,150');
      if (aAdx0 >= 15 && aAdx1 < 15 && sto8 < sto8_3)
         Drawtext("SALUCI", i, High[i] + 3 * Rge, C'0,0,150');
      else if (aAdx0 >= 15 && aAdx1 < 15 && sto8 > sto8_3)
         Drawtext("SALUCI", i, Low[i] - 3 * Rge, C'0,0,150');
      if (aAdx0 >= 13 && aAdx1 < 13 && sto8 < sto8_3)
         Drawtext("SOPLO", i, High[i] + 1.5 * Rge, C'0,0,150');
      else if (aAdx0 >= 13 && aAdx1 < 13 && sto8 > sto8_3)
         Drawtext("SOPLO", i, Low[i] - 1.5 * Rge, C'0,0,150');
      if (aAdx0 >= 10 && aAdx1 < 10 && sto8 < sto8_3)
         Drawtext("RESURR", i, High[i] + 2 * Rge, C'0,0,150');
      else if (aAdx0 >= 10 && aAdx1 < 10 && sto8 > sto8_3)
         Drawtext("RESURR", i, Low[i] - 2 * Rge, C'0,0,150');
      if (aAdx0 <= 22 && aAdx1 > 22 && sto8 < sto8_3)
         Drawtext("F2", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 22 && aAdx1 > 22 && sto8 > sto8_3)
         Drawtext("F2", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 24 && aAdx1 > 24 && sto8 < sto8_3)
         Drawtext ("F4", i,High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 24 && aAdx1 > 24 && sto8 > sto8_3)
         Drawtext("F4", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 26 && aAdx1 > 26 && sto8 < sto8_3)
         Drawtext("F6", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 26 && aAdx1 > 26 && sto8 > sto8_3)
         Drawtext("F6", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 28 && aAdx1 > 28 && sto8 < sto8_3)
         Drawtext("F8", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 28 && aAdx1 > 28 && sto8 > sto8_3)
         Drawtext("F8", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 30 && aAdx1 > 30 && sto8 < sto8_3)
         Drawtext("F30", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 30 && aAdx1 > 30 && sto8 > sto8_3)
         Drawtext("F30", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 35 && aAdx1 > 35 && sto8 < sto8_3)
         Drawtext("FF35", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 35 && aAdx1 > 35 && sto8 > sto8_3)
         Drawtext("FF35", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 15 && aAdx1 > 15 && sto8 < sto8_3)
         Drawtext("EXTREM", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 15 && aAdx1 > 15 && sto8 > sto8_3)
         Drawtext("EXTREM", i, Low[i] - 2 * Rge, C'155,0,0');
      if (aAdx0 <= 10 && aAdx1 > 10 && sto8 < sto8_3)
         Drawtext("DEATH", i, High[i] + 2 * Rge, C'155,0,0');
      else if (aAdx0 <= 10 && aAdx1 > 10 && sto8 > sto8_3)
         Drawtext("DEATH", i, Low[i] - 2 * Rge, C'155,0,0');
     
      masDM[i] = MathMax(High[i] - High[i + 1], 0);
      menosDM[i] = MathMax(Low[i + 1] - Low[i], 0);
      if (masDM[i] > menosDM[i])
         menosDM[i] = 0;
      if (masDM[i] < menosDM[i])
         masDM[i] = 0;
      if (masDM[i] == menosDM[i])
      {
         masDM[i] = 0;
         menosDM[i] = 0;
      }
      
      double masDI = Wilder(masDM[i], masDM[i + 1], 14);
      double menosDI = Wilder(menosDM[i], menosDM[i + 1], 14);

      DX[i] = (masDI + menosDI) == 0 ? 0 : MathAbs(masDI - menosDI) / (masDI + menosDI) * 100;
      if (i > Bars - 4)
         continue;
      double miadx = Wilder(DX[i], DX[i + 1], 14);
      double miadx_1 = Wilder(DX[i + 1], DX[i + 2], 14);
      double miadx_2 = Wilder(DX[i + 2], DX[i + 3], 14);
      double sto76 = iStochastic(_Symbol, _Period, 76, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      double sto76_1 = iStochastic(_Symbol, _Period, 76, 3, 3, MODE_SMA, 0, MODE_MAIN, i + 1);
      if (miadx > 15 && sto76 > sto76_1)
      {
         if (miadx > miadx_1 && miadx_1 < miadx_2)
            Drawtext("E", i, Low[i] - 3 * Rge, C'0,155,0');
         else if (miadx < miadx_1 && miadx_1 > miadx_2)
            Drawtext("C", i, Low[i] - 3 * Rge, C'255,0,0');
      }

      if (miadx > 15 && sto76 < sto76_1)
      {
         if (miadx > miadx_1 && miadx_1 < miadx_2)
            Drawtext("E", i, High[i] + 3 * Rge, C'0,155,0');
         else if (miadx < miadx_1 && miadx_1 > miadx_2)
            Drawtext("C", i, High[i] + 3 * Rge, C'255,0,0');
      }
   }
   return 0;
}

double Wilder(double price, double prev, int per)
{
   if (prev == EMPTY_VALUE)
      return price;
   return prev + (price - prev) / per; 
}

void Drawtext(string text, int pos, double price, color clr)
{
   ResetLastError();
   string id = IndicatorObjPrefix + text + "idValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos], price))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos]);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
   ObjectSetString(0, id, OBJPROP_TEXT, text);
}
