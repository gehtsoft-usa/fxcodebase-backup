// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74531

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

   #property indicator_separate_window
   #property indicator_buffers 8
   
   #property indicator_color1 White
   #property indicator_color2 Red
   #property indicator_color3 Gold
   #property indicator_color4 GreenYellow
   #property indicator_color5 DarkOrange
   #property indicator_color6 PaleVioletRed
   #property indicator_color7 DeepSkyBlue
   #property indicator_color8 Olive
   #property indicator_color9 clrMediumSeaGreen
   #property indicator_color10 clrCrimson
   #property indicator_width9 2
   #property indicator_width10 2
   
   extern string TimeFrame = "";
   extern bool   showOnlySymbolOnChart = true;
   extern bool   showDoubleGapsOnChart = true;
   extern bool   showOnlyDirectionOfPair = false;
   extern int   doubleCandleDiff = 2;
   extern int    startCandle = 0;
   extern int   endCandle= 1000;
   
   int MaMethod = 3;
   int MaFast = 3;
   int MaSlow = 5;
   int Price = 6;

   double arrUSD[];
   double arrEUR[];
   double arrGBP[];
   double arrCHF[];
   double arrJPY[];
   double arrAUD[];
   double arrCAD[];
   double arrNZD[];
   double arrowUp[];
   double arrowDn[];

   string indicatorFileName;
   bool returnBars;
   bool calculateValue;
   int timeFrame = 0;
   string curr1, curr2;

   string names[8] = {
      "USD",
      "EUR",
      "GBP",
      "CHF",
      "JPY",
      "AUD",
      "CAD",
      "NZD"
   };
   int colors[8] = {
      indicator_color1,
      indicator_color2,
      indicator_color3,
      indicator_color4,
      indicator_color5,
      indicator_color6,
      indicator_color7,
      indicator_color8
   };
   string Indicator_Name = "CCPF ";
   bool Interpolate = true;

   double arrVal(int i, string curr) {
      if (curr == "USD")
         return arrUSD[i];
      if (curr == "EUR")
         return arrEUR[i];
      if (curr == "GBP")
         return arrGBP[i];
      if (curr == "CHF")
         return arrCHF[i];
      if (curr == "JPY")
         return arrJPY[i];
      if (curr == "AUD")
         return arrAUD[i];
      if (curr == "CAD")
         return arrCAD[i];
      if (curr == "NZD")
         return arrNZD[i];
      return -1;
   }

   //+------------------------------------------------------------------
   //|                                                                  
   //+------------------------------------------------------------------
   int init() {
      IndicatorDigits(6);
      SetIndexBuffer(0, arrUSD);
      SetIndexBuffer(1, arrEUR);
      SetIndexBuffer(2, arrGBP);
      SetIndexBuffer(3, arrCHF);
      SetIndexBuffer(4, arrJPY);
      SetIndexBuffer(5, arrAUD);
      SetIndexBuffer(6, arrCAD);
      SetIndexBuffer(7, arrNZD);
      SetIndexBuffer(8, arrowUp);
      SetIndexBuffer(9, arrowDn);
      SetIndexStyle(8, DRAW_ARROW);
      SetIndexStyle(9, DRAW_ARROW);
      SetIndexArrow(8, 233);
      SetIndexArrow(9, 234);
      initLabels();
      indicatorFileName = WindowExpertName();
      returnBars = (TimeFrame == "returnBars");
      if (returnBars) return (0);
      calculateValue = (TimeFrame == "calculateValue");
      if (calculateValue) return (0);
      timeFrame = stringToTimeFrame(TimeFrame);
      switch (timeFrame) {
         case PERIOD_M1:
            MaSlow = 30;
            MaFast = 10;
            break;
         case PERIOD_M5:
            MaSlow = 12;
            MaFast = 3;
            break;
         case PERIOD_M15:
            MaSlow = 16;
            MaFast = 4;
            break;
         case PERIOD_M30:
            MaSlow = 16;
            MaFast = 2;
            break;
         case PERIOD_H1:
            MaSlow = 24;
            MaFast = 8;
            break;
         case PERIOD_H4:
            MaSlow = 18;
            MaFast = 6;
            break;
         case PERIOD_D1:
            MaSlow = 5;
            MaFast = 3;
            break;
         case PERIOD_W1:
            MaSlow = 9;
            MaFast = 3;
            break;
         case PERIOD_MN1:
            MaSlow = 12;
            MaFast = 3;
            break;
      }
      curr1 = StringSubstr(Symbol(), 0, 3);
      curr2 = StringSubstr(Symbol(), 3, 3);
      IndicatorShortName(Indicator_Name);
      return (0);
   }


   //+------------------------------------------------------------------
   //|                                                                  
   //+------------------------------------------------------------------
   string symbols[];
   void addSymbol(string tsymbol) {
      ArrayResize(symbols, ArraySize(symbols) + 1);
      symbols[ArraySize(symbols) - 1] = tsymbol;
   }

   int getLimit(int limit, string tsymbol) {
      if (tsymbol != Symbol())
         limit = MathMax(MathMin(Bars - 1, iCustom(tsymbol, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()), limit);
      return (limit);
   }


   int deinit() {
      return (0);
   }

   //+------------------------------------------------------------------
   //|                                                                  
   //+------------------------------------------------------------------
   double values[8];
   double valuea[8];
   int start() {
      int i, r, counted_bars = IndicatorCounted();

      if (counted_bars < 0) return (-1);
      if (counted_bars > 0) counted_bars--;
      int limit = MathMin(Bars - counted_bars, Bars - 1);
      if (returnBars) {
         arrUSD[0] = limit;
         return (0);
      }

      for (int t = 0; t < ArraySize(symbols); t++)
         limit = getLimit(limit, symbols[t]);
      ArrayInitialize(values, -1);
      if (calculateValue || timeFrame == Period()) {
         if (!(endCandle > 0 && endCandle > startCandle))
            endCandle = limit;
         for (i = endCandle; i >= startCandle; i--) {
            double EURUSD_Fast = ma("EURUSD", MaFast, MaMethod, Price, i);
            double EURUSD_Slow = ma("EURUSD", MaSlow, MaMethod, Price, i);
            if (!EURUSD_Fast || !EURUSD_Slow)
               break;
            double GBPUSD_Fast = ma("GBPUSD", MaFast, MaMethod, Price, i);
            double GBPUSD_Slow = ma("GBPUSD", MaSlow, MaMethod, Price, i);
            if (!GBPUSD_Fast || !GBPUSD_Slow)
               break;
            double AUDUSD_Fast = ma("AUDUSD", MaFast, MaMethod, Price, i);
            double AUDUSD_Slow = ma("AUDUSD", MaSlow, MaMethod, Price, i);
            if (!AUDUSD_Fast || !AUDUSD_Slow)
               break;
            double NZDUSD_Fast = ma("NZDUSD", MaFast, MaMethod, Price, i);
            double NZDUSD_Slow = ma("NZDUSD", MaSlow, MaMethod, Price, i);
            if (!NZDUSD_Fast || !NZDUSD_Slow)
               break;
            double USDCAD_Fast = ma("USDCAD", MaFast, MaMethod, Price, i);
            double USDCAD_Slow = ma("USDCAD", MaSlow, MaMethod, Price, i);
            if (!USDCAD_Fast || !USDCAD_Slow)
               break;
            double USDCHF_Fast = ma("USDCHF", MaFast, MaMethod, Price, i);
            double USDCHF_Slow = ma("USDCHF", MaSlow, MaMethod, Price, i);
            if (!USDCHF_Fast || !USDCHF_Slow)
               break;
            double USDJPY_Fast = ma("USDJPY", MaFast, MaMethod, Price, i) / 100.0;
            double USDJPY_Slow = ma("USDJPY", MaSlow, MaMethod, Price, i) / 100.0;
            if (!USDJPY_Fast || !USDJPY_Slow) {
               break;
            }

            arrUSD[i] = 0;
            arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
            arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
            arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
            arrUSD[i] += NZDUSD_Slow - NZDUSD_Fast;
            arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
            arrUSD[i] += USDCAD_Fast - USDCAD_Slow;
            arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
            values[0] = arrUSD[i];
            HideCurrency("USD", arrUSD[i]);

            arrEUR[i] = 0;
            arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
            arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
            arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
            arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / NZDUSD_Slow;
            arrEUR[i] += EURUSD_Fast * USDCHF_Fast - EURUSD_Slow * USDCHF_Slow;
            arrEUR[i] += EURUSD_Fast * USDCAD_Fast - EURUSD_Slow * USDCAD_Slow;
            arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
            values[1] = arrEUR[i];
            HideCurrency("EUR", arrEUR[i]);

            arrGBP[i] = 0;
            arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
            arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
            arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
            arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / NZDUSD_Slow;
            arrGBP[i] += GBPUSD_Fast * USDCHF_Fast - GBPUSD_Slow * USDCHF_Slow;
            arrGBP[i] += GBPUSD_Fast * USDCAD_Fast - GBPUSD_Slow * USDCAD_Slow;
            arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
            values[2] = arrGBP[i];
            HideCurrency("GBP", arrGBP[i]);

            arrAUD[i] = 0;
            arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
            arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
            arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
            arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / NZDUSD_Slow;
            arrAUD[i] += AUDUSD_Fast * USDCHF_Fast - AUDUSD_Slow * USDCHF_Slow;
            arrAUD[i] += AUDUSD_Fast * USDCAD_Fast - AUDUSD_Slow * USDCAD_Slow;
            arrAUD[i] += AUDUSD_Fast * USDJPY_Fast - AUDUSD_Slow * USDJPY_Slow;
            values[5] = arrAUD[i];
            HideCurrency("AUD", arrAUD[i]);

            arrNZD[i] = 0;
            arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
            arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / NZDUSD_Fast;
            arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / NZDUSD_Fast;
            arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / NZDUSD_Fast;
            arrNZD[i] += NZDUSD_Fast * USDCHF_Fast - NZDUSD_Slow * USDCHF_Slow;
            arrNZD[i] += NZDUSD_Fast * USDCAD_Fast - NZDUSD_Slow * USDCAD_Slow;
            arrNZD[i] += NZDUSD_Fast * USDJPY_Fast - NZDUSD_Slow * USDJPY_Slow;
            values[7] = arrNZD[i];
            HideCurrency("NZD", arrNZD[i]);

            arrCAD[i] = 0;
            arrCAD[i] += USDCAD_Slow - USDCAD_Fast;
            arrCAD[i] += EURUSD_Slow * USDCAD_Slow - EURUSD_Fast * USDCAD_Fast;
            arrCAD[i] += GBPUSD_Slow * USDCAD_Slow - GBPUSD_Fast * USDCAD_Fast;
            arrCAD[i] += AUDUSD_Slow * USDCAD_Slow - AUDUSD_Fast * USDCAD_Fast;
            arrCAD[i] += NZDUSD_Slow * USDCAD_Slow - NZDUSD_Fast * USDCAD_Fast;
            arrCAD[i] += USDCHF_Fast / USDCAD_Fast - USDCHF_Slow / USDCAD_Slow;
            arrCAD[i] += USDJPY_Fast / USDCAD_Fast - USDJPY_Slow / USDCAD_Slow;
            values[6] = arrCAD[i];
            HideCurrency("CAD", arrCAD[i]);

            arrCHF[i] = 0;
            arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
            arrCHF[i] += EURUSD_Slow * USDCHF_Slow - EURUSD_Fast * USDCHF_Fast;
            arrCHF[i] += GBPUSD_Slow * USDCHF_Slow - GBPUSD_Fast * USDCHF_Fast;
            arrCHF[i] += AUDUSD_Slow * USDCHF_Slow - AUDUSD_Fast * USDCHF_Fast;
            arrCHF[i] += NZDUSD_Slow * USDCHF_Slow - NZDUSD_Fast * USDCHF_Fast;
            arrCHF[i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
            arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
            values[3] = arrCHF[i];
            HideCurrency("CHF", arrCHF[i]);

            arrJPY[i] = 0;
            arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
            arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
            arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
            arrJPY[i] += AUDUSD_Slow * USDJPY_Slow - AUDUSD_Fast * USDJPY_Fast;
            arrJPY[i] += NZDUSD_Slow * USDJPY_Slow - NZDUSD_Fast * USDJPY_Fast;
            arrJPY[i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
            arrJPY[i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
            values[4] = arrJPY[i];
            HideCurrency("JPY", arrJPY[i]);
            if (i == 0) ArrayCopy(valuea, values);
            if (showDoubleGapsOnChart)
               doubleGapsOnChart(i);
         }
         manageDisplay();

         return (0);
      }
      // MTF Handling

      for (i = endCandle, r = Bars - i - 1; i >= 0; i--, r++) {
         int y = iBarShift(NULL, timeFrame, Time[i]);
         arrUSD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 0, y);
         arrEUR[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 1, y);
         arrGBP[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 2, y);
         arrCHF[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 3, y);
         arrJPY[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 4, y);
         arrAUD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 5, y);
         arrCAD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 6, y);
         arrNZD[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", showOnlySymbolOnChart, showOnlyDirectionOfPair, startCandle, endCandle, 7, y);
         values[0] = arrUSD[i];
         values[1] = arrEUR[i];
         values[2] = arrGBP[i];
         values[3] = arrCHF[i];
         values[4] = arrJPY[i];
         values[5] = arrAUD[i];
         values[6] = arrCAD[i];
         values[7] = arrNZD[i];
         if (i == 0) ArrayCopy(valuea, values);
         if (!Interpolate || y == iBarShift(NULL, timeFrame, Time[i - 1])) continue;
         interpolate(arrUSD, iTime(NULL, timeFrame, y), i);
         interpolate(arrEUR, iTime(NULL, timeFrame, y), i);
         interpolate(arrGBP, iTime(NULL, timeFrame, y), i);
         interpolate(arrJPY, iTime(NULL, timeFrame, y), i);
         interpolate(arrCHF, iTime(NULL, timeFrame, y), i);
         interpolate(arrAUD, iTime(NULL, timeFrame, y), i);
         interpolate(arrCAD, iTime(NULL, timeFrame, y), i);
         interpolate(arrNZD, iTime(NULL, timeFrame, y), i);
         if (showDoubleGapsOnChart)
            doubleGapsOnChart(i);
      }
      manageDisplay();
      return (0);
   }

   void HideCurrency(string actCur, double & ArrEl) {
      if (!showOnlySymbolOnChart)
         return;
      if (StringFind(Symbol(), actCur) == -1)
         ArrEl = EMPTY_VALUE;
   }

   //-------------------------------------------------------------------
   //                                                                  
   //-------------------------------------------------------------------

   void manageDisplay() {
      double tempV[8];
      int i;
      ArrayCopy(tempV, valuea);
      int window = WindowFind(Indicator_Name);

      // Show legend color signs
      int cur = 12;
      int st = 23;
      for (i = 0; i <= 7; i++)
         if (ShowLabelCurrency(names[i])) {
            string ID = Indicator_Name + "lblCur" + string(i);
            ObjectCreate(ID, OBJ_LABEL, window, 0, 0);
            if (TimeFrame == "")
               ObjectSet(ID, OBJPROP_XDISTANCE, cur + 30);
            else
               ObjectSet(ID, OBJPROP_XDISTANCE, cur + 40);
            ObjectSet(ID, OBJPROP_YDISTANCE, 5);
            ObjectSetText(ID, "~", 18, "Arial Black", colors[i]);
            SetIndexLabel(i, names[i]);
            cur += st;
         }


      // Show right pane
      int k = 0;
      int y = 0;
      for (i = 0; i < 8; i++)
         if (ShowLabelCurrency(names[i])) {
            string name = Indicator_Name + ":" + i;
            ObjectCreate(name, OBJ_LABEL, window, 0, 0);
            ObjectSet(name, OBJPROP_XDISTANCE, 70);
            ObjectSet(name, OBJPROP_YDISTANCE, y);
            ObjectSet(name, OBJPROP_BACK, FALSE);
            ObjectSet(name, OBJPROP_CORNER, 1);
            ObjectSetText(name, names[i] + ":  ", 10, "Arial bold", colors[i]);
            name = Indicator_Name + ":n" + i;
            ObjectCreate(name, OBJ_LABEL, window, 0, 0);
            ObjectSet(name, OBJPROP_XDISTANCE, 10);
            ObjectSet(name, OBJPROP_YDISTANCE, y);
            ObjectSet(name, OBJPROP_BACK, FALSE);
            ObjectSet(name, OBJPROP_CORNER, 1);
            ObjectSetText(name, DoubleToStr(tempV[i], 6), 10, "Arial bold", colors[i]);
            ObjectSet(name, OBJPROP_COLOR, colors[i]);
            y += 16;
            k++;
         }
   }

   //-------------------------------------------------------------------
   //                                                                  
   //-------------------------------------------------------------------
   void interpolate(double & buffer[], datetime time, int i) {
      for (int n = 1;
         (i + n) < Bars && Time[i + n] >= time; n++) continue;

      if (buffer[i] == EMPTY_VALUE || buffer[i + n] == EMPTY_VALUE) n = -1;
      double increment = (buffer[i + n] - buffer[i]) / n;
      for (int k = 1; k < n; k++) buffer[i + k] = buffer[i] + k * increment;
   }


   double ma(string sym, int per, int Mode, int tPrice, int i) {
      return (iMA(sym, 0, per, 0, Mode, tPrice, i));
   }

   //+------------------------------------------------------------------
   //|                                                                  
   //+------------------------------------------------------------------

   void sl(int buffNo, string sym, int x, color col, string buffLabel) {
      int window = WindowFind(Indicator_Name);
      string ID = Indicator_Name + buffNo;

      if (ObjectCreate(ID, OBJ_LABEL, window, 0, 0))
         ObjectSet(ID, OBJPROP_XDISTANCE, x + 25);
      ObjectSet(ID, OBJPROP_YDISTANCE, 5);
      ObjectSetText(ID, sym, 18, "Arial Black", col);

      SetIndexStyle(buffNo, DRAW_LINE, STYLE_SOLID, 1, col);
      SetIndexLabel(buffNo, buffLabel);
   }

   //+-------------------------------------------------------------------
   //|                                                                  
   //+-------------------------------------------------------------------


   string sTfTable[] = {
      "M1",
      "M5",
      "M15",
      "M30",
      "H1",
      "H4",
      "D1",
      "W1",
      "MN"
   };
   int iTfTable[] = {
      1,
      5,
      15,
      30,
      60,
      240,
      1440,
      10080,
      43200
   };


   int stringToTimeFrame(string tfs) {
      StringToUpper(tfs);
      for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
         if (tfs == sTfTable[i] || tfs == "" + iTfTable[i]) return (MathMax(iTfTable[i], Period()));
      return (Period());
   }
   string timeFrameToString(int tf) {
      for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
         if (tf == iTfTable[i]) return (sTfTable[i]);
      return ("");
   }

   bool ShowLabelCurrency(string actCur) {
      if (!showOnlySymbolOnChart)
         return true;
      return (StringFind(Symbol(), actCur) >= 0);
   }

   void initLabels() {

      Indicator_Name = StringConcatenate(Indicator_Name, TimeFrame + "   ");
      for (int i = 0; i <= 7; i++)
         if (ShowLabelCurrency(names[i]))
            Indicator_Name = StringConcatenate(Indicator_Name, names[i] + " ");
      Indicator_Name = StringConcatenate(Indicator_Name, "   ");
   }


   void doubleGapsOnChart(int i) {
      if (showDoubleGapsOnChart) {
         if (arrVal(i + doubleCandleDiff, curr1) < arrVal(i, curr1) && arrVal(i + doubleCandleDiff, curr2) > arrVal(i, curr2)) {
            arrowUp[i] = arrVal(i, curr1);
            if (!showOnlyDirectionOfPair)
               arrowDn[i] = arrVal(i, curr2);
         } else if (arrVal(i + doubleCandleDiff, curr1) > arrVal(i, curr1) && arrVal(i + doubleCandleDiff, curr2) < arrVal(i, curr2)) {
            arrowDn[i] = arrVal(i, curr1);
            if (!showOnlyDirectionOfPair)
               arrowUp[i] = arrVal(i, curr2);
         } else {
            arrowUp[i] = EMPTY_VALUE;
            arrowDn[i] = EMPTY_VALUE;
         }
      }
   }
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+