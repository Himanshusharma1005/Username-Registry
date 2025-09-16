module MyModule::UsernameRegistry {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::error;
    use std::option::{Self, Option};
    use aptos_std::table::{Self, Table};
    /// Error codes
    const E_USERNAME_ALREADY_EXISTS: u64 = 1;
    const E_USERNAME_NOT_FOUND: u64 = 2;
    const E_NOT_OWNER: u64 = 3;
    /// Struct representing the username registry
    struct UsernameRegistry has key {
        usernames: Table<String, address>,  // Maps username to owner address
        user_registry: Table<address, String>, // Maps user address to username
    }
    /// Initialize the username registry (called once by the module publisher)
    public fun initialize_registry(admin: &signer) {
        let registry = UsernameRegistry {
            usernames: table::new(),
            user_registry: table::new(),
        };
        move_to(admin, registry);
    }
    /// Function to register a unique username
    public fun register_username(
        user: &signer, 
        username: String,
        registry_owner: address
    ) acquires UsernameRegistry {
        let user_addr = signer::address_of(user);
        let registry = borrow_global_mut<UsernameRegistry>(registry_owner);

        // Check if username already exists
        assert!(
            !table::contains(&registry.usernames, username),
            error::already_exists(E_USERNAME_ALREADY_EXISTS)
        );

        // Register the username
        table::add(&mut registry.usernames, username, user_addr);
        table::add(&mut registry.user_registry, user_addr, username);
    }
    /// Function to get the owner of a username
    public fun get_username_owner(
        username: String,
        registry_owner: address
    ): Option<address> acquires UsernameRegistry {
        let registry = borrow_global<UsernameRegistry>(registry_owner);

        if (table::contains(&registry.usernames, username)) {
            option::some(*table::borrow(&registry.usernames, username))
        } else {
            option::none()
        }
    }
}