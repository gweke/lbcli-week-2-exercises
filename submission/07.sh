# Create a raw transaction with an amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

RAW_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

decode_tx=$(bitcoin-cli -regtest decoderawtransaction $RAW_TX)

#echo $decode_tx | jq '.'

# here is the process to create raw transaction :
# we need the txid of the utxo that will be use as input, and its vout (they will be the inputs parameters)
# the recipients address and the amount in btc here, the change address and the amount of change (they will be the ouput parameters)
# the createrawtransaction will return an hex of the raw transaction

# We extract input UTXO information, here is the worng one bc we use the same output as this tx used
#txid=$(echo "$decode_tx" | jq -r '.vin[0].txid')
#vout=$(echo "$decode_tx" | jq -r '.vin[0].vout')

# but we'll use the output of the rawtx as the inputs of the rawtx that we will made
txid=$(echo "$decode_tx" | jq -r '.txid')
vout_0=$(echo "$decode_tx" | jq -r '.vout[0].n')
vout_1=$(echo "$decode_tx" | jq -r '.vout[1].n')

#total_output_satoshis=$(echo "$decode_tx" | jq '[.vout[].value] | add * 100000000 | floor' | tr -d '\n')

# Explicit conversion to integer
total_output_satoshis=$((total_output_satoshis))

#echo "txid: $txid vout_0: $vout_0 vout_1: $vout_1 total_sat: $total_output_satoshis"

# We define recipient address and amount to send
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount_to_send=20000000  # 0.2 BTC in satoshis

# Define transaction fee 
#fee=1000  # Example fee in satoshis

# Calculate change
#change=$((total_output_satoshis - amount_to_send - fee))

#wallet_name="btrustwallet"

# we use getrawchangeaddress that will generate bech32 address type
#change_address=$(bitcoin-cli -regtest -rpcwallet=$wallet_name getrawchangeaddress)
#echo "change address: $change_address"

#echo "recipient: $recipient fee: $fee amount to send: $amount_to_send change: $change"
#but here we don't need fees nor change address yet

amount_to_send_btc=$(printf "%.8f" "$(bc -l <<< "scale=8; $amount_to_send / 100000000")")
#change_btc=$(printf "%.8f" "$(bc -l <<< "scale=8; $change / 100000000")")

# Create raw transaction
raw_unsigned=$(bitcoin-cli -regtest createrawtransaction \
  "[{\"txid\": \"$txid\", \"vout\": $vout_0}, {\"txid\": \"$txid\", \"vout\": $vout_1}]" \
  "{\"$recipient\": $amount_to_send_btc}")

#raw_unsigned=$(bitcoin-cli -regtest createrawtransaction \
#  "[{\"txid\": \"$txid\", \"vout\": $vout}]" \
#  "{\"$recipient\": $amount_to_send_btc, \"$change_address\": $change_btc}")

echo $raw_unsigned
