/ Import libraries
.qi.import`ipc

/ Table Schema
trade:flip `time`sym`open`high`low`close`vwap`volume!"psffffff"$\:();

/ Connection Logic
host:":wss://ws.kraken.com:443";
path:"/v2";
header:"GET ",path," HTTP/1.1\r\nHost: ws.kraken.com\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n\r\n"
currencies:("BTC/USD";"ETH/USD")
interval:1
payload:`method`params!("subscribe";`channel`symbol`interval!("ohlc";currencies;interval))
ticker_payload:`method`params!("subscribe";`channel`symbol!("ticker";currencies))

/ Kraken Data Handler
.kraken.start:{[tp]
    kraken.proc::tp;
    .z.ws:{[msg]
        package:.j.k msg;
        {if[`channel in key x;
            if[x[`channel] like "status";
                -1 "qi.kraken: Status received. System is ", first x[`data]`system;
                :neg[.z.w] .j.j payload];
            
            if[x[`channel] like "heartbeat";:(::)];
            
            d:x[`data];
            d:@[d;`symbol;`$];
            d[`timestamp]:-1_'d[`timestamp];
            d:@[d;`timestamp;"P"$];
            neg[.ipc.conn kraken.proc](`.u.upd;`$x[`channel];
                (d`timestamp;
                d`symbol;
                d`open;
                d`high;
                d`low;
                d`close;
                d`vwap;
                d`volume)
                );
            ]
            } each enlist package
        };

    / Open & Confirm Connections
    w:(hsym `$host) header;

    -1 "qi-kraken v0.1: Connection sequence initiated...";
    }
