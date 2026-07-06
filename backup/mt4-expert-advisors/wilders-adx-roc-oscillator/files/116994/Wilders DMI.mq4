// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65625

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property indicator_separate_window
#property  indicator_buffers   3
#property indicator_minimum    0
#property indicator_color1     DeepSkyBlue
#property indicator_color2     OrangeRed
#property indicator_color3     Gray
#property indicator_width3     2
#property indicator_levelcolor Gray

//
//
//
//
//


extern string TimeFrame     = "Current time frame";
extern int    AdxPeriod     = 13;
extern double Level         = 21.0;
extern bool   Show_Dmi_Only = false; 

//
//
//
//
//

double DIp[];
double DIm[];
double ADX[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int init()
{
   SetIndexBuffer(0,DIp);    SetIndexLabel(0,"DI+");
   SetIndexBuffer(1,DIm);    SetIndexLabel(1,"DI-");
   SetIndexBuffer(2,ADX);    SetIndexLabel(2,"ADX");
   SetLevelValue(0,Level);
   
   if (Show_Dmi_Only)
   {
     SetIndexStyle(2,DRAW_NONE); 
   }
   else
   {
     SetIndexStyle(2,DRAW_LINE);
   }
   
       //
       //
       //
       //
       //
     
        for (int i=0;i<8;i++) SetIndexEmptyValue(i,0.00);
        indicatorFileName = WindowExpertName();
        calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
        returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
        timeFrame         = stringToTimeFrame(TimeFrame); 
        
      //
      //
      //
      //
      //  
      
   
   IndicatorShortName(timeFrameToString(timeFrame)+" Wilder\'s Adx ("+AdxPeriod+")");
return(0);
}

int deinit() { return(0);}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double work[][3];
#define _DIp 0
#define _DIm 1
#define _TR  2

int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-2);
           if (returnBars) { DIp[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {
      if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
      double sf = (AdxPeriod-1.0)/AdxPeriod;
      for (i=limit, r=Bars-i-1;i>=0;i--,r++)
      {
         double currTR  = MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]);
         double DeltaHi = High[i]  - High[i+1];
         double DeltaLo = Low[i+1] - Low[i];
         double plusDM  = 0.00;
         double minusDM = 0.00;
         
            if ((DeltaHi > DeltaLo) && (DeltaHi > 0)) plusDM  = DeltaHi;
            if ((DeltaLo > DeltaHi) && (DeltaLo > 0)) minusDM = DeltaLo;      
         
         //
         //
         //
         //
         //
         
            work[r][_DIp] = sf*work[r-1][_DIp] + plusDM;
            work[r][_DIm] = sf*work[r-1][_DIm] + minusDM;
            work[r][_TR]  = sf*work[r-1][_TR]  + currTR;

         //
         //
         //
         //
         //
                  
            DIp[i] = 0.00;                   
            DIm[i] = 0.00;                   
            if (work[r][_TR] > 0)             
            {              
               DIp[i] = 100.00 * work[r][_DIp]/work[r][_TR];
               DIm[i] = 100.00 * work[r][_DIm]/work[r][_TR];
            }            
              double DX;
              if((DIp[i] + DIm[i])>0) 
                   DX  = 100*MathAbs(DIp[i] - DIm[i])/(DIp[i] + DIm[i]); 
              else DX  = 0.00;
              ADX[i]   = sf*ADX[i+1] + DX/AdxPeriod; 
        }
   return(0);
   } 
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         DIp[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AdxPeriod,0,y);
         DIm[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AdxPeriod,1,y);
         ADX[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AdxPeriod,2,y);       
   }
return(0);
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}