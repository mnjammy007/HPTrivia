//
//  Store.swift
//  HPTrivia
//
//  Created by Apple on 02/11/24.
//

import Foundation
import StoreKit

enum BookStatus: Codable {
    case active
    case inactive
    case locked
}

@MainActor
class Store: ObservableObject {
    @Published var books:[BookStatus] = [.active, .active, .inactive, .locked, .locked, .locked, .locked]
    @Published var products:[Product] = []
    @Published var purchasedItemIds = Set<String>()

    private var productIDs = ["hp4", "hp5", "hp6", "hp7"]
    private var updates: Task<Void, Never>? = nil
    private let saveBookStatusPath = FileManager.documentsDirectory.appending(path: "SavedBookStatus")
    
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        }
        catch {
            print("Could not fetch those products \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            // Purchase wase successful but now we have to verify the receipt
            case .success(let verificationResult):
                switch verificationResult {
                case .unverified(let signedType, let verificationError):
                    print("Error on sign type \(signedType): \(verificationError)")
                case .verified(let signedType):
                    purchasedItemIds.insert(signedType.productID)
                }
            // User cancelled or parent disapproved child's purchase
            case .userCancelled:
                break
            // Waiting for approval
            case .pending:
                break
            @unknown default:
                break
            }
        }
        catch {
            print("Could not purchase that products \(error)")
        }
    }
    
    func saveStatus() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: saveBookStatusPath)
        }
        catch {
            print("Unable to save status: \(error)")
        }
    }
    
    func loadStatus() {
        do {
            let data  = try Data(contentsOf: saveBookStatusPath)
            books = try JSONDecoder().decode([BookStatus].self, from: data)
        }
        catch {
            print("Could not load book stauses: \(error)")
        }
    }
    
    private func checkPurchased() async {
        for product in products {
            guard let state = await product.currentEntitlement else {return}
            switch state {
            case .unverified(let signedType, let verificationError):
                print("Error on sign type \(signedType): \(verificationError)")
            case .verified(let signedType):
                if signedType.revocationDate == nil {
                    purchasedItemIds.insert(signedType.productID)
                }
                else {
                    purchasedItemIds.remove(signedType.productID)
                }
            }
        }
    }
    
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}
