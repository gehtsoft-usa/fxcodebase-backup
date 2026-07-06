//+------------------------------------------------------------------+
//|                                       BB_OutsideCandle_Alert.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "Candle opening and closing outside the bands for buy/sell signals"
#property description "Optional Inside/Out Mode for open inside and close outside"

#property indicator_buffers 4
#property indicator_chart_window

extern int    SMA_Period      = 12;
extern double Deviation       = 2.2;
extern bool   Mode_Inside_Out = true;
extern bool   Show_Bands      = true;
extern bool   Show_Signals    = true;
extern bool   Display_Alert   = true;
extern color  Bands_Color     = clrFireBrick;
extern color  Short_Color     = clrRed;
extern color  Long_Color      = clrLime;

double BB_up[];
double BB_dn[];
double Signal_Short[];
double Signal_Long[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("BB_OutsideCandle_Alert");
   
   if (Show_Bands)   int Draw_Mode1 = DRAW_LINE; else Draw_Mode1 = DRAW_NONE;
   if (Show_Signals) int Draw_Mode2 = DRAW_ARROW; else Draw_Mode2 = DRAW_NONE;
   
   SetIndexStyle(0,Draw_Mode1,STYLE_SOLID,1,Bands_Color);
   SetIndexBuffer(0,BB_up);
   SetIndexLabel(0,"Top Band");
   SetIndexStyle(1,Draw_Mode1,STYLE_SOLID,1,Bands_Color);
   SetIndexBuffer(1,BB_dn);
   SetIndexLabel(1,"Bottom Band");
   SetIndexStyle(2,Draw_Mode2,STYLE_SOLID,1,Short_Color);
   SetIndexArrow(2, 234);
   SetIndexBuffer(2,Signal_Short);
   SetIndexLabel(2,"BB Short Signal");
   SetIndexStyle(3,Draw_Mode2,STYLE_SOLID,1,Long_Color);
   SetIndexArrow(3, 233);
   SetIndexBuffer(3,Signal_Long);
   SetIndexLabel(3,"BB Short Signal");
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      BB_up[i] = iBands(NULL,0,SMA_Period,Deviation,0,PRICE_CLOSE,MODE_UPPER,i);
      BB_dn[i] = iBands(NULL,0,SMA_Period,Deviation,0,PRICE_CLOSE,MODE_LOWER,i);
   }
   
   for(i=limit; i>0; i--){
      
      if (Mode_Inside_Out){
      
         // Bearish candle opening inside the bands and closing above the upper bollinger band
         if (Open[i] < BB_up[i] && Close[i] > BB_up[i]){
            Signal_Short[i] = High[i];
            // Alert after the last Close of a candle
            if (i==1 && Display_Alert && Time[0] > LastAlert){
               Alert(Symbol() + " " + TFToStr(Period()) + ": Bollinger Bands Outside Candle SHORT Signal");
               LastAlert = TimeCurrent();
            }
         }
         // Bullish candle opening inside the bands and closing below the lower bollinger band
         if (Open[i] > BB_dn[i] && Close[i] < BB_dn[i]){
            Signal_Long[i] = Low[i];
            // Alert after the last Close of a candle
            if (i==1 && Display_Alert && Time[0] > LastAlert){
               Alert(Symbol() + " " + TFToStr(Period()) + ": Bollinger Bands Outside Candle LONG Signal");
               LastAlert = TimeCurrent();
            }
         }
      
      }
      else{
      
         // Bearish candle opening and closing above the upper bollinger band
         if (Open[i] > Close[i] && Close[i] > BB_up[i]){
            Signal_Short[i] = High[i];
            // Alert after the last Close of a candle
            if (i==1 && Display_Alert && Time[0] > LastAlert){
               Alert(Symbol() + " " + TFToStr(Period()) + ": Bollinger Bands Outside Candle SHORT Signal");
               LastAlert = TimeCurrent();
            }
         }
         // Bullish candle opening and closing below the lower bollinger band
         if (Open[i] < Close[i] && Close[i] < BB_dn[i]){
            Signal_Long[i] = Low[i];
            // Alert after the last Close of a candle
            if (i==1 && Display_Alert && Time[0] > LastAlert){
               Alert(Symbol() + " " + TFToStr(Period()) + ": Bollinger Bands Outside Candle LONG Signal");
               LastAlert = TimeCurrent();
            }
         }
      
      }
   }
   
//----
   return(0);
}
  
string TFToStr(int tf)   { 
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return("");
}