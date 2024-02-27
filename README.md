## SoulFiction: Mysterion

These very special Soul Links, hand-crafted by artist Lady Oong, are known as “Mysterion” to those whose gazes are fixed on Mars.  A Mysterion provides extra boosts in rewards over what a normal Soul Link would generate for its owner.

## Usage

### prerequisites
You should install foundry. Check this [installation guide](https://book.getfoundry.sh/getting-started/installation) for more information.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy & Verify

```shell
$ source .env

# deploy on sepolia testnet
$ forge create \
--rpc-url ${SEPOLIA_URL} \
--private-key ${PRIVATE_KEY} \
--constructor-args "Mysterion" "MYST" \
--verify src/Mysterion.sol:Mysterion

# verification
$ forge verify-contract \
--chain-id 11155111 \
--num-of-optimizations 200 \
--watch \
--constructor-args $(cast abi-encode "constructor(string,string)" "Mysterion" "MYST") \
--etherscan-api-key ${ETHERSCAN_API_KEY} \
--compiler-version v0.8.21+commit.d9974bed \
0xD37e94695530A8185381930b41B9477f01f0Caa2 \
src/Mysterion.sol:Mysterion
```

### Assets

Assets(image, metadata) are uploaded & publicized on GCP bucket in *soulfiction* project. The name of bucket is *soullink-mysterion*.