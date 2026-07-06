// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73248

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
#property indicator_buffers 3
#property indicator_color1 clrRed
//----
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//---- input parameters
extern color     LineColor=clrDarkOrange;
extern int       AllBars=240;
extern int       BarsForFract=0;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1;
int UpDown=0;
double P1=0,P2=0,PP=0;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2;
string TL1, TL2, MIDL, TFS;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,164);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   //unique names for lines based on Period();
     switch(Period())
     {
         case(1):
            TFS="M1";
            break;
         case(5):
            TFS="M5";
            break;
         case(30):
            TFS="M30";
            break;
         case(60):
            TFS="H1";
            break;
         case(240):
            TFS="H4";
            break;
         case(1440):
            TFS="D1";
            break;
         case(10080):
            TFS="WK1";
            break;
         case(43200):
            TFS="MN1";
            break;
         default:
            TFS="UNKNOWN_TIMEFRAME";
            break;
        }
      TL1="TL1_" + TFS;
      TL2="TL2_" + TFS;
      MIDL="MIDL_" + TFS;
   //---
      return(0);
     }
         //+------------------------------------------------------------------+
         //| Custom indicator deinitialization function                       |
         //+------------------------------------------------------------------+
         int deinit()
           {
         //---- 
         //----
            return(0);
           }
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         void DelObj()
           {
            ObjectDelete(TL1);
            ObjectDelete(TL2);
            ObjectDelete(MIDL);
           }
         //+------------------------------------------------------------------+
         //| Custom indicator iteration function                              |
         //+------------------------------------------------------------------+
         int start()
           {
            double j;
            string temp;
            int m,s;
            m=Time[0]+Period()*60-CurTime();
            j=m/60.0;
            s=m%60;
            m=(m-m%60)/60;
            temp =(m + " minutes " + s + " seconds left to bar end");
            ObjectDelete("time");
            if(ObjectFind("time")!=0)
              {
               ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+ 0.0005);
               ObjectSetText("time", "                                 <--"+m+":"+s, 13, "Verdana", Yellow);
              }
            else
              {
               ObjectMove("time", 0, Time[0], Close[0]+0.0005);
              }
            int    counted_bars=IndicatorCounted();
         //---- 
            if ((AllBars==0) || (Bars<AllBars)) AB=Bars-1; else AB=AllBars; //AB-количество обсчитываемых баров
            if (BarsForFract>0)
               BFF=BarsForFract;
            else
              {
               switch(Period())
                 {
                  case 1: BFF=12; break;
                  case 5: BFF=48; break;
                  case 15: BFF=24; break;
                  case 30: BFF=24; break;
                  case 60: BFF=12; break;
                  case 240: BFF=15; break;
                  case 1440: BFF=10; break;
                  case 10080: BFF=6; break;
                  default: DelObj(); return(-1); break;
                 }
              }
            CurrentBar=2; //считаем с третьего бара, чтобы фрактал "закрепился
            B1=-1; B2=-1; UpDown=0;
            while(((B1==-1) || (B2==-1)) && (CurrentBar<AB))
              {
               //UpDown=1 значит первый фрактал найден сверху, UpDown=-1 значит первый фрактал
               //найден снизу, UpDown=0 значит фрактал ещё не найден.
               //В1 и В2 - номера баров с фракталами, через них строим опорную линию.
               //Р1 и Р2 - соответственно цены через которые будем линию проводить
               if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF)))
                 {
                  if(UpDown==0) { UpDown=-1; B1=CurrentBar; P1=Low[B1]; }
                  else { B2=CurrentBar; P2=Low[B2];}
                 }
               if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF)))
                 {
                  if(UpDown==0) { UpDown=1; B1=CurrentBar; P1=High[B1]; }
                  else { B2=CurrentBar; P2=High[B2]; }
                 }
               CurrentBar++;
              }
            if((B1==-1) || (B2==-1)) {DelObj(); return(-1);} // Значит не нашли фракталов среди 300 баров 8-)
            Step=(P2-P1)/(B2-B1);//Вычислили шаг, если он положительный, то канал нисходящий
            P1=P1-B1*Step; B1=0;//переставляем цену и первый бар к нулю
            //А теперь опорную точку противоположной линии канала.
            ishift=0; iprice=0;
            if(UpDown==1)
              {
               PP=Low[2]-2*Step;
               for(i=3;i<=B2;i++)
                 {
                  if(Low[i]<PP+Step*i) { PP=Low[i]-i*Step; }
                 }
               if(Low[0]<PP) {ishift=0; iprice=PP;}
               if(Low[1]<PP+Step) {ishift=1; iprice=PP+Step;}
               if(High[0]>P1) {ishift=0; iprice=P1;}
               if(High[1]>P1+Step) {ishift=1; iprice=P1+Step;}
              }
            else
              {
               PP=High[2]-2*Step;
               for(i=3;i<=B2;i++)
                 {
                  if(High[i]>PP+Step*i) { PP=High[i]-i*Step;}
                 }
               if(Low[0]<P1) {ishift=0; iprice=P1;}
               if(Low[1]<P1+Step) {ishift=1; iprice=P1+Step;}
               if(High[0]>PP) {ishift=0; iprice=PP;}
               if(High[1]>PP+Step) {ishift=1; iprice=PP+Step;}
              }
            //Теперь переставим конечную цену и бар на АВ, чтобы линии канала рисовались подлиннее
            P2=P1+AB*Step;
            T1=Time[B1]; T2=Time[AB];
            //Если не было пересечения канала, то 0, иначе ставим псису.
            if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
            DelObj();
            ObjectCreate(TL1,OBJ_TREND,0,T2,PP+Step*AB,T1,PP);
            ObjectSet(TL1,OBJPROP_COLOR,LineColor);
            ObjectSet(TL1,OBJPROP_WIDTH,2);
            ObjectSet(TL1,OBJPROP_STYLE,STYLE_SOLID);
            ObjectCreate(TL2,OBJ_TREND,0,T2,P2,T1,P1);
            ObjectSet(TL2,OBJPROP_COLOR,LineColor);
            ObjectSet(TL2,OBJPROP_WIDTH,2);
            ObjectSet(TL2,OBJPROP_STYLE,STYLE_SOLID);
            ObjectCreate(MIDL,OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
            ObjectSet(MIDL,OBJPROP_COLOR,LineColor);
            ObjectSet(MIDL,OBJPROP_WIDTH,1);
            ObjectSet(MIDL,OBJPROP_STYLE,STYLE_DOT);
            Comment("\nChannel size = ", DoubleToStr(MathAbs(PP - P1)/Point,0), " Slope = ", DoubleToStr(-Step/Point, 2) + "\nSpread @ " +
            DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0) + CreateHL());
            //Comment(temp);
         //----
            //channel distance of last/current bar
            ExtMapBuffer2[0]=NormalizeDouble(MathAbs(PP - P1)/Point,0);
            //angle of channel
            ExtMapBuffer3[0]=NormalizeDouble(-Step/Point, 2);
         //----
            return(0);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         string CreateHL()
           {
            double HI2=iHigh(NULL,1440,0);
            double LOW2=iLow(NULL,1440,0);
            double HI3=iHigh(NULL,1440,1);
            double LOW3=iLow(NULL,1440,1);
            double HI4=iHigh(NULL,1440,0);
            double LOW4=iLow(NULL,1440,0);
            double HI5=iHigh(NULL,1440,2);
            double LOW5=iLow(NULL,1440,2);
            double HI6=iHigh(NULL,1440,3);
            double LOW6=iLow(NULL,1440,3);
            double HI7=iHigh(NULL,1440,4);
            double LOW7=iLow(NULL,1440,4);
            double HI8=iHigh(NULL,1440,5);
            double LOW8=iLow(NULL,1440,5);
            double HI9=iHigh(NULL,1440,6);
            double LOW9=iLow(NULL,1440,6);
            double HI10=iHigh(NULL,1440,7);
            double LOW10=iLow(NULL,1440,7);
            double HI11=iHigh(NULL,1440,8);
            double LOW11=iLow(NULL,1440,8);
            double HI12=iHigh(NULL,1440,9);
            double LOW12=iLow(NULL,1440,9);
            double HI13=iHigh(NULL,1440,10);
            double LOW13=iLow(NULL,1440,10);
            double HI14=iHigh(NULL,1440,11);
            double LOW14=iLow(NULL,1440,11);
            double HI15=iHigh(NULL,1440,12);
            double LOW15=iLow(NULL,1440,12);
            double HI16=iHigh(NULL,1440,13);
            double LOW16=iLow(NULL,1440,13);
            double HI17=iHigh(NULL,1440,14);
            double LOW17=iLow(NULL,1440,14);
            double HI18=iHigh(NULL,1440,15);
            double LOW18=iLow(NULL,1440,15);
            double HI19=iHigh(NULL,1440,16);
            double LOW19=iLow(NULL,1440,16);
            double HI20=iHigh(NULL,1440,17);
            double LOW20=iLow(NULL,1440,17);
            double HI21=iHigh(NULL,1440,18);
            double LOW21=iLow(NULL,1440,18);
            double HI22=iHigh(NULL,1440,19);
            double LOW22=iLow(NULL,1440,19);
            double HI23=iHigh(NULL,1440,20);
            double LOW23=iLow(NULL,1440,20);
            double OPEN=iOpen(NULL,1440,0);
            double CLOSE=iClose(NULL,1440,0);
            double ONE=(HI3-LOW3)/2;
            //----
            double FIVE=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8))/10;
            double TEN=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
                            (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13))/20;
            double TWENTY=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
                         (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13)+
                         (HI14-LOW14)+(HI15-LOW15)+(HI16-LOW16)+(HI17-LOW17)+(HI18-LOW18)+
                         (HI19-LOW19)+(HI20-LOW20)+(HI21-LOW21)+(HI22-LOW22)+(HI23-LOW23))/40;
            //----
            double AV=(FIVE+TEN+TWENTY)/3;// New SettingAV = (FIVE+TEN+TWENTY)/3;
            double AV2=((FIVE+TEN+TWENTY)/3) * MathPow(10, Digits);
            double HIDaily=iHigh(NULL,1440,0)-(AV);
            double LOWDaily=iLow(NULL,1440,0)+(AV);
            double HIDaily1=iHigh(NULL,1440,0);
            double LOWDaily1 =iLow(NULL,1440,0);
            double HIDaily2=iHigh(NULL,1440,0)-(AV)*2;
            double LOWDaily2 =iLow(NULL,1440,0)+(AV)*2;
            string PipsFromOpen;
//----
              if(Bid>=OPEN)
              {
               PipsFromOpen=DoubleToStr((Bid - OPEN)/Point, 0);
               }
                  else
               {
               PipsFromOpen= DoubleToStr(-(OPEN - Bid)/Point, 0);
              }
            string retVal="\nTODAYS RANGE: " + DoubleToStr((HI2-LOW2)/Point, 0) + "\n"+"AVG. Daily Average: " +
            DoubleToStr(AV2,0) + "\n" + "Open: "+  DoubleToStr(OPEN,Digits)+"\n"+ "Today\'s Hi: "+ DoubleToStr(HI2, Digits)
            +"  Low: "+ DoubleToStr(LOW2, Digits)+"\n"+ "Pips from Open: "+ PipsFromOpen+
            "\n"+"Top Daily Range: "+DoubleToStr(LOWDaily2, Digits)+"\n"+
            "Bottom Daily Range: "+ DoubleToStr(HIDaily2, Digits)+"\n";
//----
            return(retVal);
           }
//+------------------------------------------------------------------+

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