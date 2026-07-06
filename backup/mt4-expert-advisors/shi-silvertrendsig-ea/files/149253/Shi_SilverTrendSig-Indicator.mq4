// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73264

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#define  SH_BUY   1
#define  SH_SELL  -1

//---- Входные параметры
extern int     AllBars=0;//Для скольки баров считать. 0 - для всех.
extern int     Otstup=30;//Отступ.
extern double  Per=9;//Период.
int            SH,NB,i,UD;
double         R,SHMax,SHMin;
double         BufD[];
double         BufU[];
//+------------------------------------------------------------------+
//| Функция инициализации                                            |
//+------------------------------------------------------------------+
int init()
{
   //В NB записываем количество баров для которых считаем индикатор
   if (Bars<AllBars+Per || AllBars==0) NB=Bars-Per; else NB=AllBars;
   IndicatorBuffers(2);
   IndicatorShortName("SHI_SilverTrendSig");
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
   SetIndexBuffer(0,BufU);
   SetIndexBuffer(1,BufD);
   SetIndexDrawBegin(0,Bars-NB);//Индикатор будетотображаться только для NB баров
   SetIndexDrawBegin(1,Bars-NB);
   Print("NB:", NB);
   return(0);
}
//+------------------------------------------------------------------+
//| Функция деинициализации                                          |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| Собсна индикатор                                                 |
//+------------------------------------------------------------------+
int start()
{
   int CB=IndicatorCounted();
   /* Тут вот та самая оптимизационная фишка. В язык введена функция, которая возвращает количество
   посчитанных баров, причём очень хитро. При первом вызове индикатора это 0, всё понятно, ещё ничего
   не считалось, а затем выдаёт количество обсчитанных баров минус один. Т.е. если всего баров 100,
   то функция вернёт 99. Я ввёл такой код, выше у меня определялась NB - кол-во баров подлежащих
   обсчёту. В принципе этот параметр можно и выкинуть, однако для тех кто в танке (I80286) можно
   и оставить. Так вот, здесь, при первом вызове NB остаётся прежней, а при последующих уменьшается
   до последнего бара, т.е. 1 или 2, ну или сколько там осталось посчитать*/
   if(CB<0) return(-1); else if(NB>Bars-CB) NB=Bars-CB;
      for (SH=1;SH<NB;SH++)//Прочёсываем график от 1 до NB
   {
      for (R=0,i=SH;i<SH+10;i++) {R+=(10+SH-i)*(High[i]-Low[i]);}      R/=55;

      SHMax = High[Highest(NULL,0,MODE_HIGH,Per,SH)];
      SHMin = Low[Lowest(NULL,0,MODE_LOW,Per,SH)];
      if (Close[SH]<SHMin+(SHMax-SHMin)*Otstup/100 && UD!=SH_SELL) { BufU[SH]=Low[SH]-R*0.5; UD=SH_SELL; }
      if (Close[SH]>SHMax-(SHMax-SHMin)*Otstup/100 && UD!=SH_BUY) { BufD[SH]=High[SH]+R*0.5; UD=SH_BUY; }
   }
   return(0);
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
