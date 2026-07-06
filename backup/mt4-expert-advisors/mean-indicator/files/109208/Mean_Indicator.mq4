//+------------------------------------------------------------------+
//|                                               Mean_Indicator.mq4 |
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
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_color2 clrLime
#property indicator_width2 1
#property indicator_color3 clrRed
#property indicator_width3 1

extern int   Number_Of_Days        = 20;
extern int   Day_Start             = 0;

double Mean[];
double Up[];
double Dn[];
double Temp[];

int init(){
   
   IndicatorShortName("Mean Indicator");
   IndicatorBuffers(4);
   
   if (Period()>60) Alert("This indicator works only on H1 charts and lower");
   
   SetIndexBuffer(0,Mean);
   SetIndexBuffer(1,Up);
   SetIndexBuffer(2,Dn);
   
   for (int k=0; k<3; k++){
      SetIndexArrow(k,159);
      SetIndexStyle(k,DRAW_ARROW);
   }
   
   SetIndexBuffer(3,Temp);
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll();
   return(0);
}

int start(){
   
   // It works only for Periods lower or equal than 60 minutes
   if (Period()<=60){
   
      int i, j, n, m, prev_start;
      double daily_mean, current_mean;
      
      for(i=Number_Of_Days*(1440/Period()); i>=0; i--){
         
         if (TimeHour(Time[i]) == Day_Start){
         
            prev_start = iBarShift(NULL,0,iTime(NULL,PERIOD_D1,iBarShift(NULL,PERIOD_D1,Time[i])+1));
            
            n = daily_mean = 0;
            for (j=prev_start; j>i; j--){
               daily_mean+=Close[j];
               n++;
            }
            daily_mean = (daily_mean/n);
            prev_start = i;
         
         }
         Mean[i] = Temp[i] = daily_mean;
         
         if (i < prev_start){
         
            m = current_mean = 0;
            
            for (j=prev_start; j>i; j--){
               
               current_mean+=Close[j];
               m++;
               
            }
            Temp[i] = current_mean/m;
         
         }
         
         if (Temp[i] >= Temp[i+1]) Up[i] = Temp[i]; else Dn[i] = Temp[i];
         
      }
   
   }
   
//----
   return(0);
}
