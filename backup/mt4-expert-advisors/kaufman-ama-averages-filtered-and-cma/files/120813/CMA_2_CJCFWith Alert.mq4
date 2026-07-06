// Id: 21785
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                       Modified by : Mario Jemic  |
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

#property copyright "Vladradon"
#property link "vladradon@mail.ru"
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_color1 clrYellow
#property indicator_color12 clrAqua
#property indicator_color13 clrRed
#property indicator_color15 clrAqua
#property indicator_color16 clrRed
#property indicator_width1 2
#property indicator_width12 2
#property indicator_width13 2
#property indicator_width15 2
#property indicator_width16 2
#property strict
//---- input parameters 
extern int Length1=30;
 // глубина сглаживания 
extern int Phase1 =100;
 // параметр, изменяющийся в пределах -150 ... +150, влияет на качество переходного процесса; 
extern int Shift1 =0;
 // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs1=0;
//Выбор цен, по которым производится расчёт индикатора (0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low") 
extern int Length2=20;
 // глубина сглаживания 
extern int Phase2 =100;
 // параметр, изменяющийся в пределах -150 ... +150, влияет на качество переходного процесса; 
extern int Shift2 =0;
 // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs2=0;
//Выбор цен, по которым производится расчёт индикатора (0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low") 
extern int Ndot_Cool2_JMA_1=7;
extern int Ndot_Cool2_JMA_2=7;
extern int CCF_MA=2;
extern int CJCF_MA=2;
extern int Ndot_CJCF_1=20;
extern int Ndot_CJCF_2=20;
extern int CountBars=1000;
extern int Ma_PeriodStd = 20;
extern int Ma_Method = 0;
extern int Ma_Price = 1;
extern bool CMA2Colors=true;
//Signaler v 1.1.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install AdvancedNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Make sure that Microsoft .NET Framework 4.6 is installed on your PC -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

//---- buffers
double CA[];
double DIR[];
double UpBuffer[];
double DnBuffer[];
double K=0;
double V1=0;
double V2=0;
int LastDir=0;
//---- buffers
double    cfl[];
double    cfl1[];
double    ExtBuffer_CF1[];
double    ExtBuffer_MA[];
double    ExtBuffer_EMA[];
double    ExtBuffer_CF[];

double cool21[];
double cool22[];
//---- indicator buffers 
double JMA_Buf1[];
double JMA_Buf2[];

double arrow_up[];
double arrow_down[];
datetime Top=0;
double Kg1,Dr1,Ds1,Dl1,Pf1,Kg2,Dr2,Ds2,Dl2,Pf2;
double Pp;
int dig;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Pp = _Point;
   dig = Digits;
   if (NormalizeDouble(Pp,dig)==NormalizeDouble(0.00001,dig) || NormalizeDouble(Pp,dig)==NormalizeDouble(0.001,dig)) Pp*=10; 

   SetIndexStyle(0,DRAW_LINE);
   if(CMA2Colors)
     {
      SetIndexStyle(11,DRAW_LINE);
      SetIndexStyle(12,DRAW_LINE);
     }
   else
     {
      SetIndexStyle(11,DRAW_NONE);
      SetIndexStyle(12,DRAW_NONE);
     }
   SetIndexBuffer(0,CA);
   SetIndexBuffer(11,UpBuffer);
   SetIndexBuffer(12,DnBuffer);
   SetIndexBuffer(13,DIR);
   SetIndexStyle(13,DRAW_NONE);
//---- indicator line
   SetIndexStyle(10,DRAW_NONE);
   SetIndexBuffer(10,cfl);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,cfl1);
   SetIndexBuffer(2,ExtBuffer_CF1);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,ExtBuffer_MA);
   SetIndexBuffer(4,ExtBuffer_EMA);
   SetIndexBuffer(5,ExtBuffer_CF);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   ArraySetAsSeries(ExtBuffer_MA,true);
   ArraySetAsSeries(ExtBuffer_EMA,true);
   ArraySetAsSeries(ExtBuffer_CF,true);
   ArraySetAsSeries(ExtBuffer_CF1,true);

   SetIndexStyle(6,DRAW_NONE);
   SetIndexShift(6,Shift1);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexShift(8,Shift2);
//---- 1 indicator buffers mapping 
   SetIndexBuffer(6,JMA_Buf1);
   SetIndexBuffer(8,JMA_Buf2);
   SetIndexEmptyValue(0,0.0);

   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,cool21);
   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,cool22);
   
   SetIndexBuffer(14,arrow_up);
   SetIndexStyle(14,DRAW_ARROW);
   SetIndexArrow(14,233);
   SetIndexEmptyValue(14,0);
   
   SetIndexBuffer(15,arrow_down);
   SetIndexStyle(15,DRAW_ARROW);
   SetIndexArrow(15,234);
   SetIndexEmptyValue(15,0);
//---- 
   IndicatorShortName("CMA 2 CJCF");
  // IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS));
//---- initial part 
   if(Phase1<-100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + DoubleToStr(Phase1,0)+ " будет использовано -100");}
   if(Phase1> 100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + DoubleToStr(Phase1,0)+ " будет использовано  100");}
   if(Length1<  1){Alert("Параметр Length должен не менее 1" + " Вы ввели недопустимое " + DoubleToStr(Length1,0)+ " будет использовано  1");}
   if(Input_Price_Customs1<0){Alert("Параметр Input_Price_Customs должен не менее 0" + " Вы ввели недопустимое " + DoubleToStr(Input_Price_Customs1,0)+ " будет использовано 0");}
   if(Input_Price_Customs1>4){Alert("Параметр Input_Price_Customs должен не более 4" + " Вы ввели недопустимое " + DoubleToStr(Input_Price_Customs1,0)+ " будет использовано 0");}
   if(Length1<1.0000000002) Dr1=0.0000000001; //{1.0e-10} 
   else Dr1=(Length1-1.0)/2.0;
   if(Phase1 >   100) Pf1=2.5;
   if(Phase1 <  -100) Pf1=0.5;
   if((Phase1>=-100) && (Phase1<=100)) Pf1=Phase1/100.0+1.5;
   Dr1=Dr1 * 0.9; Kg1=Dr1/(Dr1 + 2.0);
   Ds1=MathSqrt(Dr1); Dl1=MathLog(Ds1);

   if(Phase2<-100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + DoubleToStr(Phase2,0)+ " будет использовано -100");}
   if(Phase2> 100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " + DoubleToStr(Phase2,0)+ " будет использовано  100");}
   if(Length2<  1){Alert("Параметр Length должен не менее 1" + " Вы ввели недопустимое " + DoubleToStr(Length2,0)+ " будет использовано  1");}
   if(Input_Price_Customs2<0){Alert("Параметр Input_Price_Customs должен не менее 0" + " Вы ввели недопустимое " + DoubleToStr(Input_Price_Customs2,0)+ " будет использовано 0");}
   if(Input_Price_Customs2>4){Alert("Параметр Input_Price_Customs должен не более 4" + " Вы ввели недопустимое " + DoubleToStr(Input_Price_Customs2,0)+ " будет использовано 0");}
   if(Length2<1.0000000002) Dr2=0.0000000001; //{1.0e-10} 
   else Dr2=(Length2-1.0)/2.0;
   if(Phase2 >   100) Pf2=2.5;
   if(Phase2 <  -100) Pf2=0.5;
   if((Phase2>=-100) && (Phase2<=100)) Pf2=Phase2/100.0+1.5;
   Dr2=Dr2 * 0.9; Kg2=Dr2/(Dr2 + 2.0);
   Ds2=MathSqrt(Dr2); Dl2=MathLog(Ds2);
//----
   return(0);
  }

datetime _lastDatetime;

string GetTimeframe()
{
   switch (_Period)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
   }
   return "M1";
}

void SendNotifications(const int direction)
{
   if (direction == 0)
      return;

   datetime currentTime = iTime(_Symbol, _Period, 0);
   if (_lastDatetime == currentTime)
      return;

   _lastDatetime = currentTime;
   string tf = GetTimeframe();
   string alert_Subject;
   string alert_Body;
   switch (direction)
   {
      case 1:
         alert_Subject = "CMA 2 CJCF up on " + _Symbol + "/" + tf;
         alert_Body = "CMA 2 CJCF up on " + _Symbol + "/" + tf;
         break;
      case -1:
         alert_Subject = "CMA 2 CJCF down on " + _Symbol + "/" + tf;
         alert_Body = "CMA 2 CJCF down on " + _Symbol + "/" + tf;
         break;
   }
   SendNotifications(alert_Subject, alert_Body, _Symbol, tf);
}

void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
{
   if (Popup_Alert)
      Alert(message);
   if (Email_Alert)
      SendMail(subject, message);
   if (Play_Sound)
      PlaySound(Sound_File);
   if (Notification_Alert)
      SendNotification(message);
   if (Advanced_Alert && Advanced_Key != "")
      AdvancedAlert(Advanced_Key, message, symbol, timeframe);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(Top!=iTime(_Symbol,PERIOD_CURRENT,0)) Top=iTime(_Symbol,PERIOD_CURRENT,0); else return(0);
   JMA1(prev_calculated);
   
   Cool21();
   JMA2(prev_calculated);
   Cool22();

   int begin=0;
   ArraySetAsSeries(close,true); ArraySetAsSeries(open,true);
   CalculateSimpleMA(rates_total,prev_calculated,begin,close);
   CalculateEMA(rates_total,prev_calculated,begin,open);
   CalculateCF(rates_total,prev_calculated,begin);
   CFL1();
   CFL2();
//----
   CalculateCF1(rates_total,prev_calculated,begin);
   CMA();
   if (arrow_up[0])
   {
      SendNotifications(1);
   }
   if (arrow_down[0])
   {
      SendNotifications(-1);
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IntPortion(double param)
  {
   if(param > 0) return((int)MathFloor (param));
   if(param < 0) return((int)MathCeil  (param));
   return(0);
  }
//+------------------------------------------------------------------+
void Cool21()
  {
   if(CountBars>=Bars) CountBars=Bars;
  // SetIndexDrawBegin(0,Bars-CountBars+Ndot_Cool2_JMA_1+1);
   int shift,cnt,ndot1,counted_bars=IndicatorCounted();
   double TYVar,ZYVar,TIndicatorVar,ZIndicatorVar,M,N,AY,AIndicator;
//----
   shift=CountBars-Ndot_Cool2_JMA_1-1;
   while(shift>=0)
     {
      TYVar=0;
      ZYVar=0;
      N=0;
      M=0;
      TIndicatorVar=0;
      ZIndicatorVar=0;
      ndot1=Ndot_Cool2_JMA_1;
      if(shift+1<ndot1) ndot1=shift+1;
      for(cnt=Ndot_Cool2_JMA_1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         N=N+cnt*cnt;  //равно 55
         M=M+cnt;      //равно 15
        }
      for(cnt=ndot1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         ZYVar=ZYVar+(High[shift-cnt+1]+Low[shift-cnt+1])/2*(Ndot_Cool2_JMA_1+1-cnt);
         TYVar=TYVar+(High[shift-cnt+1]+Low[shift-cnt+1])/2;
         ZIndicatorVar=ZIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1)*(Ndot_Cool2_JMA_1+1-cnt);
         TIndicatorVar=TIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1);
        }
      AY=(TYVar+(N-2*ZYVar)*Ndot_Cool2_JMA_1/M)/M;
      AIndicator=(TIndicatorVar+(N-2*ZIndicatorVar)*Ndot_Cool2_JMA_1/M)/M;
      cool21[shift]=JMA_Buf1[shift]+((-1000)*MathLog(AY/AIndicator)/500);
      shift--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Cool22()
  {
   if(CountBars>=Bars) CountBars=Bars;
  // SetIndexDrawBegin(0,Bars-CountBars+Ndot_Cool2_JMA_2+1);
   int shift,cnt,ndot1,counted_bars=IndicatorCounted();
   double TYVar,ZYVar,TIndicatorVar,ZIndicatorVar,M,N,AY,AIndicator;
//----
   shift=CountBars-Ndot_Cool2_JMA_2-1;
   while(shift>=0)
     {
      TYVar=0;
      ZYVar=0;
      N=0;
      M=0;
      TIndicatorVar=0;
      ZIndicatorVar=0;
      ndot1=Ndot_Cool2_JMA_2;
      if(shift+1<ndot1) ndot1=shift+1;
      for(cnt=Ndot_Cool2_JMA_2; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         N=N+cnt*cnt;  //равно 55
         M=M+cnt;      //равно 15
        }
      for(cnt=ndot1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         ZYVar=ZYVar+(High[shift-cnt+1]+Low[shift-cnt+1])/2*(Ndot_Cool2_JMA_2+1-cnt);
         TYVar=TYVar+(High[shift-cnt+1]+Low[shift-cnt+1])/2;
         ZIndicatorVar=ZIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1)*(Ndot_Cool2_JMA_2+1-cnt);
         TIndicatorVar=TIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1);
        }
      AY=(TYVar+(N-2*ZYVar)*Ndot_Cool2_JMA_2/M)/M;
      AIndicator=(TIndicatorVar+(N-2*ZIndicatorVar)*Ndot_Cool2_JMA_2/M)/M;
      cool22[shift]=JMA_Buf2[shift]+((-1000)*MathLog(AY/AIndicator)/500);
      shift--;
     }
  }
//+------------------------------------------------------------------+
int JMA1(int counted_bars=-1)
  {
   double MEMORY1[9];
   int    MEMORY2[12];
   double MEMORY3[128];
   double list[128],ring1[128],ring2[11],buffer[62];
   ArrayInitialize (MEMORY1, 0.0);ArrayInitialize (MEMORY2, 0  );
   ArrayInitialize (MEMORY3, 0.0);
   ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
   ArrayInitialize (ring2,   0.0);ArrayInitialize (list,    0.0);
   
//---- double vars 
   double f8=0.0,f60=0.0,f20=0.0,f28=0.0,f30=0.0,f40=0.0,f48=0.0,f58=0.0,f68=0.0,f70=0.0,f90=0.0,f78=0.0,f88=0.0,f98=0.0;
   double JMA=0.0,series=0.0,vv=0.0,v1=0.0,v2=0.0,v3=0.0,v4=0.0,s20=0.0,s10=0.0,fB0=0.0,fD0=0.0;
//---- integer vars 
   int ii=0,jj=0,s28=0,s30=0,f0=0,v5=0,v6=0,fE0=0,fD8=0,fE8=0,val=0,s48=0,s58=0,s60=0,T0=0;
   double s68=0.0,f18=0.0,f38=0.0,fA0=0.0,fA8=0.0,fC0=0.0,fC8=0.0,s8=0.0,s18=0.0;
   int    s38=0,  s40=0,  s50=0,  s70=0,  LP2=0,  LP1=0;
//---- get already counted bars 
   //int counted_bars=prev_calculated;
//---- check for possible errors 
   if(counted_bars<0) return(-1);
   int limit=Bars-counted_bars-1;

//----
   if(limit==Bars-1)
     {
      //---- Повторное объявление переменных и их инициализация
      ArrayInitialize (MEMORY1, 0.0);ArrayInitialize (MEMORY2, 0  );
      ArrayInitialize (MEMORY3, 0.0);
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (ring2,   0.0);ArrayInitialize (list,    0.0);
      //----
      f18=0.0;f38=0.0;fA0=0.0;fA8=0.0;fC0=0.0;fC8=0.0;s8=0.0;s18=0.0;
      s38=0;  s40=0;  s50=0;  s70=0;  LP2=0;  LP1=0;
      //----
      f0=1; s28=63; s30=64;
      for(ii=0;   ii<=s28; ii++)list[ii]=-1000000.0;
      for(ii=s30; ii<=127; ii++)list[ii]= 1000000.0;
      //----
     }
   if(limit<Bars-1)
     {
      //---- инициализация переменных  инициализация
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (list,    0.0);ArrayInitialize (ring2,   0.0);
      //----
      f8 =0.0;f60=0.0;f20=0.0;f28=0.0;f30=0.0;f40=0.0;f48=0.0;f58=0.0;f68=0.0;
      f70=0.0;f90=0.0;f78=0.0;f88=0.0;f98=0.0;vv =0.0;v1 =0.0;v2 =0.0;v3 =0.0;
      v4 =0.0;fB0=0.0;fD0=0.0;v5 =0;  v6 =0;  fE0=0;  fD8=0;  fE8=0;  val=0;
      //----
      if(Time[limit+1]!=T0)
        {
         //--- Восстановение переменных
         if(Time[limit+1]!=MEMORY2[0])return(-1);
         fC0=MEMORY1[00];
         fC8=MEMORY1[01];
         fA8=MEMORY1[02];
         s8 =MEMORY1[03];
         f18=MEMORY1[04];
         f38=MEMORY1[05];
         s18=MEMORY1[06];
         s20=MEMORY1[07];
         s10=MEMORY1[08];
         //----
         s38=MEMORY2[01];
         s48=MEMORY2[02];
         s50=MEMORY2[03];
         LP1=MEMORY2[04];
         LP2=MEMORY2[05];
         s28=MEMORY2[06];
         s30=MEMORY2[07];
         s48=MEMORY2[08];
         s58=MEMORY2[09];
         s60=MEMORY2[10];
         s68=MEMORY2[11];
         JMA=JMA_Buf1[limit+1];
         for(ii=0;ii<=127;ii++)list[ii]=MEMORY3[ii];
         //----
        }
     }
   if(counted_bars==0) limit-=3;
   for(int bar=limit; bar>=0; bar--)
     {
      //---- main cycle
      if((Input_Price_Customs1<=0) || Input_Price_Customs1>4)series=Close[bar];
      if(Input_Price_Customs1==1)series= Open[bar];
      if(Input_Price_Customs1==2)series=(High[bar]+Low[bar])/2;
      if(Input_Price_Customs1==3)series= High[bar];
      if(Input_Price_Customs1==4)series= Low [bar];
      //---- 
      if(LP1<61){LP1++; buffer[LP1]=series;}
      if(LP1>30)
        {
         v1=Dl1; v2=v1;
         if((v1/MathLog(2.0))+2.0<0.0) v3=0.0; else v3=(v2/MathLog(2.0))+2.0;
         f98=v3;
         if(f98>=2.5)f88=f98-2.0; else f88=0.5;
         f78=Ds1*f98; f90=f78/(f78+1.0);
         if(f0!=0)
           {
            f0=0; v5=0;
            for(ii=0; ii<=29; ii++) {if(buffer[ii+1]!=buffer[ii]) v5=1; break; }
            fD8=v5*30;
            if(fD8==0) f38=series; else f38=buffer[1];
            f18=f38;
            if(fD8>29) fD8=29;
           }
         else fD8=0;
         for(ii=fD8; ii>=0; ii--)
           {
            val=31-ii;
            if(ii==0) f8=series; else f8=buffer[val];
            f28=f8-f18; f48=f8-f38;
            if(MathAbs(f28)>MathAbs(f48)) v2=MathAbs(f28); else v2=MathAbs(f48);
            fA0=v2; vv=fA0+0.0000000001; //{1.0e-10;} 
            if(s48<=1) s48=127; else s48=s48 - 1;
            if(s50<=1) s50=10;  else s50=s50 - 1;
            if(s70<128) s70=s70+1;
            s8=s8+vv-ring2[s50]; ring2[s50]=vv;
            if(s70>10) s20=s8/10.0; else s20=s8/s70;
            if(s70>127)
              {
               s10=ring1[s48]; ring1[s48]=s20; s68=64; s58=(int)s68;
               while(s68>1)
                 {
                  if(list[s58]<s10){s68=s68 *0.5; s58=(int)(s58+s68);}
                  else if(list[s58]<=s10) s68=1; else{s68=s68 *0.5; s58=(int)(s58-s68);}
                 }
              }
            else
              {
               ring1[s48]=s20;
               if(s28+s30>127){s30=s30-1; s58=s30;}
               else {s28=s28+1; s58=s28;}
               if(s28 > 96) s38=96; else s38=s28;
               if(s30 < 32) s40=32; else s40=s30;
              }
            s68=64; s60=(int)s68;
            while(s68>1)
              {
               if(list[s60]>=s20)
                 {
                  if(list[s60-1]<=s20) s68=1; else {s68=s68 *0.5; s60=(int)(s60-s68); }
                 }
               else{s68=s68 *0.5; s60=(int)(s60+s68);}
               if((s60==127) && (s20>list[127])) s60=128;
              }
            if(s70>127)
              {
               if(s58>=s60)
                 {
                  if((s38+1>s60) && (s40-1<s60)) s18=s18+s20;
                  else if((s40+0>s60) && (s40-1<s58)) s18=s18+list[s40-1];
                 }
               else
               if(s40>=s60) {if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1]; }
               else if(s38+2>s60) s18=s18+s20; else if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1];
               if(s58>s60)
                 {
                  if((s40-1<s58) && (s38+1>s58)) s18=s18-list[s58];
                  else if((s38<s58) && (s38+1>s60)) s18=s18-list[s38];
                 }
               else
                 {
                  if((s38+1>s58) && (s40-1<s58)) s18=s18-list[s58];
                  else
                     if((s40+0>s58) && (s40-0<s60)) s18=s18-list[s40];
                 }
              }
            if(s58<=s60)
              {
               if((s58>=s60) && s60<ArraySize(list)-1) list[s60]=s20;
               else
                 {
                  for(jj=s58+1;(jj<=s60-1) && (jj>0);jj++)list[jj-1]=list[jj];
                  list[s60-1]=s20;
                 }
              }
            else
              {
               for(jj=s58-1;(jj>=s60) && (jj<ArraySize(list)-1);jj--) list[jj+1]=list[jj];
               list[s60]=s20;
              }
            if(s70<=127)
              {
               s18=0;
               for(jj=s40;jj<=s38;jj++) s18=s18+list[jj];
              }
            f60=s18/(s38-s40+1.0);
            if(LP2+1>31) LP2=31; else LP2=LP2+1;
            if(LP2<=30)
              {
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f90;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f90;
               JMA=series;
               if(LP2!=30) continue;
               if(LP2==30)
                 {
                  fC0=series;
                  if(MathCeil(f78)>=1) v4=MathCeil(f78); else v4=1.0;
                  fE8=IntPortion(v4);
                  if(MathFloor(f78)>=1) v2=MathFloor(f78); else v2=1.0;
                  fE0=IntPortion(v2);
                  if(fE8==fE0) f68=1.0; else {v4=fE8-fE0; f68=(f78-fE0)/v4;}
                  if(fE0<=29) v5=fE0; else v5=29;
                  if(fE8<=29) v6=fE8; else v6=29;
                  fA8=(series-buffer[LP1-v5]) *(1.0-f68)/fE0+(series-buffer[LP1-v6])*f68/fE8;
                 }
              }
            else
              {
               if(f98>=MathPow(fA0/f60, f88)) v1=MathPow(fA0/f60, f88);
               else v1=f98;
               if(v1<1.0) v2=1.0;
               else
                 {
                  if(f98>=MathPow(fA0/f60,f88)) v3=MathPow(fA0/f60,f88);
                  else v3=f98; v2=v3;
                 }
               f58=v2; f70=MathPow(f90,MathSqrt(f58));
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f70;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f70;
              }
           }
         if(LP2>30)
           {
            f30=MathPow(Kg1,f58);
            fC0 =(1.0 - f30) * series + f30 * fC0;
            fC8 =(series - fC0) * (1.0 - Kg1) + Kg1 * fC8;
            fD0=Pf1 * fC8 + fC0;
            f20=f30 *(-2.0);
            f40=f30 * f30;
            fB0=f20 + f40 + 1.0;
            fA8=(fD0-JMA) * fB0+f40 * fA8;
            JMA=JMA+fA8;
           }
        }
      if(LP1<=30)JMA=0.0;
      JMA_Buf1[bar]=JMA;

      if(bar==1)
        {
         MEMORY1[00]=fC0;
         MEMORY1[01]=fC8;
         MEMORY1[02]=fA8;
         MEMORY1[03]= s8;
         MEMORY1[04]=f18;
         MEMORY1[05]=f38;
         MEMORY1[06]=s18;
         MEMORY1[07]=s20;
         MEMORY1[08]=s10;
         //----
         MEMORY2[01]=s38;
         MEMORY2[02]=s48;
         MEMORY2[03]=s50;
         MEMORY2[04]=LP1;
         MEMORY2[05]=LP2;
         MEMORY2[06]=s28;
         MEMORY2[07]=s30;
         MEMORY2[08]=s48;
         MEMORY2[09]=s58;
         MEMORY2[10]=s60;
         MEMORY2[11]=(int)s68;
         MEMORY2[00]=(int)Time[1];
         for(ii=0; ii<=127; ii++)
            MEMORY3[ii]=list[ii];
         T0=(int)Time[0];
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
int JMA2(int counted_bars=-1)
  {
   double MEMORY1[9];
   int    MEMORY2[12];
   double MEMORY3[128];
   double list[128],ring1[128],ring2[11],buffer[62];
   ArrayInitialize (MEMORY1, 0.0);ArrayInitialize (MEMORY2, 0  );
   ArrayInitialize (MEMORY3, 0.0);
   ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
   ArrayInitialize (ring2,   0.0);ArrayInitialize (list,    0.0);
   
//---- double vars 
   double f8=0.0,f60=0.0,f20=0.0,f28=0.0,f30=0.0,f40=0.0,f48=0.0,f58=0.0,f68=0.0,f70=0.0,f90=0.0,f78=0.0,f88=0.0,f98=0.0;
   double JMA=0.0,series=0.0,vv=0.0,v1=0.0,v2=0.0,v3=0.0,v4=0.0,s20=0.0,s10=0.0,fB0=0.0,fD0=0.0;
//---- integer vars 
   int ii=0,jj=0,s28=0,s30=0,f0=0,v5=0,v6=0,fE0=0,fD8=0,fE8=0,val=0,s48=0,s58=0,s60=0,T0=0;
   double s68=0.0,f18=0.0,f38=0.0,fA0=0.0,fA8=0.0,fC0=0.0,fC8=0.0,s8=0.0,s18=0.0;
   int    s38=0,  s40=0,  s50=0,  s70=0,  LP2=0,  LP1=0;
//---- get already counted bars 
   //int counted_bars=0;
//---- check for possible errors 
   if(counted_bars<0) return(-1);
   int limit=Bars-counted_bars-1;

//----
   if(limit==Bars-1)
     {
      //---- Повторное объявление переменных и их инициализация
      ArrayInitialize (MEMORY1, 0.0);ArrayInitialize (MEMORY2, 0  );
      ArrayInitialize (MEMORY3, 0.0);
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (ring2,   0.0);ArrayInitialize (list,    0.0);
      //----
      f18=0.0;f38=0.0;fA0=0.0;fA8=0.0;fC0=0.0;fC8=0.0;s8=0.0;s18=0.0;
      s38=0;  s40=0;  s50=0;  s70=0;  LP2=0;  LP1=0;
      //----
      f0=1; s28=63; s30=64;
      for(ii=0;   ii<=s28; ii++)list[ii]=-1000000.0;
      for(ii=s30; ii<=127; ii++)list[ii]= 1000000.0;
      //----
     }
   if(limit<Bars-1)
     {
      //---- инициализация переменных  инициализация
      ArrayInitialize (buffer,  0.0);ArrayInitialize (ring1,   0.0);
      ArrayInitialize (list,    0.0);ArrayInitialize (ring2,   0.0);
      //----
      f8 =0.0;f60=0.0;f20=0.0;f28=0.0;f30=0.0;f40=0.0;f48=0.0;f58=0.0;f68=0.0;
      f70=0.0;f90=0.0;f78=0.0;f88=0.0;f98=0.0;vv =0.0;v1 =0.0;v2 =0.0;v3 =0.0;
      v4 =0.0;fB0=0.0;fD0=0.0;v5 =0;  v6 =0;  fE0=0;  fD8=0;  fE8=0;  val=0;
      //----
      if(Time[limit+1]!=T0)
        {
         //--- Восстановение переменных
         if(Time[limit+1]!=MEMORY2[0])return(-1);
         fC0=MEMORY1[00];
         fC8=MEMORY1[01];
         fA8=MEMORY1[02];
         s8 =MEMORY1[03];
         f18=MEMORY1[04];
         f38=MEMORY1[05];
         s18=MEMORY1[06];
         s20=MEMORY1[07];
         s10=MEMORY1[08];
         //----
         s38=MEMORY2[01];
         s48=MEMORY2[02];
         s50=MEMORY2[03];
         LP1=MEMORY2[04];
         LP2=MEMORY2[05];
         s28=MEMORY2[06];
         s30=MEMORY2[07];
         s48=MEMORY2[08];
         s58=MEMORY2[09];
         s60=MEMORY2[10];
         s68=MEMORY2[11];
         JMA=JMA_Buf2[limit+1];
         for(ii=0;ii<=127;ii++)list[ii]=MEMORY3[ii];
         //----
        }
     }
   if(counted_bars==0) limit-=3;
   for(int bar=limit; bar>=0; bar--)
     {
      //---- main cycle
      if((Input_Price_Customs2<=0) || Input_Price_Customs2>4)series=Close[bar];
      if(Input_Price_Customs2==1)series= Open[bar];
      if(Input_Price_Customs2==2)series=(High[bar]+Low[bar])/2;
      if(Input_Price_Customs2==3)series= High[bar];
      if(Input_Price_Customs2==4)series= Low [bar];
      //---- 
      if(LP1<61){LP1++; buffer[LP1]=series;}
      if(LP1>30)
        {
         v1=Dl2; v2=v1;
         if((v1/MathLog(2.0))+2.0<0.0) v3=0.0; else v3=(v2/MathLog(2.0))+2.0;
         f98=v3;
         if(f98>=2.5)f88=f98-2.0; else f88=0.5;
         f78=Ds2*f98; f90=f78/(f78+1.0);
         if(f0!=0)
           {
            f0=0; v5=0;
            for(ii=0; ii<=29; ii++) {if(buffer[ii+1]!=buffer[ii]) v5=1; break; }
            fD8=v5*30;
            if(fD8==0) f38=series; else f38=buffer[1];
            f18=f38;
            if(fD8>29) fD8=29;
           }
         else fD8=0;
         for(ii=fD8; ii>=0; ii--)
           {
            val=31-ii;
            if(ii==0) f8=series; else f8=buffer[val];
            f28=f8-f18; f48=f8-f38;
            if(MathAbs(f28)>MathAbs(f48)) v2=MathAbs(f28); else v2=MathAbs(f48);
            fA0=v2; vv=fA0+0.0000000001; //{1.0e-10;} 
            if(s48<=1) s48=127; else s48=s48 - 1;
            if(s50<=1) s50=10;  else s50=s50 - 1;
            if(s70<128) s70=s70+1;
            s8=s8+vv-ring2[s50]; ring2[s50]=vv;
            if(s70>10) s20=s8/10.0; else s20=s8/s70;
            if(s70>127)
              {
               s10=ring1[s48]; ring1[s48]=s20; s68=64; s58=(int)s68;
               while(s68>1)
                 {
                  if(list[s58]<s10){s68=s68 *0.5; s58=(int)(s58+s68);}
                  else if(list[s58]<=s10) s68=1; else{s68=s68 *0.5; s58=(int)(s58-s68);}
                 }
              }
            else
              {
               ring1[s48]=s20;
               if(s28+s30>127){s30=s30-1; s58=s30;}
               else {s28=s28+1; s58=s28;}
               if(s28 > 96) s38=96; else s38=s28;
               if(s30 < 32) s40=32; else s40=s30;
              }
            s68=64; s60=(int)s68;
            while(s68>1)
              {
               if(list[s60]>=s20)
                 {
                  if(list[s60-1]<=s20) s68=1; else {s68=s68 *0.5; s60=(int)(s60-s68); }
                 }
               else{s68=s68 *0.5; s60=(int)(s60+s68);}
               if((s60==127) && (s20>list[127])) s60=128;
              }
            if(s70>127)
              {
               if(s58>=s60)
                 {
                  if((s38+1>s60) && (s40-1<s60)) s18=s18+s20;
                  else if((s40+0>s60) && (s40-1<s58)) s18=s18+list[s40-1];
                 }
               else
               if(s40>=s60) {if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1]; }
               else if(s38+2>s60) s18=s18+s20; else if((s38+1<s60) && (s38+1>s58)) s18=s18+list[s38+1];
               if(s58>s60)
                 {
                  if((s40-1<s58) && (s38+1>s58)) s18=s18-list[s58];
                  else if((s38<s58) && (s38+1>s60)) s18=s18-list[s38];
                 }
               else
                 {
                  if((s38+1>s58) && (s40-1<s58)) s18=s18-list[s58];
                  else
                     if((s40+0>s58) && (s40-0<s60)) s18=s18-list[s40];
                 }
              }
            if(s58<=s60)
              {
               if((s58>=s60) && s60<ArraySize(list)-1) list[s60]=s20;
               else
                 {
                  for(jj=s58+1;(jj<=s60-1) && (jj>0);jj++)list[jj-1]=list[jj];
                  list[s60-1]=s20;
                 }
              }
            else
              {
               for(jj=s58-1;(jj>=s60) && (jj<ArraySize(list)-1);jj--) list[jj+1]=list[jj];
               list[s60]=s20;
              }
            if(s70<=127)
              {
               s18=0;
               for(jj=s40;jj<=s38;jj++) s18=s18+list[jj];
              }
            f60=s18/(s38-s40+1.0);
            if(LP2+1>31) LP2=31; else LP2=LP2+1;
            if(LP2<=30)
              {
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f90;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f90;
               JMA=series;
               if(LP2!=30) continue;
               if(LP2==30)
                 {
                  fC0=series;
                  if(MathCeil(f78)>=1) v4=MathCeil(f78); else v4=1.0;
                  fE8=IntPortion(v4);
                  if(MathFloor(f78)>=1) v2=MathFloor(f78); else v2=1.0;
                  fE0=IntPortion(v2);
                  if(fE8==fE0) f68=1.0; else {v4=fE8-fE0; f68=(f78-fE0)/v4;}
                  if(fE0<=29) v5=fE0; else v5=29;
                  if(fE8<=29) v6=fE8; else v6=29;
                  fA8=(series-buffer[LP1-v5]) *(1.0-f68)/fE0+(series-buffer[LP1-v6])*f68/fE8;
                 }
              }
            else
              {
               if(f98>=MathPow(fA0/f60, f88)) v1=MathPow(fA0/f60, f88);
               else v1=f98;
               if(v1<1.0) v2=1.0;
               else
                 {
                  if(f98>=MathPow(fA0/f60,f88)) v3=MathPow(fA0/f60,f88);
                  else v3=f98; v2=v3;
                 }
               f58=v2; f70=MathPow(f90,MathSqrt(f58));
               if(f28 > 0.0) f18=f8; else f18=f8 - f28 * f70;
               if(f48 < 0.0) f38=f8; else f38=f8 - f48 * f70;
              }
           }
         if(LP2>30)
           {
            f30=MathPow(Kg2,f58);
            fC0 =(1.0 - f30) * series + f30 * fC0;
            fC8 =(series - fC0) * (1.0 - Kg2) + Kg2 * fC8;
            fD0=Pf2 * fC8 + fC0;
            f20=f30 *(-2.0);
            f40=f30 * f30;
            fB0=f20 + f40 + 1.0;
            fA8=(fD0-JMA) * fB0+f40 * fA8;
            JMA=JMA+fA8;
           }
        }
      if(LP1<=30)JMA=0.0;
      JMA_Buf2[bar]=JMA;

      if(bar==1)
        {
         MEMORY1[00]=fC0;
         MEMORY1[01]=fC8;
         MEMORY1[02]=fA8;
         MEMORY1[03]= s8;
         MEMORY1[04]=f18;
         MEMORY1[05]=f38;
         MEMORY1[06]=s18;
         MEMORY1[07]=s20;
         MEMORY1[08]=s10;
         //----
         MEMORY2[01]=s38;
         MEMORY2[02]=s48;
         MEMORY2[03]=s50;
         MEMORY2[04]=LP1;
         MEMORY2[05]=LP2;
         MEMORY2[06]=s28;
         MEMORY2[07]=s30;
         MEMORY2[08]=s48;
         MEMORY2[09]=s58;
         MEMORY2[10]=s60;
         MEMORY2[11]=(int)s68;
         MEMORY2[00]=(int)Time[1];
         for(ii=0; ii<=127; ii++)
            MEMORY3[ii]=list[ii];
         T0=(int)Time[0];
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFL1()
  {
   int counted_bars=IndicatorCounted();
   if(CountBars>=Bars) CountBars=Bars;
  // SetIndexDrawBegin(0,Bars-CountBars+Ndot_CJCF_1+1);
   int shift,cnt,ndot1;
   double TYVar,ZYVar,TIndicatorVar,ZIndicatorVar,M,N,AY,AIndicator;
//----
   shift=CountBars-Ndot_CJCF_1-1;
   while(shift>=0)
     {
      TYVar=0;
      ZYVar=0;
      N=0;
      M=0;
      TIndicatorVar=0;
      ZIndicatorVar=0;
      ndot1=Ndot_CJCF_1;
      if(shift+1<ndot1) ndot1=shift+1;
      for(cnt=Ndot_CJCF_1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         N=N+cnt*cnt;  //равно 55
         M=M+cnt;      //равно 15
        }
      for(cnt=ndot1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         ZYVar=ZYVar+(ExtBuffer_CF[shift-cnt+1]+ExtBuffer_CF[shift-cnt+1])/2*(Ndot_CJCF_1+1-cnt);
         TYVar=TYVar+(ExtBuffer_CF[shift-cnt+1]+ExtBuffer_CF[shift-cnt+1])/2;
         ZIndicatorVar=ZIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1)*(Ndot_CJCF_1+1-cnt);
         TIndicatorVar=TIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1);
        }
      AY=(TYVar+(N-2*ZYVar)*Ndot_CJCF_1/M)/M;
      AIndicator=(TIndicatorVar+(N-2*ZIndicatorVar)*Ndot_CJCF_1/M)/M;
      cfl[shift]=cool21[shift]+((-1000)*MathLog(AY/AIndicator)/500);
      shift--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFL2()
  {
   int counted_bars=IndicatorCounted();
   if(CountBars>=Bars) CountBars=Bars;
 //  SetIndexDrawBegin(1,Bars-CountBars+Ndot_CJCF_2+1);
   int shift,cnt,ndot1;
   double TYVar,ZYVar,TIndicatorVar,ZIndicatorVar,M,N,AY,AIndicator;
//----
   shift=CountBars-Ndot_CJCF_2-1;
   while(shift>=0)
     {
      TYVar=0;
      ZYVar=0;
      N=0;
      M=0;
      TIndicatorVar=0;
      ZIndicatorVar=0;
      ndot1=Ndot_CJCF_2;
      if(shift+1<ndot1) ndot1=shift+1;
      for(cnt=Ndot_CJCF_2; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         N=N+cnt*cnt;  //равно 55
         M=M+cnt;      //равно 15
        }
      for(cnt=ndot1; cnt>=1; cnt--) // n=5 -  по пяти точкам
        {
         ZYVar=ZYVar+(ExtBuffer_CF[shift-cnt+1]+ExtBuffer_CF[shift-cnt+1])/2*(Ndot_CJCF_2+1-cnt);
         TYVar=TYVar+(ExtBuffer_CF[shift-cnt+1]+ExtBuffer_CF[shift-cnt+1])/2;
         ZIndicatorVar=ZIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1)*(Ndot_CJCF_2+1-cnt);
         TIndicatorVar=TIndicatorVar+iMA(NULL,0,5,3,MODE_SMMA,PRICE_MEDIAN,shift-cnt+1);
        }
      AY=(TYVar+(N-2*ZYVar)*Ndot_CJCF_2/M)/M;
      AIndicator=(TIndicatorVar+(N-2*ZIndicatorVar)*Ndot_CJCF_2/M)/M;
      cfl1[shift]=cool22[shift]+((-1000)*MathLog(AY/AIndicator)/500);
      shift--;
     }
  }
//+------------------------------------------------------------------+
//|  simple cluster filter                                           |
//+------------------------------------------------------------------+
void CalculateCF1(int rates_total,int prev_calculated,int begin)
  {
   int    i=0,limit=0;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=CJCF_MA+begin;
      for(i=begin;i<limit;i++)
         ExtBuffer_CF1[i]=cfl1[i];
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(ExtBuffer_CF1[i-1]>ExtBuffer_CF1[i-2])
        {
         if(ExtBuffer_CF1[i-1]<cfl[i] && ExtBuffer_CF1[i-1]<cfl1[i])
           {
            ExtBuffer_CF1[i]=fmin(cfl[i],cfl1[i]);
            continue;
           }
         if(ExtBuffer_CF1[i-1]<cfl[i] && ExtBuffer_CF1[i-1]>cfl1[i])
           {
            ExtBuffer_CF1[i]=cfl[i];
            continue;
           }
         if(ExtBuffer_CF1[i-1]>cfl[i] && ExtBuffer_CF1[i-1]<cfl1[i])
           {
            ExtBuffer_CF1[i]=cfl1[i];
            continue;
           }
         ExtBuffer_CF1[i]=fmax(cfl[i],cfl1[i]);
        }
      else
        {
         if(ExtBuffer_CF1[i-1]>cfl[i] && ExtBuffer_CF1[i-1]>cfl1[i])
           {
            ExtBuffer_CF1[i]=fmax(cfl[i],cfl1[i]);
            continue;
           }
         if(ExtBuffer_CF1[i-1]>cfl[i] && ExtBuffer_CF1[i-1]<cfl1[i])
           {
            ExtBuffer_CF1[i]=cfl[i];
            continue;
           }
         if(ExtBuffer_CF1[i-1]<cfl[i] && ExtBuffer_CF1[i-1]>cfl1[i])
           {
            ExtBuffer_CF1[i]=cfl1[i];
            continue;
           }
         ExtBuffer_CF1[i]=fmin(cfl[i],cfl1[i]);
        }

     }
//---
  }
//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
   {
      limit=CCF_MA+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++){ ExtBuffer_MA[i]=0.0; }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++){
         firstValue+=price[i];
      }
      firstValue/=CCF_MA;
      ExtBuffer_MA[limit-1]=firstValue;
   }else{ limit=prev_calculated-1; }
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtBuffer_MA[i]=ExtBuffer_MA[i-1]+(price[i]-price[i-CCF_MA])/CCF_MA;
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+CCF_MA);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=CCF_MA+begin;
      ExtBuffer_EMA[begin]=price[begin];
      for(i=begin+1;i<limit;i++)
         ExtBuffer_EMA[i]=price[i]*SmoothFactor+ExtBuffer_EMA[i-1]*(1.0-SmoothFactor);
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtBuffer_EMA[i]=price[i]*SmoothFactor+ExtBuffer_EMA[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
//|  simple cluster filter                                           |
//+------------------------------------------------------------------+
void CalculateCF(int rates_total,int prev_calculated,int begin)
  {
   int    i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=CCF_MA+begin;
      for(i=begin;i<limit;i++)
         ExtBuffer_CF[i]=ExtBuffer_EMA[i];
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(ExtBuffer_CF[i-1]>ExtBuffer_CF[i-2])
        {
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=fmin(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
            continue;
           }
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_MA[i];
            continue;
           }
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_EMA[i];
            continue;
           }
         ExtBuffer_CF[i]=fmax(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
        }
      else
        {
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=fmax(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
            continue;
           }
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_MA[i];
            continue;
           }
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_EMA[i];
            continue;
           }
         ExtBuffer_CF[i]=fmin(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
        }

     }
//---
  }
//+------------------------------------------------------------------+
void CMA()
  {
   CA[CountBars+1]=ExtBuffer_CF1[CountBars+1];
   if (CountBars+1>Bars-2)  CountBars=Bars-2;
   for(int i=CountBars;i>=0;i--)
   {
    V1=MathSqrt(iStdDev(NULL,0,Ma_PeriodStd,0,Ma_Method,Ma_Price,i));
    V2=MathSqrt(MathAbs(CA[i+1]-ExtBuffer_CF1[i]));
    if (V2<V1) {DIR[i]=DIR[i+1];K=0;}
    else {K=1-(V1/V2);}
    CA[i]=CA[i+1]+K*(ExtBuffer_CF1[i]-CA[i+1]);
     DIR[i]=DIR[i+1];
     if (CA[i]-CA[i+1] > 0) DIR[i]= 1; 
     if (CA[i+1]-CA[i] > 0) DIR[i]=-1; 
        if (DIR[i]>0)
        {  
        if(DIR[i+1]<0) 
         arrow_up[i] = Low[i]-5*Pp;
         else{
         arrow_up[i] = 0;
         arrow_down[i] = 0;
         }
        UpBuffer[i] = CA[i];
        if (DIR[i+1]<0) UpBuffer[i+1]=CA[i+1];
        DnBuffer[i] = EMPTY_VALUE;
        }
        else if (DIR[i]<0) 
        {
        if(DIR[i+1]>0) 
         arrow_down[i] = High[i]+5*Pp;
         else{
         arrow_up[i] = 0;
         arrow_down[i] = 0;
         }
        DnBuffer[i] = CA[i];
        if (DIR[i+1]>0) DnBuffer[i+1]=CA[i+1];
        UpBuffer[i] = EMPTY_VALUE;
        } 
   }
//----
  }