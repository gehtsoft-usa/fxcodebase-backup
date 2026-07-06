//+------------------------------------------------------------------+
//|                                                 PMF.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int ExtOBVAppliedPrice=0;
extern bool  Cumulative = true;           


double PMF[];


int init()
  {
   IndicatorShortName("PMF");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,PMF);
   
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {
   int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
	
   for(int i=limit; i>=0; i--)
   {
   
      PMF[i]=0;
 
	 double Current=GetAppliedPrice(ExtOBVAppliedPrice, i);
	 double Previous=GetAppliedPrice(ExtOBVAppliedPrice, i+1);
	 double	 PreviousPrevious= GetAppliedPrice(ExtOBVAppliedPrice, i+2);
	 
     double DiffCurrent = (Current-Previous) * Volume[i];	 
	 double DiffPrevious = (Previous-PreviousPrevious) * Volume[i+1];
	 
	 
	 if (Cumulative == true ) 
	 {
	 PMF[i]= PMF[i+1] +	DiffCurrent;
	 }
	 else
	 {
	 PMF[i]= DiffCurrent + DiffPrevious;
	 }
	  
  } 
 

 return(0);
}


double GetAppliedPrice(int nAppliedPrice, int nIndex)
  {
   double dPrice;
//----
   switch(nAppliedPrice)
     {
      case 0:  dPrice=Close[nIndex];                                  break;
      case 1:  dPrice=Open[nIndex];                                   break;
      case 2:  dPrice=High[nIndex];                                   break;
      case 3:  dPrice=Low[nIndex];                                    break;
      case 4:  dPrice=(High[nIndex]+Low[nIndex])/2.0;                 break;
      case 5:  dPrice=(High[nIndex]+Low[nIndex]+Close[nIndex])/3.0;   break;
      case 6:  dPrice=(High[nIndex]+Low[nIndex]+2*Close[nIndex])/4.0; break;
      default: dPrice=0.0;
     }
//----
   return(dPrice);
  }
//+------------------------------------------------------------------+
