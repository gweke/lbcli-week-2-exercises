# List the current UTXOs in your wallet.

wallet_name="btrustwallet"

UTXOs=$(bitcoin-cli -regtest -rpcwallet=$wallet_name listunspent)

echo $UTXOs