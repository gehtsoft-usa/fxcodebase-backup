// Id: 23593
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1  clrLime
#property indicator_width1  1
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_color3  clrDodgerBlue
#property indicator_width3  1
#property indicator_color4  clrYellow
#property indicator_width4  1

enum MA_Types{ MASMA=1,  MAEMA=2, MASMMA=3,MALWMA=4 };
input  MA_Types SmoothingType = MAEMA; // Smoothing type
extern int SmoothingPeriod = 50; // Smoothing period

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

enum e_method{ SMA        =  1,
               EMA        =  2,
               Wilder     =  3,
               LWMA       =  4,
               SineWMA    =  5,
               TriMA      =  6,
               LSMA       =  7,
               SMMA       =  8,
               HMA        =  9,
               ZeroLagEMA = 10,
               ITrend     = 11,
               Median     = 12,
               GeoMean    = 13,
               REMA       = 14,
               ILRS       = 15,
               IE_2       = 16,
               TriMAgen   = 17
             };

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string    Comment1       = "- TimeFrame 1 Parameters -";
input  e_cycles  TimeFrame_1    = Min_15;
extern int       MA_Period1     = 50;
extern e_method  MA_Method1     = EMA;
extern e_price   MA_Price_Type1 = CLOSE;
extern string    Comment2       = "- TimeFrame 2 Parameters -";
input  e_cycles  TimeFrame_2    = Min_60;
extern int       MA_Period2     = 50;
extern e_method  MA_Method2     = EMA;
extern e_price   MA_Price_Type2 = CLOSE;
extern string    Comment3       = "- TimeFrame 3 Parameters -";
input  e_cycles  TimeFrame_3    = Min_240;
extern int       MA_Period3     = 50;
extern e_method  MA_Method3     = EMA;
extern e_price   MA_Price_Type3 = CLOSE;
extern string    Comment4       = "- TimeFrame 4 Parameters -";
input  e_cycles  TimeFrame_4    = Daily;
extern int       MA_Period4     = 50;
extern e_method  MA_Method4     = EMA;
extern e_price   MA_Price_Type4 = CLOSE;
extern string    Comment5       = "- Dashboard Parameters -";
extern color     Labels_Color   = clrWhite;
extern color     Up_Slope_Color = clrLime;
extern color     Dn_Slope_Color = clrRed;
extern color     All_Sync_Color = clrYellow;
extern bool      Alert_ON       = true;
extern int       Alert_Minutes_Interval = 15;

double Diff[];
double Signal[];

double BufferMA1[];
double BufferMA2[];
double BufferMA3[];
double BufferMA4[];
double MA1[];
double MA2[];
double MA3[];
double MA4[];
double Price1[];
double Price2[];
double Price3[];
double Price4[];

datetime LastAlert;
int WindowNumber;

//+****************************************************************+
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
   
   int Minutes1 = Get_TimeFrame(TimeFrame_1, true);
   int Minutes2 = Get_TimeFrame(TimeFrame_2, true);
   int Minutes3 = Get_TimeFrame(TimeFrame_3, true);
   int Minutes4 = Get_TimeFrame(TimeFrame_4, true);
   
   int m = (Minutes1 > Minutes2) ? Minutes1/Period() : Minutes2/Period();
   if (Minutes3 > m) m = Minutes3/Period();
   if (Minutes4 > m) m = Minutes4/Period();
   int DrawBegin = MA_Period1 > MA_Period2 ? m*MA_Period1 : m*MA_Period2;
   if ((m*MA_Period3) > DrawBegin) DrawBegin = m*MA_Period3;
   if ((m*MA_Period4) > DrawBegin) DrawBegin = m*MA_Period4;
   
   IndicatorName = GenerateIndicatorName("Multi Time Frame Overview");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(12);
   
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)||Check(TimeFrame_4)) Alert("The Bigger TF Sources selected for this Time Frame cannot be calculated");
   
   SetIndexBuffer(0,MA1);
   SetIndexBuffer(1,MA2);
   SetIndexBuffer(2,MA3);
   SetIndexBuffer(3,MA4);
   
   for (int i=0; i<4; i++){
      SetIndexStyle(i,DRAW_SECTION);
   }
   
   SetIndexBuffer(4,Price1);
   SetIndexBuffer(5,Price2);
   SetIndexBuffer(6,Price3);
   SetIndexBuffer(7,Price4);

   SetIndexBuffer(8, BufferMA1);
   SetIndexBuffer(9, BufferMA2);
   SetIndexBuffer(10, BufferMA3);
   SetIndexBuffer(11, BufferMA4);
   
   return(0);
}
  
int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (Digits==3||Digits==5) pipSize=pipSize*10;
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false  && Check(TimeFrame_3)==false && Check(TimeFrame_4)==false){
      // TimeFrame 1
      
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
        
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price1[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type1),i);
         
         switch(MA_Method1){
            case 1 : BufferMA1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
            case 2 : BufferMA1[current] = EMA(Price1[current],BufferMA1[current+(1*multiplier)],MA_Period1,current); break;
            case 3 : BufferMA1[current] = Wilder(Price1[current],BufferMA1[current+(1*multiplier)],MA_Period1,current); break;  
            case 4 : BufferMA1[current] = LWMA(Price1,MA_Period1,current, multiplier); break;
            case 5 : BufferMA1[current] = SineWMA(Price1,MA_Period1,current, multiplier); break;
            case 6 : BufferMA1[current] = TriMA(Price1,MA_Period1,current, multiplier); break;
            case 7 : BufferMA1[current] = LSMA(Price1,MA_Period1,current, multiplier); break;
            case 8 : BufferMA1[current] = SMMA(Price1,BufferMA1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 9 : BufferMA1[current] = HMA(Price1,MA_Period1,current, multiplier); break;
            case 10: BufferMA1[current] = ZeroLagEMA(Price1,BufferMA1[current+(1*multiplier)],MA_Period1,current, multiplier); break;
            case 11: BufferMA1[current] = ITrend(Price1,BufferMA1,MA_Period1,current, multiplier); break;
            case 12: BufferMA1[current] = Median(Price1,MA_Period1,current, multiplier); break;
            case 13: BufferMA1[current] = GeoMean(Price1,MA_Period1,current, multiplier); break;
            case 14: BufferMA1[current] = REMA(Price1[current],BufferMA1,MA_Period1,0.5,current, multiplier); break;
            case 15: BufferMA1[current] = ILRS(Price1,MA_Period1,current, multiplier); break;
            case 16: BufferMA1[current] = IE2(Price1,MA_Period1,current, multiplier); break;
            case 17: BufferMA1[current] = TriMA_gen(Price1,MA_Period1,current, multiplier); break;
            default: BufferMA1[current] = SMA(Price1,MA_Period1,current, multiplier); break;
         }
         MA1[current] = iMAOnArray(BufferMA1, 0, SmoothingPeriod, 0, (int)SmoothingType, current);
         for (j=current; j>=next; j--){
            MA1[j] = MA1[current];
         }
         
      }
      
      // TimeFrame 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price2[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type2),i);
         
         switch(MA_Method2){
            case 1 : BufferMA2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
            case 2 : BufferMA2[current] = EMA(Price2[current],BufferMA2[current+(1*multiplier)],MA_Period2,current); break;
            case 3 : BufferMA2[current] = Wilder(Price2[current],BufferMA2[current+(1*multiplier)],MA_Period2,current); break;  
            case 4 : BufferMA2[current] = LWMA(Price2,MA_Period2,current, multiplier); break;
            case 5 : BufferMA2[current] = SineWMA(Price2,MA_Period2,current, multiplier); break;
            case 6 : BufferMA2[current] = TriMA(Price2,MA_Period2,current, multiplier); break;
            case 7 : BufferMA2[current] = LSMA(Price2,MA_Period2,current, multiplier); break;
            case 8 : BufferMA2[current] = SMMA(Price2,BufferMA2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 9 : BufferMA2[current] = HMA(Price2,MA_Period2,current, multiplier); break;
            case 10: BufferMA2[current] = ZeroLagEMA(Price2,BufferMA2[current+(1*multiplier)],MA_Period2,current, multiplier); break;
            case 11: BufferMA2[current] = ITrend(Price2,BufferMA2,MA_Period2,current, multiplier); break;
            case 12: BufferMA2[current] = Median(Price2,MA_Period2,current, multiplier); break;
            case 13: BufferMA2[current] = GeoMean(Price2,MA_Period2,current, multiplier); break;
            case 14: BufferMA2[current] = REMA(Price2[current],BufferMA2,MA_Period2,0.5,current, multiplier); break;
            case 15: BufferMA2[current] = ILRS(Price2,MA_Period2,current, multiplier); break;
            case 16: BufferMA2[current] = IE2(Price2,MA_Period2,current, multiplier); break;
            case 17: BufferMA2[current] = TriMA_gen(Price2,MA_Period2,current, multiplier); break;
            default: BufferMA2[current] = SMA(Price2,MA_Period2,current, multiplier); break;
         }
         MA2[current] = iMAOnArray(BufferMA2, 0, SmoothingPeriod, 0, (int)SmoothingType, current);
         for (j=current; j>=next; j--){
            MA2[j] = MA2[current];
         }
         
      }
      
      // TimeFrame 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price3[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type3),i);
         
         switch(MA_Method3){
            case 1 : BufferMA3[current] = SMA(Price3,MA_Period3,current, multiplier); break;
            case 2 : BufferMA3[current] = EMA(Price3[current],BufferMA3[current+(1*multiplier)],MA_Period3,current); break;
            case 3 : BufferMA3[current] = Wilder(Price3[current],BufferMA3[current+(1*multiplier)],MA_Period3,current); break;  
            case 4 : BufferMA3[current] = LWMA(Price3,MA_Period3,current, multiplier); break;
            case 5 : BufferMA3[current] = SineWMA(Price3,MA_Period3,current, multiplier); break;
            case 6 : BufferMA3[current] = TriMA(Price3,MA_Period3,current, multiplier); break;
            case 7 : BufferMA3[current] = LSMA(Price3,MA_Period3,current, multiplier); break;
            case 8 : BufferMA3[current] = SMMA(Price3,BufferMA3[current+(1*multiplier)],MA_Period3,current, multiplier); break;
            case 9 : BufferMA3[current] = HMA(Price3,MA_Period3,current, multiplier); break;
            case 10: BufferMA3[current] = ZeroLagEMA(Price3,BufferMA3[current+(1*multiplier)],MA_Period3,current, multiplier); break;
            case 11: BufferMA3[current] = ITrend(Price3,BufferMA3,MA_Period3,current, multiplier); break;
            case 12: BufferMA3[current] = Median(Price3,MA_Period3,current, multiplier); break;
            case 13: BufferMA3[current] = GeoMean(Price3,MA_Period3,current, multiplier); break;
            case 14: BufferMA3[current] = REMA(Price3[current],BufferMA3,MA_Period3,0.5,current, multiplier); break;
            case 15: BufferMA3[current] = ILRS(Price3,MA_Period3,current, multiplier); break;
            case 16: BufferMA3[current] = IE2(Price3,MA_Period3,current, multiplier); break;
            case 17: BufferMA3[current] = TriMA_gen(Price3,MA_Period3,current, multiplier); break;
            default: BufferMA3[current] = SMA(Price3,MA_Period3,current, multiplier); break;
         }
         MA3[current] = iMAOnArray(BufferMA3, 0, SmoothingPeriod, 0, (int)SmoothingType, current);
         for (j=current; j>=next; j--){
            MA3[j] = MA3[current];
         }
         
      }
      
      // TimeFrame 4
      period     = Get_TimeFrame(TimeFrame_4);
      multiplier = Get_TimeFrame(TimeFrame_4, true)/Period();
      
      for(i=floor(limit/multiplier) ; i>=0; i--){
      
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         
         Price4[current] = iMA(NULL,period,1,0,0,ENUM_APPLIED_PRICE(MA_Price_Type4),i);
         
         switch(MA_Method4){
            case 1 : BufferMA4[current] = SMA(Price4,MA_Period4,current, multiplier); break;
            case 2 : BufferMA4[current] = EMA(Price4[current],BufferMA4[current+(1*multiplier)],MA_Period4,current); break;
            case 3 : BufferMA4[current] = Wilder(Price4[current],BufferMA4[current+(1*multiplier)],MA_Period4,current); break;  
            case 4 : BufferMA4[current] = LWMA(Price4,MA_Period4,current, multiplier); break;
            case 5 : BufferMA4[current] = SineWMA(Price4,MA_Period4,current, multiplier); break;
            case 6 : BufferMA4[current] = TriMA(Price4,MA_Period4,current, multiplier); break;
            case 7 : BufferMA4[current] = LSMA(Price4,MA_Period4,current, multiplier); break;
            case 8 : BufferMA4[current] = SMMA(Price4,BufferMA4[current+(1*multiplier)],MA_Period4,current, multiplier); break;
            case 9 : BufferMA4[current] = HMA(Price4,MA_Period4,current, multiplier); break;
            case 10: BufferMA4[current] = ZeroLagEMA(Price4,BufferMA4[current+(1*multiplier)],MA_Period4,current, multiplier); break;
            case 11: BufferMA4[current] = ITrend(Price4,BufferMA4,MA_Period4,current, multiplier); break;
            case 12: BufferMA4[current] = Median(Price4,MA_Period4,current, multiplier); break;
            case 13: BufferMA4[current] = GeoMean(Price4,MA_Period4,current, multiplier); break;
            case 14: BufferMA4[current] = REMA(Price4[current],BufferMA4,MA_Period4,0.5,current, multiplier); break;
            case 15: BufferMA4[current] = ILRS(Price4,MA_Period4,current, multiplier); break;
            case 16: BufferMA4[current] = IE2(Price4,MA_Period4,current, multiplier); break;
            case 17: BufferMA4[current] = TriMA_gen(Price4,MA_Period4,current, multiplier); break;
            default: BufferMA4[current] = SMA(Price4,MA_Period4,current, multiplier); break;
         }
         MA4[current] = iMAOnArray(BufferMA4, 0, SmoothingPeriod, 0, (int)SmoothingType, current);
         for (j=current; j>=next; j--){
            MA4[j] = MA4[current];
         }
         
      }
      
      WindowNumber = 0;
      int Pair_y = 50;
      int TF_x   =  300;
      int Original_x = TF_x;
      
      string TF1_L = "M"+Get_TimeFrame(TimeFrame_1, true);
      string TF2_L = "M"+Get_TimeFrame(TimeFrame_2, true);
      string TF3_L = "M"+Get_TimeFrame(TimeFrame_3, true);
      string TF4_L = "M"+Get_TimeFrame(TimeFrame_4, true);
      
      int TF1_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel(TF1_L+"Label", TF1_x, 20, TF1_L, Labels_Color, 1, WindowNumber, "Arial", 12 );
      
      int TF2_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel(TF2_L+"Label", TF2_x, 20, TF2_L, Labels_Color, 1, WindowNumber, "Arial", 12 );
      
      int TF3_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel(TF3_L+"Label", TF3_x, 20, TF3_L, Labels_Color, 1, WindowNumber, "Arial", 12 );
      
      int TF4_x  = TF_x;
      TF_x = TF_x-80;
      ObjectMakeLabel(TF4_L+"Label", TF4_x, 20, TF4_L, Labels_Color, 1, WindowNumber, "Arial", 12 );
      
      int  TFs, Ups, Dns;
      bool Alerts_Found=false;
      
      TFs = 0;
      Ups = 0;
      Dns = 0;
      
      ObjectMakeLabel("MA_Name",  Original_x+50, 50, "MA", Labels_Color, 1, WindowNumber, "Arial", 12 );
      ObjectMakeLabel("Price_Name", Original_x+50, 80, "Price", Labels_Color, 1, WindowNumber, "Arial", 12 );
      ObjectMakeLabel("MA_Price_Name", Original_x+50, 110, "MA/Price", Labels_Color, 1, WindowNumber, "Arial", 12 );
      
      color price_color, ma_color, maprice_color;
      string price_arrow, ma_arrow, maprice_arrow;
      
      // TF1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      if (MA1[0] > MA1[multiplier]){ ma_arrow = "é"; ma_color = Up_Slope_Color; }else{ ma_arrow = "ê"; ma_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > iClose(NULL,period,1)){ price_arrow = "é"; price_color = Up_Slope_Color; }else{ price_arrow = "ê"; price_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > MA1[0]){ maprice_arrow = "é"; maprice_color = Up_Slope_Color; }else{ maprice_arrow = "ê"; maprice_color = Dn_Slope_Color; }
      ObjectMakeLabel("MA_TF1", TF1_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("Price_TF1", TF1_x, 80, price_arrow, price_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("MAPrice_TF1", TF1_x, 110, maprice_arrow, maprice_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && price_arrow=="é" && maprice_arrow=="é") Ups++;
      if (ma_arrow=="ê" && price_arrow=="ê" && maprice_arrow=="ê") Dns++;
      TFs++;
      
      // TF2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      if (MA2[0] > MA2[multiplier]){ ma_arrow = "é"; ma_color = Up_Slope_Color; }else{ ma_arrow = "ê"; ma_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > iClose(NULL,period,1)){ price_arrow = "é"; price_color = Up_Slope_Color; }else{ price_arrow = "ê"; price_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > MA2[0]){ maprice_arrow = "é"; maprice_color = Up_Slope_Color; }else{ maprice_arrow = "ê"; maprice_color = Dn_Slope_Color; }
      ObjectMakeLabel("MA_TF2", TF2_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("Price_TF2", TF2_x, 80, price_arrow, price_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("MAPrice_TF2", TF2_x, 110, maprice_arrow, maprice_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && price_arrow=="é" && maprice_arrow=="é") Ups++;
      if (ma_arrow=="ê" && price_arrow=="ê" && maprice_arrow=="ê") Dns++;
      TFs++;
      
      // TF3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      if (MA3[0] > MA3[multiplier]){ ma_arrow = "é"; ma_color = Up_Slope_Color; }else{ ma_arrow = "ê"; ma_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > iClose(NULL,period,1)){ price_arrow = "é"; price_color = Up_Slope_Color; }else{ price_arrow = "ê"; price_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > MA3[0]){ maprice_arrow = "é"; maprice_color = Up_Slope_Color; }else{ maprice_arrow = "ê"; maprice_color = Dn_Slope_Color; }
      ObjectMakeLabel("MA_TF3", TF3_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("Price_TF3", TF3_x, 80, price_arrow, price_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("MAPrice_TF3", TF3_x, 110, maprice_arrow, maprice_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && price_arrow=="é" && maprice_arrow=="é") Ups++;
      if (ma_arrow=="ê" && price_arrow=="ê" && maprice_arrow=="ê") Dns++;
      TFs++;
      
      // TF4
      period     = Get_TimeFrame(TimeFrame_4);
      multiplier = Get_TimeFrame(TimeFrame_4, true)/Period();
      if (MA4[0] > MA4[multiplier]){ ma_arrow = "é"; ma_color = Up_Slope_Color; }else{ ma_arrow = "ê"; ma_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > iClose(NULL,period,1)){ price_arrow = "é"; price_color = Up_Slope_Color; }else{ price_arrow = "ê"; price_color = Dn_Slope_Color; }
      if (iClose(NULL,period,0) > MA4[0]){ maprice_arrow = "é"; maprice_color = Up_Slope_Color; }else{ maprice_arrow = "ê"; maprice_color = Dn_Slope_Color; }
      ObjectMakeLabel("MA_TF4", TF4_x, 50, ma_arrow, ma_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("Price_TF4", TF4_x, 80, price_arrow, price_color, 1, WindowNumber, "Wingdings", 12 );
      ObjectMakeLabel("MAPrice_TF4", TF4_x, 110, maprice_arrow, maprice_color, 1, WindowNumber, "Wingdings", 12 );
      if (ma_arrow=="é" && price_arrow=="é" && maprice_arrow=="é") Ups++;
      if (ma_arrow=="ê" && price_arrow=="ê" && maprice_arrow=="ê") Dns++;
      TFs++;
      
      // All Sync Mark
      if (Ups==TFs || Dns==TFs)
         ObjectMakeLabel("All_Sync", Original_x+130, Pair_y, "è", All_Sync_Color, 1, WindowNumber, "Wingdings", 12 );
      else
         ObjectDelete("All_Sync");
      
      if (Alert_ON && (TimeCurrent()-LastAlert) > (Alert_Minutes_Interval*60)){
         
         if (Ups==TFs || Dns==TFs){
            if (Ups==TFs)
               Alert(Symbol() + " All TFs in Sync for the Up - Price Above MA and both MA and Price Positive");
            else
               Alert(Symbol() + " All TFs in Sync for the Down - Price Below MA and both MA and Price Negative");
            Alerts_Found = true;
         }
      }
      
      if (Alerts_Found){
         LastAlert = TimeCurrent();
      }
      
   
   } // if Check==false
      
   return(0);
   
  }
  
bool Check (int BTF){
   
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<1) wrong_tf = true;
   if (Period()==15    && BTF<2) wrong_tf = true;
   if (Period()==30    && BTF<3) wrong_tf = true;
   if (Period()==60    && BTF<4) wrong_tf = true;
   if (Period()==240   && BTF<5) wrong_tf = true;
   if (Period()==1440  && BTF<6) wrong_tf = true;
   if (Period()==10080 && BTF<7) wrong_tf = true;
   if (Period()==43200)          wrong_tf = true;
   
   return(wrong_tf);
   
}

int Get_TimeFrame(int BTF, bool mins = false){
   int Periodo, Minutes;
   if (BTF==1){ Periodo = PERIOD_M5;  Minutes = 5;     }
   if (BTF==2){ Periodo = PERIOD_M15; Minutes = 15;    }
   if (BTF==3){ Periodo = PERIOD_M30; Minutes = 30;    }
   if (BTF==4){ Periodo = PERIOD_H1;  Minutes = 60;    }
   if (BTF==5){ Periodo = PERIOD_H4;  Minutes = 240;   }
   if (BTF==6){ Periodo = PERIOD_D1;  Minutes = 1440;  }
   if (BTF==7){ Periodo = PERIOD_W1;  Minutes = 10080; }
   if (BTF==8){ Periodo = PERIOD_MN1; Minutes = 43200; }
   if (mins) return(Minutes); else return(Periodo);
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

double SMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+(i*mult)];
   return(Sum/per);
}                

double EMA(double price,double prev,int per,int bar){
   return bar >= Bars - 2 ? price : prev + 2.0/(1+per)*(price - prev); 
}

double Wilder(double price,double prev,int per,int bar){
   return bar >= Bars - 2 ? price : prev + (price - prev)/per; 
}

double LWMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+(i*mult)]*(per - i);
   }
   if(Weight>0)
      return Sum/Weight;
   return 0;
} 

double SineWMA(double &array[],int per,int bar, int mult=1){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+(i*mult)]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      return Sum/Weight;
   return 0;
}

double TriMA(double &array[],int per,int bar, int mult=1){
   double sma;
   int len = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+(i*mult),mult);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar, int mult=1){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+((per-i)*mult)];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar, int mult=1){
   if(bar == Bars - per)
      return SMA(array,per,bar, mult);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) 
         Sum += array[bar+((i+1)*mult)];
      return (Sum - prev + array[bar])/per;
   }
   return 0;
}                

double HMA(double &array[],int per,int bar, int mult=1){
   double tmp1[];
   int len = MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      return array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+(i*mult),mult) - LWMA(array,per,bar+(i*mult),mult);  
      return LWMA(tmp1,len,0); 
   }  
   return 0;
}

double ZeroLagEMA(double &price[],double prev,int per,int bar, int mult=1){
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   if(bar >= Bars - lag)
      return price[bar];
   return alfa*(2*price[bar] - price[bar+(lag*mult)]) + (1-alfa)*prev;
}

double ITrend(double &price[],double &array[],int per,int bar, int mult=1){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      return (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+(1*mult)] - (alfa - 0.75*alfa*alfa)*price[bar+(2*mult)] + 2*(1-alfa)*array[bar+(1*mult)] - (1-alfa)*(1-alfa)*array[bar+(2*mult)];
   
   return (price[bar] + 2*price[bar+(1*mult)] + price[bar+(2*mult)])/4;
}

double Median(double &price[],int per,int bar, int mult=1){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+(i*mult)];
   ArraySort(array);
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) 
      return array[num];
   return 0.5*(array[num]+array[num+1]);
}

double GeoMean(double &price[],int per,int bar, int mult=1){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+(i*mult)],1.0/per); 
      return gmean;
   }   
   return 0;
}

double REMA(double price,double &array[],int per,double lambda,int bar, int mult=1){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      return price;
   return (array[bar+(1*mult)]*(1+2*lambda) + alpha*(price - array[bar+(1*mult)]) - lambda*array[bar+(2*mult)])/(1+lambda);    
}

double ILRS(double &price[],int per,int bar, int mult=1){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+(i*mult)];
      sumy += price[bar+(i*mult)];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   double slope = num2 != 0 ? num1/num2 : 0; 
   double ilrs = slope + SMA(price,per,bar,mult);
   return(ilrs);
}

double IE2(double &price[],int per,int bar, int mult=1){
   double ie = 0.5*(ILRS(price,per,bar,mult) + LSMA(price,per,bar,mult));
   return(ie); 
}
 

double TriMA_gen(double &array[],int per,int bar, int mult=1){
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+(i*mult),mult);
   double trimagen = sum/len2;
   return(trimagen);
}
