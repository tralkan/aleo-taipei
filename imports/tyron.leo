// The "TyronSSI Account's Social Recovery" program.
program tyron.aleo {
    mapping accounts: address => Account;
    mapping signers: address => u8;
    
    record Guardian{
        // The guardian.
        owner: address,
        // The signer.
        signer: address,
    }
    
    struct Account{
        signer: address,
        guardian_count: u8,
    }

    struct Signer{
        id: address,
    }

    // The initialization can be called only once.
    transition init(){
        return then finalize(self.signer);
    }

    finalize init(signer: address) {
        let nonce: address = aleo1tve29pw8ze7kejtavwpwsv0jjmhrnp22ukgkfqv9x52c9kqelygsyhgjhh;
        let initialized: bool = Mapping::contains(accounts, nonce);
        assert_eq(initialized, false);

        let newAccount: Account = Account{
            signer: signer,
            guardian_count: 0u8,
        };
        Mapping::set(accounts, signer, newAccount);
        Mapping::set(accounts, nonce, newAccount);  
    }

    transition is_signer(){
        return then finalize(self.signer);
    }

    finalize is_signer(caller: address) {
        let exists: bool = Mapping::contains(accounts, caller);
        assert(exists);
    }

    transition add_guardian(guardian: address) -> Guardian{
        assert_neq(self.caller, guardian);
        return Guardian{
            owner: guardian,
            signer: self.caller,
        } then finalize(self.caller, guardian);
    }

    finalize add_guardian(signer: address, guardian: address){
        // Update the account info.
        let account: Account = Mapping::get(accounts, signer);
        
        let guardianCount: u8 = account.guardian_count;
        guardianCount += 1u8;

        let updatedAccount: Account = Account{
            signer: signer,
            guardian_count: guardianCount,
        };

        Mapping::set(accounts, signer, updatedAccount);
    }

    transition add_signature(guardian: Guardian, new_signer: Signer, s: signature){
        return then finalize(self.caller, new_signer, s);
    }

    finalize add_signature(guardian_id: address, new_signer: Signer, s: signature){
        let verified: bool = s.verify(guardian_id, new_signer);
        assert(verified);

        let sigs: u8 = Mapping::get_or_use(signers, new_signer.id, 0u8);
        sigs += 1u8;

        Mapping::set(signers, new_signer.id, sigs);
    }

    transition social_recovery(guardian: Guardian, new_signer: Signer) -> Guardian{
        return Guardian{
            owner: self.caller,
            signer: new_signer.id,
        } then finalize(guardian.signer, new_signer.id);
    }

    finalize social_recovery(old_signer: address, new_signer_id: address){
        // Calculate guardian threshold.
        let account: Account = Mapping::get(accounts, old_signer);
        let threshold: u8 = account.guardian_count.div(2u8).add(1u8);

        let sigs: u8 = Mapping::get_or_use(signers, new_signer_id, 0u8);
        let verified: bool = sigs >= threshold;
        assert(verified);

        // Update signer.
        Mapping::remove(accounts, old_signer);

        let newAccount: Account = Account{
            signer: new_signer_id,
            guardian_count: account.guardian_count,
        };
        Mapping::set(accounts, new_signer_id, newAccount);    
    }
}
