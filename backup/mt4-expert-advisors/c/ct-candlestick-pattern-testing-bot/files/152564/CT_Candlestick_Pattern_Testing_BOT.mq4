//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74158

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_label1 "Three White Soldiers"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "5 W S"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "5 W S"
#property indicator_type3 DRAW_ARROW
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "6 W S"
#property indicator_type4 DRAW_ARROW
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "RBRBR"
#property indicator_type5 DRAW_ARROW
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Three Black Crows"
#property indicator_type6 DRAW_ARROW
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "4 Black Crows"
#property indicator_type7 DRAW_ARROW
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "4 Black Crows"
#property indicator_type8 DRAW_ARROW
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "6 Black Crows"
#property indicator_type9 DRAW_ARROW
#property indicator_color9 Blue
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Identical Three Crows"
#property indicator_type10 DRAW_ARROW
#property indicator_color10 Blue
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "DBDBD"
#property indicator_type11 DRAW_ARROW
#property indicator_color11 Blue
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1

input int bars_limit = 100000; // Bars limit

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

double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double plot7[];
double plot8[];
double plot9[];
double plot10[];
double plot11[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("CT Candlestick Pattern Testing BOT");
   IndicatorShortName("CT Candlestick Pattern Testing BOT");
   IndicatorBuffers(11);
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot3);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot4);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot5);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot6);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot7);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot8);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot9);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot10);
   SetIndexArrow(id++, 161);
   SetIndexBuffer(id, plot11);
   SetIndexArrow(id++, 161);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(plot10, EMPTY_VALUE);
      ArrayInitialize(plot11, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 7;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double open_today = open[pos];
      double open_1_day_ago = open[pos + 1];
      double open_2_days_ago = open[pos + 2];
      double open_3_days_ago = open[pos + 3];
      double open_4_days_ago = open[pos + 4];
      double open_5_days_ago = open[pos + 5];
      double open_6_days_ago = open[pos + 6];
      double close_today = close[pos];
      double close_1_day_ago = close[pos + 1];
      double close_2_days_ago = close[pos + 2];
      double close_3_days_ago = close[pos + 3];
      double close_4_days_ago = close[pos + 4];
      double close_5_days_ago = close[pos + 5];
      double close_6_days_ago = close[pos + 6];
      double high_today = high[pos];
      double high_1_day_ago = high[pos + 1];
      double high_2_days_ago = high[pos + 2];
      double high_3_days_ago = high[pos + 3];
      double high_4_days_ago = high[pos + 4];
      double high_5_days_ago = high[pos + 5];
      double high_6_days_ago = high[pos + 6];
      double low_today = low[pos];
      double low_1_day_ago = low[pos + 1];
      double low_2_days_ago = low[pos + 2];
      double low_3_days_ago = low[pos + 3];
      double low_4_days_ago = low[pos + 4];
      double low_5_days_ago = low[pos + 5];
      double low_6_days_ago = low[pos + 6];
      bool green_candle_today = (open[pos] < close[pos]);
      bool green_candle_1_day_ago = (open[pos + 1] < close[pos + 1]);
      bool green_candle_2_days_ago = (open[pos + 2] < close[pos + 2]);
      bool green_candle_3_days_ago = (open[pos + 3] < close[pos + 3]);
      bool green_candle_4_days_ago = (open[pos + 4] < close[pos + 4]);
      bool green_candle_5_days_ago = (open[pos + 5] < close[pos + 5]);
      bool green_candle_6_days_ago = (open[pos + 5] < close[pos + 6]);
      bool red_candle_today = (open[pos] > close[pos]);
      bool red_candle_1_day_ago = (open[pos + 1] > close[pos + 1]);
      bool red_candle_2_days_ago = (open[pos + 2] > close[pos + 2]);
      bool red_candle_3_days_ago = (open[pos + 3] > close[pos + 3]);
      bool red_candle_4_days_ago = (open[pos + 4] > close[pos + 4]);
      bool red_candle_5_days_ago = (open[pos + 5] > close[pos + 5]);
      bool red_candle_6_days_ago = (open[pos + 6] > close[pos + 6]);
      bool doji_1_day_ago_green = (green_candle_1_day_ago && (close_1_day_ago - open_1_day_ago <= (close_1_day_ago + open_1_day_ago) * 0.001));
      bool doji_2_day_ago_green = (green_candle_2_days_ago && (close_2_days_ago - open_2_days_ago <= (close_2_days_ago + open_2_days_ago) * 0.001));
      bool doji_3_day_ago_green = (green_candle_3_days_ago && (close_3_days_ago - open_3_days_ago <= (close_3_days_ago + open_3_days_ago) * 0.001));
      bool doji_1_day_ago_red = (red_candle_1_day_ago && (open_1_day_ago - close_1_day_ago <= (open_1_day_ago + close_1_day_ago) * 0.001));
      bool doji_2_days_ago_red = (red_candle_2_days_ago && (open_2_days_ago - close_2_days_ago <= (open_2_days_ago + close_2_days_ago) * 0.001));
      bool doji_3_days_ago_red = (red_candle_3_days_ago && (open_3_days_ago - close_3_days_ago <= (open_3_days_ago + close_3_days_ago) * 0.001));
      bool doji_1_day_ago_RG = (MathAbs(high_1_day_ago - low_1_day_ago) > MathAbs(open_1_day_ago - close_1_day_ago));
      bool doji_2_days_ago_RG = (MathAbs(high_2_days_ago - low_2_days_ago) > MathAbs(open_2_days_ago - close_2_days_ago));
      bool doji_3_days_ago_RG = (MathAbs(high_3_days_ago - low_3_days_ago) > MathAbs(open_3_days_ago - close_3_days_ago));
      bool Three_White_Soldiers = ((((((((green_candle_2_days_ago && green_candle_1_day_ago) && green_candle_today) && (high_2_days_ago <= close_1_day_ago)) && (high_1_day_ago <= close_today)) && (close_2_days_ago >= open_1_day_ago)) && (close_1_day_ago >= open_today)) && (open_2_days_ago <= low_1_day_ago)) && (open_1_day_ago <= low_today));
      if (Three_White_Soldiers)
         plot1[pos] = low[pos];
      bool Four_White_Soldiers = (((((((((((((((green_candle_3_days_ago && green_candle_2_days_ago) && green_candle_1_day_ago) && green_candle_today) && (high_3_days_ago <= close_2_days_ago)) && (high_2_days_ago <= close_1_day_ago)) && (high_2_days_ago <= close_1_day_ago)) && (high_1_day_ago <= close_today)) && (close_3_days_ago >= open_2_days_ago)) && (close_2_days_ago >= open_1_day_ago)) && (close_2_days_ago >= open_1_day_ago)) && (close_1_day_ago >= open_today)) && (open_3_days_ago <= low_2_days_ago)) && (open_2_days_ago <= low_1_day_ago)) && (open_2_days_ago <= low_1_day_ago)) && (open_1_day_ago <= low_today));
      if (Four_White_Soldiers)
         plot2[pos] = low[pos];
      bool Five_White_Soldiers = ((((((((((((((((green_candle_4_days_ago && green_candle_3_days_ago) && green_candle_2_days_ago) && green_candle_1_day_ago) && green_candle_today) && (high_4_days_ago <= close_3_days_ago)) && (high_3_days_ago <= close_2_days_ago)) && (high_2_days_ago <= close_1_day_ago)) && (high_1_day_ago <= close_today)) && (close_4_days_ago >= open_3_days_ago)) && (close_3_days_ago >= open_2_days_ago)) && (close_2_days_ago >= open_1_day_ago)) && (close_1_day_ago >= open_today)) && (open_4_days_ago <= low_3_days_ago)) && (open_3_days_ago <= low_2_days_ago)) && (open_2_days_ago <= low_1_day_ago)) && (open_1_day_ago <= low_today));
      if (Five_White_Soldiers)
         plot3[pos] = low[pos];
      bool SIX_White_Soldiers = (((((((((((((((((((((((green_candle_5_days_ago && green_candle_4_days_ago) && green_candle_3_days_ago) && green_candle_2_days_ago) && green_candle_1_day_ago) && green_candle_today) && (high_5_days_ago <= close_4_days_ago)) && (high_4_days_ago <= close_3_days_ago)) && (high_4_days_ago <= close_3_days_ago)) && (high_3_days_ago <= close_2_days_ago)) && (high_2_days_ago <= close_1_day_ago)) && (high_1_day_ago <= close_today)) && (close_5_days_ago >= open_4_days_ago)) && (close_4_days_ago >= open_3_days_ago)) && (close_4_days_ago >= open_3_days_ago)) && (close_3_days_ago >= open_2_days_ago)) && (close_2_days_ago >= open_1_day_ago)) && (close_1_day_ago >= open_today)) && (open_5_days_ago <= low_4_days_ago)) && (open_4_days_ago <= low_3_days_ago)) && (open_4_days_ago <= low_3_days_ago)) && (open_3_days_ago <= low_2_days_ago)) && (open_2_days_ago <= low_1_day_ago)) && (open_1_day_ago <= low_today));
      if (SIX_White_Soldiers)
         plot4[pos] = low[pos];
      bool Rallys_Base_Rallys_Combinations = ((((((((green_candle_4_days_ago && doji_3_days_ago_RG) && green_candle_2_days_ago) && doji_1_day_ago_RG) && green_candle_today) && (low_4_days_ago <= low_3_days_ago)) && (low_2_days_ago <= low_1_day_ago)) && (high_today >= low_1_day_ago)) && (close_today >= open_1_day_ago));
      if (Rallys_Base_Rallys_Combinations)
         plot5[pos] = low[pos];
      bool Three_Black_Crows = ((((((((red_candle_2_days_ago && red_candle_1_day_ago) && red_candle_today) && (open_1_day_ago >= close_2_days_ago)) && (open_today >= close_1_day_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_1_day_ago >= high_today)) && (low_2_days_ago >= close_1_day_ago)) && (low_1_day_ago >= close_today));
      if (Three_Black_Crows)
         plot6[pos] = high[pos];
      bool FOUR_Black_Crows = (((((((((((((((red_candle_3_days_ago && red_candle_2_days_ago) && red_candle_1_day_ago) && red_candle_today) && (open_2_days_ago >= close_3_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_today >= close_1_day_ago)) && (open_3_days_ago >= high_2_days_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_1_day_ago >= high_today)) && (low_3_days_ago >= close_2_days_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_1_day_ago >= close_today));
      if (FOUR_Black_Crows)
         plot7[pos] = high[pos];
      bool Five_Black_Crows = ((((((((((((((((((((((red_candle_4_days_ago && red_candle_3_days_ago) && red_candle_2_days_ago) && red_candle_1_day_ago) && red_candle_today) && (open_3_days_ago >= close_4_days_ago)) && (open_2_days_ago >= close_3_days_ago)) && (open_2_days_ago >= close_3_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_today >= close_1_day_ago)) && (open_4_days_ago >= high_3_days_ago)) && (open_3_days_ago >= high_2_days_ago)) && (open_3_days_ago >= high_2_days_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_1_day_ago >= high_today)) && (low_4_days_ago >= close_3_days_ago)) && (low_3_days_ago >= close_2_days_ago)) && (low_3_days_ago >= close_2_days_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_1_day_ago >= close_today));
      if (Five_Black_Crows)
         plot8[pos] = high[pos];
      bool Six_Black_Crows = (((((((((((((((((((((((((((((red_candle_5_days_ago && red_candle_4_days_ago) && red_candle_3_days_ago) && red_candle_2_days_ago) && red_candle_1_day_ago) && red_candle_today) && (open_4_days_ago >= close_5_days_ago)) && (open_3_days_ago >= close_4_days_ago)) && (open_3_days_ago >= close_4_days_ago)) && (open_2_days_ago >= close_3_days_ago)) && (open_2_days_ago >= close_3_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_1_day_ago >= close_2_days_ago)) && (open_today >= close_1_day_ago)) && (open_5_days_ago >= high_4_days_ago)) && (open_4_days_ago >= high_3_days_ago)) && (open_4_days_ago >= high_3_days_ago)) && (open_3_days_ago >= high_2_days_ago)) && (open_3_days_ago >= high_2_days_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_2_days_ago >= high_1_day_ago)) && (open_1_day_ago >= high_today)) && (low_5_days_ago >= close_4_days_ago)) && (low_4_days_ago >= close_3_days_ago)) && (low_4_days_ago >= close_3_days_ago)) && (low_3_days_ago >= close_2_days_ago)) && (low_3_days_ago >= close_2_days_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_2_days_ago >= close_1_day_ago)) && (low_1_day_ago >= close_today));
      if (Five_Black_Crows)
         plot9[pos] = high[pos];
      bool Identical_Three_Crows = ((((((((((red_candle_2_days_ago && red_candle_1_day_ago) && red_candle_today) && (close_2_days_ago >= open_1_day_ago)) && (close_1_day_ago >= open_today)) && (low_2_days_ago <= open_1_day_ago)) && (low_1_day_ago <= open_today)) && (open_2_days_ago >= high_1_day_ago)) && (open_1_day_ago >= high_today)) && (low_2_days_ago >= close_1_day_ago)) && (low_1_day_ago >= open_today));
      if (Identical_Three_Crows)
         plot10[pos] = high[pos];
      bool Drop_Base_Drop_Combination = (((((((red_candle_4_days_ago && doji_3_days_ago_RG) && red_candle_2_days_ago) && doji_1_day_ago_RG) && red_candle_today) && (open_4_days_ago >= open_3_days_ago)) && (open_2_days_ago >= open_1_day_ago)) && (close_today <= close_1_day_ago));
      if (Drop_Base_Drop_Combination)
         plot11[pos] = high[pos];
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+