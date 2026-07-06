//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Silver

 

extern bool DMI=true;
extern bool ADX=true;
extern bool CCI=true;
extern bool MACD=true;
extern bool STOHASTIC=true;

extern int My_ADX_Period=14;
extern double ADX_Entry = 20;
extern double ADX_Exit = 40;
extern int My_DMI_Period=14;

extern int CCI_Period=14;
extern double CCI_Buy= 0;
extern double CCI_Sell= 0;

extern int MACD_Short= 12 ;
extern int MACD_Long= 26 ;
extern int MACD_Signal= 26 ;
extern double MACD_Buy = 0;
extern double MACD_Sell= 0;

extern int Stochastic_K = 5;
extern int Stochastic_SD=  3;
extern int Stochastic_D=  3;
extern double Stochastic_OB=  80;
extern double Stochastic_OS=  20; 
   
double UP[], DOWN[], NEUTRAL[];
 

int init()
{
 IndicatorShortName("Consensus of Five");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DOWN);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,NEUTRAL);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 
 double My_ADX;
 double My_DMI_Minus;
 double My_DMI_Plus;
 double My_CCI;
 double My_MACD;
 double My_Stochastic_K;
 double My_Stochastic_D;
 pos=limit;
 
  
 
    int ONE=0;
	int TWO=0;
	int THREE_B=0;
	int THREE_S=0;
	int FOUR_B=0;
	int FOUR_S=0;
	int FIVE_B=0;	
	int FIVE_S=0;	
	
 while(pos>=0)
 {
       
	    
 
      ONE=0;
	  TWO=0;
	  THREE_B=0;
	  THREE_S=0;
	  FOUR_B=0;
	  FOUR_S=0;
	  FIVE_B=0;	
	  FIVE_S=0;	
	
 
        if (DMI)
        {    
		
		     My_DMI_Minus  = iADX(NULL,0,My_DMI_Period,PRICE_CLOSE,MODE_MINUSDI ,pos);  
			 My_DMI_Plus   = iADX(NULL,0,My_DMI_Period,PRICE_CLOSE,MODE_PLUSDI ,pos);  			            			  
   
		   if (My_DMI_Plus > My_DMI_Minus )
			{
			ONE = 1;
			}
			else
			{
			ONE = -1;
			} 
			
		}		
		
		if (ADX)
		{
		     My_ADX  = iADX(NULL,0,My_ADX_Period,PRICE_CLOSE,MODE_MAIN,pos);  
			 
			if (My_ADX >  ADX_Entry
		   && My_ADX <  ADX_Exit )
            {
			TWO = 1;
			}
			else
			{
			TWO = -1;
			}  
		}
		


		if (CCI) 
		{		
		 My_CCI =iCCI(NULL,0,CCI_Period,PRICE_CLOSE,pos);
		 
		  
		   if (My_CCI >   CCI_Buy )
		   {
			THREE_B = 1;
			}
			else
			{
			THREE_B = -1;
			}
			
			if (My_CCI <   CCI_Sell  )
			{
			THREE_S = -1;
			}
			else
			{
			THREE_S = 1;
			} 

		
		}
		
		if (MACD)
		{
		        My_MACD= iMACD(NULL,0,MACD_Short,MACD_Long,MACD_Signal,PRICE_CLOSE,MODE_MAIN,pos);
		
		 if( My_MACD >  MACD_Buy  )
		 {		 
			FOUR_B  = 1;
		 }	
			else
		{	
			FOUR_B = -1;
		} 
			
			
			if (My_MACD <   MACD_Sell )
			{
			FOUR_S  = -1;
			}
			else
			{
			FOUR_S = 1;
			} 
			
		}
	 
		
 		if (STOHASTIC )  
		{
		
		My_Stochastic_K =iStochastic(NULL,0,Stochastic_K,Stochastic_SD,Stochastic_D,MODE_SMA,0,MODE_MAIN,pos);
		My_Stochastic_D =iStochastic(NULL,0,Stochastic_K,Stochastic_SD,Stochastic_D,MODE_SMA,0,MODE_SIGNAL,pos);
		
		 if  (My_Stochastic_K > My_Stochastic_D
			&& My_Stochastic_D < Stochastic_OB )
		{
			FIVE_B  = 1;
		}	
			else
		{	
			FIVE_B = -1;
		}
			
			if  (My_Stochastic_K < My_Stochastic_D
			&& My_Stochastic_D > Stochastic_OS ) 
			{
			FIVE_S  = -1;
			}
			else
			{
			FIVE_S = 1;
			} 
			
			
		}
		  

 
 
 
       Set(0,pos);
 
       if ( ONE == 0  
	   &&  TWO == 0 
	   && THREE_B == 0 
	   && THREE_S == 0
	   && FOUR_B== 0 
	   && FOUR_S== 0 
	   && FIVE_B== 0 
	   && FIVE_S== 0 )
	   {
		 Set(0,pos);
       }
	   
		 if ((ONE == 1 ||  ONE == 0)  
		&& (TWO  == 1  ||  TWO == 0)  
		&& (THREE_B  == 1  ||  THREE_B == 0) 
		&& (FOUR_B == 1   ||  FOUR_B == 0)  
		&& (FIVE_B == 1   ||  FIVE_B == 0) )
		{ 		
		 Set(1,pos); 
		}
		 
        if((ONE == -1 ||  ONE == 0) 
		&&  (TWO == 1 ||  TWO == 0) 
		&& (THREE_S == -1 ||  THREE_S == 0)   
		&& (FOUR_S == -1 ||  FOUR_S == 0)  
		&& (FIVE_S  == -1 ||  FIVE_S == 0))  
		{
		 Set(-1,pos); 
		}
		 
   pos=pos-1;
 
 } 
  
  
 return(0);
}


int Set(int x, int p)
{
	if (x==1)
	{
	UP[p]=1;
	DOWN[p]=0;
	NEUTRAL[p]=0;
	}
	
	if (x==-1)
	{
	DOWN[p]=1;
	NEUTRAL[p]=0;
	UP[p]=0;
	}
	
	if (x==0)
	{
	NEUTRAL[p]=1;
	DOWN[p]=0;
	UP[p]=0;
	}
	
	return (0);

}