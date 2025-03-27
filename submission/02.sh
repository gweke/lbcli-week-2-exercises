# Create a new Bitcoin address, for receiving change.
wallet_name="btrustwallet"

#echo "Load the wallet : $wallet_name"
load_wallet=$(bitcoin-cli -regtest loadwallet $wallet_name)

# we use getrawchangeaddress that will generate bech32 address type
change_address=$(bitcoin-cli -regtest -rpcwallet=$wallet_name getrawchangeaddress)

echo $change_address