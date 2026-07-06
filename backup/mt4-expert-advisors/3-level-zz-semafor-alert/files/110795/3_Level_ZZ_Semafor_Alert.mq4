// Id: 17503
//+------------------------------------------------------------------+
//|                                     3_Level_ZZ_Semafor_Alert.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8, Current = 9  };

#property indicator_chart_window

input  e_cycles TimeFrame = Current;
extern bool  Sound_Alert  = true;
extern bool  Email_Alert  = true;

datetime LastAlert;

int init(){
   
       double temp = iCustom(NULL, 0, "3_Level_ZZ_Semafor", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the '3_Level_ZZ_Semafor' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("SemaforAlert_"+TimeFrame);
   
   if (Check(TimeFrame)) Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   return(0);
  }

int start(){
      
   if (Check(TimeFrame)==false){
   
      int period = Get_TimeFrame(TimeFrame);
      string Alerta="";
      
      double Up_Signal = iCustom(NULL, period, "3_Level_ZZ_Semafor", 4, 0);
      double Dn_Signal = iCustom(NULL, period, "3_Level_ZZ_Semafor", 5, 0);
      
      if (Up_Signal>0) Alerta = "Up Semafor Showing!";
      if (Dn_Signal>0) Alerta = "Down Semafor Showing!";
      
      if (Time[0] > LastAlert && Alerta!=""){
         if (Sound_Alert) Alert(Symbol() + "," + TFToStr(period) + ": "+Alerta);
         if (Email_Alert) SendMail("Vortex Signal", Symbol() + "," + TFToStr(Period()) + ": "+Alerta);
         LastAlert = TimeCurrent();
      }
   
   }
   
//----
   return(0);
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
   if (BTF==1){ Periodo = PERIOD_M5;  Minutes = 5;        }
   if (BTF==2){ Periodo = PERIOD_M15; Minutes = 15;       }
   if (BTF==3){ Periodo = PERIOD_M30; Minutes = 30;       }
   if (BTF==4){ Periodo = PERIOD_H1;  Minutes = 60;       }
   if (BTF==5){ Periodo = PERIOD_H4;  Minutes = 240;      }
   if (BTF==6){ Periodo = PERIOD_D1;  Minutes = 1440;     }
   if (BTF==7){ Periodo = PERIOD_W1;  Minutes = 10080;    }
   if (BTF==8){ Periodo = PERIOD_MN1; Minutes = 43200;    }
   if (BTF==9){ Periodo = 0;          Minutes = Period(); }
   if (mins) return(Minutes); else return(Periodo);
}