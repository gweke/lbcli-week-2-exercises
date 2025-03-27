# Create a wallet with the name "btrustwallet".
wallet_name="btrustwallet"
echo $(bitcoin-cli -regtest createwallet $wallet_name)

#echo "Load the wallet : $wallet_name"
#echo "Load the wallet : $wallet_name"
load_wallet=$(bitcoin-cli -regtest loadwallet $wallet_name)

#echo "Get the wallet info : $wallet_name"
#echo $(bitcoin-cli -regtest -rpcwallet=$wallet_name getwalletinfo)