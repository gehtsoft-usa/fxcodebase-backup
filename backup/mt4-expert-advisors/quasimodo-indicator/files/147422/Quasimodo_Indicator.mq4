//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

bool LONG,SHORT;
int buys,sells;
bool trade;
extern color color_long = clrLimeGreen;
extern color color_short = clrDarkOrange;
extern int line_width = 2;
extern int arrow_size = 3;
extern int arrow_code_up = 233;



int      size=0;
double   fractal[];
int      fractal_candle[10000];
int      fractal_dir[10000];
   
string cmt;
string id="quazi";
   
datetime time;
datetime alert_time;

void init(){

   //EventSetTimer(1);
   time=0;
   
   Comment("");
   return;
}
void deinit(){
   Comment("");
   remove_objects();
   time=0;
   return;
}

void remove_objects()
{
   string name;
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      name=ObjectName(0,i);
      if(StringFind(name,id)>=0)ObjectDelete(0,name);
   }
   
   return;
}


//void OnTimer()
//  {
//   checkTrade();
//  }
  
void start()
{
   if(Time[0]!=time)
   { 
      buys=0;
      sells=0;
      check_fractals2();
      
      for(int s=0;s<ArraySize(fractal)-6;s++)
      {
         check_long_short(s);
      }
      time=Time[0];
   }
   return;
}
  
//+------------------------------------------------------------------+

int check_long_short(int shift)
{
    
      LONG=FALSE;
      SHORT=FALSE;
      bool up=false;
      bool dn=false;
      
      up=  
      (
      fractal_dir[shift]==-1 && 
      fractal_dir[shift+1]==1 && 
      fractal_dir[shift+2]==-1 &&
      fractal_dir[shift+3]==1 &&
      fractal_dir[shift+4]==-1 &&
      
      fractal[shift]<fractal[shift+1] &&
      fractal[shift]>fractal[shift+2] &&
      fractal[shift]<fractal[shift+3] &&
      fractal[shift]>fractal[shift+4] &&
      
      fractal[shift+1]>fractal[shift+2] &&
      fractal[shift+1]>fractal[shift+3] &&
      fractal[shift+1]>fractal[shift+4]);
      
     
      dn=
      (  
      fractal_dir[shift]==1 && 
      fractal_dir[shift+1]==-1 && 
      fractal_dir[shift+2]==1 &&
      fractal_dir[shift+3]==-1 &&
      fractal_dir[shift+4]==1 &&
      
      fractal[shift]>fractal[shift+1] &&
      fractal[shift]<fractal[shift+2] &&
      fractal[shift]>fractal[shift+3] &&
      fractal[shift]<fractal[shift+4] &&
      
      fractal[shift+1]<fractal[shift+2] &&
      fractal[shift+1]<fractal[shift+3] &&
      fractal[shift+1]<fractal[shift+4]);
        
      color c;
      int style;
      if(up){c=color_long;}
      else
      if(dn){c=color_short;}
      else
      c=clrBlue; 
      
      if(up)buys++;
      if(dn)sells++;
      //Comment("longs "+buys+"  shorts "+sells);
      
      
      if(up || dn)
      for(int t=shift;t<shift+4;t++)
      {
         make_trend(IntegerToString(Time[fractal_candle[t]]),
         Time[fractal_candle[t]],
         fractal[t],
         Time[fractal_candle[t+1]],
         fractal[t+1],
         c,line_width,style);
          
      }
      
      if(up)
      {
          make_arrow(
            "BUY "+IntegerToString(Time[fractal_candle[shift]]),
            1,
            fractal[shift],
            Time[fractal_candle[shift]],arrow_size,arrow_code_up,color_long
         );
         
         if(Time[0]!=alert_time && fractal_candle[shift]<3)
         {
            LONG=TRUE;
            
            Alert(ChartSymbol()+"  LONG CANDLE "+fractal_candle[shift]+"  Period() "+Period()+"  Time "+Time[shift]+"  TRADE LONG NOW");
            PlaySound("alert");
            alert_time=Time[0];
         }
      }
           
      if(dn)
      {
         make_arrow(
            "SELL "+IntegerToString(Time[fractal_candle[shift]]),
            -1,
            fractal[shift],
            Time[fractal_candle[shift]],arrow_size,arrow_code_up,color_short
         );
        
         if(Time[0]!=alert_time && fractal_candle[shift]<3)
         {
            SHORT=TRUE;
            
            Alert(ChartSymbol()+"  SHORT CANDLE "+fractal_candle[shift]+"  Period() "+Period()+"  Time "+Time[shift]+"  TRADE SHORT NOW");
            PlaySound("alert");
            alert_time=Time[0];
         }
      }
         
      return(0);
      
}
    
void check_fractals2()
{
   size=0;
   
   //for(int f=0;f<(Bars-6)-IndicatorCounted();f++)
   for(int f=0;f<Bars-6;f++)
   {
      if(iFractals(ChartSymbol(),0,MODE_UPPER,f)!=0)
      {
         size++;
         
         ArrayResize(fractal,size);
         fractal[size-1]=iFractals(ChartSymbol(),0,MODE_UPPER,f);
         fractal_candle[size-1]=f;
         fractal_dir[size-1]=1;
         //make_arrow("fract "+f,1,fractal[size-1],Time[f],4,clrMagenta);
      }

      if(iFractals(ChartSymbol(),0,MODE_LOWER,f)!=0)
      {
      
         size++;
         
         ArrayResize(fractal,size);
         fractal[size-1]=iFractals(ChartSymbol(),0,MODE_LOWER,f);
         fractal_candle[size-1]=f;
         fractal_dir[size-1]=-1;
         //make_arrow("fract "+f,-1,fractal[size-1],Time[f],4,clrMagenta);
      }
   }
   
   return;
}

void make_hline(string name,int t1,double p1,color c,int width, int style)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_HLINE,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSetText(name,name);
   ObjectMove(name,0,t1,p1);
   return;
}

void make_text(string name,string text,double p1,color c, datetime t1,double angle, int size)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_TEXT,0,0,0);
   ObjectSetText(name,text,size,"",c);
   ObjectSet(name,OBJPROP_ANGLE,angle);
   ObjectMove(0,name,0,t1,p1);
   return;
}


void make_vline(string name,int t1,double p1,color c,int width, int style)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_VLINE,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectMove(name,0,t1,p1);
   return;
}


void make_trend(string name, int t1, double p1, int t2, double p2,color c, int w, int s)
{
   name=id+name;
   ObjectCreate(name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectMove(name,0,t2,p2);
   ObjectMove(name,1,t1,p1);
   ObjectSet(name,OBJPROP_RAY,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,w);
   ObjectSet(name,OBJPROP_STYLE,s);
   ObjectSetText(name,name);

   return;
}

void make_label(string name,int x,int y,color c,string text,string font_type, int font_size,int cnr)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_CORNER,cnr);
   ObjectSetText(name,text,font_size,font_type,c);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   return;
}


void make_arrow(string name,int dir, double p1, datetime t1,int size, int code, color c)
{
   int ac;
   int object_type=-1;
   if(dir>0)ac=code;
   if(dir<0)ac=code+1;
   
   if(dir>0)object_type=OBJ_ARROW_UP;
   if(dir<0)object_type=OBJ_ARROW_DOWN;
   
   name=id+name;
      ObjectCreate(0,name,object_type,0,0,0);
      ObjectSet(name,OBJPROP_ARROWCODE,ac);
      if(dir<0)ObjectSet(name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(name,OBJPROP_COLOR,c);
      ObjectSet(name,OBJPROP_WIDTH,size);
      ObjectMove(0,name,0,t1,p1);
      
   return;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+