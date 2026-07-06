//+------------------------------------------------------------------+
//|                                    Spearman_Rank_Correlation.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue 
#property indicator_width1  2
 

//--- input parameters

extern int  Range=14; 
extern bool direction = true;

double IntPrice[];
double Spearman[];
double RealRank[];
double PriceTable1[];
double PriceTable2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
    IndicatorShortName("SPEARMAN");
    IndicatorDigits(Digits);
	
	ArrayResize(RealRank, Range);
    ArrayResize(PriceTable1, Range);
	ArrayResize(PriceTable2, Range);	   

   IndicatorBuffers(1);
   
    SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Spearman); 
    
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
	  int i,                           // Bar index
		   Counted_bars;                // Amount of calculated bars 
	 
	   Counted_bars=IndicatorCounted(); // Amount of calculated bars 
	   i=Bars-Counted_bars-1;           // Index of the first uncounted
	   double PipSize= MarketInfo(Symbol(),MODE_TICKSIZE);
 
	  
	  
	   i=Bars-Counted_bars-1;
	  
	  int k;
	  
	   while(i>=0)                    
      {    
	      for(k = 0; k < Range; k++)
          {		  
          PriceTable1[k] =Close[i+k]/PipSize;
		  PriceTable2[k] =Close[i+k]/PipSize;
		  } 
	   RankPrices(i);
       Spearman[i]=Calculate (i);	   
      i--;
	  }
	   
	   
	   
	
 
   return(0);
  }
//+------------------------------------------------------------------+

double Calculate (int j)
{
  double rankSum=0;
    for (j=0;j < Range;j++)
	{
     rankSum=rankSum+MathPow(RealRank[j]-j-1,2);
    }
    return (1-6*rankSum/(MathPow(Range,3)-Range));
}	

void RankPrices(int i)
  {
  
  int j;
  

	double TrueRanks[];

	   ArrayResize(TrueRanks, Range);


  if(direction)
       ArraySort(PriceTable1, 0, 0, MODE_DESCEND);
   else
       ArraySort(PriceTable1, 0, 0, MODE_ASCEND);
	   
   
    double duplicate;
    int k;
    int m;
    int counter;
    double master;
    int duplicateCounter;
    double averageRank;
	
	 for (j=0;j  < Range;j++ )
	 {
     TrueRanks[j]=j+1;
     RealRank[j]=0;
     }
		
	for (j=0;j < Range-1;j++)
	{   
     if (PriceTable1[j] != PriceTable1[j+1] )
	  continue;
      duplicate=PriceTable1[j];
      k=j+1;
      counter=1;
      averageRank=j+1;
      while (k<=Range)
	  {
		   if (PriceTable1[k]==duplicate) 
		   {
			counter=counter+1;
			averageRank=averageRank+k+1;
			k=k+1;
		   }
		   else
		   break;
		  
		   
      }
      duplicateCounter=counter;
      averageRank=averageRank/duplicateCounter;
      for (m=j;m<k; m++)
	  {
       TrueRanks[m]=averageRank;
      }
      j=k;
     
    }
	
    for ( j=0;j< Range; j++)
	{
	master=PriceTable2[j];
     k=0;
     while (k<=Range) 
	 {
      if (master==PriceTable1[k]) 
	  {
       RealRank[j]=TrueRanks[k];
       break;
      }
      k=k+1;
     }
    
	}
 

//----
   return;
  }