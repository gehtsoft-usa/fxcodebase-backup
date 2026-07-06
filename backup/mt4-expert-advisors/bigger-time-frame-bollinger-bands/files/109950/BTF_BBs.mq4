//+------------------------------------------------------------------+
//|                                                      BTF_BBs.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrRed
#property indicator_width1  3
#property indicator_color2  clrLime
#property indicator_width2  3
#property indicator_color3  clrLime
#property indicator_width3  3

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

input  e_cycles TimeFrame      = Min_240;
input  e_price  Price_Type     = CLOSE;
extern int      MA_Periods     = 14;
extern int      Deviation      = 2;
extern bool     Show_Middle    = true;
extern bool     Steps_Mode     = false;
extern bool     Sound_Alert    = true;
extern bool     Email_Alert    = true;

double MA[];
double TOP[];
double BOTTOM[];

datetime LastAlert;

//+****************************************************************+

int init(){
   
   int Minutes = Get_TimeFrame(TimeFrame, true);
   
   IndicatorShortName("BTF Bollinger Bands "+Minutes+" mins");
   
   if (Check(TimeFrame)) Alert("The Bigger TF Source selected should be greater or equal than the current one");
   
   if (Show_Middle) int MiddleLine = DRAW_SECTION; else MiddleLine = DRAW_NONE;
   
   SetIndexStyle(0,MiddleLine);
   SetIndexBuffer(0,MA);
   SetIndexLabel(0,"Main");
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,TOP);
   SetIndexLabel(1,"Upper");
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,BOTTOM);
   SetIndexLabel(2,"Lower");
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;
   
   if (Check(TimeFrame)==false){
   
      period     = Get_TimeFrame(TimeFrame);
      multiplier = Get_TimeFrame(TimeFrame, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         
         current = iBarShift(NULL,0,iTime(NULL,period,i));
         if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
         MA[current]     = iBands(NULL,period,MA_Periods,Deviation,0,ENUM_APPLIED_PRICE(Price_Type),MODE_MAIN,i);
         TOP[current]    = iBands(NULL,period,MA_Periods,Deviation,0,ENUM_APPLIED_PRICE(Price_Type),MODE_UPPER,i);
         BOTTOM[current] = iBands(NULL,period,MA_Periods,Deviation,0,ENUM_APPLIED_PRICE(Price_Type),MODE_LOWER,i);
         if (Steps_Mode){
            for (j=current; j>=next; j--){
               MA[j]     = MA[current];
               TOP[j]    = TOP[current];
               BOTTOM[j] = BOTTOM[current];
            }
         }else{
            if (i==0){
               MA[0]     = MA[current];
               TOP[0]    = TOP[current];
               BOTTOM[0] = BOTTOM[current];
            }
         }

      }
      
      if (Time[0] > LastAlert && Close[0] > TOP[0]){
         if (Sound_Alert) Alert(Symbol() + "," + TFToStr(period) + ": Price is above the Upper BTF Bollinger Band!");
         if (Email_Alert) SendMail("Price Above BTF Bollinger Band", Symbol() + "," + TFToStr(period) + ": Price is above the Upper BTF Bollinger Band!");
         LastAlert = TimeCurrent();
      }
      
      if (Time[0] > LastAlert && Close[0] < BOTTOM[0]){
         if (Sound_Alert) Alert(Symbol() + "," + TFToStr(period) + ": Price is below the Lower BTF Bollinger Band!");
         if (Email_Alert) SendMail("Price below BTF Bollinger Band", Symbol() + "," + TFToStr(period) + ": Price is below the Lower BTF Bollinger Band!");
         LastAlert = TimeCurrent();
      }
   
   } // if Check==false
   
   return(0);
   
  }
  
bool Check (int BTF){
   
   bool wrong_tf = false;
   
   if (Period()==5     && BTF<2) wrong_tf = true;
   if (Period()==15    && BTF<3) wrong_tf = true;
   if (Period()==30    && BTF<4) wrong_tf = true;
   if (Period()==60    && BTF<5) wrong_tf = true;
   if (Period()==240   && BTF<6) wrong_tf = true;
   if (Period()==1440  && BTF<7) wrong_tf = true;
   if (Period()==10080 && BTF<8) wrong_tf = true;
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

string TFToStr(int tf){
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