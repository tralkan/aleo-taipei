# TyronSSI Account's Social Recovery

## Build Guide

Make sure to have Leo installed. For details, follow this [guide](https://developer.aleo.org/leo/installation). Alternatively, ensure that Leo is up to date: `leo update`.

Then, run:

```bash
leo build
```

In this repository, using the basic_bank.leo as an example, the goal is to use `tyron.leo/is_signer()` instead of a hardcoded address of the bank to verify that the order comes from the bank indeed.

Changing:

```bash
assert_eq(self.caller, aleo1t0uer3jgtsgmx5tq6x6f9ecu8tr57rzzfnc2dgmcqldceal0ls9qf6st7a);
```

For:

```bash
tyron.leo/is_signer();
```

And more importantly, the signer is secured by Tyron's social recovery.

### Supported features

- [x] Initialise the TyronSSI account by setting the address of the signer.

- [x] Verify that the call comes from the signer's EOA.

- [x] Add new guardians.

- [ ] Remove guardians.

- [x] Add a guardian's signature.

- [x] Execute social recovery to set up a new signer. The number of recorded signatures must be greater or equal to the threshold (absolute majority, i.e. half plus one).
