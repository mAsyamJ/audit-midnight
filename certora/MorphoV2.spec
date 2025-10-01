// SPDX-License-Identifier: GPL-2.0-or-later

/// METHODS ///

methods {
    function sharesOf(address owner, bytes32 id) external returns (uint256) envfree;
    function debtOf(address owner, bytes32 id) external returns (uint256) envfree;
}

/// SANITY ///

rule sanity() {
    assert true;
}

invariant notBorrowerAndLender(bytes32 id, address user)
    sharesOf(user, id) == 0 || debtOf(user, id) == 0;