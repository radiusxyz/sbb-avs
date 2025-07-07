# (0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# (1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
# (2) 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
# (3) 0x90F79bf6EB2c4f870365E785982E1f101E93b906 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
# (4) 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
# (5) 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
# (6) 0x976EA74026E726554dB657fA54763abd0C3a0aa9 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
# (7) 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
# (8) 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
# (9) 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6


#!/bin/bash
set -e

echo "🚀 Starting strategy deployment and setup..."

# Set environment
RPC_URL=http://localhost:8545

# Entities
NETWORK_OWNER_ADDR=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
STRATEGY_DEPLOYER_ADDR=0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65
STAKER_0_ADDR=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
STAKER_1_ADDR=0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc
OPERATOR_0_ADDR=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
OPERATOR_1_ADDR=0x90F79bf6EB2c4f870365E785982E1f101E93b906

NETWORK_OWNER_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
STRATEGY_DEPLOYER_KEY=0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
STAKER_0_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
STAKER_1_KEY=0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
OPERATOR_0_KEY=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
OPERATOR_1_KEY=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

# Contracts
ERC20_TOKEN=0x0e801d84fa97b50751dbf25036d067dcf18858bf
STRATEGY_FACTORY=0x9a9f2ccfde556a7e9ff0848998aa4a0cfd8863ae
STRATEGY_MANAGER=0x0165878a594ca255338adfa4d48449f69242eb8f
DELEGATION_MANAGER=0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0
SERVICE_MANAGER=0x809d550fca64d94bd9f66e60752a544199cfac3d
ALLOCATION_MANAGER=0x2279b7a0a67db372996a5fab50d91eaa73d2ebe6                
SLASHING_REGISTRY_COORDINATOR=0x82e01223d51eb87e16a03e24687edf0f294da6f1
SLASHER=0xb0d4afd8879ed9f52b28595d31b441d079b2ca07                    
STRATEGY=0x2b961e3959b79326a8e7f64ef0d2d825707669b5
# Utils
AMOUNT=1000000000000000000

send_and_check() {
  tx_hash=$(cast send "$@" --json | jq -r '.transactionHash')
  status=$(cast receipt $tx_hash --rpc-url $RPC_URL --json | jq -r '.status')
  if [ "$status" == "0x1" ]; then
    echo "      ✅ SUCCESS: $tx_hash"
    echo ""
  else
    echo "      ❌ REVERTED: $tx_hash"
    echo ""

  fi
}

# Deploy strategy
# echo "📦 Deploying strategy..."
# STRATEGY=$(cast send $STRATEGY_FACTORY \
#   "deployNewStrategy(address)" $ERC20_TOKEN \
#   --rpc-url $RPC_URL \
#   --private-key $STRATEGY_DEPLOYER_KEY \
#   --json | jq -r '.returns[0]')
# echo "✅ Strategy deployed at $STRATEGY"

echo "💸 Minting tokens to SERVICE_MANAGER..."
send_and_check $ERC20_TOKEN \
  "mint(address,uint256)" $SERVICE_MANAGER $AMOUNT \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL

echo "💸 Minting and depositing tokens for STAKER_0..."
send_and_check $ERC20_TOKEN \
  "mint(address,uint256)" $STAKER_0_ADDR $AMOUNT \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL
send_and_check $ERC20_TOKEN \
  "increaseAllowance(address,uint256)" $STRATEGY_MANAGER $AMOUNT \
  --private-key $STAKER_0_KEY \
  --rpc-url $RPC_URL
send_and_check $STRATEGY_MANAGER \
  "depositIntoStrategy(address,address,uint256)" $STRATEGY $ERC20_TOKEN $AMOUNT \
  --private-key $STAKER_0_KEY \
  --rpc-url $RPC_URL

echo "💸 Minting and depositing tokens for STAKER_1..."
send_and_check $ERC20_TOKEN \
  "mint(address,uint256)" $STAKER_1_ADDR $AMOUNT \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL
send_and_check $ERC20_TOKEN \
  "increaseAllowance(address,uint256)" $STRATEGY_MANAGER $AMOUNT \
  --private-key $STAKER_1_KEY \
  --rpc-url $RPC_URL
send_and_check $STRATEGY_MANAGER \
  "depositIntoStrategy(address,address,uint256)" $STRATEGY $ERC20_TOKEN $AMOUNT \
  --private-key $STAKER_1_KEY \
  --rpc-url $RPC_URL

echo "🧾 Registering OPERATOR_0..."
send_and_check $DELEGATION_MANAGER \
  "registerAsOperator(address,uint32,string)" \
  0x0000000000000000000000000000000000000000 \
  0 \
  "" \
  --private-key $OPERATOR_0_KEY \
  --rpc-url $RPC_URL

echo "🧾 Delegating to OPERATOR_0..."
send_and_check $DELEGATION_MANAGER \
  "delegateTo(address,(bytes,uint256),bytes32)" \
  $OPERATOR_0_ADDR \
  "(0x0000000000000000000000000000000000000000000000000000000000000000,0)" \
  "0x0000000000000000000000000000000000000000000000000000000000000000" \
  --private-key $STAKER_0_KEY \
  --rpc-url $RPC_URL

echo "🧾 Registering OPERATOR_1..."
send_and_check $DELEGATION_MANAGER \
  "registerAsOperator(address,uint32,string)" \
  0x0000000000000000000000000000000000000000 \
  0 \
  "" \
  --private-key $OPERATOR_1_KEY \
  --rpc-url $RPC_URL

echo "🧾 Delegating to OPERATOR_1..."
send_and_check $DELEGATION_MANAGER \
  "delegateTo(address,(bytes,uint256),bytes32)" \
  $OPERATOR_1_ADDR \
  "(0x0000000000000000000000000000000000000000000000000000000000000000,0)" \
  "0x0000000000000000000000000000000000000000000000000000000000000000" \
  --private-key $STAKER_1_KEY \
  --rpc-url $RPC_URL

echo "🔐 Setting up AVS permissions..."
SET_AVS_REGISTRAR_SELECTOR=$(cast sig "setAVSRegistrar(address,address)")
CREATE_OPERATOR_SETS_SELECTOR=$(cast sig "createOperatorSets(address,(uint32,address[])[])")
# CREATE_TOTAL_DELEGATED_STAKE_QUORUM_SELECTOR=$(cast sig "createTotalDelegatedStakeQuorum()")
SLASH_OPERATOR_SELECTOR=$(cast sig "slashOperator(address,uint32)")
UPDATE_METADATA_URI_SELECTOR=$(cast sig "updateAVSMetadataURI(address,string)")

# 1. serviceManager.setAppointee(deployer, ALLOCATION_MANAGER, setAVSRegistrar.selector)
send_and_check $SERVICE_MANAGER \
  "setAppointee(address,address,bytes4)" \
  $(cast wallet address $NETWORK_OWNER_KEY) \
  $ALLOCATION_MANAGER \
  $SET_AVS_REGISTRAR_SELECTOR \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 



# 2. allocationManager.setAVSRegistrar(SERVICE_MANAGER, SLASHING_REGISTRY_COORDINATOR)
send_and_check $ALLOCATION_MANAGER \
  "setAVSRegistrar(address,address)" \
  $SERVICE_MANAGER \
  $SLASHING_REGISTRY_COORDINATOR \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 



# 3. serviceManager.setAppointee(SLASHING_REGISTRY_COORDINATOR, ALLOCATION_MANAGER, createOperatorSets.selector)
send_and_check $SERVICE_MANAGER \
  "setAppointee(address,address,bytes4)" \
  $SLASHING_REGISTRY_COORDINATOR \
  $ALLOCATION_MANAGER \
  $CREATE_OPERATOR_SETS_SELECTOR \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 


# 4. serviceManager.setAppointee(SLASHER, ALLOCATION_MANAGER, slashOperator.selector)
send_and_check $SERVICE_MANAGER \
  "setAppointee(address,address,bytes4)" \
  $SLASHER \
  $ALLOCATION_MANAGER \
  $SLASH_OPERATOR_SELECTOR \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 


# 5. serviceManager.setAppointee(deployer, ALLOCATION_MANAGER, updateAVSMetadataURI.selector)
send_and_check $SERVICE_MANAGER \
  "setAppointee(address,address,bytes4)" \
  $(cast wallet address $NETWORK_OWNER_KEY) \
  $ALLOCATION_MANAGER \
  $UPDATE_METADATA_URI_SELECTOR \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 



# 6. allocationManager.updateAVSMetadataURI(SERVICE_MANAGER, "metadataURI")
send_and_check $ALLOCATION_MANAGER \
  "updateAVSMetadataURI(address,string)" \
  $SERVICE_MANAGER \
  "metadataURI" \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL


echo "🏗 Creating operator set quorum..."
MAX_OPERATOR_COUNT=3
KICK_BIPS_OPERATOR=100
KICK_BIPS_TOTAL=1000
MINIMUM_STAKE=0
STRATEGY_MULTIPLIER=1
STRATEGY_PARAM="[($STRATEGY,$STRATEGY_MULTIPLIER)]"

OPERATOR_SET_ID=0  # or set this to your actual operator set ID
STRATEGIES="[$STRATEGY]"  # comma-separated if multiple
MAGNITUDES="[100000000]"  # same length as STRATEGIES

send_and_check $SLASHING_REGISTRY_COORDINATOR \
  "createTotalDelegatedStakeQuorum((uint32,uint16,uint16),uint96,(address,uint96)[])" \
  "($MAX_OPERATOR_COUNT,$KICK_BIPS_OPERATOR,$KICK_BIPS_TOTAL)" \
  $MINIMUM_STAKE \
  $STRATEGY_PARAM \
  --private-key $NETWORK_OWNER_KEY \
  --rpc-url $RPC_URL \
  --gas-limit 1000000 

# echo "⚙️ Registering OPERATOR_0 with AVS via SlashingRegistryCoordinator..."

# # BLS pubkey (G1 and G2)
# G1_X=0x1
# G1_Y=0x2
# G2_X=0x3
# G2_Y=0x4

# # Assemble PubkeyRegistrationParams
# PUBKEY_PARAMS="([$G1_X,$G1_Y],[$G2_X,$G2_Y])" # G1Point and G2Point

# # RegistrationType: 0 = NORMAL, 1 = CHURN
# REGISTRATION_TYPE=0

# SOCKET="\"127.0.0.1:9001\""

# # Encode the `data` parameter
# DATA=$(cast abi-encode "tuple(uint8,string,(uint256[2],uint256[2]))" \
#   $REGISTRATION_TYPE \
#   $SOCKET \
#   "$PUBKEY_PARAMS")

# send_and_check $SLASHING_REGISTRY_COORDINATOR \
#   "registerOperator(address,address,uint32[],bytes)" \
#   $OPERATOR_0_ADDR \
#   $SERVICE_MANAGER \
#   "[$OPERATOR_SET_ID]" \
#   $DATA \
#   --private-key $OPERATOR_0_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 2000000


# echo "🛠 Setting allocation delay to 0 for OPERATOR_0..."
# send_and_check $ALLOCATION_MANAGER \
#   "setAllocationDelay(address,uint32)" \
#   $OPERATOR_0_ADDR \
#   0 \
#   --private-key $OPERATOR_0_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 1000000

# echo "⚙️ Modifying allocations for OPERATOR_0..."
# send_and_check $ALLOCATION_MANAGER \
#   "modifyAllocations(address,(address,uint32,address[],uint64[])[])" \
#   $OPERATOR_0_ADDR \
#   "[( $SERVICE_MANAGER, $OPERATOR_SET_ID, $STRATEGIES, $MAGNITUDES )]" \
#   --private-key $OPERATOR_0_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 1000000

# echo "⚙️ Registering OPERATOR_1 with AVS via SlashingRegistryCoordinator..."

# # BLS pubkey (G1 and G2)
# G1_X=0x5
# G1_Y=0x6
# G2_X=0x7
# G2_Y=0x8

# # Assemble PubkeyRegistrationParams
# PUBKEY_PARAMS="([$G1_X,$G1_Y],[$G2_X,$G2_Y])" # G1Point and G2Point

# # RegistrationType: 0 = NORMAL, 1 = CHURN
# REGISTRATION_TYPE=0

# SOCKET="\"127.0.0.1:9001\""

# # Encode the `data` parameter
# DATA=$(cast abi-encode "tuple(uint8,string,(uint256[2],uint256[2]))" \
#   $REGISTRATION_TYPE \
#   $SOCKET \
#   "$PUBKEY_PARAMS")

# send_and_check $SLASHING_REGISTRY_COORDINATOR \
#   "registerOperator(address,address,uint32[],bytes)" \
#   $OPERATOR_1_ADDR \
#   $SERVICE_MANAGER \
#   "[$OPERATOR_SET_ID]" \
#   $DATA \
#   --private-key $OPERATOR_1_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 2000000

# echo "🛠 Setting allocation delay to 0 for OPERATOR_1..."
# send_and_check $ALLOCATION_MANAGER \
#   "setAllocationDelay(address,uint32)" \
#   $OPERATOR_1_ADDR \
#   0 \
#   --private-key $OPERATOR_1_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 1000000

# echo "⚙️ Modifying allocations for OPERATOR_1..."
# send_and_check $ALLOCATION_MANAGER \
#   "modifyAllocations(address,(address,uint32,address[],uint64[])[])" \
#   $OPERATOR_1_ADDR \
#   "[( $SERVICE_MANAGER, $OPERATOR_SET_ID, $STRATEGIES, $MAGNITUDES )]" \
#   --private-key $OPERATOR_1_KEY \
#   --rpc-url $RPC_URL \
#   --gas-limit 1000000

# echo "✅ Done. All components deployed and configured successfully."


cast send $ALLOCATION_MANAGER_ADDRESS \
  "registerForOperatorSets(address,(address,uint32[],bytes))" \
  $OPERATOR_ADDRESS \
  "($AVS_ADDRESS,[$OPERATOR_SET_IDS],0x$DATA)" \
  --private-key $PRIVATE_KEY