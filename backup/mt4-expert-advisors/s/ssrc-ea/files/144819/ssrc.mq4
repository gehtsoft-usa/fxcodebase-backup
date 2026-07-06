// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71812

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_maximum 1.3
#property indicator_minimum -1.3
#property indicator_level1 0.9
#property indicator_level2 -0.9
#property indicator_level3 0.75
#property indicator_level4 -0.75
#property indicator_level5 0
#property indicator_buffers 1
#property indicator_color1 Lime
//---- input parameters
//---- Snake 
extern int TotalBars=700;
extern int    SnakeRange   =14; 
extern int    FilterPeriod =21; 
extern double MartFiltr    =2;
extern int    PriceConst   =6; // 0 - Close
                               // 1 - Open
                               // 2 - High
                               // 3 - Low
                               // 4 - (H+L)/2
                               // 5 - (H+L+C)/3
                               // 6 - (H+L+2*C)/4
//---- buffers
double SRCBuffer[];
double Axis[];
double Mart[];
//---- SpearmanRankCorrelation
int    rangeN = 14; //   = 30 maximum
double R2[];
double multiply;
int    PriceInt[];
int    SortInt[];

//+------------------------------------------------------------------+
void MartAxis(int Pos) 
{ 
   int SnakeWeight,i,w,ww,Shift;
   double SnakeSum;
/*
   switch(PriceConst) 
   {
      case  0:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_CLOSE,Pos);    break;
      case  1:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_OPEN,Pos);     break;
      case  2:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_HIGH,Pos);     break;
      case  3:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_LOW,Pos);      break;
      case  4:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_MEDIAN,Pos);   break;
      case  5:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_TYPICAL,Pos);  break;
      case  6:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_WEIGHTED,Pos); break;
      default:  Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PRICE_WEIGHTED,Pos); 
   }
*/
   Axis[Pos]=iMA(NULL,0,SnakeRange+1,0,MODE_LWMA,PriceConst,Pos);

   for(Shift=Pos+SnakeRange+2;Shift>Pos;Shift--) 
   { 
      SnakeSum=0.0;
      SnakeWeight=0; 

      i=0; 
      w=Shift+SnakeRange; 
      while(w>=Shift) 
      { 
         i++; 
         SnakeSum+=i*SnakePrice(w); 
         SnakeWeight+=i; 
         w--; 
      }

      ww=Shift-SnakeRange;
      if(ww<Pos) ww=Pos;
      while(w>=ww) 
      { 
         i--; 
         SnakeSum+=i*SnakePrice(w);
         SnakeWeight+=i; 
         w--; 
      }
      Axis[Shift]=SnakeSum/SnakeWeight; 
   } 
   return; 
}

//----
double SnakePrice(int Shift) 
{
   switch(PriceConst) 
   {
      case  0: return(Close[Shift]);
      case  1: return(Open[Shift]);
      case  2: return(High[Shift]);
      case  3: return(Low[Shift]);
      case  4: return((High[Shift]+Low[Shift])/2);
      case  5: return((Close[Shift]+High[Shift]+Low[Shift])/3);
      case  6: return((2*Close[Shift]+High[Shift]+Low[Shift])/4);
      default: return(Close[Shift]); 
   } 
}

//+------------------------------------------------------------------+
void SmoothOverMart(int Shift) 
{ 
   double t,b;
   t=Axis[ArrayMaximum(Axis,FilterPeriod,Shift)];
   b=Axis[ArrayMinimum(Axis,FilterPeriod,Shift)];
   Mart[Shift]=(2*(2+MartFiltr)*Axis[Shift]-(t+b))/2/(1+MartFiltr);
   return; 
}

//+------------------------------------------------------------------+
double SpearmanRankCorrelation(double Ranks[], int N) 
{ 
   double res,z2;
   for(int i=0;i<N;i++) 
   { 
      z2 += MathPow(Ranks[i] - i - 1, 2); 
   }
   res=1-6*z2/(MathPow(N,3)-N); 
   return(res); 
}

//+------------------------------------------------------------------+
void RankPrices(int InitialArray[]) 
{ 
   double dcounter, averageRank;
   int i, k, m, dublicat, counter, etalon; 
   double TrueRanks[];

   ArrayResize(TrueRanks, rangeN); 
   ArrayCopy(SortInt, InitialArray);
   for(i=0;i<rangeN;i++) TrueRanks[i]=i+1; 

   ArraySort(SortInt, 0, 0, MODE_DESCEND);
   for(i=0;i<rangeN-1;i++) 
   { 
      if(SortInt[i]!=SortInt[i+1]) continue;
      dublicat=SortInt[i]; 
      k=i+1; 
      counter=1; 
      averageRank=i+1;
      while(k<rangeN) 
      { 
         if(SortInt[k]==dublicat) 
         {
            counter++; 
            averageRank+=k+1; 
            k++; 
         } else break; 
      }
      dcounter=counter; 
      averageRank=averageRank/dcounter;
      for(m=i;m<k;m++) TrueRanks[m]=averageRank; i=k; 
   }
   for(i=0;i<rangeN;i++) 
   { 
      etalon=InitialArray[i]; 
      k=0;
      while(k<rangeN) 
      { 
         if(etalon==SortInt[k]) 
         { 
            R2[i]=TrueRanks[k]; 
            break; 
         } 
         k++; 
      } 
   } 
   return; 
}

//+------------------------------------------------------------------+
int init() 
{
   IndicatorBuffers(3);
   
   SetIndexBuffer(0,SRCBuffer); 
   SetIndexStyle(0,DRAW_LINE);
   
   SetIndexBuffer(1,Axis); 
   SetIndexStyle(1,DRAW_NONE);
   
   SetIndexBuffer(2,Mart); 
   SetIndexStyle(2,DRAW_NONE);
   
   ArrayResize(R2,rangeN);
   ArrayResize(PriceInt,rangeN);
   ArrayResize(SortInt,rangeN);

   if(rangeN>30) 
      IndicatorShortName("Decrease rangeN input!");
   else 
      IndicatorShortName("SSRC( SR:"+SnakeRange+", FP:"+FilterPeriod+" )");
   multiply=MathPow(10,Digits); 
   return(0); 
}

//+------------------------------------------------------------------+
int deinit() 
{ 
   return(0); 
}

//+------------------------------------------------------------------+
int start() 
{ 
   int i,k,limit,limit2,limit3;
   int counted_bars=TotalBars; 
   if(rangeN>30) return(-1);
   if(counted_bars==0) {
      limit=TotalBars-(rangeN+FilterPeriod+SnakeRange+4);
      limit2=TotalBars-(SnakeRange+2);
      limit3=TotalBars-(FilterPeriod+SnakeRange+3); 
   }
   if(counted_bars>0) { 
      limit=TotalBars+1; //-counted_bars
      limit2=limit; 
      limit3=limit; 
   }
   for(i=limit2;i>=0;i--) MartAxis(i);
   for(i=limit3;i>=0;i--) SmoothOverMart(i);
   for(i=limit;i>=0;i--) 
   { 
      for(k=0;k<rangeN;k++) PriceInt[k]=Mart[i+k]*multiply;
      RankPrices(PriceInt); 
      SRCBuffer[i]=SpearmanRankCorrelation(R2,rangeN);
      if(SRCBuffer[i]>1.0) SRCBuffer[i]=1.0; 
      if(SRCBuffer[i]<-1.0) SRCBuffer[i]=-1.0; 
   } 
   return(0); 
}

//+------------------------------------------------------------------+

