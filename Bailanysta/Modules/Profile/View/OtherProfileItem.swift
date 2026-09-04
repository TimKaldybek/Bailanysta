//
//  OtherProfileItem.swift
//  Bailanysta
//

enum OtherProfileItem: Hashable {
    case post(ProfilePostViewData)
    /// Placeholder card shown while the profile's first load is in flight; the associated value
    /// only keeps skeleton slots unique in the diffable snapshot.
    case skeleton(Int)
}
