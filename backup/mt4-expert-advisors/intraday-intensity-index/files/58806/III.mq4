//+------------------------------------------------------------------+
//|                                                           III.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green


extern bool Normalized=true;
extern int IIIPeriod=21;
double Raw[];
double III[];


int init()
  {
  
   IndicatorBuffers(2);
   IndicatorShortName("III");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,III);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Raw);
		 
	
	 
   
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
   
   
		  
				 if  ( (High[i] - Low[i]) == 0   )  
				 {
				 Raw[i] =0;
				 }else
				 {
				 Raw[i]= ((2*Close[i]-High[i]-Low[i])/(High[i]-Low[i]))*Volume[i];
				 }	 
		  
	  
  } 
  
  double VolSum;
  double IIISum;
 
   for(int j=limit-IIIPeriod; j>=0; j--)
   {
        
		     IIISum = ArraySum(Raw, j);
		 
		 
			 if ( Normalized == true ) 
			 {
			 III[j]= IIISum;
			 } else			
			 {
			  VolSum = ArraySum(Volume, j);
			 III[j]= (IIISum/VolSum)*100;
			 }
		
		
		
 
 }

 return(0);
}

double ArraySum(double array[], int i)
{
   double summation=0;
   
   //iArray = ArraySize(array) - 1
   
   for (int iArray = IIIPeriod; iArray >= 0; iArray--) 
   {
   summation += array[iArray+i];
   }
   
   return (summation);
}
