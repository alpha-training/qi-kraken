\e 1

/ Import libraries
.qi.import`ipc
.qi.import`log
.qi.frompkg[`kraken]

/ Table Schema
/ trade:flip `time`sym`open`high`low`close`vwap`volume!"psffffff"$\:();

/ export SSL_CA_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt

\d .kraken

/ Connection Logic
host:":wss://ws.kraken.com:443";
krpath:"/v2";
header:"GET ",krpath," HTTP/1.1\r\nHost: ws.kraken.com\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n\r\n"
currencies:("BTC/USD";"ETH/USD")
interval:1
payload:`method`params!("subscribe";`channel`symbol`interval!("ohlc";currencies;interval))
ticker_payload:`method`params!("subscribe";`channel`symbol!("ticker";currencies))

H:0Ni;

/ Kraken Data Handler

.z.ws:{[msg]
    pkg:.j.k msg;
    {if[`channel in key x;
        if[x[`channel] like "status";
            -1 "qi.kraken: Status received. System is ", first x[`data]`system;
            :neg[H] .j.j payload];
        if[x[`channel] like "heartbeat";-1 "qi.kraken: Heartbeat received";:(::)];
        if[x[`channel] like "ohlc";-1 "qi.kraken: data received";dbg]];
        }each enlist pkg
    }

start:{[target]
    if[null H::.ipc.conn .qi.tosym target;
        if[null H::first c:.ipc.tryconnect target;
            .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];
    .log.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .log.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .log.info"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.log.info"Connection success"];
    }

/w:(hsym `$host) header;
\

    .z.ws:{[msg]
        package:.j.k msg;
        {if[`channel in key x;
            if[x[`channel] like "status";
                -1 "qi.kraken: Status received. System is ", first x[`data]`system;
                :neg[.z.w] .j.j payload];
            
            if[x[`channel] like "heartbeat";:(::)];
            if[x[`channel] like "ohlc";dbg];
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
