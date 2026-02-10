\d .kraken

norm.OHLC:{
    d:@[x;`symbol;`$];
    d[`timestamp]:-1_'d[`timestamp];
    d:@[d;`timestamp;"N"$];
        (d`timestamp;
                d`symbol;
                d`open;
                d`high;
                d`low;
                d`close;
                d`vwap;
                d`volume)
    }