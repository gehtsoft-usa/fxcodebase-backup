// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73180&p=149031#p149031

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
 
#property description "THIS IS A FREE INDICATOR WITH NO TIME RESTRICTIONS"
#property description "                                                      "
#property description "Welcome to the XARD UNIVERSE"
#property description "                                                      "
#property description "Let the light shine and illuminate your trading world"
#property description "and with it secure your financial prosperity"

#property indicator_chart_window
#property indicator_buffers  5
#property indicator_color1 clrNONE//clrBlue
#property indicator_color2 clrRed
#property indicator_color3 clrBlue
#property indicator_color4 clrRed
#property indicator_color5 clrBlue
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#define Version "XU v48"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Name = WindowExpertName(), MyName = "XU_v48-INDEX_ENTRY", indicatorFileName;
//+------------------------------------------------------------------------------------------------------------------+
extern string Indicator                  = Version;
string SymbolPair                 = "";
//+------------------------------------------------------------------------------------------------------------------+
double angle_up                   = 360;
double angle_dn                   = 360;
int Width                      = 3;
int Style                      = 2;
int kol_lev                    = 1;
color ResistanceColor            = clrOrange;
color SupportColor               = clrLimeGreen;
color Level_0                    = clrGray;
bool lev_V                      = true;
color Level_V                    = clrGray;
int Complect                   = 0;
color öâåò_óðîâíÿ;
//+------------------------------------------------------------------------------------------------------------------+
int ExtDepth                   = 144;
int ExtDeviation               =  5;
int ExtBackstep                =  1;
double ZigZagBuffer[];
double GreenLine1[], GreenLine2[];
double OrangeLine1[], OrangeLine2[];
int timeFirstBar = 0;
int flag;
bool work = true;
double vel_prev;
//+------------------------------------------------------------------------------------------------------------------+
int init()
  {
   if(SymbolPair == "")
      SymbolPair = Symbol();
//Gary, Ithink this is it here, I have started adding in the dif broker feeds. If you can more that I missed - great
   if(StringSubstr(Symbol(), 0, 4) == "WS30")
     {
      angle_up = 360;
      angle_dn = 360;
     }
   if(StringSubstr(Symbol(), 0, 4) == "US30")
     {
      angle_up = 360;
      angle_dn = 360;
     }
   if(StringSubstr(Symbol(), 0, 2) == "DJ")
     {
      angle_up = 360;
      angle_dn = 360;
     }
   if(StringSubstr(Symbol(), 0, 4) == "DE30")
     {
      angle_up = 360;
      angle_dn = 360;
     }
   if(StringSubstr(Symbol(), 0, 5) == "US500")
     {
      angle_up = 180;
      angle_dn = 180;
     }
   if(StringSubstr(Symbol(), 0, 6) == "XAUUSD")
     {
      angle_up = 180;
      angle_dn = 180;
     }
   if(StringSubstr(Symbol(), 0, 5) == "DAX30")
     {
      angle_up = 360;
      angle_dn = 360;
     }
   if(StringSubstr(Symbol(), 0, 6) == "GBPUSD")
     {
      angle_up = 22.5;
      angle_dn = 22.5;
     }
   if(StringSubstr(Symbol(), 0, 6) == "GBPJPY")
     {
      angle_up = 22.5;
      angle_dn = 22.5;
     }
   if(StringSubstr(Symbol(), 0, 6) == "USOUSD")
     {
      angle_up = 67.5;
      angle_dn = 67.5;
     }
   if(Period() >= PERIOD_H4)
     {
      ExtDepth = 3 * 3;  //Semafor off Daily
     }
   if(Period() == PERIOD_H1)
     {
      ExtDepth = 36 / 2;  //Semafor off 1hr
     }
   if(Period() == PERIOD_M30)
     {
      ExtDepth = 36 * 1;  //Semafor off 1hr
     }
   if(Period() == PERIOD_M15)
     {
      ExtDepth = 36 * 2;  //Semafor off 1hr       24
     }
   if(Period() == PERIOD_M5)
     {
      ExtDepth = 36 * 6 - 8;  //Semafor off 1hr
     }
   if(Period() == PERIOD_M1)
     {
      ExtDepth = 36 * 30 - 5;  //Semafor off 1hr
     }
   /* if(Period()>=PERIOD_H1) {ExtDepth=144/12-1;}
    if(Period()==PERIOD_M30){ExtDepth=144/6-1;}
    if(Period()==PERIOD_M15){ExtDepth=144/3-1;}
    if(Period()==PERIOD_M5) {ExtDepth=144-1;}
    if(Period()==PERIOD_M1) {ExtDepth=144*5-1;}
   */
   SetIndexBuffer(0, ZigZagBuffer);
   SetIndexStyle(0, DRAW_SECTION, 2);
   SetIndexEmptyValue(0, 0.0);
   SetIndexBuffer(1, GreenLine1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexEmptyValue(1, 0.0);
   SetIndexBuffer(2, OrangeLine1);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexEmptyValue(2, 0.0);
//
   SetIndexBuffer(3, GreenLine2);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexEmptyValue(3, 0.0);
   SetIndexBuffer(4, OrangeLine2);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexEmptyValue(4, 0.0);
   IndicatorShortName(MyName);
   return(0);
  }
//+------------------------------------------------------------------------------------------------------------------+
int deinit() {ObjDel();  return(0);}
//+------------------------------------------------------------------------------------------------------------------+
int start()
  {
   if(Name == MyName)
     {
      if(Bars - 1 < ExtDepth)
         return(0);
      static int time2, time3, time4;
      static  double ZigZag2, ZigZag3, ZigZag4;
      int MaxBar, limit, supr2_bar, supr3_bar, supr4_bar, counted_bars = IndicatorCounted();
      if(counted_bars < 0)
         return(-1);
      if(counted_bars > 0)
         counted_bars--;
      int shift, back, lasthighpos, lastlowpos;
      double val, res, TempBuffer[1];
      double curlow, curhigh, lasthigh, lastlow;
      int metka = 0;
      MaxBar = Bars - ExtDepth;
      if(counted_bars == 0 || Bars - counted_bars > 2)
        {
         limit = MaxBar;
        }
      else
        {
         supr2_bar = iBarShift(NULL, 0, time2, TRUE);
         supr3_bar = iBarShift(NULL, 0, time3, TRUE);
         supr4_bar = iBarShift(NULL, 0, time4, TRUE);
         limit = supr3_bar;
         if((supr2_bar < 0) || (supr3_bar < 0) || (supr4_bar < 0))
           {
            limit = MaxBar;
           }
        }
      if(limit >= MaxBar || timeFirstBar != Time[Bars - 1])
        {
         timeFirstBar = Time[Bars - 1];
         limit = MaxBar;
        }
      if(limit == MaxBar)
         ArrayResize(TempBuffer, Bars);
      else
         ArrayResize(TempBuffer, limit + ExtBackstep + 1);
      //+--- LOW ----------------------------------------------------------------------------------------------------------+
      for(shift = limit; shift >= 0; shift--)
        {
         val = Low[Lowest(NULL, 0, MODE_LOW, ExtDepth, shift)];
         if(val == lastlow)
            val = 0.0;
         else
           {
            lastlow = val;
            if((Low[shift] - val) > (ExtDeviation * Point))
               val = 0.0;
            else
              {
               for(back = 1; back <= ExtBackstep; back++)
                 {
                  res = ZigZagBuffer[shift + back];
                  if((res != 0) && (res > val))
                     ZigZagBuffer[shift + back] = 0.0;
                 }
              }
           }
         if(Low[shift] == val)
           {
            ZigZagBuffer[shift] = val;
           }
         else
            ZigZagBuffer[shift] = 0.0;
         //+--- HIGH ---------------------------------------------------------------------------------------------------------+
         val = High[Highest(NULL, 0, MODE_HIGH, ExtDepth, shift)];
         if(val == lasthigh)
            val = 0.0;
         else
           {
            lasthigh = val;
            if((val - High[shift]) > (ExtDeviation * Point))
               val = 0.0;
            else
              {
               for(back = 1; back <= ExtBackstep; back++)
                 {
                  res = TempBuffer[shift + back];
                  if((res != 0) && (res < val))
                     TempBuffer[shift + back] = 0.0;
                 }
              }
           }
         if(High[shift] == val)
           {
            TempBuffer[shift] = val;
           }
         else
            TempBuffer[shift] = 0.0;
        }
      //--- final cutting
      lasthigh = -1;
      lasthighpos = -1;
      lastlow = -1;
      lastlowpos = -1;
      for(shift = limit; shift >= 0; shift--)
        {
         curlow = ZigZagBuffer[shift];
         curhigh = TempBuffer[shift];
         if((curlow == 0) && (curhigh == 0))
            continue;
         if(curhigh != 0)
           {
            if(lasthigh > 0)
              {
               if(lasthigh < curhigh)
                  TempBuffer[lasthighpos] = 0;
               else
                  TempBuffer[shift] = 0;
              }
            if(lasthigh < curhigh || lasthigh < 0)
              {
               lasthigh = curhigh;
               lasthighpos = shift;
              }
            lastlow = -1;
           }
         if(curlow != 0)
           {
            if(lastlow > 0)
              {
               if(lastlow > curlow)
                  ZigZagBuffer[lastlowpos] = 0;
               else
                  ZigZagBuffer[shift] = 0;
              }
            if((curlow < lastlow) || (lastlow < 0))
              {
               lastlow = curlow;
               lastlowpos = shift;
              }
            lasthigh = -1;
           }
        }
      for(shift = limit; shift >= 0; shift--)
        {
         res = TempBuffer[shift];
         if(res != 0.0)
            ZigZagBuffer[shift] = res;
        }
      int i = 0, j = 0;
      res = 0;
      for(shift = 0; i < 3; shift++)
        {
         if(ZigZagBuffer[shift] > 0)
           {
            i++;
            if(i == 1 && ZigZagBuffer[shift] == High[shift])
              {
               j = shift;
               res = ZigZagBuffer[shift];
              }
            if(i == 2 && res > 0 && ZigZagBuffer[shift] == High[shift])
              {
               if(ZigZagBuffer[shift] >= ZigZagBuffer[j])
                  ZigZagBuffer[j] = 0;
               else
                  ZigZagBuffer[shift] = 0;
               res = 0;
               i = 0;
               j = 0;
               shift = 0;
              }
           }
        }
      if(limit < MaxBar)
        {
         ZigZagBuffer[supr2_bar] = ZigZag2;
         ZigZagBuffer[supr3_bar] = ZigZag3;
         ZigZagBuffer[supr4_bar] = ZigZag4;
         for(int qqq = supr4_bar - 1; qqq > supr3_bar; qqq--)
            ZigZagBuffer[qqq] = 0;
         for(int ggg = supr3_bar - 1; ggg > supr2_bar; ggg--)
            ZigZagBuffer[ggg] = 0;
        }
      double vel1, vel2, vel3, vel4;
      int bar1, bar2, bar3, bar4;
      int count;
      if(limit == MaxBar)
         supr4_bar = MaxBar;
      for(int bar = supr4_bar; bar >= 0; bar--)
        {
         if(ZigZagBuffer[bar] != 0)
           {
            count++;
            vel4 = vel3;
            bar4 = bar3;
            vel3 = vel2;
            bar3 = bar2;
            vel2 = vel1;
            bar2 = bar1;
            vel1 = ZigZagBuffer[bar];
            bar1 = bar;
            ObjDel();
            if(count < 3)
               continue;
            if((vel3 < vel2) && (vel2 < vel1))
              {
               ZigZagBuffer[bar2] = 0;
               bar = bar3 + 1;
              }
            if((vel3 > vel2) && (vel2 > vel1))
              {
               ZigZagBuffer[bar2] = 0;
               bar = bar3 + 1;
              }
            if((vel2 == vel1) && (vel1 != 0))
              {
               ZigZagBuffer[bar1] = 0;
               bar = bar3 + 1;
              }
           }
        }
      time2 = Time[bar2];
      time3 = Time[bar3];
      time4 = Time[bar4];
      ZigZag2 = vel2;
      ZigZag3 = vel3;
      ZigZag4 = vel4;
      if(bar1 >= 2)
        {
         if(Low[bar1] == vel1)
           {
            flag = 1;
            for(i = 1; i <= kol_lev; i++)
              {
               GreenLine1[bar1] = PlotLine("_lev " + bar1 + "_" + Complect + "_" + i, vel1, bar1, bar1, 0, angle_up * i, flag);
              }
           }
         else
           {
            flag = -1;
            for(i = 1; i <= kol_lev; i++)
              {
               GreenLine1[bar1] = PlotLine("_lev " + bar1 + "_" + Complect + "_" + i, vel1, bar1, bar1, 0, angle_dn * i, flag);
              }
           }
         PlotLineM("_lev " + bar1 + "_" + Complect + "_", vel1, bar1, bar1, 0, flag);
        }
      if(Low[bar2] == vel2)
        {
         flag = 1;
         for(i = 1; i <= kol_lev; i++)
           {
            OrangeLine1[bar2] = PlotLine("_lev " + bar2 + "_" + Complect + "_" + i, vel2, bar2, bar1, 1, angle_up * i, flag);
           }
        }
      else
        {
         flag = -1;
         for(i = 1; i <= kol_lev; i++)
           {
            OrangeLine1[bar2] = PlotLine("_lev " + bar2 + "_" + Complect + "_" + i, vel2, bar2, bar1, 1, angle_dn * i, flag);
           }
        }
      PlotLineM("_lev " + bar2 + "_" + Complect + "_", vel2, bar2, bar1, 1, flag);
      if(Low[bar3] == vel3)
        {
         flag = 1;
         for(i = 1; i <= kol_lev; i++)
           {
            GreenLine2[bar3] = PlotLine("_lev " + bar3 + "_" + Complect + "_" + i, vel3, bar3, bar2, 1, angle_up * i, flag);
           }
        }
      else
        {
         flag = -1;
         for(i = 1; i <= kol_lev; i++)
           {
            GreenLine2[bar3] = PlotLine("_lev " + bar3 + "_" + Complect + "_" + i, vel3, bar3, bar2, 1, angle_dn * i, flag);
           }
        }
      PlotLineM("_lev " + bar3 + "_" + Complect + "_", vel3, bar3, bar2, 1, flag);
      if(Low[bar4] == vel4)
        {
         flag = 1;
         for(i = 1; i <= kol_lev; i++)
           {
            OrangeLine2[bar4] = PlotLine("_lev " + bar4 + "_" + Complect + "_" + i, vel4, bar4, bar3, 1, angle_up * i, flag);
           }
        }
      else
        {
         flag = -1;
         for(i = 1; i <= kol_lev; i++)
           {
            OrangeLine2[bar4] = PlotLine("_lev " + bar4 + "_" + Complect + "_" + i, vel4, bar4, bar3, 1, angle_dn * i, flag);
           }
        }
      PlotLineM("_lev " + bar4 + "_" + Complect + "_", vel4, bar4, bar3, 1, flag);
      // OrangeLine1[bar4] = vel4;
      //+---ex4 Protection Function----------------------------------------------------------------------------------------+
     }
   else
     {
      Comment("\n            The name of this indicator cannot be changed\n    ''XU_v48-INDEX_ENTRY''");
     }
   int k, l, lastBar, lookBack = 100;
   double lastVal;
   for(l = 1; l < lookBack; l++)
     {
      if(GreenLine1[l] > 0)
        {
         
         lastBar = l;
         lastVal = GreenLine1[l];
         for(k = 0; k < lastBar; k++)
           {
            GreenLine1[k] = lastVal;
           }
         break;
        }
     }
   lastBar = 0;
   lastVal = 0.0;
   for(l = 0; l < lookBack; l++)
     {
      if(OrangeLine1[l] > 0)
        {
         lastBar = l;
         lastVal = OrangeLine1[l];
         for(k = 0; k < lastBar; k++)
           {
            OrangeLine1[k] = lastVal;
           }
         break;
        }
     }
   lastBar = 0;
   lastVal = 0.0;
   for(l = 1; l < lookBack; l++)
     {
      if(GreenLine2[l] > 0)
        {
         
         lastBar = l;
         lastVal = GreenLine2[l];
         for(k = 0; k < lastBar; k++)
           {
            GreenLine2[k] = lastVal;
           }
         break;
        }
     }
   lastBar = 0;
   lastVal = 0.0;
   for(l = 0; l < lookBack; l++)
     {
      if(OrangeLine2[l] > 0)
        {
         lastBar = l;
         lastVal = OrangeLine2[l];
         for(k = 0; k < lastBar; k++)
           {
            OrangeLine2[k] = lastVal;
           }
         break;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------------------------------------------------------+
void PlotLineM(string name, double Price1, int Date1, int Date2, int lev0, int âåðõ_âíèç)
  {
   int D2;  //double P1;
   if(lev0 == 1)
      D2 = Time[Date2];
   else
      D2 = Time[0] + 50 * Period() * 60;
//+------------------------------------------------------------------------------------------------------------------+
   ObjectDelete(name + " 0");
   ObjectCreate(name + " 0", OBJ_TREND, 0, Time[Date1], Price1, D2, Price1);
   ObjectSet(name + " 0", OBJPROP_COLOR, clrNONE); //Level_0);
   ObjectSet(name + " 0", OBJPROP_STYLE, 0);
   ObjectSet(name + " 0", OBJPROP_WIDTH, 1);
   ObjectSet(name + " 0", OBJPROP_BACK, true);
   ObjectSet(name + " 0", OBJPROP_RAY, false);
//+------------------------------------------------------------------------------------------------------------------+
   /*  if(âåðõ_âíèç==1) P1=Price1-2*Point; else if(âåðõ_âíèç==-1)
        P1=Price1+4*Point;
       ObjectDelete(name+" 0txt");
       ObjectCreate(name+" 0txt", OBJ_TEXT, 0, Time[Date1], P1);
          ObjectSet(name+" 0txt", OBJPROP_BACK, true);
      ObjectSetText(name+" 0txt", DoubleToStr(Price1,Digits), 12, "Tahoma Bold",Level_0); */
//+------------------------------------------------------------------------------------------------------------------+
   if(lev_V)
     {
      ObjectDelete(name + " V");
      ObjectCreate(name + " V", OBJ_VLINE, 0, Time[Date1], 0);
      ObjectSet(name + " V", OBJPROP_COLOR, clrNONE); //Level_V);
      ObjectSet(name + " V", OBJPROP_STYLE, 2);
      ObjectSet(name + " V", OBJPROP_WIDTH, 0);
      ObjectSet(name + " V", OBJPROP_BACK, true);
     }
  }
//+------------------------------------------------------------------------------------------------------------------+
double PlotLine(string name, double Price1, int Date1, int Date2, int lev0, double gr, int âåðõ_âíèç)
  {
   double level, points;
   int D2, nBar;
   if(Digits == 5 || Digits == 3)
      points = Point * 10;
   else
      points = Point;
   if(âåðõ_âíèç == 1)
     {
      level = MathSqrt(Price1 / points) + gr / 180;
      level = MathPow(level, 2) * points;
      öâåò_óðîâíÿ = SupportColor;
     }
   else
      if(âåðõ_âíèç == -1)
        {
         level = MathSqrt(Price1 / points) - gr / 180;
         level = MathPow(level, 2) * points;
         öâåò_óðîâíÿ = ResistanceColor;
        }
   if(lev0 == 1)
      D2 = Time[Date2];
   else
      D2 = Time[0] + 50 * Period() * 60;
//+------------------------------------------------------------------------------------------------------------------+
   ObjectDelete(name);
   ObjectCreate(name, OBJ_TREND, 0, Time[Date1], level, D2, level);
   ObjectSet(name, OBJPROP_COLOR, öâåò_óðîâíÿ);
   ObjectSet(name, OBJPROP_STYLE, Style);
   ObjectSet(name, OBJPROP_WIDTH, Width);
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_BACK, true);
//+------------------------------------------------------------------------------------------------------------------+
   ObjectDelete(name + " txt");
   if(lev0 == 1)
     {
      nBar = Date1 - 8;
      ObjectCreate(name + " txt", OBJ_TEXT, 0, Time[nBar], level);
      ObjectSet(name + " txt", OBJPROP_BACK, true);
     }
   else
     {
      ObjectCreate(name + " txt", OBJ_TEXT, 0, Time[0] + 8 * Period() * 60, level);
      ObjectSet(name + " txt", OBJPROP_BACK, true);
     }
   ObjectSetText(name + " txt", /*DoubleToStr(level,Digits)+*/"        XARD INDEX ENTRY", 12, "MV Boli", öâåò_óðîâíÿ);
   return(level);
  }
//+------------------------------------------------------------------------------------------------------------------+
void ObjDel()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i --)
     {
      if(StringFind(ObjectName(i), "_", 0) == 0)
        {
         ObjectDelete(ObjectName(i));
        }
     }
  }
//+------------------------------------------------------------------+

// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73180&p=149031#p149031

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
