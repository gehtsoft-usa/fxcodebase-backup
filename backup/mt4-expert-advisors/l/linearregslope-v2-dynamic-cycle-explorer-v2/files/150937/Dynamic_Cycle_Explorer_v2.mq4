//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73755

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

#property indicator_separate_window
#property indicator_buffers 3


#property indicator_color1  clrLimeGreen
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrPaleVioletRed


#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  3


extern int                 Period1        = 44; //44;
extern int                 Period2        = 22; //22;
extern int                 Period3        = 66; //66;
extern int                 Period4        = 33; //33;
extern int                 Period5        = 29; //29;
extern int                 Period6        = 14; //14;


extern ENUM_APPLIED_PRICE  Price          = PRICE_CLOSE;
extern ENUM_MA_METHOD      Signal_Method  = MODE_SMA; 
extern ENUM_BASE_CORNER    Corner         = CORNER_RIGHT_LOWER;
extern string              fontType       = "Arial";
extern int                 fontSize       = 10;
extern color               textColor      = clrSilver;
extern string              CommentID      = "CycleExplorer";


//
//
//
//




double Map[];
double MapDa[];
double MapDb[];
double prc[];
double slope[];

int    maxPeriod;
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
  {
   IndicatorBuffers(5);
   SetIndexBuffer(0,Map);
   SetIndexBuffer(1,MapDa);
   SetIndexBuffer(2,MapDb);
   SetIndexBuffer(3,prc);
   SetIndexBuffer(4,slope);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);

   IndicatorShortName("DCE"+Period1+","+Period2);
   maxPeriod = MathMax(Period1,Period2);
   maxPeriod = MathMax(Period3,maxPeriod);
   maxPeriod = MathMax(Period4,maxPeriod);
   maxPeriod = MathMax(Period5,maxPeriod);
   maxPeriod = MathMax(Period6, maxPeriod);

   SetLevelValue(0, 0);   
   SetLevelStyle(STYLE_SOLID, 1, DimGray);
   
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete(CommentID);
   return(0);
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
  {
   int i,counted_bars=IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
     int limit=MathMin(Bars-counted_bars,Bars-1);

//
//
//
//
//

   if(slope[limit]==1) CleanPoint(limit,MapDa,MapDb);
   for(i=limit; i>=0; i--) prc[i] = iMA(NULL,0,1,0,Signal_Method,Price,i);
   for(i=limit; i>=0; i--)
     {
      Map[i]   = iTma(prc[i],Period2,i,0)-iTma(prc[i],Period1,i,1)+iTma(prc[i],Period4,i,2)-iTma(prc[i],Period3,i,3)+iTma(prc[i],Period6,i,4)-iTma(prc[i],Period5,i,5);
      //Map[i]   = icTma(Period2,i)-icTma(Period1,i)                +icTma(Period4,i)        -icTma(Period3,i)        +icTma(Period6,i)        -icTma(Period5,i);
      MapDa[i] = EMPTY_VALUE;
      MapDb[i] = EMPTY_VALUE;
      slope[i] = slope[i+1];

      if(Map[i]>Map[i+1]) slope[i] = 1;
      if(Map[i]<Map[i+1]) slope[i] =-1;
      if (slope[i] == -1) PlotPoint(i, MapDa, MapDb, Map);

      
      int bars = 500;
      double max = Map[ArrayMaximum(Map, bars, 0)];
      SetLevelValue(1, max);
      SetLevelValue(2, -max);
   }

//
//
//
//
//

   for(i=0; i<Bars-1; i++) if(slope[i]!=slope[i+1]) break; SetComment("Slope Changed: "+(i+1)+" Bar Back",textColor);
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double workTma[][6];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArraySize(workTma)!= Bars) ArrayResize(workTma,Bars); r=Bars-r-1;
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double &first[],double &second[])
  {
   if((second[i]  != EMPTY_VALUE) &&(second[i+1] != EMPTY_VALUE))
      second[i+1]= EMPTY_VALUE;
   else
   if((first[i] != EMPTY_VALUE) &&(first[i+1] != EMPTY_VALUE) &&(first[i+2]== EMPTY_VALUE))
                  first[i+1]= EMPTY_VALUE;
  }
//
//
//
//
//

void PlotPoint(int i,double &first[],double &second[],double &from[])
  {
   if(first[i+1]==EMPTY_VALUE)
     {
      if(first[i+2]==EMPTY_VALUE) 
        {
         first[i]   = from[i];
         first[i+1] = from[i+1];
         second[i]  = EMPTY_VALUE;
        }
      else 
        {
         second[i]   =  from[i];
         second[i+1] =  from[i+1];
         first[i]    = EMPTY_VALUE;
        }
     }
   else
     {
      first[i]  = from[i];
      second[i] = EMPTY_VALUE;
     }
  }
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void SetComment(string value,color clr)
  {
   string name=CommentID;
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,Corner);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_XDISTANCE,15);
   ObjectSet(name,OBJPROP_YDISTANCE,15);
   ObjectSetText(name,value,fontSize,fontType);

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