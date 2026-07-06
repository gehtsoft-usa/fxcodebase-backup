//+------------------------------------------------------------------+
//|                                         Elders_Safe_Zone_MTF.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrYellow
#property indicator_width2  2
#property indicator_color3  clrRed
#property indicator_width3  2

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

extern int      LookBack    = 10;
extern int      StopFactor  = 3;
extern int      EMALength   = 13;
input  e_cycles TimeFrame_1 = Min_60;
input  e_cycles TimeFrame_2 = Min_240;
input  e_cycles TimeFrame_3 = Daily;

double ESZ1[];
double EMA1[];
double ESZ2[];
double EMA2[];
double ESZ3[];
double EMA3[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Elder's Safe Zone MTF");
   
   IndicatorBuffers(6);
      
   if (Check(TimeFrame_1)||Check(TimeFrame_2)||Check(TimeFrame_3)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ESZ1);
   SetIndexLabel(0,"Elders Safe Zone "+Get_TimeFrame(TimeFrame_1, true)+" mins");
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,ESZ2);
   SetIndexLabel(1,"Elders Safe Zone "+Get_TimeFrame(TimeFrame_2, true)+" mins");
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,ESZ3);
   SetIndexLabel(2,"Elders Safe Zone "+Get_TimeFrame(TimeFrame_3, true)+" mins");
   
   SetIndexBuffer(3,EMA1);
   SetIndexBuffer(4,EMA2);
   SetIndexBuffer(5,EMA3);
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   if (Check(TimeFrame_1)==false && Check(TimeFrame_2)==false && Check(TimeFrame_3)==false){
      
      double PreSafeStop, Pen, Counter, SafeStop;
      int period, multiplier;
      
      for(i=limit; i>=0; i--) ResetBuffers(i);
      
      // TF 1
      period     = Get_TimeFrame(TimeFrame_1);
      multiplier = Get_TimeFrame(TimeFrame_1, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         EMA1[i*multiplier] = iMA(NULL,period,EMALength,0,MODE_EMA,PRICE_CLOSE,i);
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
   
         PreSafeStop = ESZ1[(i+1)*multiplier];
         Pen = 0;
         Counter = 0;
         
         if (EMA1[i*multiplier] > EMA1[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iLow(NULL,period,i+j) < iLow(NULL,period,i+j+1)){
                  
                  Pen = iLow(NULL,period,i+j+1) - iLow(NULL,period,i+j) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*Pen);
               
            if (SafeStop < PreSafeStop && EMA1[(i+1)*multiplier] > EMA1[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
            
         }
         else if (EMA1[i*multiplier] < EMA1[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iHigh(NULL,period,i+j) > iHigh(NULL,period,i+j+1)){
                  
                  Pen = iHigh(NULL,period,i+j) - iHigh(NULL,period,i+j+1) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*Pen);
               
            if (SafeStop > PreSafeStop && EMA1[(i+1)*multiplier] < EMA1[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
         
         }
         
         PreSafeStop=SafeStop;
         ESZ1[i*multiplier]=SafeStop;
         
      }
      
      // TF 2
      period     = Get_TimeFrame(TimeFrame_2);
      multiplier = Get_TimeFrame(TimeFrame_2, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         EMA2[i*multiplier] = iMA(NULL,period,EMALength,0,MODE_EMA,PRICE_CLOSE,i);
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
   
         PreSafeStop = ESZ2[(i+1)*multiplier];
         Pen = 0;
         Counter = 0;
         
         if (EMA2[i*multiplier] > EMA2[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iLow(NULL,period,i+j) < iLow(NULL,period,i+j+1)){
                  
                  Pen = iLow(NULL,period,i+j+1) - iLow(NULL,period,i+j) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*Pen);
               
            if (SafeStop < PreSafeStop && EMA2[(i+1)*multiplier] > EMA2[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
            
         }
         else if (EMA2[i*multiplier] < EMA2[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iHigh(NULL,period,i+j) > iHigh(NULL,period,i+j+1)){
                  
                  Pen = iHigh(NULL,period,i+j) - iHigh(NULL,period,i+j+1) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*Pen);
               
            if (SafeStop > PreSafeStop && EMA2[(i+1)*multiplier] < EMA2[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
         
         }
         
         PreSafeStop=SafeStop;
         ESZ2[i*multiplier]=SafeStop;
         
      }
      
      // TF 3
      period     = Get_TimeFrame(TimeFrame_3);
      multiplier = Get_TimeFrame(TimeFrame_3, true)/Period();
      for(i=floor(limit/multiplier) ; i>=0; i--){
         EMA3[i*multiplier] = iMA(NULL,period,EMALength,0,MODE_EMA,PRICE_CLOSE,i);
      }
      for(i=floor(limit/multiplier) ; i>=0; i--){
   
         PreSafeStop = ESZ3[(i+1)*multiplier];
         Pen = 0;
         Counter = 0;
         
         if (EMA3[i*multiplier] > EMA3[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iLow(NULL,period,i+j) < iLow(NULL,period,i+j+1)){
                  
                  Pen = iLow(NULL,period,i+j+1) - iLow(NULL,period,i+j) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) - (StopFactor*Pen);
               
            if (SafeStop < PreSafeStop && EMA3[(i+1)*multiplier] > EMA3[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
            
         }
         else if (EMA3[i*multiplier] < EMA3[(i+1)*multiplier]){
         
            for (j=0; j<LookBack; j++){
            
               if (iHigh(NULL,period,i+j) > iHigh(NULL,period,i+j+1)){
                  
                  Pen = iHigh(NULL,period,i+j) - iHigh(NULL,period,i+j+1) + Pen;
                  Counter++;
                  
               }
            
            }
            
            if (Counter > 0)
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*(Pen/Counter));
               
            else
            
               SafeStop = iClose(NULL,period,i) + (StopFactor*Pen);
               
            if (SafeStop > PreSafeStop && EMA3[(i+1)*multiplier] < EMA3[(i+2)*multiplier])
            
               SafeStop = PreSafeStop;
         
         }
         
         PreSafeStop=SafeStop;
         ESZ3[i*multiplier]=SafeStop;
         
      }
   
   } // if check
   
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

void ResetBuffers(int shift){
   
   EMA1[shift] = EMPTY_VALUE;
   ESZ1[shift] = EMPTY_VALUE;
   EMA2[shift] = EMPTY_VALUE;
   ESZ2[shift] = EMPTY_VALUE;
   EMA3[shift] = EMPTY_VALUE;
   ESZ3[shift] = EMPTY_VALUE;
   return;
   
}
