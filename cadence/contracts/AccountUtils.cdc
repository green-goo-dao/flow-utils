import "FungibleToken"
import "FlowToken"
import "FlowIDTableStaking"
import "LockedTokens"
import "FlowStakingCollection"
import "FlowStorageFees"


pub contract AccountUtils {

    pub struct AccountInfo {

        pub(set) var primaryAddress: Address
        pub(set) var primaryAcctBalance: UFix64
        pub(set) var secondaryAddress: Address?
        pub(set) var secondaryAcctBalance: UFix64
        pub(set) var nodeStakedBalance: UFix64
        pub(set) var delegatedBalance: UFix64

        init(_ address:Address) {
            self.primaryAddress=address
            self.primaryAcctBalance = 0.0
            self.secondaryAddress = nil
            self.secondaryAcctBalance = 0.0
            self.nodeStakedBalance = 0.0
            self.delegatedBalance = 0.0
        }

        pub fun getTotalBalance() :UFix64 {
            return self.primaryAcctBalance+self.secondaryAcctBalance+self.nodeStakedBalance+self.delegatedBalance
        }
    }

    /// Get the total flow balance for this account and its linked account
    pub fun getTotalFlowBalance(address: Address): UFix64? {

        if let info = self.getAccountInfo(address: address) {
            return info.getTotalBalance()
        }
        return nil
    }

    /// Get the account info for this account
    pub fun getAccountInfo(address: Address): AccountInfo?{

        var info: AccountInfo = AccountInfo(address)

        let account = getAccount(address)
        //if balance is 0 the account is not valid
        if account.balance == 0.0 {
            return  nil
        }

        //TODO: should we return something here
        if account.getLinkTarget(/public/lockedFlowTokenReceiver) != nil {
            return  nil
        }

        // Get the main Vault balance of this account
        if let vaultRef = account.getCapability(/public/flowTokenBalance).borrow<&FlowToken.Vault{FungibleToken.Balance}>(){
            info.primaryAcctBalance = vaultRef.balance
        }

        // Get the locked account associated with the primary account if there is one
        if let lockedAccount = account.getCapability(LockedTokens.LockedAccountInfoPublicPath).borrow<&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>() {
        }

        var allNodeInfo: [FlowIDTableStaking.NodeInfo] = []
        var allDelegateInfo: [FlowIDTableStaking.DelegatorInfo] = []


        // get all node objects using the original basic node account configuration
        if let nodeStaker = account.getCapability<&{FlowIDTableStaking.NodeStakerPublic}>(FlowIDTableStaking.NodeStakerPublicPath).borrow() {
            allNodeInfo.append(FlowIDTableStaking.NodeInfo(nodeID: nodeStaker.id))
        }

        // get all delegator objects using the original basic delegator account configuration
        if let delegator = account.getCapability<&{FlowIDTableStaking.NodeDelegatorPublic}>(/public/flowStakingDelegator).borrow() {
            allDelegateInfo.append(FlowIDTableStaking.DelegatorInfo(nodeID: delegator.nodeID, delegatorID: delegator.id))
        }

        // get all nodes/delegators from the staking collection
        // includes all nodes and delegators that are in the locked account
        var doesAccountHaveStakingCollection = FlowStakingCollection.doesAccountHaveStakingCollection(address: account.address)
        if doesAccountHaveStakingCollection {
            allNodeInfo.appendAll(FlowStakingCollection.getAllNodeInfo(address: account.address))
            allDelegateInfo.appendAll(FlowStakingCollection.getAllDelegatorInfo(address: account.address))
        }

        // If we have a lockedAccount linked but don't have a staking collection we need to add nodes/delegators there
        // If there is a locked account and a staking collection, the staking collection staking information would have already included the locked account
        if let lockedAccountInfo = account.getCapability<&LockedTokens.TokenHolder{LockedTokens.LockedAccountInfo}>(LockedTokens.LockedAccountInfoPublicPath).borrow() {

            info.secondaryAddress = lockedAccountInfo.getLockedAccountAddress() 
            info.secondaryAcctBalance = lockedAccountInfo.getLockedAccountBalance() + FlowStorageFees.minimumStorageReservation
            if !doesAccountHaveStakingCollection {
                if let nodeID = lockedAccountInfo.getNodeID() {
                    allNodeInfo.append(FlowIDTableStaking.NodeInfo(nodeID: nodeID))
                }

                if let delegatorID = lockedAccountInfo.getDelegatorID() {
                    if let nodeID = lockedAccountInfo.getDelegatorNodeID() {
                        allDelegateInfo.append(FlowIDTableStaking.DelegatorInfo(nodeID: nodeID, delegatorID: delegatorID))
                    }
                }
            }
        }

        // ===== Aggregate all stakes and delegations in a digestible set =====
        // deduplication between the old way and the new way will happen automatically because the result is stored in a map
        let nodes : {String:UFix64} = {}
        let delegators : {String:UFix64} = {}
        for nodeInfo in allNodeInfo {
            let balance =  nodeInfo.tokensStaked
            + nodeInfo.tokensCommitted
            + nodeInfo.tokensUnstaking
            + nodeInfo.tokensUnstaked
            + nodeInfo.tokensRewarded

            nodes["n:".concat(nodeInfo.id)] = balance
        }

        for delegatorInfo in  allDelegateInfo {
            let balance =  delegatorInfo.tokensStaked
            + delegatorInfo.tokensCommitted
            + delegatorInfo.tokensUnstaking
            + delegatorInfo.tokensUnstaked
            + delegatorInfo.tokensRewarded

            delegators["n:".concat(delegatorInfo.nodeID).concat(" d:").concat(delegatorInfo.id.toString())] = balance
        }


        for key in nodes.keys {
            let value = nodes[key]!
            info.nodeStakedBalance = info.nodeStakedBalance + value
        }

        for key in delegators.keys {
            let value = delegators[key]!
            info.delegatedBalance = info.delegatedBalance + value
        }

        return info
    }
}
