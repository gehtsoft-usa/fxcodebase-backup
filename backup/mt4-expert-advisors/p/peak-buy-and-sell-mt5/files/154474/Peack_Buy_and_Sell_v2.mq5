// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74641

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

#property strict
#property indicator_separate_window
#property indicator_levelcolor DimGray
#property indicator_buffers 10
#property indicator_plots   2
#property indicator_level1 25.0
#property indicator_level2 15.0

#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

input int     Len = 20;
input int     HistoryBars = 200;
input ENUM_TIMEFRAMES     TF1 = 0;
input ENUM_TIMEFRAMES     TF2 = 0;
input bool    ModeHL = true;
input bool    ModeOnline = true;
bool    ModeinFile = false;
bool    ModeHistory = false;
input bool    alert = true;
input bool    sound = true;
input bool    email = true;
input bool    GV = true;
input double  UrovenSignal = 25.0;

double buyBuffer[];
double sellBuffer[];
double gd_156;
double gd_164;
double gd_172;
int i;
int s;
int barsBack;
int BarShift;
int l;
double gd_212;
double gd_220;
double gd_228;
double gd_236;
double gd_244;
double gd_252;
double HistoryClose[][240];
double HistoryHigh[][240];
double HistoryLow[][240];
int g_timeframe_272;
int timeOnTF2;
int gi_280;
bool gi_284;
int g_file_288;
bool gi_292;
int li_16;
ENUM_TIMEFRAMES TF_1 = TF1;
ENUM_TIMEFRAMES TF_2 = TF2;
int History_Bars = HistoryBars;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ModeinFile)
      FileDelete(Symbol() + "-SP-" + Period() + ".ini");
   if(TF_2 == 0)
      TF_2 =  Period();
   History_Bars = NormalizeDouble(History_Bars / (TFvalue(TF_2) / TFvalue(Period())), 0);
   Print(__FUNCTION__," History_Bars: ",History_Bars);

   SetIndexBuffer(0, buyBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   SetIndexBuffer(1, sellBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);

   ArraySetAsSeries(buyBuffer, true);
   ArraySetAsSeries(sellBuffer, true);


   ArrayResize(HistoryClose, HistoryBars + Len +1);
   ArrayResize(HistoryHigh, HistoryBars + Len+1);
   ArrayResize(HistoryLow, HistoryBars + Len+1);
   g_timeframe_272 = Period();
   if(ModeinFile)
      g_file_288 = FileOpen(Symbol() + "-SP-" + Period() + ".ini", FILE_WRITE, " ");
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
  {
   int count;
   int bars;
   int li_12;
   int li_20;
   int str2time_24;
   int str2int_28;
   int str2int_32;
   int file_36;


   if(ModeOnline || ModeinFile)
     {
      if(iTime(Symbol(), TF_2, 0) == timeOnTF2)
      timeOnTF2 = iTime(Symbol(), TF_2, 0);

      for(i = HistoryBars + Len; i > 0; i--)
      {
         BarShift = iBarShift(Symbol(), TF_1, iTime(Symbol(), TF_2, i));

         count = 0;
         for(s = BarShift; s > BarShift - TF_2; s--)
           {
            //Print(count);
            HistoryClose[i][count] = iClose(Symbol(), TF_1, s);
            if(ModeHL)
               HistoryHigh[i][count] = iHigh(Symbol(), TF_1, s);
            else
               HistoryHigh[i][count] = MathMax(iOpen(Symbol(), TF_1, s), iClose(Symbol(), TF_1, s));
            if(ModeHL)
               HistoryLow[i][count] = iLow(Symbol(), TF_1, s);
            else
               HistoryLow[i][count] = MathMin(iOpen(Symbol(), TF_1, s), iClose(Symbol(), TF_1, s));

            count++;
            if(count > 239)
                break;
           }
        }

    //   bars = NormalizeDouble((iBars(Symbol(), Period()) - 100) / (TFvalue(TF_2) / TFvalue(Period())), 0)-1;

    //   if(ModeOnline && !MQLInfoInteger(MQL_TESTER))
          bars = History_Bars-1;

      for(int i = bars; i > 0; i--)
      {
         l = 0;
         gd_228 = 0;
         gd_236 = 0;
         gd_212 = 0;
         gd_220 = 1000000;

         while(l < Len-1)
         {
            barsBack = i + l;
            // Print(__FUNCTION__," barsBack: ",barsBack);
            gd_244 = 0;
            gd_252 = 0;

            // for(int count_8 = 0; count_8 < TFvalue(TF_2); count_8++)
            for(int count_8 = 0; count_8 < 238; count_8++)
            {
               if(HistoryClose[barsBack][count_8] != EMPTY_VALUE)  gd_156 = HistoryClose[barsBack][count_8];
               if(HistoryHigh[barsBack][count_8] != EMPTY_VALUE)   gd_164 = HistoryHigh[barsBack][count_8];
               if(HistoryLow[barsBack][count_8] != EMPTY_VALUE)    gd_172 = HistoryLow[barsBack][count_8];

               if(gd_164 > gd_212)
               {
                  gd_212 = gd_164;
                  gd_244 += gd_156;
                 }
               if(gd_172 < gd_220)
                 {
                  gd_220 = gd_172;
                  gd_252 += gd_156;
                 }

               if(count_8>238)
                  break;
              }

            if(gd_244 > 0.0) gd_228 += gd_244;
            if(gd_252 > 0.0) gd_236 += gd_252;

            l++;
         }
         
         if(gd_228 > 0.0 && gd_236 > 0.0)
           {
            // if(ModeinFile && gi_280 != iTime(Symbol(), Period(), i))
            //   {
            //    gi_280 = iTime(Symbol(), Period(), i);
            //    FileWrite(g_file_288, (string)gi_280 + ";" + DoubleToString(gd_228 / gd_236, 0)+";"+ DoubleToString(gd_236 / gd_228, 0));
            //   }

            li_12 = iBarShift(Symbol(), 0, iTime(Symbol(), TF_2, i));

            for(li_16 = li_12; li_16 > li_12 - TFvalue(TF_2) / TFvalue(Period()); li_16--)
            {
               buyBuffer[li_16] = gd_228 / gd_236;
               sellBuffer[li_16] = gd_236 / gd_228;
              }
           }
        }
   }
   
   //    ChartRedraw();


   
//    string ls_44 = "";
//    if(sound || alert || email || GV)
//      {
//       if(buyBuffer[li_16 + 1] > UrovenSignal && buyBuffer[li_16 + 1] < 1000000.0)
//          ls_44 = Symbol() + " Signal " + MQLInfoString(MQL_PROGRAM_NAME) + " BUY ( " + DoubleToString(buyBuffer[li_16 + 1], 1) + " )";

//       if(sellBuffer[li_16 + 1] > UrovenSignal && sellBuffer[li_16 + 1] < 1000000.0)
//           ls_44 = Symbol() + " Signal " + MQLInfoString(MQL_PROGRAM_NAME) + " SELL ( " + DoubleToString(sellBuffer[li_16 + 1], 1) + " )";

//     //   if(GV && (!MQLInfoInteger(MQL_TESTER)))
//     //       GlobalVariableSet(Symbol() + MQLInfoString(MQL_PROGRAM_NAME), buyBuffer[li_16 + 1] - (sellBuffer[li_16 + 1]));

//       if(ls_44 != "" && (!MQLInfoInteger(MQL_TESTER)))
//       {
//          if(sound && gi_292 == false) PlaySound("Wait.wav");
//          if(alert && gi_292 == false) Alert(ls_44);
//          if(email && gi_292 == false) f0_0(ls_44);
//          gi_292 = true;
//       }
//       else
//          gi_292 = false;
//      }

   
   return (rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_0(string as_0)
  {
   if(MQLInfoInteger(MQL_TESTER) == false && MQLInfoInteger(MQL_OPTIMIZATION) == false && MQLInfoInteger(MQL_VISUAL_MODE) == false)
      SendMail(MQLInfoString(MQL_PROGRAM_NAME), as_0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   if(ModeinFile)
      FileClose(g_file_288);
  }
//+------------------------------------------------------------------+


int TFvalue(ENUM_TIMEFRAMES tf=0)
{
    
    if(tf = PERIOD_CURRENT) return 0;
    if(tf = PERIOD_M5) return 5;
    if(tf = PERIOD_M15) return 15;
    if(tf = PERIOD_M30) return 30;
    if(tf = PERIOD_H1) return 60;
    if(tf = PERIOD_H4) return 240;
    if(tf = PERIOD_D1) return 1440;
    if(tf = PERIOD_W1) return 10080;
    if(tf = PERIOD_MN1) return 43200; 

    return 0;
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