// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71913

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property strict
#property indicator_separate_window
#property indicator_levelcolor DimGray
#property indicator_buffers 10
#property indicator_plots   2
#property indicator_level1 25.0
#property indicator_level2 15.0

#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int     Len = 150;
input int     HistoryBars = 500;
input int     TF1 = 0;
input int     TF2 = 0;
input bool    ModeHL = true;
input bool    ModeOnline = true;
input bool    ModeinFile = false;
input bool    ModeHistory = false;
input bool    alert = false;
input bool    sound = false;
input bool    email = false;
input bool    GV = false;
input double  UrovenSignal = 25.0;

double g_ibuf_148[];
double g_ibuf_152[];
double gd_156;
double gd_164;
double gd_172;
int gi_188;
int g_shift_192;
int gi_196;
int g_shift_200;
int g_count_208;
double gd_212;
double gd_220;
double gd_228;
double gd_236;
double gd_244;
double gd_252;
double gda_260[][240];
double gda_264[][240];
double gda_268[][240];
int g_timeframe_272;
int g_datetime_276;
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
      TF_2 = Period();
   History_Bars = NormalizeDouble(History_Bars / (TF_2 / Period()), 0);
   SetIndexBuffer(0, g_ibuf_148, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   SetIndexBuffer(1, g_ibuf_152, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);

   ArraySetAsSeries(g_ibuf_148, true);
   ArraySetAsSeries(g_ibuf_152, true);


   ArrayResize(gda_260, HistoryBars + Len +10);
   ArrayResize(gda_264, HistoryBars + Len+10);
   ArrayResize(gda_268, HistoryBars + Len+10);
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
   int count_0;
   int li_4;
   int li_12;
   int li_20;
   int str2time_24;
   int str2int_28;
   int str2int_32;
   int file_36;
   if(ModeOnline || ModeinFile)
     {
      if(iTime(Symbol(), TF_2, 0) == g_datetime_276)
         // return (0);
      g_datetime_276 = iTime(Symbol(), TF_2, 0);
      for(gi_188 = HistoryBars + Len; gi_188 > 0; gi_188--)
        {
         g_shift_200 = iBarShift(Symbol(), TF_1, iTime(Symbol(), TF_2, gi_188));
         count_0 = 0;
         for(g_shift_192 = g_shift_200; g_shift_192 > g_shift_200 - TF_2; g_shift_192--)
           {
            //Print(count_0);
            gda_260[gi_188][count_0] = iClose(Symbol(), TF_1, g_shift_192);
            if(ModeHL)
               gda_264[gi_188][count_0] = iHigh(Symbol(), TF_1, g_shift_192);
            else
               gda_264[gi_188][count_0] = MathMax(iOpen(Symbol(), TF_1, g_shift_192), iClose(Symbol(), TF_1, g_shift_192));
            if(ModeHL)
               gda_268[gi_188][count_0] = iLow(Symbol(), TF_1, g_shift_192);
            else
               gda_268[gi_188][count_0] = MathMin(iOpen(Symbol(), TF_1, g_shift_192), iClose(Symbol(), TF_1, g_shift_192));
            count_0++;
            if(count_0>239)
               break;
           }
        }
      li_4 = NormalizeDouble((iBars(Symbol(), Period()) - 100) / (TF_2 / Period()), 0);
      if(ModeOnline && !MQLInfoInteger(MQL_TESTER))
         li_4 = History_Bars;
      for(gi_188 = li_4; gi_188 > 0; gi_188--)
        {
         g_count_208 = 0;
         gd_228 = 0;
         gd_236 = 0;
         gd_212 = 0;
         gd_220 = 1000000;
         while(g_count_208 < Len)
           {
            gi_196 = gi_188 + g_count_208;
            gd_244 = 0;
            gd_252 = 0;
            for(int count_8 = 0; count_8 < TF_2; count_8++)
              {
               if(gda_260[gi_196][count_8] != EMPTY_VALUE)
                  gd_156 = gda_260[gi_196][count_8];
               if(gda_264[gi_196][count_8] != EMPTY_VALUE)
                  gd_164 = gda_264[gi_196][count_8];
               if(gda_268[gi_196][count_8] != EMPTY_VALUE)
                  gd_172 = gda_268[gi_196][count_8];
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
            if(gd_244 > 0.0)
               gd_228 += gd_244;
            if(gd_252 > 0.0)
               gd_236 += gd_252;
            g_count_208++;
           }
         if(gd_228 > 0.0 && gd_236 > 0.0)
           {
            if(ModeinFile && gi_280 != iTime(Symbol(), Period(), gi_188))
              {
               gi_280 = iTime(Symbol(), Period(), gi_188);
               FileWrite(g_file_288, (string)gi_280 + ";" + DoubleToString(gd_228 / gd_236, 0)+";"+ DoubleToString(gd_236 / gd_228, 0));
              }
            li_12 = iBarShift(Symbol(), 0, iTime(Symbol(), TF_2, gi_188));
            for(li_16 = li_12; li_16 > li_12 - TF_2 / Period(); li_16--)
              {
               g_ibuf_148[li_16] = gd_228 / gd_236;
               g_ibuf_152[li_16] = gd_236 / gd_228;
              }
           }
        }
     }
   ChartRedraw();
   if(ModeHistory && (!ModeOnline) && (!ModeinFile) && gi_284 == false)
     {
      gi_284 = true;
      file_36 = FileOpen(Symbol() + "-SP-" + (string)TF_2 + ".ini", FILE_READ);
      while(!FileIsEnding(file_36))
        {
         str2time_24 = StringToTime(FileReadString(file_36));
         str2int_28 = StringToInteger(FileReadString(file_36));
         str2int_32 = StringToInteger(FileReadString(file_36));
         li_20 = iBarShift(Symbol(), 0, str2time_24, false);
         for(int li_40 = li_20; li_40 > li_20 - TF_2 / Period(); li_40--)
           {
            g_ibuf_148[li_40] = str2int_28;
            g_ibuf_152[li_40] = str2int_32;
           }
        }
      FileClose(file_36);
     }
   string ls_44 = "";
   if(sound || alert || email || GV)
     {
      if(g_ibuf_148[li_16 + 1] > UrovenSignal && g_ibuf_148[li_16 + 1] < 1000000.0)
         ls_44 = Symbol() + " Signal " + MQLInfoString(MQL_PROGRAM_NAME) + " BUY ( " + DoubleToString(g_ibuf_148[li_16 + 1], 1) + " )";
      if(g_ibuf_152[li_16 + 1] > UrovenSignal && g_ibuf_152[li_16 + 1] < 1000000.0)
         ls_44 = Symbol() + " Signal " + MQLInfoString(MQL_PROGRAM_NAME) + " SELL ( " + DoubleToString(g_ibuf_152[li_16 + 1], 1) + " )";
      if(GV && (!MQLInfoInteger(MQL_TESTER)))
         GlobalVariableSet(Symbol() + MQLInfoString(MQL_PROGRAM_NAME), g_ibuf_148[li_16 + 1] - (g_ibuf_152[li_16 + 1]));
      if(ls_44 != "" && (!MQLInfoInteger(MQL_TESTER)))
        {
         if(sound && gi_292 == false)
            PlaySound("Wait.wav");
         if(alert && gi_292 == false)
            Alert(ls_44);
         if(email && gi_292 == false)
            f0_0(ls_44);
         gi_292 = true;
        }
      else
         gi_292 = false;
     }
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
