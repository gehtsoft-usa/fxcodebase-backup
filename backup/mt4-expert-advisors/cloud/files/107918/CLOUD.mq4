//+------------------------------------------------------------------+
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

#property indicator_buffers 10
#property indicator_chart_window

enum e_method{ SMA=0, EMA=1, SMMA=2, LWMA=3 };
enum e_price{ CLOSE=0, OPEN=1, LOW=2, HIGH=3, MEDIAN=4, TYPICAL=5, WEIGHTED=6 };

extern int      Fast_Average_Period = 50;
input  e_method Fast_MA_Method      = EMA;
input  e_price  Fast_Price_Type     = CLOSE;

extern int      Slow_Average_Period = 200;
input  e_method Slow_MA_Method      = SMA;
input  e_price  Slow_Price_Type     = CLOSE;

extern color    Color_Up            = clrGreen;
extern color    Color_UpDown        = clrLime;
extern color    Color_DownUp        = clrOrange;
extern color    Color_Down          = clrRed;
extern color    Color_Fast_MA       = clrYellow;
extern color    Color_Slow_MA       = clrWhite;

extern bool     Alert_ON            = true;

double Fast_MA[];
double Slow_MA[];
double Up_min[];     double Up_max[];
double UpDown_min[]; double UpDown_max[];
double DownUp_min[]; double DownUp_max[];
double Down_min[];   double Down_max[];

bool   OriginalCalculation = false;

int i;
datetime LastAlert;

int init(){
   
   IndicatorShortName("CLOUD");
   
   SetIndexBuffer(0,Fast_MA);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,Color_Fast_MA);
   SetIndexLabel(0,"Fast MA");
   
   SetIndexBuffer(1,Slow_MA);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,Color_Slow_MA);
   SetIndexLabel(1,"Slow MA");
   
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Up);
   SetIndexBuffer(2,Up_min);
   SetIndexLabel(2,"Up Cloud");
   
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Up);
   SetIndexBuffer(3,Up_max);
   SetIndexLabel(3,"Up Cloud");
   
   SetIndexStyle(4,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_UpDown);
   SetIndexBuffer(4,UpDown_min);
   SetIndexLabel(4,"UpDown Cloud");
   
   SetIndexStyle(5,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_UpDown);
   SetIndexBuffer(5,UpDown_max);
   SetIndexLabel(6,"UpDown Cloud");
   
   SetIndexStyle(6,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_DownUp);
   SetIndexBuffer(6,DownUp_min);
   SetIndexLabel(6,"DownUp Cloud");
   
   SetIndexStyle(7,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_DownUp);
   SetIndexBuffer(7,DownUp_max);
   SetIndexLabel(7,"DownUp Cloud");
   
   SetIndexStyle(8,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Down);
   SetIndexBuffer(8,Down_min);
   SetIndexLabel(8,"Down Cloud");
   
   SetIndexStyle(9,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Down);
   SetIndexBuffer(9,Down_max);
   SetIndexLabel(9,"Down Cloud");
   
   return(0);
}

int start()
  {
   
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double max_ma, min_ma;
   
   for(i=limit; i>=0; i--){
      Fast_MA[i] = iMA(NULL,0,Fast_Average_Period,0,Fast_MA_Method,Fast_Price_Type,i);
      Slow_MA[i] = iMA(NULL,0,Slow_Average_Period,0,Slow_MA_Method,Slow_Price_Type,i);
      
      max_ma = MathMax(Fast_MA[i],Slow_MA[i]);
      min_ma = MathMin(Fast_MA[i],Slow_MA[i]);
      
      if (OriginalCalculation){
      
         if (Fast_MA[i] >= Fast_MA[i+1]){
            if (Slow_MA[i] >= Slow_MA[i+1]){
               Up_max[i] = max_ma;
               Up_min[i] = min_ma;
            }else{
               UpDown_max[i] = max_ma;
               UpDown_min[i] = min_ma;
            }
         }else{
            if (Slow_MA[i] >= Slow_MA[i+1]){
               DownUp_max[i] = max_ma;
               DownUp_min[i] = min_ma;
            }else{
               Down_max[i] = max_ma;
               Down_min[i] = min_ma;
            }
         }
      
      // This is a twist of the original calculation:
      // - When Fast MA is above Slow MA the cloud is Green
      // - When Fast MA is below Slow MA the cloud is Red
      // - When is Green but the fast is beginning to decrease the color of the cloud will change to another green tonality, same with red
      }else{
         if (Fast_MA[i] >= Slow_MA[i]){
            if (Fast_MA[i] >= Fast_MA[i+1]){
               Up_max[i] = max_ma;
               Up_min[i] = min_ma;
            }else{
               UpDown_max[i] = max_ma;
               UpDown_min[i] = min_ma;
            }
         }else{
            if (Fast_MA[i] >= Fast_MA[i+1]){
               DownUp_max[i] = max_ma;
               DownUp_min[i] = min_ma;
            }else{
               Down_max[i] = max_ma;
               Down_min[i] = min_ma;
            }
         }
      }
      
   }
   
   if (Alert_ON && Time[0] > LastAlert){
      
      if (Fast_MA[0] > Slow_MA[0] && Fast_MA[1] < Slow_MA[1]){
         Alert(Symbol() + " " + TFToStr(Period()) + ": Cloud Mode changed to UP");
         LastAlert = TimeCurrent();
      }
      
      if (Fast_MA[0] < Slow_MA[0] && Fast_MA[1] > Slow_MA[1]){
         Alert(Symbol() + " " + TFToStr(Period()) + ": Cloud Mode changed to DOWN");
         LastAlert = TimeCurrent();
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