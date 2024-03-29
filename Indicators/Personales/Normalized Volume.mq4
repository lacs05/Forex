//+------------------------------------------------------------------+
//|                                             NormalizedVolume.mq4 |
//|                         Copyright © Vadim Shumilov (DrShumiloff) |
//|                                                shumiloff@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Vadim Shumilov (DrShumiloff)"
#property link      "shumiloff@mail.ru"
//----
#property indicator_separate_window

#property  indicator_buffers 4
#property  indicator_color1  Red
#property  indicator_color2  Green

extern int VolumePeriod=9;
double Level=1.0;

#property indicator_level1 1.0
#property indicator_levelwidth 1
//#property indicator_levelstyle 1

double VolBufferLow[];
double VolBufferHigh[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

   IndicatorBuffers(2);

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,VolBufferLow);
   SetIndexDrawBegin(0,VolumePeriod);

   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,VolBufferHigh);
   SetIndexDrawBegin(1,VolumePeriod)

//SetIndexStyle(0,DRAW_LINE);

   ;

   short_name="Normalized Volume("+(string)VolumePeriod+")";
   IndicatorShortName(short_name);
//SetIndexLabel(0,short_name);
//SetIndexLabel(1, 

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();

   if(counted_bars<1)
      for(int i=1; i<=VolumePeriod; i++)
         VolBufferLow[Bars-i]=0.0;
         VolBufferHigh[Bars-i]=0.0;
   int limit=Bars-counted_bars;
   if(counted_bars>0)
      limit++;
   else
      limit-=VolumePeriod;

   for(i=0; i<limit; i++)
     {
      double normalizedLevel=NormalizedVolume(i);
      if(normalizedLevel>Level)
        {
         VolBufferHigh[i]=normalizedLevel;
        }
      else if(normalizedLevel<=Level)
        {
         VolBufferLow[i]=normalizedLevel;
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizedVolume(int i)
  {
   double nv=0;

   for(int j=i; j<(i+VolumePeriod); j++)
      nv=nv+Volume[j];
   nv=nv/VolumePeriod;
   return(Volume[i]/nv);
  }
//+------------------------------------------------------------------+
