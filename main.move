/// See the profits of a grocery
public fun profits(grocery: &Grocery): u64 {
        balance::value(&grocery.profits)
}

/// Owner of the grocery can collect profits by passing his capability
public entry fun collect_profits(_cap: &GroceryOwnerCapability, grocery: &mut Grocery, ctx: &mut TxContext) {
        let amount = balance::value(&grocery.profits);

        assert!(amount > 0, ENoProfits);

        // Take a transferable `Coin` from a `Balance`
        let coin = coin::take(&mut grocery.profits, amount, ctx);

        transfer::transfer(coin, tx_context::sender(ctx));
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
}