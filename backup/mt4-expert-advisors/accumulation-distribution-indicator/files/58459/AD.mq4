//+------------------------------------------------------------------+
//|                                                           AD.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green


extern int Method=1;
double Current[];
double AD[];


int init()
  {
  
    IndicatorBuffers(2);
   IndicatorShortName("AD");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AD);
   SetIndexStyle(1,DRAW_NONE);
    SetIndexBuffer(1,Current);
		 
	
	  
	   if(Method!= 1 && Method!= 2 && Method!= 3  )  Alert("Permitted methods are 1, 2 or 3");
   
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
    
      if(Method == 1)  Comment("Classical");
	  if(Method == 2) Comment("Classical Incremental");
	  if(Method == 3)  Comment("Trade Station Incremental ");
	
   for(int i=limit; i>=0; i--)
   {
   
   
		   if  (Method == 1 ||  Method == 2)  
		   {
		   
				 if  ( (High[i] - Low[i]) == 0   )  
				 {
				 Current[i] =0;
				 }else
				 {
				 Current[i]=(((Close[i] - Low[i]) - (High[i] - Close[i])) / (High[i] - Low[i])) * Volume[i];
				 }	 
		  
		   } else 
		   {
		   
						  if  (Method == 3)  
						  {
						   if  ( (High[i] - Low[i]) == 0   )  
							 {
							 Current[i] =0;
							 }else
							 {
							  Current[i]=((Close[i] - Open[i]) / (High[i] - Low[i])) * Volume[i];
							} 
						  }
						  else
						  {
						   Current[i] =0;
						  }
		   }
  
 
		 
		
	  
  } 
  
   for(int j=limit-1; j>=0; j--)
   {
          if  (Method == 2 ||  Method == 3)  
		   {
			AD[j] = AD[j+1]+Current[j];
		   }else
		   {
		       if  (Method == 1)
			   {
			   AD[j] = Current[j];
			   }
			   else
			   {
			     AD[j] = 0;
			   }
			    
		   }
 
 }

 return(0);
}

