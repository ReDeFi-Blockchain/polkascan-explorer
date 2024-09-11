# Polkascan Explorer
<img width="332" valign="top" alt="Screenshot 2022-10-10 at 10 03 34" src="https://user-images.githubusercontent.com/5286904/194822070-48c172d4-c65d-4ea0-8287-15b772f32eb4.png"> <img width="312" valign="top" alt="Screenshot 2022-10-10 at 10 30 11" src="https://user-images.githubusercontent.com/5286904/194826118-9d655e0c-02d3-4a8c-b4f1-73bfc00e076b.png">

Polkascan Explorer provides a generalized block explorer for 
[Substrate](https://github.com/paritytech/substrate)-based blockchains.

It combines data retrieved directly from the Substrate node RPC with data retrieved from a third-party indexer API.

At the moment the following third-party data are supported: 

* Polkascan API
* Subsquid 

## Prepare repository

Run `init.sh` to initialize repository; this will basically setup git submodules and copy necessary scripts.

## Running the application

Run polkascan on **L1 Testnet**:

* `docker compose -f docker-compose.L1.yml -p polkascan-l1 up --build`

Run polkascan on **L2 Testnet**:

* `docker compose -f docker-compose.L2.yml -p polkascan-l2 up --build`

Run the Explorer UI:

* `docker compose -f docker-compose.yml -p polkascan up --build`

## Services

* Polkascan UI: http://127.0.0.1:8080/

### L1

API playground: http://127.0.0.1:8000/graphql/.

Websocket: ws://127.0.0.1:8000/graphql-ws.

MySQL database exposed at mysql://root:root@localhost:33060.

### L2

API playground: http://127.0.0.1:8001/graphql/.

Websocket: ws://127.0.0.1:8001/graphql-ws.

MySQL database exposed at mysql://root:root@localhost:33061.

## Components

The explorer application consist of several components:

### Harvester component

The [harvester](https://github.com/polkascan/harvester) retrieves data from the connected 
Substrate node and stores it into a MySQL (by default) database.

#### Storage cron

With the processing of each block, it can also be desirable to retrieve and decode certain storage records. By default, 
for every block the `System.Events` are stored as this is a fundamental element to determine which calls are executed.

When other storage records are needed, for example a balance snapshot of all accounts every 10000 blocks, additional 
cron items can be added:

```bash
cd harvester
./harvester-cli.sh storage-cron add 

> Block interval (e.g. 10 = every 10th block): 10000
> Pallet: System
> Storage function: Account
> Added cron System.Account every 10000 blocks
```

Check the current storage cron items:
```
  Id    Block interval  Pallet    Storage name
----  ----------------  --------  --------------
   1                 1  System    Events
   2             10000  System    Account
```

Then run the harvester:
```bash
./harvester-cli.sh run 
```

#### Storage tasks

When storage cron items retrieve records as part of the block harvest process, storage tasks can be added to retrieve 
records for any given blocks that are already processed. 

Also, this feature can be used standalone, so it basically acts as a storage harvester.

Example: Store total issuance for blocks 1-1000:
```bash
cd harvester
./harvester-cli.sh storage-tasks add
> Pallet: Balances
> Storage function: TotalIssuance
> Blocks (e.g. '100,104' or '100-200'): 1-1000
> Added task Balances.TotalIssuance for blocks 1-1000 
```

Then run only the 'cron' job of the harvester:
```bash
./harvester-cli.sh run --job cron 
```

List progress of tasks:

```bash
./harvester-cli.sh storage-tasks list
>   Id  Pallet    Storage name    Blocks                                 Complete
> ----  --------  --------------  -------------------------------------  ----------
>    1  System    Account         {'block_ids': [1, 2]}                  True
>    2  Balances  TotalIssuance   {'block_end': 1000, 'block_start': 1}  True
```

### Explorer API component

The [explorer API](https://github.com/polkascan/explorer-api) transforms the data via an ETL process into an 
explorer-specific format. It exposes a GraphQL endpoint and enables subscription-based communication to the UI.

### Explorer UI component

[Explorer UI](https://github.com/polkascan/explorer-ui) is a client-sided [Angular](https://angular.io/) based application that utilizes 
[PolkADAPT](https://github.com/polkascan/polkadapt) and its Adapters to obtain data from multiple data sources, like 
the Explorer API and the Substrate node. Its design is based on flat [Material](https://material.angular.io/) component 
design, styled in Polkascan branding.

## Known Issues and Limitations

* Substrate runtimes that implements metadata prior to `MetadataV14` decode in a different format as expected by the explorer, so not all functionality is available. This can have effect on early blocks as well, a workaround is to set `BLOCK_START` env setting for the harvester, to a block number with `MetadataV14`.
* Errors during building `explorer-ui` Docker container on M1 architecture. This could happen when the chromium binary is not available for arm64, there is [a workaround available](https://github.com/polkascan/explorer-ui/issues/26)
* Currently, the `explorer-api` application supports Python version >3.6 and <3.10 

## License
https://github.com/polkascan/explorer/blob/main/LICENSE
