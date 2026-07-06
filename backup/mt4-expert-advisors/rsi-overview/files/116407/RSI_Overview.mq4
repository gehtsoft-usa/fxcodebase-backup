// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65183

//+------------------------------------------------------------------+
//|                                                 RSI_Overview.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Will present at a glance RSI+BB information for all time frames for Chart instrument."

#property indicator_separate_window

extern int    RSI_Periods     = 14;
extern int    RSI_SMA_Periods = 5;
extern int BB_Length=20;
extern double BB_Deviation=2.;
extern bool   Include_M5      = true;
extern bool   Include_M15     = true;
extern bool   Include_M30     = true;
extern bool   Include_H1      = true;
extern bool   Include_H4      = true;
extern bool   Include_D1      = true;
extern bool   Include_W1      = true;
extern bool   Include_MN1     = true;
extern double OB_Level        = 70;
extern double OS_Level        = 30;
extern color  Labels_Color    = clrWhite;
extern color  OB_Color        = clrLime;
extern color  OS_Color        = clrRed;
extern color  BuyZone_Color   = clrLime;
extern color  SellZone_Color  = clrRed;
extern color  Uptrend_Color   = clrLime;
extern color  Downtrend_Color = clrRed;

string   WindowName;
int      WindowNumber;

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

int init(){
   
   WindowName = "RSI_Overview";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   WindowName = IndicatorName;

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   WindowNumber = WindowFind(WindowName);
   
   int Pair_y = 50;
   int TF_x   =  1100;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
     
     int bb_label_y = 90;
   int j;
      
      double rsi0, rsi_ma,rsi_ma_sum, BB_U, BB_L;
      
      ObjectMakeLabel("Filter1_Name", Original_x+120, Pair_y, "Filter 1 - OB/OS:", Labels_Color, 1, WindowNumber, "Arial", 12 );
      ObjectMakeLabel("Filter2_Name", Original_x+120, Pair_y+30, "Filter 2 - Zone:", Labels_Color, 1, WindowNumber, "Arial", 12 );
      ObjectMakeLabel("Filter3_Name", Original_x+120, Pair_y+60, "Filter 2 - Trend:", Labels_Color, 1, WindowNumber, "Arial", 12 );
      ObjectMakeLabel("Filter4_Name", Original_x+120, Pair_y+bb_label_y, "BB Zone:", Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         rsi0 = iRSI(NULL,PERIOD_M5,RSI_Periods,PRICE_CLOSE,0);

         ObjectDelete("OBOS_M5");
         ObjectDelete("Zone_M5");
         ObjectDelete("Trend_M5");
         ObjectDelete("BB_M5");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_M5", M5_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_M5", M5_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("OBOS_M5", M5_x, Pair_y+30, "Overbought", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("OBOS_M5", M5_x, Pair_y+30, "Oversold", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_M5,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_M5", M5_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_M5", M5_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_M5, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_M5, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_M5", M5_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_M5", M5_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_M15){
         rsi0 = iRSI(NULL,PERIOD_M15,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_M15");
         ObjectDelete("Zone_M15");
         ObjectDelete("Trend_M15");
         ObjectDelete("BB_M15");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_M15", M15_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_M15", M15_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_M15", M15_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_M15", M15_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_M15,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_M15", M15_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_M15", M15_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_M15, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_M15, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_M15", M15_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_M15", M15_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_M30){
         rsi0 = iRSI(NULL,PERIOD_M30,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_M30");
         ObjectDelete("Zone_M30");
         ObjectDelete("Trend_M30");
         ObjectDelete("BB_M30");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_M30", M30_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_M30", M30_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_M30", M30_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_M30", M30_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_M30,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_M30", M30_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_M30", M30_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_M30, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_M30, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_M30", M30_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_M30", M30_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_H1){
         rsi0 = iRSI(NULL,PERIOD_H1,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_H1");
         ObjectDelete("Zone_H1");
         ObjectDelete("Trend_H1");
         ObjectDelete("BB_H1");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_H1", H1_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_H1", H1_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_H1", H1_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_H1", H1_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_H1,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_H1", H1_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_H1", H1_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_H1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_H1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_H1", H1_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_H1", H1_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_H4){
         rsi0 = iRSI(NULL,PERIOD_H4,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_H4");
         ObjectDelete("Zone_H4");
         ObjectDelete("Trend_H4");
         ObjectDelete("BB_H4");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_H4", H4_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_H4", H4_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_H4", H4_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_H4", H4_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_H4,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_H4", H4_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_H4", H4_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_H4, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_H4, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_H4", H4_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_H4", H4_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_D1){
         rsi0 = iRSI(NULL,PERIOD_D1,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_D1");
         ObjectDelete("Zone_D1");
         ObjectDelete("Trend_D1");
         ObjectDelete("BB_D1");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_D1", D1_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_D1", D1_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_D1", D1_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_D1", D1_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_D1,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_D1", D1_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_D1", D1_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_D1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_D1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_D1", D1_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_D1", D1_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_W1){
         rsi0 = iRSI(NULL,PERIOD_W1,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_W1");
         ObjectDelete("Zone_W1");
         ObjectDelete("Trend_W1");
         ObjectDelete("BB_W1");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_W1", W1_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_W1", W1_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_W1", W1_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_W1", W1_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_W1,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_W1", W1_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_W1", W1_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_W1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_W1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_W1", W1_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_W1", W1_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
      if (Include_MN1){
         rsi0 = iRSI(NULL,PERIOD_MN1,RSI_Periods,PRICE_CLOSE,0);
         ObjectDelete("OBOS_MN1");
         ObjectDelete("Zone_MN1");
         ObjectDelete("Trend_MN1");
         ObjectDelete("BB_MN1");
         if (rsi0 > OB_Level){
            ObjectMakeLabel("OBOS_MN1", MN1_x, Pair_y, "Overbought", OB_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < OS_Level){
            ObjectMakeLabel("OBOS_MN1", MN1_x, Pair_y, "Oversold", OS_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 > 50){
            ObjectMakeLabel("Zone_MN1", MN1_x, Pair_y+30, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < 50){
            ObjectMakeLabel("Zone_MN1", MN1_x, Pair_y+30, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         rsi_ma_sum = 0;
         rsi_ma = 0;
         for (j=0; j<RSI_SMA_Periods; j++){
            rsi_ma+=iRSI(NULL,PERIOD_MN1,RSI_Periods,PRICE_CLOSE,j);
         }
         rsi_ma=rsi_ma_sum/RSI_SMA_Periods;
         if (rsi0 > rsi_ma){
            ObjectMakeLabel("Trend_MN1", MN1_x, Pair_y+60, "Up Trend", Uptrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (rsi0 < rsi_ma){
            ObjectMakeLabel("Trend_MN1", MN1_x, Pair_y+60, "Down Trend", Downtrend_Color, 1, WindowNumber, "Arial", 11 );
         }
         BB_U=iBands(NULL, PERIOD_MN1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
         BB_L=iBands(NULL, PERIOD_MN1, BB_Length, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
         if (Close[0] > BB_U)
         {
           ObjectMakeLabel("BB_MN1", MN1_x, Pair_y+bb_label_y, "Sell Zone", SellZone_Color, 1, WindowNumber, "Arial", 11 );
         }
         if (Close[0] < BB_L)
         {
           ObjectMakeLabel("BB_MN1", MN1_x, Pair_y+bb_label_y, "Buy Zone", BuyZone_Color, 1, WindowNumber, "Arial", 11 );
         }
      }
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
   return;
}
