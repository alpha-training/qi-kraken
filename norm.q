\d .kraken

norm.OHLC:{
    d:@[x;`symbol;`$];
    d[`timestamp]:"N"$-1_'d[`timestamp];
        (d`timestamp;
                d`symbol;
                d`open;
                d`high;
                d`low;
                d`close;
                d`vwap;
                d`volume)
    }