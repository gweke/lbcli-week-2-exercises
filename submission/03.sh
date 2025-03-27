# Created a SegWit address.
# Add funds to the address.
# Return only the Address

wallet_name="btrustwallet"

# Create Segwit address
SEGWIT_ADDR=$(bitcoin-cli -regtest -rpcwallet=$wallet_name getnewaddress "" "bech32")

NUM_BLOCKS=103

# Before adding funds to the address, we need to generate some blocks 
MINE_103_BLOCKS=$(bitcoin-cli -regtest generatetoaddress $NUM_BLOCKS $SEGWIT_ADDR)

# Use settxfee to set a reasonable fee for regtest
#bitcoin-cli -regtest -rpcwallet=$wallet_name settxfee 0.00001

amount=10
comment="The first transaction"
# Send the transaction
TXID=$(bitcoin-cli -regtest -rpcwallet=$wallet_name sendtoaddress "$SEGWIT_ADDR" "$amount" "$comment")

# Mine blocks to confirm the transactions
MINE_6_BLOCKS=$(bitcoin-cli -regtest generatetoaddress 6 $SEGWIT_ADDR)

echo $SEGWIT_ADDR




