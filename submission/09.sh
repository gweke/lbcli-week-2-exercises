#!/bin/bash

# Import helper functions
source .github/functions.sh

# Week Two Exercise: Advanced Bitcoin Transaction
# This script combines concepts from previous exercises into a comprehensive challenge

# Ensure script fails fast on errors
set -e

echo "========================================================"
echo "🚀 ADVANCED BITCOIN TRANSACTION MASTERY CHALLENGE 🚀"
echo "========================================================"
echo ""
echo "Welcome to the final challenge! In this exercise, you'll"
echo "demonstrate your mastery of Bitcoin transactions by"
echo "completing a series of increasingly complex tasks."
echo ""
echo "Each task builds on concepts from previous exercises."
echo "Let's begin your journey to becoming a Bitcoin transaction expert!"
echo ""

# ======================================================================
# SETUP - These transactions are provided for the challenges
# ======================================================================

# Base transaction data from previous exercises
BASE_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

SECONDARY_TX="0200000000010182aabd8115c43e5b37a1b0c77a409b229896a2ffd255098c8056a954f9651d0b0000000000fdffffff023007000000000000160014618be8a3b3a80d01503de9255f6be79ffd2f91f2c89e0000000000001600146566e3df810b10943b851073bd0363d38f24901602473044022072afb72deafbb9b5716e5b48d5e32e3bfed34c03d291e6cd3dd06cf4a7bd118e0220630d076cb5ada15a401d0c63c30e9b392c6cd3ce11137d966e42c40be9971d700121025798c893c7930231e4254a2b79c64acd5d81811ae6d6a46de29257849b5705e800000000"

# For the signing challenge, we'll need a private key
# This is a testnet private key - NEVER use this in production!
TEST_PRIVATE_KEY="L27QxBowwWzRPVuLCCwGxAwehP6uGaDsrC8K4wmPjxdbjztrGJZb"
TEST_ADDRESS="mxqPaW7UH8F82R7dN6bsBbntnzFNbFYkMm"


# =========================================================================
# CHALLENGE 1: Transaction Decoding - Identify transaction components
# =========================================================================
echo "CHALLENGE 1: Transaction Analysis"
echo "--------------------------------"
echo "To begin working with transactions, you must first understand their structure."
echo "Decode the provided transaction and extract key information."
echo ""
echo "Transaction hex: ${BASE_TX:0:64}... (truncated)"
echo ""

# STUDENT TASK: Decode the transaction to get the TXID
# WRITE YOUR SOLUTION BELOW:
decode_tx=$(bitcoin-cli -regtest decoderawtransaction $BASE_TX)
TXID=$(echo $decode_tx | jq -r '.txid')
check_cmd "Transaction decoding" "TXID" "$TXID"

echo "Transaction ID: $TXID"

# STUDENT TASK: Extract the number of inputs and outputs from the transaction
# WRITE YOUR SOLUTION BELOW:

NUM_INPUTS=$(echo $decode_tx | jq -r '.vin | length')
check_cmd "Input counting" "NUM_INPUTS" "$NUM_INPUTS"

NUM_OUTPUTS=$(echo $decode_tx | jq -r '.vout | length')
check_cmd "Output counting" "NUM_OUTPUTS" "$NUM_OUTPUTS"

echo "Number of inputs: $NUM_INPUTS"
echo "Number of outputs: $NUM_OUTPUTS"

# STUDENT TASK: Extract the value of the first output in satoshis
# WRITE YOUR SOLUTION BELOW:
FIRST_OUTPUT_VALUE=$(echo $decode_tx | jq -r '.vout[0].value * 100000000 | floor')
check_cmd "Output value extraction" "FIRST_OUTPUT_VALUE" "$FIRST_OUTPUT_VALUE"

echo "First output value: $FIRST_OUTPUT_VALUE satoshis"

# =========================================================================
# CHALLENGE 2: UTXO Selection - Identify and select appropriate UTXOs
# =========================================================================
echo ""
echo "CHALLENGE 2: UTXO Selection"
echo "--------------------------"
echo "Every Bitcoin transaction spends existing UTXOs. For this challenge, you'll"
echo "identify and select the appropriate UTXOs for a new transaction."
echo ""
echo "You want to create a transaction spending 15,000,000 satoshis."
echo "Select UTXOs from the decoded transaction that will cover this amount."
echo ""

# STUDENT TASK: Extract the available UTXOs from the decoded transaction for spending
# WRITE YOUR SOLUTION BELOW:
UTXO_TXID=$TXID
UTXO_VOUT_INDEX=$(echo "$decode_tx" | jq -r '.vout[0].n')
check_cmd "UTXO vout selection" "UTXO_VOUT_INDEX" "$UTXO_VOUT_INDEX"

UTXO_VALUE=$(echo $decode_tx | jq -r '.vout[0].value * 100000000 | floor')
check_cmd "UTXO value extraction" "UTXO_VALUE" "$UTXO_VALUE"

echo "Selected UTXO:"
echo "TXID: $UTXO_TXID"
echo "Vout Index: $UTXO_VOUT_INDEX"
echo "Value: $UTXO_VALUE satoshis"

# Validate selection
if [ "$UTXO_VALUE" -ge 15000000 ]; then
  echo "✅ This UTXO is sufficient for spending 15,000,000 satoshis!"
else
  echo "❌ Selected UTXO doesn't have enough funds! Need at least 15,000,000 satoshis."
  exit 1
fi

# =========================================================================
# CHALLENGE 3: Fee Calculation - Calculate appropriate transaction fees
# =========================================================================
echo ""
echo "CHALLENGE 3: Fee Calculation"
echo "---------------------------"
echo "Every Bitcoin transaction requires a fee to be included in a block."
echo "For this transaction, calculate a fee based on transaction size."
echo ""
echo "Assume a fee rate of 10 satoshis/vbyte. The transaction will have:"
echo "- 1 input (from your selected UTXO)"
echo "- 2 outputs (payment and change)"
echo ""
n_input=1
n_output=2

# Information about approximate transaction sizes (simplified for exercise)
echo "Approximate transaction components:"
echo "- Base transaction: 10 vbytes"
echo "- Each input: 68 vbytes"
echo "- Each output: 31 vbytes"
echo ""

# STUDENT TASK: Calculate the approximate transaction size and fee
# WRITE YOUR SOLUTION BELOW:
input_size=68
output_size=31
base_tx_size=10

TX_SIZE=$((base_tx_size + (n_input * input_size) + (n_output * output_size)))
check_cmd "Transaction size calculation" "TX_SIZE" "$TX_SIZE"

FEE_RATE=10  # satoshis/vbyte
FEE_SATS=$((FEE_RATE * TX_SIZE))
check_cmd "Fee calculation" "FEE_SATS" "$FEE_SATS"

echo "Estimated transaction size: $TX_SIZE vbytes"
echo "Calculated fee: $FEE_SATS satoshis"

# For this exercise, we're checking if the fee is in a reasonable range
if [ "$FEE_SATS" -lt 1000 ] || [ "$FEE_SATS" -gt 5000 ]; then
  echo "⚠️ Warning: Fee seems unusual. Double-check your calculation."
else
  echo "✅ Fee amount seems reasonable!"
fi

# =========================================================================
# CHALLENGE 4: Create Raw Transaction - Build a raw transaction with RBF
# =========================================================================
echo ""
echo "CHALLENGE 4: Creating a Raw Transaction with RBF"
echo "----------------------------------------------"
echo "Now it's time to create a raw transaction that spends your selected UTXO."
echo "The transaction should:"
echo "- Enable Replace-By-Fee (RBF)"
echo "- Send 15,000,000 satoshis to the address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
echo "- Return the change to: bcrt1qg09ftw43jvlhj4wlwwhkxccjzmda3kdm4y83ht"
echo "- Include the appropriate fee you calculated"
echo ""

# STUDENT TASK: Create the input JSON structure with RBF enabled
# HINT: RBF is enabled by setting the sequence number to less than 0xffffffff-1
# WRITE YOUR SOLUTION BELOW:
PAYMENT_ADDRESS="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
CHANGE_ADDRESS="bcrt1qg09ftw43jvlhj4wlwwhkxccjzmda3kdm4y83ht"

# STUDENT TASK: Create a proper input JSON for createrawtransaction
TX_INPUTS="[{\"txid\": \"$UTXO_TXID\", \"vout\": $UTXO_VOUT_INDEX, \"sequence\": 1}]"
check_cmd "Input JSON creation" "TX_INPUTS" "$TX_INPUTS"

# Verify RBF is enabled in the input structure
if [[ "$TX_INPUTS" == *"sequence"* ]] && [[ "$TX_INPUTS" != *"4294967295"* ]]; then
  echo "✅ RBF appears to be enabled!"
else
  echo "⚠️ Warning: RBF might not be properly enabled. Check your sequence number."
fi

echo "TX_INPUTS: $TX_INPUTS"

# STUDENT TASK: Calculate the change amount
PAYMENT_AMOUNT=15000000  # in satoshis
CHANGE_AMOUNT=$((UTXO_VALUE - PAYMENT_AMOUNT - FEE_SATS))
check_cmd "Change calculation" "CHANGE_AMOUNT" "$CHANGE_AMOUNT"

echo "payment amount: $PAYMENT_AMOUNT change amount: $CHANGE_AMOUNT"

# Convert amounts to BTC for createrawtransaction
PAYMENT_BTC=$(printf "%.8f" "$(bc -l <<< "scale=8; $PAYMENT_AMOUNT / 100000000")")
CHANGE_BTC=$(printf "%.8f" "$(bc -l <<< "scale=8; $CHANGE_AMOUNT / 100000000")")

echo "payment amount btc: $PAYMENT_BTC change amount btc: $CHANGE_BTC"

# STUDENT TASK: Create the outputs JSON structure
TX_OUTPUTS="{\"$PAYMENT_ADDRESS\": $PAYMENT_BTC, \"$CHANGE_ADDRESS\": $CHANGE_BTC}"
check_cmd "Output JSON creation" "TX_OUTPUTS" "$TX_OUTPUTS"

echo "TX_OUTPUT: $TX_OUTPUTS"

# STUDENT TASK: Create the raw transaction
RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$TX_INPUTS" "$TX_OUTPUTS")
check_cmd "Raw transaction creation" "RAW_TX" "$RAW_TX"

echo "Successfully created raw transaction!"
echo "Raw transaction hex: ${RAW_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE 5: Transaction Verification - Decode and verify the transaction
# =========================================================================
echo ""
echo "CHALLENGE 5: Transaction Verification"
echo "-----------------------------------"
echo "Before broadcasting any transaction, it's crucial to verify its contents."
echo "Decode your transaction and verify it meets the requirements."
echo ""

# STUDENT TASK: Decode the raw transaction
# WRITE YOUR SOLUTION BELOW:
DECODED_TX=$(bitcoin-cli -regtest decoderawtransaction $RAW_TX)
check_cmd "Transaction decoding" "DECODED_TX" "$DECODED_TX"

echo "decoded raw_tx to check the output index--------------------------------"
echo $DECODED_TX | jq '.'

# STUDENT TASK: Extract and verify the key components from the decoded transaction
# WRITE YOUR SOLUTION BELOW:
VERIFY_RBF=$(echo "$DECODED_TX" | jq -r '.vin[0].sequence')
if [ "$VERIFY_RBF" -lt 4294967294 ]; then
  VERIFY_RBF=true
  break
fi
check_cmd "RBF verification" "VERIFY_RBF" "$VERIFY_RBF"

VERIFY_PAYMENT=$(echo "$DECODED_TX" | jq -r '.vout[0].value')
check_cmd "Payment verification" "VERIFY_PAYMENT" "$VERIFY_PAYMENT"

VERIFY_CHANGE=$(echo "$DECODED_TX" | jq -r '.vout[1].value')
check_cmd "Change verification" "VERIFY_CHANGE" "$VERIFY_CHANGE"

echo "Verification Results:"
echo "- RBF enabled: $VERIFY_RBF"
echo "- Payment to $PAYMENT_ADDRESS with amount $VERIFY_PAYMENT BTC"
echo "- Change to $CHANGE_ADDRESS with amount $VERIFY_CHANGE BTC"

# Final verification
if [ "$VERIFY_RBF" == "true" ] && [ "$VERIFY_PAYMENT" == "$PAYMENT_BTC" ] && [ "$VERIFY_CHANGE" == "$CHANGE_BTC" ]; then
  echo "✅ Transaction looks good! Ready for signing."
else
  echo "❌ Transaction verification failed! Double-check your transaction."
  exit 1
fi

# =========================================================================
# CHALLENGE 6: Raw Transaction Creation
# =========================================================================
echo ""
echo "CHALLENGE 6: Raw Transaction Creation"
echo "------------------------------"
echo "A raw transaction is created for this challenge,"
echo ""
echo "In a real scenario, you would also use your own wallet to sign transactions."
echo ""

# For this exercise, we'll create a simple transaction
# This is a simplified example for educational purposes
echo "Creating a simple transaction for signing..."

# STUDENT TASK: Create a simple transaction that sends funds to the test address
SIMPLE_TX_INPUTS='[{"txid":"'$TXID'","vout":0,"sequence":4294967293}]'
SIMPLE_TX_OUTPUTS='{"'$TEST_ADDRESS'":0.0001}'

# Create a raw transaction for signing using the SIMPLE_TX_INPUTS and SIMPLE_TX_OUTPUTS
SIMPLE_RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$SIMPLE_TX_INPUTS" "$SIMPLE_TX_OUTPUTS")
check_cmd "Raw transaction creation" "RAW_TX" "$RAW_TX"

check_cmd "Simple transaction creation" "SIMPLE_RAW_TX" "$SIMPLE_RAW_TX"

echo "Simple transaction created: ${SIMPLE_RAW_TX:0:64}... (truncated)"

# Check if the transaction is properly created
if [[ -n "$SIMPLE_RAW_TX" && "$SIMPLE_RAW_TX" =~ ^02[0-9a-fA-F]+$ ]]; then
  echo "✅ Transaction is properly created!"
else
  echo "❌ Transaction creation verification failed!"
  exit 1
fi

# =========================================================================
# CHALLENGE 7: Child Transaction (CPFP) - Create a "child" transaction
# =========================================================================
echo ""
echo "CHALLENGE 7: Child Transaction (CPFP)"
echo "-----------------------------------"
echo "In this advanced challenge, imagine your transaction is stuck with a low fee."
echo "You'll create a 'child' transaction that spends the change output to implement"
echo "Child Pays For Parent (CPFP) fee bumping."
echo ""
echo "The child transaction should:"
echo "- Spend the change output from your previous transaction"
echo "- Pay a higher fee of at least 20 satoshis/vbyte"
echo "- Send the funds to: 2MvM2nZjueT9qQJgZh7LBPoudS554B6arQc"
echo ""

# For the exercise, we'll assume the first transaction's TXID is the one created above in challenge 4 ($RAW_TX)
PARENT_TXID=$(echo "$DECODED_TX" | jq -r '.txid')
check_cmd "Parent TXID extraction" "PARENT_TXID" "$PARENT_TXID"
echo "Parent transaction ID: $PARENT_TXID"

# STUDENT TASK: Identify the change output index from the parent transaction
# WRITE YOUR SOLUTION BELOW:
CHANGE_OUTPUT_INDEX=$(echo "$DECODED_TX" | jq -r '.vout[1].n')
check_cmd "Change output identification" "CHANGE_OUTPUT_INDEX" "$CHANGE_OUTPUT_INDEX"

# STUDENT TASK: Create the input JSON structure for the child transaction
# WRITE YOUR SOLUTION BELOW:
CHILD_INPUTS="[{\"txid\": \"$PARENT_TXID\", \"vout\": $CHANGE_OUTPUT_INDEX}]"
check_cmd "Child input creation" "CHILD_INPUTS" "$CHILD_INPUTS"

# STUDENT TASK: Calculate fees, allowing for a high fee to help the parent transaction
CHILD_TX_SIZE=$((base_tx_size + (1 * input_size) + (1 * output_size)))
check_cmd "Child transaction size calculation" "CHILD_TX_SIZE" "$CHILD_TX_SIZE"

CHILD_FEE_RATE=20 # satoshis/vbyte
CHILD_FEE_SATS=$((CHILD_FEE_RATE * CHILD_FEE_SATS))
check_cmd "Child fee calculation" "CHILD_FEE_SATS" "$CHILD_FEE_SATS"

# Calculate the amount to send after deducting fee
CHILD_OUTPUT_VALUE=$(echo $DECODED_TX | jq -r '.vout[1].value * 100000000 | floor')
#CHILD_OUTPUT_VALUE_BTC=$(printf "%.8f" "$(bc -l <<< "scale=8; $CHILD_OUTPUT_VALUE / 100000000")")

CHILD_RECIPIENT="2MvM2nZjueT9qQJgZh7LBPoudS554B6arQc"
CHILD_SEND_AMOUNT=$((CHILD_OUTPUT_VALUE - CHILD_FEE_SATS))
check_cmd "Child amount calculation" "CHILD_SEND_AMOUNT" "$CHILD_SEND_AMOUNT"

# Convert to BTC
CHILD_SEND_BTC=$(printf "%.8f" "$(bc -l <<< "scale=8; $CHILD_SEND_AMOUNT / 100000000")")

# STUDENT TASK: Create the outputs JSON structure
CHILD_OUTPUTS="{\"$CHILD_RECIPIENT\": $CHILD_SEND_BTC}"
check_cmd "Child output creation" "CHILD_OUTPUTS" "$CHILD_OUTPUTS"

# STUDENT TASK: Create the raw child transaction
CHILD_RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$CHILD_INPUTS" "$CHILD_OUTPUTS")
check_cmd "Child transaction creation" "CHILD_RAW_TX" "$CHILD_RAW_TX"

echo "Successfully created child transaction with higher fee!"
echo "Child raw transaction hex: ${CHILD_RAW_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE 8: CSV Timelock - Create a transaction with relative timelock
# =========================================================================
echo ""
echo "CHALLENGE 8: Timelock Transaction"
echo "-------------------------------"
echo "For the final challenge, you'll create a transaction with a relative timelock using CSV."
echo "This advanced feature allows funds to be locked for a specified number of blocks."
echo ""
echo "Create a transaction that:"
echo "- Spends the output from the SECONDARY_TX"
echo "- Includes a 10-block relative timelock (CSV)"
echo "- Sends funds to: bcrt1qxhy8dnae50nwkg6xfmjtedgs6augk5edj2tm3e"
echo ""

# Decode the secondary transaction (SECONDARY_TX) to get its TXID
decode_second_tx=$(bitcoin-cli -regtest decoderawtransaction $SECONDARY_TX)

SECONDARY_TXID=$(echo $decode_second_tx | jq -r '.txid')
check_cmd "Secondary TXID extraction" "SECONDARY_TXID" "$SECONDARY_TXID"
echo "Secondary transaction ID: $SECONDARY_TXID"
echo ""
echo $decode_second_tx | jq '.'


# STUDENT TASK: Create the input JSON structure with a 10-block relative timelock
# WRITE YOUR SOLUTION BELOW:

# some explanation for me to remember
# the sequence number is 32 bit unsigned number, then range from 0 to 2^32 -1 : 4 294 967 295
# so in Less Significant Bit (LSB) numerotin (31 30 29 .. .. .. 0 bit) if :

# Bit 31: 
#If set to 1 (0x80000000), it might disable certain features like relative lock-time, 
# allowing the transaction input to be included in any block without delay. 
# If set to 0, it enables those features, enforcing rules like waiting a certain number 
#of blocks before the input can be spent.

# Bit 22
# Similarly, Bit 22 can serve as a type flag:​
# If set to 1 (0x00400000), it could indicate that a particular feature (e.g., relative lock-time) 
# is measured in time units (like seconds). 
# If set to 0, it indicates measurement in block units.

# Bits 0-15
# The lower 16 bits (Bits 0-15) often represent a numerical value:​
# Bits 0-15: These bits can store a value (e.g., the number of blocks or time units to wait). 
# Since 16 bits can represent values from 0 to 65,535, this allows for specifying a wide range of values.

#Suppose you want to set a sequence value with a 10-block relative lock-time. Using the conventions discussed:​
# Bit 31: Set to 0 to enable relative lock-time 0x00000000.​
# Bit 22: Set to 0 to measure in blocks 0x00000000.​
# Bits 0-15: Set to 10 to specify a 10-block delay 0x0000000A.​
# nSequence = 0x00000000 | 0x00000000 | 0x0000000A
#           = 0x0000000A

# Bash calculation
# relative_blocks=10
# sequence=$((0x00000000 | 0x00000000 | relative_blocks))
# In binary, this would be: 0000 0000 0000 0000 0000 0000 0000 1010
# Converting this to hexadecimal:​ 0x0000000A

# The value 0x50000000 corresponds to a scenario where:​
# Bit 31 is 0 (enabling relative locktime).​
# Bit 22 is 1 (indicating time-based measurement).​
# Bits 0-15 are 0 (initializing the locktime value).
# This setup is used when specifying a time-based relative locktime.

relative_blocks=10
#sequence=$((0x50000000 + relative_blocks)) # this is for timelock in time (seconds)
# echo "sequence=dollarsign((0x50000000 + relative_blocks)) : $sequence"

sequence=$((0x00000000 | 0x00000000 | relative_blocks))
echo "sequence=dollarsign((0x00000000 | 0x00000000 | relative_blocks)): $sequence"

# sequence=$(echo "ibase=16; $sequence" | bc) # to convert hex to decimal
# echo "obase=16; $decimal_number" | bc # to convert decimal to hex
# echo "(echo q ibase=16; dollarsign_sequence q | bc) : $sequence"

secondary_tx_output_index=$(echo $decode_second_tx | jq -r '.vout[1].n')
echo "secondary_tx_output_index : $secondary_tx_output_index"

TIMELOCK_INPUTS="[{\"txid\": \"$SECONDARY_TXID\", \"vout\": $secondary_tx_output_index, \"sequence\": $sequence}]"
check_cmd "Timelock input creation" "TIMELOCK_INPUTS" "$TIMELOCK_INPUTS"

# Recipient address for timelock funds
TIMELOCK_ADDRESS="bcrt1qxhy8dnae50nwkg6xfmjtedgs6augk5edj2tm3e"

# STUDENT TASK: Calculate the amount to send (use the output value from SECONDARY_TX, minus a fee)
# Hint: Extract the output value from the secondary TX first


SECONDARY_OUTPUT_VALUE=$(echo $decode_second_tx | jq -r '.vout[1].value * 100000000 | floor')
check_cmd "Secondary output value extraction" "SECONDARY_OUTPUT_VALUE" "$SECONDARY_OUTPUT_VALUE"

TIMELOCK_FEE=1000 # Use a simple fee of 1000 satoshis for this exercise
TIMELOCK_AMOUNT=$((SECONDARY_OUTPUT_VALUE - TIMELOCK_FEE))
check_cmd "Timelock amount calculation" "TIMELOCK_AMOUNT" "$TIMELOCK_AMOUNT"

# Convert to BTC
TIMELOCK_BTC=$(printf "%.8f" "$(bc -l <<< "scale=8; $TIMELOCK_AMOUNT / 100000000")")

# STUDENT TASK: Create the outputs JSON structure
TIMELOCK_OUTPUTS="{\"$TIMELOCK_ADDRESS\": $TIMELOCK_BTC}"
check_cmd "Timelock output creation" "TIMELOCK_OUTPUTS" "$TIMELOCK_OUTPUTS"

# STUDENT TASK: Create the raw transaction with timelock
TIMELOCK_TX=$(bitcoin-cli -regtest createrawtransaction "$TIMELOCK_INPUTS" "$TIMELOCK_OUTPUTS")
check_cmd "Timelock transaction creation" "TIMELOCK_TX" "$TIMELOCK_TX"

echo "Successfully created transaction with 10-block relative timelock!"
echo "Timelock transaction hex: ${TIMELOCK_TX:0:64}... (truncated)"

# =========================================================================
# CHALLENGE COMPLETE
# =========================================================================
echo ""
echo "🎉 ADVANCED BITCOIN TRANSACTION MASTERY COMPLETED! 🎉"
echo "===================================================="
echo ""
echo "Congratulations! You've successfully demonstrated your mastery of:"
echo "✓ Transaction decoding and analysis"
echo "✓ UTXO selection and management"
echo "✓ Fee calculation and optimization"
echo "✓ Replace-By-Fee (RBF) implementation"
echo "✓ Transaction signing with private keys"
echo "✓ Child Pays For Parent (CPFP) fee bumping"
echo "✓ Relative timelock creation with CSV"
echo ""
echo "These are advanced Bitcoin transaction concepts that form the foundation"
echo "of Bitcoin's transaction capabilities and fee market."
echo ""
echo "Ready for real-world Bitcoin development!"

# Output the final transaction hex - useful for verification
echo $TIMELOCK_TX 
