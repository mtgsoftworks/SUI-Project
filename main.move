module legIDModule::mainnn {

    use std::string;
    use std::vector;

    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use sui::event::emit;


    use sui::package;
    use sui::display;

    // resource Addresses {
    //     addresses: vector<address>;
    // }

    const NULL_ADDRESS : address = @0x0;


    struct NFTCreationEvent has copy, drop {
        id : ID,
        name : string::String
    }


    struct ApprovedManufacturers has key {
        id : UID,
        listOfManufacturers : vector<address>,
        size : u64
    }

    // structure to show the status of the NFT, whether it is in the process of being sold or not
    struct TransitStatus has store {
        in_transit : bool, // boolean of whether the nft is in transit
        pending_buyer: address // if in_transit, pending_buyer = buyer's address, otherwise blank address of 0x0
    }

    struct AdminCapabilities has key {
        id : UID,
    }

    struct ManuCapabilities has key {
        id : UID,
    }

    struct LegIdNft has key, store{
        //nft_id = something to identify the initial nft, whether it be a hash or w/e
            /*
            use number:: u64;
            use name:: string::String;
            use capacity:: u64;
            */
        
        id : UID,
        transit_status : TransitStatus, // 
        epoch_stamp: u64, // block number correlating to transaction. block number has date
        collection_number: u64,
        name: string::String,
        current_owner : address, //null address
        transaction_history : vector<u8>, // the hash of the last state of the nft
        original_minter : address // the address of the manufacturer
    }

    struct NftWrapper has key {
        id: UID,
        nft: LegIdNft,
        intended_address : address,
        original_sender : address
    }


    public entry fun create_NFT(
        _manuCap : &ManuCapabilities,
        _name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        _collection_number : u64,
        ctx: &mut TxContext
    ){
        // Intake: product_unique_info, manufacturer address
            // ASSERTS tx.sender is in list of Verified Manufacturers
        // Purpose: create an object and transfer it to the tx.sender
        // Output: NFT formed
            // in_transit initialized as 0
            // current_owner and original_minter set as the one who call create_NFT
            // hash transaction_history = 0x0 (empty hash)
            // the product unique info is loaded with w/e info the creator wants to put in
        // Person working on this:
        // Expected time: 1 hour
        
        let sender = tx_context::sender(ctx);
        
        let init_transit_status = TransitStatus {
            in_transit : false,
            pending_buyer: NULL_ADDRESS
        };

        let tempId = object::new(ctx);
        let tempName : string::String = string::utf8(_name); 

        let nft = LegIdNft {
            name: tempName,
            id: tempId,
            transit_status: init_transit_status,
            epoch_stamp: tx_context::epoch(ctx),
            collection_number: _collection_number,
            current_owner : sender,
            transaction_history : vector::empty<u8>(),
            original_minter: sender,
        };

        emit (NFTCreationEvent {
            id: object::id<LegIdNft>(&nft),
            name : tempName
        });

        transfer::public_transfer(nft, sender);

        
        
    } 
    
    
    public entry fun manufacturer_add(_cap : &AdminCapabilities,
                                manufacturer : address, 
                                company_name : vector<u8>, 
                                ctx : &mut TxContext) {

        let sender = tx_context::sender(ctx);

        transfer::transfer(ManuCapabilities {
            id: object::new(ctx)
        }, manufacturer);

        // Intake: company_name, wallet public address
            // ASSERTS tx.sender is a verified admin address
        // Purpose: adds verified manufacturer to list and makes an ID
        // Output: hash_ID_manufacturer. We expect the manufacturer to make this address public, and that other people can't login. We can store a list of these
        // Person working on this:
        // Expected time:
    }


    public entry fun transfer_initiate(
        nft: LegIdNft,
        buyer_address: address,
        ctx: &mut TxContext
    ) {
        // Intake: buyer_address, nft, seller_address
            // ASSERTS tx.initiator is current owner of nft
        // Purpose: to initiate the transfer by the current owner
        // Output: sets the nft in 'in_transit' mode, where the nft can only be accepted or cancelled
        // Person working on this:
        // Expected Time:
        let sender = tx_context::sender(ctx);

        assert!(sender == nft.current_owner, 423);

        assert!(!nft.transit_status.in_transit, 122);

        nft.transit_status.in_transit = true;
        nft.transit_status.pending_buyer = buyer_address;

        let nftWrap = NftWrapper {
            id : object::new(ctx),
            nft,
            intended_address: buyer_address,
            original_sender: sender
        };

        transfer::transfer(nftWrap, buyer_address);

        // transfer::public_transfer(nft, @0x0);

        // (true)
    }

    public entry fun transfer_accept(
        _nftWrap: NftWrapper,
        ctx: &mut TxContext,
        // seller_address: address,
        // manufacturer_address: address
    ) {
        
        // Intake: nft, buyer_address
            // ASSERTS tx.acceptor is the listed acceptor of the initated transfer
            // ASSERTS validate() 
            // ASSERTS in_transit is true
        // Purpose: to end the transfter
        // Output: nft object is updated to reflect the transfer
        let sender = tx_context::sender(ctx);
        assert!(_nftWrap.intended_address == sender, 2312);

        // Asserts that the nft is in transit
        assert!(_nftWrap.nft.transit_status.in_transit, 42);

        // Asserts that transfer acceptor is nft pending buyer
        assert!(sender == _nftWrap.nft.transit_status.pending_buyer, 4032);
        
        let NftWrapper {
            id,
            nft,
            intended_address: _,
            original_sender: _
        } = _nftWrap;

        transfer::public_transfer(nft, tx_context::sender(ctx));

        object::delete(id);

        // transfer::public_transfer(nft, sender);

        // set nft attributes here



        // Asserts that the product is valid
        // if (!validate(nft, seller_address, manufacturer_address)) return false;
        
        // let new_hash = sha3(nft);
    }


    public entry fun transfer_cancel(
        nftWrap: NftWrapper,
        ctx: &mut TxContext
    ) {
        // Intake: nft
        // Purpose: to cancel the transfer from either the buyer or seller side
            // buyer can cancel the transfer if deemed fake, asserts that buyer matches in_transit
            // seller can cancel the transfer if they reject the sale, asserts seller matches owner_id
        // Output: nft with state changed, in_transit = 0x0
        let sender = tx_context::sender(ctx);
        let owner = nftWrap.original_sender;
        let pendingBuyer : address = nftWrap.nft.transit_status.pending_buyer;

        // sender must be either the seller or the pending buyer to cancel the transfer
        // if (!((sender ==  LegIdNft.current_owner) || (sender == LegIdNft.transit_status.pending_buyer))) return false;
        assert!((sender == owner) || (sender == pendingBuyer), 294);

        // nft.transit_status.in_transit = false; // transit status set false
        // nft.transit_status.pending_buyer = NULL_ADDRESS; // pending_buyer address is blanked

        transfer::transfer(nftWrap, owner);
    }
}    
