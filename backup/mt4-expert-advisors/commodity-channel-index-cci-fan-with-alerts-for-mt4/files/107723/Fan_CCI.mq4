//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 20
#property indicator_separate_window
#property indicator_levelcolor clrYellow

extern int   Period_1         = 14;
enum e_method{
 Add=1,
 Multiply=2
};
input e_method  Method = Add;
extern int   K                = 2;
extern int   N                = 12;
extern color Fan_Fast_Color   = clrRed;
extern color Fan_Medium_Color = clrLime;
extern color Fan_Slow_Color   = clrDodgerBlue;
extern int   CCI_OB           = 100;
extern int   CCI_OS           = -100;
extern bool  Alert_ON  = true;

double Fan_1[];
double Fan_2[];
double Fan_3[];
double Fan_4[];
double Fan_5[];
double Fan_6[];
double Fan_7[];
double Fan_8[];
double Fan_9[];
double Fan_10[];
double Fan_11[];
double Fan_12[];
double Fan_13[];
double Fan_14[];
double Fan_15[];
double Fan_16[];
double Fan_17[];
double Fan_18[];
double Fan_19[];
double Fan_20[];

int i;
datetime LastAlert;

double current[];
double previous[];

int init(){
   
   IndicatorShortName("Fan_CCI");
   
   SetIndexBuffer(0,Fan_1);
   SetIndexBuffer(1,Fan_2);
   SetIndexBuffer(2,Fan_3);
   SetIndexBuffer(3,Fan_4);
   SetIndexBuffer(4,Fan_5);
   SetIndexBuffer(5,Fan_6);
   SetIndexBuffer(6,Fan_7);
   SetIndexBuffer(7,Fan_8);
   SetIndexBuffer(8,Fan_9);
   SetIndexBuffer(9,Fan_10);
   SetIndexBuffer(10,Fan_11);
   SetIndexBuffer(11,Fan_12);
   SetIndexBuffer(12,Fan_13);
   SetIndexBuffer(13,Fan_14);
   SetIndexBuffer(14,Fan_15);
   SetIndexBuffer(15,Fan_16);
   SetIndexBuffer(16,Fan_17);
   SetIndexBuffer(17,Fan_18);
   SetIndexBuffer(18,Fan_19);
   SetIndexBuffer(19,Fan_20);
   
   color Fan_Color;
   for (i=0; i<N; i++){
      if (i<N/3)
         Fan_Color = Fan_Slow_Color;
      else if (i>=N/3 && i<2*N/3)
         Fan_Color = Fan_Medium_Color;
      else
         Fan_Color = Fan_Fast_Color;
      SetIndexStyle(i,DRAW_LINE,STYLE_SOLID,1,Fan_Color);
   }
   
   SetLevelValue(0,CCI_OB);
   SetLevelValue(1,CCI_OS);
   SetLevelStyle(STYLE_SOLID,2);
   
   return(0);
}

int start()
  {
   
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   ArrayResize(current,20);
   ArrayResize(previous,20);
   
   for(i=limit; i>=0; i--){
      Fan_1[i]  = Fan_CCI(Period_1, 0, K, i, Method);
      Fan_2[i]  = Fan_CCI(Period_1, 1, K, i, Method);
      Fan_3[i]  = Fan_CCI(Period_1, 2, K, i, Method);
      Fan_4[i]  = Fan_CCI(Period_1, 3, K, i, Method);
      Fan_5[i]  = Fan_CCI(Period_1, 4, K, i, Method);
      Fan_6[i]  = Fan_CCI(Period_1, 5, K, i, Method);
      Fan_7[i]  = Fan_CCI(Period_1, 6, K, i, Method);
      Fan_8[i]  = Fan_CCI(Period_1, 7, K, i, Method);
      Fan_9[i]  = Fan_CCI(Period_1, 8, K, i, Method);
      Fan_10[i] = Fan_CCI(Period_1, 9, K, i, Method);
      Fan_11[i] = Fan_CCI(Period_1, 10, K, i, Method);
      Fan_12[i] = Fan_CCI(Period_1, 11, K, i, Method);
      Fan_13[i] = Fan_CCI(Period_1, 12, K, i, Method);
      Fan_14[i] = Fan_CCI(Period_1, 13, K, i, Method);
      Fan_15[i] = Fan_CCI(Period_1, 14, K, i, Method);
      Fan_16[i] = Fan_CCI(Period_1, 15, K, i, Method);
      Fan_17[i] = Fan_CCI(Period_1, 16, K, i, Method);
      Fan_18[i] = Fan_CCI(Period_1, 17, K, i, Method);
      Fan_19[i] = Fan_CCI(Period_1, 18, K, i, Method);
      Fan_20[i] = Fan_CCI(Period_1, 19, K, i, Method);
   }
   
   string Alerta;
   for (i=0; i<N; i++){
      if (current[i] > 0 && current[i+1] >0 && previous[i] > 0 && previous[i+1] > 0 && current[i] > current[i+1] && previous[i] < previous[i+1]){
          Alerta = "Fan CCI Up Cross";
          break;
      }
      else if (current[i] > 0 && current[i+1] >0 && previous[i] > 0 && previous[i+1] > 0 && current[i] < current[i+1] && previous[i] > previous[i+1]){
          Alerta = "Fan CCI Dn Cross";
          break;
      }
      else{
         Alerta = "";
      }
   }
   
   if (Alert_ON && i==0 && Time[0] > LastAlert && Alerta!=""){
      Alert(Symbol() + " " + TFToStr(Period()) + ": "+Alerta);
      LastAlert = TimeCurrent();
   }
   
//----
   return(0);
}
  
double Fan_CCI(int Periodo, int Step, int KK, int num, int Metodo){
   
   double CCI, Previous_CCI;
   
   if (Step==0){
      CCI = iCCI(NULL,0,Periodo,PRICE_TYPICAL,num);
      Previous_CCI = iCCI(NULL,0,Periodo,PRICE_TYPICAL,num+1);
   }else if (Metodo==1){
      CCI = iCCI(NULL,0,Periodo+(Step*KK),PRICE_TYPICAL,num);
      Previous_CCI = iCCI(NULL,0,Periodo+(Step*KK),PRICE_TYPICAL,num+1);
   }else{
      CCI = iCCI(NULL,0,Periodo*(Step*KK),PRICE_TYPICAL,num);
      Previous_CCI = iCCI(NULL,0,Periodo*(Step*KK),PRICE_TYPICAL,num+1);
   }
   
   if (Step>=N){
      CCI = 0;
   }
   
   int eval = 0;
   
   if (num==eval){
      ArrayFill(current,Step,1,CCI);
      ArrayFill(previous,Step,1,Previous_CCI);
   }
   
   return CCI;
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